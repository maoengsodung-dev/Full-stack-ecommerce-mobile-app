<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1\Customer;

use App\Http\Controllers\Controller;
use App\Http\Requests\Address\StoreAddressRequest;
use App\Http\Requests\Address\UpdateAddressRequest;
use App\Http\Resources\AddressResource;
use App\Models\Address;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AddressController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $addresses = $request->user()
            ->addresses()
            ->orderByDesc('is_default')
            ->latest()
            ->get();

        return $this->ok(AddressResource::collection($addresses));
    }

    public function store(StoreAddressRequest $request): JsonResponse
    {
        $data = $request->validated();
        $user = $request->user();

        $address = DB::transaction(function () use ($user, $data): Address {
            $isDefault = (bool) ($data['is_default'] ?? false);

            if ($isDefault) {
                $user->addresses()->update(['is_default' => false]);
            } elseif ($user->addresses()->doesntExist()) {
                $isDefault = true;
            }

            return $user->addresses()->create([...$data, 'is_default' => $isDefault]);
        });

        return $this->created(new AddressResource($address), 'Address created.');
    }

    public function update(UpdateAddressRequest $request, int $id): JsonResponse
    {
        /** @var Address $address */
        $address = $request->user()->addresses()->findOrFail($id);

        $data = $request->validated();

        if (! empty($data['is_default'])) {
            $request->user()->addresses()->where('id', '!=', $address->id)->update(['is_default' => false]);
        }

        $address->update($data);

        return $this->ok(new AddressResource($address->fresh()), 'Address updated.');
    }

    public function destroy(Request $request, int $id): JsonResponse
    {
        /** @var Address $address */
        $address = $request->user()->addresses()->findOrFail($id);
        $address->delete();

        return $this->ok(null, 'Address deleted.');
    }

    public function makeDefault(Request $request, int $id): JsonResponse
    {
        /** @var Address $address */
        $address = $request->user()->addresses()->findOrFail($id);

        DB::transaction(function () use ($request, $address): void {
            $request->user()->addresses()->update(['is_default' => false]);
            $address->update(['is_default' => true]);
        });

        return $this->ok(new AddressResource($address->fresh()), 'Default address updated.');
    }
}
