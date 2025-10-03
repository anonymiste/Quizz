<?php

use App\Models\User;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Route;
use Laravel\Sanctum\PersonalAccessToken;

// Route par défaut - Redirige vers l'API ou affiche un message
Route::get('/', function () {
    return response()->json([
        'message' => 'Quizz API',
        'version' => '1.0',
    //     'endpoints' => [
    //         'auth' => '/api/auth/login',
    //         'documentation' => 'À compléter'
    //     ],
    ]);
});

// Si vous voulez garder la route welcome mais sans la vue
Route::get('/isconnected', function () {
     $users = User::whereHas('tokens')->get();
     $tokens = PersonalAccessToken::with('tokenable')->get();
     $authUser = $tokens->pluck('tokenable')->unique();

    return response()->json([
        'users' => $users,
        'auth_user' => $authUser,
    ]);
});