<?php

namespace App\Http\Controllers\Api;

use App\Enums\PhaseLevel;
use App\Http\Controllers\Controller;
use App\Models\Phase;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Validation\ValidationException;
use Laravel\Sanctum\PersonalAccessToken;

class PhaseController extends Controller
{
    public function index()
    {
        try {
            $phases = Phase::with(['themes', 'user'])->get();
            
            return response()->json([
                'message' => 'Liste des phases récupérée avec succès',
                'data' => $phases,
                'count' => $phases->count()
            ], 200);
            
        } catch (\Exception $e) {
            Log::error('Erreur lors de la récupération des phases: ' . $e->getMessage());
            
            return response()->json([
                'message' => 'Erreur lors de la récupération des phases',
                'error' => config('app.debug') ? $e->getMessage() : 'Erreur interne'
            ], 500);
        }
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
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
            
            if (!$currentUser) {
                return response()->json(["message" => "Utilisateur non trouvé."], 401);
            }
                // Vérification que l'utilisateur peut modifier cette phase
            if ($currentUser->role !== 'admin') {
                return response()->json([
                    "message" => "Non autorisé à créer cette phase.",
                ], 403);
            }
            $validated = $request->validate([
                "title" => "required|string|min:2|max:255|unique:phases,title",
                "level" => "sometimes|string|in:" . implode(',', PhaseLevel::values()),
                "average" => "sometimes|integer|min:0|max:3",
                'user_id' => "sometimes|integer|exists:users,id",
            ]);

            $phase = Phase::create([
                "title" => $validated['title'],
                "level" => $validated['level'] ?? PhaseLevel::UNDEFINED->value,
                "average" => $validated['average'] ?? 0,
                "user_id" => $validated['user_id'] ?? auth()->id() ?? 1,
            ]);
            
            return response()->json([
                'message' => 'Phase créée avec succès',
                'data' => $phase->load('user')
            ], 201);
            
        } catch (ValidationException $e) {
            return response()->json([
                'message' => 'Erreur de validation',
                'errors' => $e->errors()
            ], 422);
            
        } catch (\Exception $e) {
            Log::error('Erreur création phase: ' . $e->getMessage());
            
            return response()->json([
                'message' => 'Erreur lors de la création de la phase',
                'error' => config('app.debug') ? $e->getMessage() : 'Erreur interne'
            ], 500);
        }
    }

    /**
     * Display the specified resource.
     */
    public function show(string $id)
    {
        try {
            $phase = Phase::with(['themes.questions.reponses', 'user'])->find($id);
            
            if (!$phase) {
                return response()->json([
                    'message' => 'Phase non trouvée'
                ], 404);
            }
            
            return response()->json([
                'message' => 'Détails de la phase',
                'data' => $phase
            ], 200);
            
        } catch (\Exception $e) {
            Log::error('Erreur récupération phase: ' . $e->getMessage());
            
            return response()->json([
                'message' => 'Erreur lors de la récupération de la phase',
                'error' => config('app.debug') ? $e->getMessage() : 'Erreur interne'
            ], 500);
        }
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $id)
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
            
            if (!$currentUser) {
                return response()->json(["message" => "Utilisateur non trouvé."], 401);
            }
            //     // Vérification que l'utilisateur peut modifier cette phase
            if ($currentUser->role !== 'admin') {
                return response()->json([
                    "message" => "Non autorisé à modifier cette phase.",
                ], 403);
            }

            $phase = Phase::find($id);
            
            if (!$phase) {
                return response()->json([
                    'message' => 'Phase non trouvée'
                ], 404);
            }

            $validated = $request->validate([
                "title" => "sometimes|string|min:2|max:255|unique:phases,title,{$id}",
                "level" => "sometimes|string|in:" . implode(',', PhaseLevel::values()),
                "average" => "sometimes|integer|min:0|max:100",
                'user_id' => "sometimes|integer|exists:users,id",
            ]);

            $phase->update($validated);
            
            return response()->json([
                'message' => 'Phase mise à jour avec succès',
                'data' => $phase->fresh(['themes', 'user'])
            ], 200);
            
        } catch (ValidationException $e) {
            return response()->json([
                'message' => 'Erreur de validation',
                'errors' => $e->errors()
            ], 422);
            
        } catch (\Exception $e) {
            Log::error('Erreur mise à jour phase: ' . $e->getMessage());
            
            return response()->json([
                'message' => 'Erreur lors de la mise à jour de la phase',
                'error' => config('app.debug') ? $e->getMessage() : 'Erreur interne'
            ], 500);
        }
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        try {
            $token = request()->bearerToken();
            
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
                // Vérification que l'utilisateur peut modifier cette phase
            if ($currentUser->role !== 'admin') {
                return response()->json([
                    "message" => "Non autorisé à supprimer cette phase.",
                ], 403);
            }

            $phase = Phase::find($id);
            
            if (!$phase) {
                return response()->json([
                    'message' => 'Phase non trouvée'
                ], 404);
            }

            // Vérifier s'il y a des thèmes associés
            if ($phase->themes()->count() > 0) {
                return response()->json([
                    'message' => 'Impossible de supprimer une phase contenant des thèmes',
                    'themes_count' => $phase->themes()->count()
                ], 422);
            }

            $phase->delete();
            
            return response()->json([
                'message' => 'Phase supprimée avec succès'
            ], 200);
            
        } catch (\Exception $e) {
            Log::error('Erreur suppression phase: ' . $e->getMessage());
            
            return response()->json([
                'message' => 'Erreur lors de la suppression de la phase',
                'error' => config('app.debug') ? $e->getMessage() : 'Erreur interne'
            ], 500);
        }
    }

    /**
     * Get phases by level
     */
    public function byLevel(string $level)
    {
        try {
            if (!in_array($level, PhaseLevel::values())) {
                return response()->json([
                    'message' => 'Niveau invalide',
                    'available_levels' => PhaseLevel::values()
                ], 422);
            }

            $phases = Phase::with(['themes', 'user'])
                ->where('level', $level)
                ->get();
            
            return response()->json([
                'message' => "Phases du niveau {$level}",
                'Phases' => $phases,
                'count' => $phases->count()
            ], 200);
            
        } catch (\Exception $e) {
            Log::error('Erreur phases par niveau: ' . $e->getMessage());
            return response()->json(['message' => 'Erreur serveur'], 500);
        }
    }

    /**
     * Get user's phases
     */
    public function byUser(string $userId)
    {
        try {
            $phases = Phase::with(['themes', 'user'])
                ->where('user_id', $userId)
                ->get();
            
            return response()->json([
                'message' => "Phases de l'utilisateur",
                'data' => $phases,
                'count' => $phases->count()
            ], 200);
            
        } catch (\Exception $e) {
            Log::error('Erreur phases utilisateur: ' . $e->getMessage());
            return response()->json(['message' => 'Erreur serveur'], 500);
        }
    }
}