<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Product\StoreProductRequest;
use App\Http\Requests\Product\StoreVariantRequest;
use App\Http\Requests\Product\UpdateProductRequest;
use App\Http\Resources\ProductImageResource;
use App\Http\Resources\ProductResource;
use App\Http\Resources\ProductVariantResource;
use App\Models\Product;
use App\Models\ProductImage;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;

class AdminProductController extends Controller
{
    public function store(StoreProductRequest $request): JsonResponse
    {
        $data = $request->validated();

        $product = DB::transaction(function () use ($data, $request): Product {
            $images = $data['images'] ?? [];
            $singleImage = $request->file('image');
            unset($data['images'], $data['image'], $data['alt'], $data['is_primary'], $data['sort_order']);

            $product = Product::create($data);

            $this->processProductImages(
                $product,
                $images,
                $singleImage,
                $request->input('alt'),
                $request->has('sort_order') ? (int) $request->input('sort_order') : null,
                $request->has('is_primary') ? $request->boolean('is_primary') : null
            );

            return $product;
        });

        // Push notification to customers on topic 'all'
        try {
            $imageUrl = $product->primaryImage?->url ?? '';
            \App\Jobs\SendFCMNotification::dispatch(
                target: ['type' => 'topic', 'value' => 'all'],
                title: 'New Product in Store! 🔥',
                body: "Check out {$product->name} now available in our store!",
                data: [
                    'event' => 'new_product',
                    'type' => 'product',
                    'id' => (string) $product->id,
                    'slug' => (string) $product->slug,
                    'name' => (string) $product->name,
                    'price' => (string) $product->price,
                    'image' => $imageUrl,
                ],
            );
        } catch (\Throwable $e) {
            \Illuminate\Support\Facades\Log::channel('fcm')->error('Failed to dispatch new product notification', ['error' => $e->getMessage()]);
        }

        return $this->created(
            new ProductResource($product->load(['category', 'images', 'variants'])),
            'Product created.'
        );
    }

    public function update(UpdateProductRequest $request, string|int $id): JsonResponse
    {
        /** @var Product $product */
        $product = $this->findProduct($id);

        $data = $request->validated();

        $product = DB::transaction(function () use ($product, $data, $request): Product {
            $images = $data['images'] ?? null;
            $singleImage = $request->file('image');
            unset($data['images'], $data['image'], $data['alt'], $data['is_primary'], $data['sort_order'], $data['replace_images']);

            $product->update($data);

            if ($images !== null || $singleImage !== null || $request->has('is_primary') || $request->has('sort_order')) {
                $this->processProductImages(
                    $product,
                    $images ?? [],
                    $singleImage,
                    $request->input('alt'),
                    $request->has('sort_order') ? (int) $request->input('sort_order') : null,
                    $request->has('is_primary') ? $request->boolean('is_primary') : null,
                    $request->boolean('replace_images')
                );
            }

            return $product;
        });

        return $this->ok(
            new ProductResource($product->fresh(['category', 'images', 'variants'])),
            'Product updated.'
        );
    }

    public function destroy(string|int $id): JsonResponse
    {
        $this->findProduct($id)->delete();

        return $this->ok(null, 'Product deleted.');
    }

    public function addVariant(StoreVariantRequest $request, string|int $id): JsonResponse
    {
        /** @var Product $product */
        $product = $this->findProduct($id);

        $variant = $product->variants()->create($request->validated());

        return $this->created(new ProductVariantResource($variant), 'Variant created.');
    }

    public function addImage(Request $request, string|int $id): JsonResponse
    {
        /** @var Product $product */
        $product = $this->findProduct($id);

        $data = $request->validate([
            'image'              => ['required_without:url', 'nullable', 'file', 'mimes:jpeg,png,jpg,gif,svg,webp', 'max:5120'],
            'url'                => ['required_without:image', 'nullable', 'string', 'max:500'],
            'alt'                => ['nullable', 'string', 'max:191'],
            'sort_order'         => ['nullable', 'integer', 'min:0'],
            'is_primary'         => ['nullable', 'boolean'],
            'product_variant_id' => ['nullable', 'integer', 'exists:product_variants,id'],
        ]);

        $url = null;
        if ($request->hasFile('image')) {
            $url = $request->file('image')->store('products', 'public');
        } elseif (! empty($data['url'])) {
            $url = $data['url'];
        }

        $isPrimary = $request->boolean('is_primary');
        if ($isPrimary) {
            $product->images()->update(['is_primary' => false]);
        } else {
            $isPrimary = ! $product->images()->where('is_primary', true)->exists();
        }

        /** @var ProductImage $image */
        $image = $product->images()->create([
            'product_variant_id' => $data['product_variant_id'] ?? null,
            'url'                => $url,
            'alt'                => $data['alt'] ?? $product->name,
            'sort_order'         => (int) ($data['sort_order'] ?? (($product->images()->max('sort_order') ?? 0) + 1)),
            'is_primary'         => $isPrimary,
        ]);

        return $this->created(new ProductImageResource($image), 'Product image added.');
    }

    public function updateImage(Request $request, string|int $productId, int $imageId): JsonResponse
    {
        /** @var Product $product */
        $product = $this->findProduct($productId);

        /** @var ProductImage $image */
        $image = $product->images()->findOrFail($imageId);

        $data = $request->validate([
            'image'              => ['sometimes', 'nullable', 'file', 'mimes:jpeg,png,jpg,gif,svg,webp', 'max:5120'],
            'url'                => ['sometimes', 'nullable', 'string', 'max:500'],
            'alt'                => ['sometimes', 'nullable', 'string', 'max:191'],
            'sort_order'         => ['sometimes', 'integer', 'min:0'],
            'is_primary'         => ['sometimes', 'boolean'],
            'product_variant_id' => ['sometimes', 'nullable', 'integer', 'exists:product_variants,id'],
        ]);

        if ($request->hasFile('image')) {
            $data['url'] = $request->file('image')->store('products', 'public');
        }

        if (isset($data['is_primary']) && $data['is_primary']) {
            $product->images()->where('id', '!=', $imageId)->update(['is_primary' => false]);
        }

        $image->update($data);

        return $this->ok(new ProductImageResource($image->fresh()), 'Product image updated.');
    }

    public function deleteImage(string|int $productId, int $imageId): JsonResponse
    {
        /** @var Product $product */
        $product = $this->findProduct($productId);

        /** @var ProductImage $image */
        $image = $product->images()->findOrFail($imageId);

        $wasPrimary = (bool) $image->is_primary;
        $image->delete();

        if ($wasPrimary) {
            $nextImage = $product->images()->first();
            if ($nextImage) {
                $nextImage->update(['is_primary' => true]);
            }
        }

        return $this->ok(null, 'Product image deleted.');
    }

    public function updateImageDirect(Request $request, int $imageId): JsonResponse
    {
        /** @var ProductImage $image */
        $image = ProductImage::findOrFail($imageId);

        $data = $request->validate([
            'image'              => ['sometimes', 'nullable', 'file', 'mimes:jpeg,png,jpg,gif,svg,webp', 'max:5120'],
            'url'                => ['sometimes', 'nullable', 'string', 'max:500'],
            'alt'                => ['sometimes', 'nullable', 'string', 'max:191'],
            'sort_order'         => ['sometimes', 'integer', 'min:0'],
            'is_primary'         => ['sometimes', 'boolean'],
            'product_variant_id' => ['sometimes', 'nullable', 'integer', 'exists:product_variants,id'],
        ]);

        if ($request->hasFile('image')) {
            $data['url'] = $request->file('image')->store('products', 'public');
        }

        if (isset($data['is_primary']) && $data['is_primary']) {
            ProductImage::where('product_id', $image->product_id)
                ->where('id', '!=', $imageId)
                ->update(['is_primary' => false]);
        }

        $image->update($data);

        return $this->ok(new ProductImageResource($image->fresh()), 'Product image updated.');
    }

    public function deleteImageDirect(int $imageId): JsonResponse
    {
        /** @var ProductImage $image */
        $image = ProductImage::findOrFail($imageId);
        $productId = $image->product_id;
        $wasPrimary = (bool) $image->is_primary;

        $image->delete();

        if ($wasPrimary) {
            $nextImage = ProductImage::where('product_id', $productId)->first();
            if ($nextImage) {
                $nextImage->update(['is_primary' => true]);
            }
        }

        return $this->ok(null, 'Product image deleted.');
    }

    private function findProduct(string|int $id): Product
    {
        return is_numeric($id)
            ? Product::findOrFail((int) $id)
            : Product::where('slug', $id)->firstOrFail();
    }

    private function processProductImages(
        Product $product,
        array $images,
        ?UploadedFile $singleImage = null,
        ?string $alt = null,
        ?int $sortOrder = null,
        ?bool $isPrimary = null,
        bool $replaceImages = false
    ): void {
        if ($replaceImages) {
            foreach ($product->images as $existingImage) {
                $existingImage->delete();
            }
        }

        $hasPrimary = $product->images()->where('is_primary', true)->exists();

        if ($singleImage instanceof UploadedFile) {
            $primaryFlag = $isPrimary ?? (! $hasPrimary);
            if ($primaryFlag) {
                $product->images()->update(['is_primary' => false]);
            }

            $path = $singleImage->store('products', 'public');
            $product->images()->create([
                'url'        => $path,
                'alt'        => $alt ?? $product->name,
                'sort_order' => $sortOrder ?? 0,
                'is_primary' => $primaryFlag,
            ]);
            $hasPrimary = true;
        }

        foreach ($images as $i => $img) {
            $url = null;
            $imgAlt = $alt ?? $product->name;
            $imgSortOrder = $sortOrder ?? $i;
            $imgPrimary = false;

            if ($img instanceof UploadedFile) {
                $url = $img->store('products', 'public');
                $imgPrimary = $isPrimary ?? (! $hasPrimary && $i === 0);
            } elseif (is_array($img)) {
                if (isset($img['file']) && $img['file'] instanceof UploadedFile) {
                    $url = $img['file']->store('products', 'public');
                } elseif (! empty($img['url'])) {
                    $url = $img['url'];
                }
                $imgAlt = $img['alt'] ?? ($alt ?? $product->name);
                $imgSortOrder = (int) ($img['sort_order'] ?? ($sortOrder ?? $i));
                $imgPrimary = (bool) ($img['is_primary'] ?? ($isPrimary ?? (! $hasPrimary && $i === 0)));
            } elseif (is_string($img)) {
                $url = $img;
                $imgPrimary = $isPrimary ?? (! $hasPrimary && $i === 0);
            }

            if ($url !== null) {
                if ($imgPrimary) {
                    $product->images()->update(['is_primary' => false]);
                }

                $product->images()->create([
                    'url'        => $url,
                    'alt'        => $imgAlt,
                    'sort_order' => $imgSortOrder,
                    'is_primary' => $imgPrimary,
                ]);

                if ($imgPrimary) {
                    $hasPrimary = true;
                }
            }
        }
    }
}
