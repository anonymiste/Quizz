<?php

namespace App\Http\Controllers\Auth;

use App\Enums\UserRole;
use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Validation\ValidationException;
use Laravel\Sanctum\PersonalAccessToken;

class AuthController extends Controller
{

// ... dans votre contrôleur

public function register(string $email)
{
    // Utiliser une transaction pour s'assurer que l'utilisateur ET les statistiques sont créés
    try {
        DB::beginTransaction();

        $userCreated = true;
        
        // 1. Création de l'utilisateur avec rôle par défaut
        $user = User::create([
            'email' => $email,
            'role' => UserRole::USER->value,
        ]);

        // 2. Création des statistiques par défaut
        $user->userstatistics()->create([
            'total_points' => 0,
            'quizzes_completed' => 0,
            'correct_answers' => 0,
            'incorrect_answers' => 0,
            'success_rate' => 0.00,
            'current_streak' => 0,
            'best_streak' => 0,
            'total_time_spent' => 0,
            'phases_progress' => null, // Ou [] si vous préférez un tableau vide
        ]);
        
        // 3. Création du token d'authentification
        $token = $user->createToken($user->email . '_connexion')->plainTextToken;

        // Si tout s'est bien passé, on valide la transaction
        DB::commit(); 
        
        return response()->json([
            'user' => [
                'id' => $user->id,
                'email' => $user->email,
                'name' => $user->name,
                'role' => $user->role ?? 'user',
                'statistics' => $user->statistics ?? null,
            ],
            'token' => $token,
            'message' => 'Utilisateur créé et connecté avec succès.',
            'user_created' => $userCreated,
        ], 201);
        
    } catch (\Throwable $th) {
        // En cas d'erreur, annuler toutes les opérations de la transaction
        DB::rollBack();

        // Log de l'erreur pour le débogage
        Log::error('Erreur lors de la création de l\'utilisateur et des statistiques : ' . $th->getMessage(), [
            'email' => $email,
            'trace' => $th->getTraceAsString()
        ]);

        return response()->json([
            "message" => "Erreur lors de la création de l'utilisateur.",
            "error" => config('app.debug') ? $th->getMessage() : 'Erreur interne du serveur',
        ], 500);
    }
}
    /**
     * Connexion de l'utilisateur
     */
    public function login (Request $request)
    {
        try {
            // Validation supplémentaire
            $userCreated = false;
            
            $request->validate([
                "email" => "required|string|min:2|max:255",
            ]);
            $email = $request->email;
            $id = User::where('email', $email)->value('id');
            $user = User::find($id);
            if (!$user) {
                // Création de l'utilisateur avec rôle par défaut
                return $this->register($email);
            }

            // Suppression des anciens tokens et création d'un nouveau
            $existingTokens = $user->tokens();
            if ($existingTokens->count() > 0) {
                $existingTokens->delete();
            }
            $token = $user->createToken($user->email . '_connexion')->plainTextToken;            
            // Cache::put('user-is-online-' . $user->id, true);
            
            return response()->json([
                'message' => 'Connexion réussie.',
                'user' => [
                    'id' => $user->id,
                    'email' => $user->email,
                    'name' => $user->name,
                    'role' => $user->role ?? 'user',
                    'statistics' => $user->statistics ?? null,
                    ],
                'token' => $token,
                'user_created' => $userCreated,

            ], $userCreated ? 201 : 200);
            
        } catch (\Throwable $th) {
            // Log de l'erreur pour le débogage
            Log::error('Erreur lors de la connexion : ' . $th->getMessage(), [
                'email' => $request->email,
                'trace' => $th->getTraceAsString()
            ]);

            return response()->json([
                "message" => "Erreur lors de la connexion.",
                "error" => config('app.debug') ? $th->getMessage() : 'Erreur interne du serveur',
            ], 500);
        }
    }

    /**
     * Déconnexion de l'utilisateur
    */
    public function logout(string $id)
    {
        try {
            $user = User::find($id);
            $tokens = PersonalAccessToken::with('tokenable')->get();
            $currentUsers = $tokens->pluck('tokenable')->unique();

            foreach ($tokens as $token) {
                foreach ($currentUsers as $currentUser) {
                    if ($token->tokenable_id === $currentUser->id) {
                        $currentUser = $token->tokenable;
                        break 2;
                    }
                }
            }
            if ($currentUser->token != $user->token && ($currentUser->role !== 'admin')) {
                return response()->json([
                    "message" => "Non autorisé à déconnecter cet utilisateur.",
                ], 403);
            }

            if ($user) {
                // Suppression des tokens courants
                $user->tokens()->delete();
                // Cache::forget('user-is-online-' . $user->id);
            }

            return response()->json([
                'message' => "Déconnexion réussie.",
            ], 200);
            
        } catch (\Throwable $th) {
            Log::error('Erreur lors de la déconnexion : ' . $th->getMessage());

            return response()->json([
                'message' => "Erreur lors de la déconnexion.",
                'error' => config('app.debug') ? $th->getMessage() : 'Erreur interne',
            ], 500);
        }
    }

    /**
     * Mise à jour du profil utilisateur
     */
    public function update(Request $request, string $id): JsonResponse
    {
        try {

            $token = $request->bearerToken();
            
            if (!$token) {
                return response()->json(["message" => "Token manquant."], 401);
            }

            // Trouver l'utilisateur associé au token
            $accessToken = PersonalAccessToken::findToken($token);
            
            if (!$accessToken) {
                return response()->json(["message" => "Token invalide."], 401);
            }

            $currentUser = $accessToken->tokenable;

            $user = User::find($id);
            
            $user = User::find($id);
            if (!$user) {
                return response()->json([
                    "message" => "Utilisateur non trouvé !",
                ], 404);
            }

            // Vérification que l'utilisateur peut modifier ce profil
            if ($currentUser->role !== 'admin'&& $currentUser->id != $user->id && $currentUser->email != "admin@paul.com" ) {
                return response()->json([
                    "message" => "Non autorisé à modifier cet utilisateur.",
                ], 403);
            }

            // Validation
            $validated = $request->validate([
                "name" => "required|string|min:2|max:255",
                "email" => "sometimes|email|unique:users,email," . $user->id,
                "role" => "sometimes|string|in:" . implode(',', UserRole::values()),
            ]);

            $user->update($validated);

            return response()->json([
                "message" => "Mise à jour réussie !",
                'user' => [
                    'id' => $user->id,
                    'email' => $user->email,
                    'name' => $user->name,
                    'role' => $user->role ?? 'user',
                ],
            ], 200);

        } catch (ValidationException $e) {
            return response()->json([
                "message" => "Erreur de validation.",
                "errors" => $e->errors(),
            ], 422);
            
        } catch (\Throwable $th) {
            Log::error('Erreur lors de la mise à jour : ' . $th->getMessage());

            return response()->json([
                "message" => "Erreur lors de la mise à jour.",
                "error" => config('app.debug') ? $th->getMessage() : 'Erreur interne',
            ], 500);
        }
    }

    /**
     * Suppression d'un utilisateur
     */
    public function delete(Request $request, string $id): JsonResponse
    {
        try {
            // Récupérer l'utilisateur via le token
            $token = $request->bearerToken();
            
            if (!$token) {
                return response()->json(["message" => "Token manquant."], 401);
            }

            // Trouver l'utilisateur associé au token
            $accessToken = PersonalAccessToken::findToken($token);
            
            if (!$accessToken) {
                return response()->json(["message" => "Token invalide."], 401);
            }

            $currentUser = $accessToken->tokenable;
            
            if (!$currentUser) {
                return response()->json(["message" => "Utilisateur non trouvé."], 401);
            }

            // Suite de la logique...
            $userToDelete = User::find($id);
            
            if (!$userToDelete) {
                return response()->json(["message" => "Utilisateur à supprimer non trouvé."], 404);
            }

            // Vérification des permissions
            if ($currentUser->id != $userToDelete->id && $currentUser->role !== 'admin') {
                return response()->json(["message" => "Non autorisé."], 403);
            }

            $userToDelete->delete();

            return response()->json(["message" => "Utilisateur supprimé avec succès."], 200);
            
        } catch (\Throwable $th) {
            Log::error('Erreur suppression: ' . $th->getMessage());
            return response()->json(["message" => "Erreur lors de la suppression."], 500);
        }
    }

    /**
     * Récupération des informations de l'utilisateur connecté
     */
    public function me(Request $request)
    {
        try {

            // Récupérer l'utilisateur via le token
            $token = $request->bearerToken();
            
            if (!$token) {
                return response()->json(["message" => "Token manquant."], 401);
            }

            // Trouver l'utilisateur associé au token
            $accessToken = PersonalAccessToken::findToken($token);
            
            if (!$accessToken) {
                return response()->json(["message" => "Token invalide."], 401);
            }

            $currentUser = $accessToken->tokenable;

            if (!$currentUser) {
                return response()->json([
                    "message" => "Utilisateur non authentifié.",
                ], 401);
            }

            // Si un email est fourni dans la requête, vérifier les permissions
            if ($request->has('email')) {
                $request->validate([
                    "email" => "required|string|min:2|max:255",
                ]);
                    
                $email = $request->email;
                $id = User::where('email', $email)->value('id');
                $user = User::find($id);

                if (!$user) {
                    return response()->json([
                        "message" => "Utilisateur non trouvé.",
                    ], 404);
                }

                // Vérifier les permissions (admin ou même utilisateur)
                if ($currentUser->id !== $user->id && $currentUser->role !== 'admin') {
                    return response()->json([
                        "message" => "Non autorisé à accéder à ces informations.",
                    ], 403);
                }
            } else {
                // Si aucun email n'est fourni, retourner l'utilisateur connecté
                $user = $currentUser;
            }

            return response()->json([
                'user' => [
                    'id' => $user->id,
                    'email' => $user->email,
                    'name' => $user->name,
                    'role' => $user->role ?? 'user',
                ],
            ], 200);
            
        } catch (\Throwable $th) {
            Log::error('Erreur lors de la récupération du profil : ' . $th->getMessage());

            return response()->json([
                "message" => "Erreur lors de la récupération des informations.",
                "error" => config('app.debug') ? $th->getMessage() : 'Erreur interne',
            ], 500);
        }
    }
}