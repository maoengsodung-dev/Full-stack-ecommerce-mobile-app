<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreCategoryRequest;
use App\Http\Resources\CategoryResource;
use App\Models\Category;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class AdminCategoryController extends Controller
{
    /**
     * List all categories (for admin table/management).
     */
    public function index(Request $request): JsonResponse
    {
        $categories = Category::query()
            ->withCount(['products', 'children'])
            ->with(['parent'])
            ->when($request->filled('search'), function ($q) use ($request) {
                $q->where('name', 'like', '%' . $request->query('search') . '%')
                    ->orWhere('slug', 'like', '%' . $request->query('search') . '%');
            })
            ->when($request->has('is_active'), function ($q) use ($request) {
                $q->where('is_active', $request->boolean('is_active'));
            })
            ->when($request->has('parent_id'), function ($q) use ($request) {
                $parentId = $request->query('parent_id');
                if ($parentId === 'null' || $parentId === '') {
                    $q->whereNull('parent_id');
                } else {
                    $q->where('parent_id', (int) $parentId);
                }
            })
            ->orderBy('sort_order')
            ->orderBy('name')
            ->paginate((int) $request->query('per_page', 20));

        return $this->ok(CategoryResource::collection($categories));
    }

    /**
     * Show a single category by ID.
     */
    public function show(int $id): JsonResponse
    {
        $category = Category::withCount(['products', 'children'])
            ->with(['parent', 'children'])
            ->findOrFail($id);

        return $this->ok(new CategoryResource($category));
    }

    /**
     * Create a new category.
     */
    public function store(StoreCategoryRequest $request): JsonResponse
    {
        $data = $request->validated();

        if ($request->hasFile('icon')) {
            $data['icon'] = $request->file('icon')->store('categories/icons', 'public');
        }
        if ($request->hasFile('image')) {
            $data['image'] = $request->file('image')->store('categories/images', 'public');
        }

        $category = Category::create($data);

        return $this->created(new CategoryResource($category), 'Category created successfully.');
    }

    /**
     * Update an existing category.
     */
    public function update(Request $request, int $id): JsonResponse
    {
        /** @var Category $category */
        $category = Category::findOrFail($id);

        if ($request->filled('name') && ! $request->filled('slug')) {
            $request->merge([
                'slug' => Str::slug((string) $request->input('name')),
            ]);
        }

        $data = $request->validate([
            'name'        => ['sometimes', 'string', 'max:120', 'unique:categories,name,' . $id],
            'slug'        => ['sometimes', 'string', 'max:140', 'unique:categories,slug,' . $id],
            'description' => ['sometimes', 'nullable', 'string'],
            'icon'        => $request->hasFile('icon')
                ? ['sometimes', 'nullable', 'file', 'mimes:jpeg,png,jpg,gif,svg,webp', 'max:2048']
                : ['sometimes', 'nullable', 'string', 'max:191'],
            'image'       => $request->hasFile('image')
                ? ['sometimes', 'nullable', 'file', 'mimes:jpeg,png,jpg,gif,svg,webp', 'max:5120']
                : ['sometimes', 'nullable', 'string', 'max:500'],
            'parent_id'   => ['sometimes', 'nullable', 'integer', 'exists:categories,id', 'not_in:' . $id],
            'sort_order'  => ['sometimes', 'integer'],
            'is_active'   => ['sometimes', 'boolean'],
        ], [
            'name.unique' => 'A category with this name already exists.',
            'slug.unique' => 'A category with this slug already exists.',
        ]);

        // Upload new icon and remove previous file
        if ($request->hasFile('icon')) {
            if ($category->icon && ! str_starts_with($category->icon, 'http')) {
                Storage::disk('public')->delete($category->icon);
            }
            $data['icon'] = $request->file('icon')->store('categories/icons', 'public');
        }

        // Upload new image and remove previous file
        if ($request->hasFile('image')) {
            if ($category->image && ! str_starts_with($category->image, 'http')) {
                Storage::disk('public')->delete($category->image);
            }
            $data['image'] = $request->file('image')->store('categories/images', 'public');
        }

        $category->update($data);

        return $this->ok(new CategoryResource($category->fresh()), 'Category updated successfully.');
    }

    /**
     * Delete a single category by ID.
     */
    public function destroy(Request $request, int $id): JsonResponse
    {
        /** @var Category $category */
        $category = Category::findOrFail($id);

        return DB::transaction(function () use ($request, $category, $id) {
            // Option 1: Reassign products to another category if specified
            if ($request->filled('reassign_to')) {
                $targetId = (int) $request->input('reassign_to');
                if ($targetId === $id || ! Category::where('id', $targetId)->exists()) {
                    return $this->error('Target category for product reassignment does not exist or is invalid.', 422);
                }
                $category->products()->withTrashed()->update(['category_id' => $targetId]);
            }
            // Option 2: Delete products if explicitly requested
            elseif ($request->boolean('delete_products')) {
                foreach ($category->products as $product) {
                    $product->delete();
                }
                $category->products()->withTrashed()->update(['category_id' => null]);
            }
            // Option 3: Disassociate all products (active and soft-deleted) so FK constraint never fails
            else {
                $category->products()->withTrashed()->update(['category_id' => null]);
            }

            // Subcategory handling
            if ($category->children()->exists()) {
                if ($request->boolean('delete_subcategories') || $request->boolean('force')) {
                    foreach ($category->children as $child) {
                        if ($child->icon && ! str_starts_with($child->icon, 'http')) {
                            Storage::disk('public')->delete($child->icon);
                        }
                        if ($child->image && ! str_starts_with($child->image, 'http')) {
                            Storage::disk('public')->delete($child->image);
                        }
                        $child->products()->withTrashed()->update(['category_id' => null]);
                        $child->forceDelete();
                    }
                } else {
                    $category->children()->update(['parent_id' => null]);
                }
            }

            // Delete physical files from public storage
            if ($category->icon && ! str_starts_with($category->icon, 'http')) {
                Storage::disk('public')->delete($category->icon);
            }
            if ($category->image && ! str_starts_with($category->image, 'http')) {
                Storage::disk('public')->delete($category->image);
            }

            // Permanently remove the category from database table
            $category->forceDelete();

            return $this->ok(null, 'Category deleted successfully.');
        });
    }

    /**
     * Delete multiple categories at once.
     */
    public function destroyMultiple(Request $request): JsonResponse
    {
        $request->validate([
            'ids'         => ['required', 'array', 'min:1'],
            'ids.*'       => ['integer', 'exists:categories,id'],
            'reassign_to' => ['nullable', 'integer', 'exists:categories,id'],
        ]);

        $ids = $request->input('ids');
        $categories = Category::whereIn('id', $ids)->get();

        return DB::transaction(function () use ($request, $categories, $ids) {
            $targetId = $request->input('reassign_to') ? (int) $request->input('reassign_to') : null;
            if ($targetId && in_array($targetId, $ids, true)) {
                return $this->error('Target category for reassignment cannot be in the deletion list.', 422);
            }

            foreach ($categories as $category) {
                if ($targetId) {
                    $category->products()->withTrashed()->update(['category_id' => $targetId]);
                } elseif ($request->boolean('delete_products')) {
                    foreach ($category->products as $product) {
                        $product->delete();
                    }
                    $category->products()->withTrashed()->update(['category_id' => null]);
                } else {
                    $category->products()->withTrashed()->update(['category_id' => null]);
                }

                if ($category->children()->whereNotIn('id', $ids)->exists()) {
                    if ($request->boolean('delete_subcategories') || $request->boolean('force')) {
                        foreach ($category->children as $child) {
                            $child->products()->withTrashed()->update(['category_id' => null]);
                            $child->forceDelete();
                        }
                    } else {
                        $category->children()->whereNotIn('id', $ids)->update(['parent_id' => null]);
                    }
                }
            }

            foreach ($categories as $category) {
                if ($category->icon && ! str_starts_with($category->icon, 'http')) {
                    Storage::disk('public')->delete($category->icon);
                }
                if ($category->image && ! str_starts_with($category->image, 'http')) {
                    Storage::disk('public')->delete($category->image);
                }
                $category->forceDelete();
            }

            return $this->ok(null, count($categories) . ' categories deleted successfully.');
        });
    }
}
