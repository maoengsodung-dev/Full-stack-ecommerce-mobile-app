<?php

declare(strict_types=1);

namespace App\Exceptions;

use Illuminate\Auth\AuthenticationException;
use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpKernel\Exception\HttpException;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
use Symfony\Component\HttpKernel\Exception\TooManyRequestsHttpException;
use Throwable;

class ApiExceptionRenderer
{
    public static function render(Throwable $e, Request $request): JsonResponse
    {
        return match (true) {
            $e instanceof ValidationException        => self::validation($e),
            $e instanceof AuthenticationException    => self::unauthenticated(),
            $e instanceof AuthorizationException     => self::forbidden($e),
            $e instanceof ModelNotFoundException     => self::notFound('Resource not found.'),
            $e instanceof NotFoundHttpException      => self::notFound('Endpoint not found.'),
            $e instanceof TooManyRequestsHttpException => self::tooManyRequests(),
            $e instanceof HttpException              => self::http($e),
            default                                  => self::server($e, $request),
        };
    }

    private static function validation(ValidationException $e): JsonResponse
    {
        return response()->json([
            'success' => false,
            'message' => 'The given data was invalid.',
            'errors'  => $e->errors(),
            'code'    => 'VALIDATION_FAILED',
        ], Response::HTTP_UNPROCESSABLE_ENTITY);
    }

    private static function unauthenticated(): JsonResponse
    {
        return response()->json([
            'success' => false,
            'message' => 'Unauthenticated.',
            'code'    => 'UNAUTHENTICATED',
        ], Response::HTTP_UNAUTHORIZED);
    }

    private static function forbidden(AuthorizationException $e): JsonResponse
    {
        return response()->json([
            'success' => false,
            'message' => $e->getMessage() ?: 'You do not have permission to perform this action.',
            'code'    => 'FORBIDDEN',
        ], Response::HTTP_FORBIDDEN);
    }

    private static function notFound(string $message): JsonResponse
    {
        return response()->json([
            'success' => false,
            'message' => $message,
            'code'    => 'NOT_FOUND',
        ], Response::HTTP_NOT_FOUND);
    }

    private static function tooManyRequests(): JsonResponse
    {
        return response()->json([
            'success' => false,
            'message' => 'Too many requests. Please try again later.',
            'code'    => 'TOO_MANY_REQUESTS',
        ], Response::HTTP_TOO_MANY_REQUESTS);
    }

    private static function http(HttpException $e): JsonResponse
    {
        return response()->json([
            'success' => false,
            'message' => $e->getMessage() ?: Response::$statusTexts[$e->getStatusCode()] ?? 'Error',
            'code'    => 'HTTP_'.$e->getStatusCode(),
        ], $e->getStatusCode());
    }

    private static function server(Throwable $e, Request $request): JsonResponse
    {
        $payload = [
            'success' => false,
            'message' => 'Server error.',
            'code'    => 'SERVER_ERROR',
        ];

        if (config('app.debug')) {
            $payload['debug'] = [
                'exception' => $e::class,
                'message'   => $e->getMessage(),
                'file'      => $e->getFile().':'.$e->getLine(),
            ];
        }

        return response()->json($payload, Response::HTTP_INTERNAL_SERVER_ERROR);
    }
}
