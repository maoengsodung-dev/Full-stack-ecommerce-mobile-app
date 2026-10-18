<?php

declare(strict_types=1);

namespace App\Traits;

use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Http\Resources\Json\ResourceCollection;
use Symfony\Component\HttpFoundation\Response;

trait ApiResponse
{
    protected function ok(mixed $data = null, string $message = '', array $meta = []): JsonResponse
    {
        return $this->successResponse($data, $message, Response::HTTP_OK, $meta);
    }

    protected function created(mixed $data = null, string $message = 'Created'): JsonResponse
    {
        return $this->successResponse($data, $message, Response::HTTP_CREATED);
    }

    protected function noContent(string $message = 'No Content'): JsonResponse
    {
        return response()->json([
            'success' => true,
            'message' => $message,
        ], Response::HTTP_OK);
    }

    protected function successResponse(mixed $data, string $message, int $status, array $meta = []): JsonResponse
    {
        $payload = [
            'success' => true,
            'message' => $message,
        ];

        if ($data instanceof ResourceCollection) {
            $resourceArr = $data->response()->getData(true);
            $payload['data'] = $resourceArr['data'] ?? [];

            if (isset($resourceArr['meta'])) {
                $meta = array_merge($meta, $resourceArr['meta']);
            }
            if (isset($resourceArr['links'])) {
                $meta['links'] = $resourceArr['links'];
            }
        } elseif ($data instanceof JsonResource) {
            $resourceArr = $data->response()->getData(true);
            $payload['data'] = $resourceArr['data'] ?? $resourceArr;
        } elseif ($data instanceof LengthAwarePaginator) {
            $payload['data'] = $data->items();
            $meta = array_merge($meta, [
                'current_page' => $data->currentPage(),
                'per_page'     => $data->perPage(),
                'total'        => $data->total(),
                'last_page'    => $data->lastPage(),
            ]);
        } else {
            $payload['data'] = $data;
        }

        if (! empty($meta)) {
            $payload['meta'] = $meta;
        }

        return response()->json($payload, $status);
    }

    protected function error(
        string $message,
        int $status = Response::HTTP_BAD_REQUEST,
        ?array $errors = null,
        string $code = 'ERROR'
    ): JsonResponse {
        $payload = [
            'success' => false,
            'message' => $message,
            'code'    => $code,
        ];

        if ($errors !== null) {
            $payload['errors'] = $errors;
        }

        return response()->json($payload, $status);
    }
}
