<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Phase;
use App\Models\Theme;
use Illuminate\Http\Request;
use Laravel\Sanctum\PersonalAccessToken;

class ThemeController extends Controller
{ 
    public function index()
    {
        $themes = Theme::all();
        return response()->json([
            'Message' => 'Liste des thèmes',
            'Themes' => $themes,
            'count' => $themes->count(),
        ], 200);
    }

    public function store(Request $request)
    {
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
                "message" => "Non autorisé à Créer ce thème.",
            ], 403);
        }
        
        $request->validate([
            "title" => "required|string|min:2|max:255",
            "score" => "sometimes|integer|min:0|max:100",
            'phase_id' => "sometimes|integer|exists:phases,id",
        ]);
        
        
        $theme = Theme::create([
            "title" => $request->title,
            "score" => $request->score ?? 0,
            "phase_id" => $request->phase_id ?? 4,
        ]);
        return response()->json([
            'Message' => 'Thème créé avec succès',
            'Themes' => $theme
        ], 201);
    }

    public function show(string $theme)
    {
        $theme = Theme::where('phase_id', $theme)->get();
        if (!$theme) {
            return response()->json([
                'Message' => 'Thème non trouvé'
            ], 404);
        }
        return response()->json([
            'Message' => 'Détails du thème',
            'Theme' => $theme
        ], 200);
    }
    
    public function update(Request $request, string $theme)
    {
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
                "message" => "Non autorisé à mettre à jour ce thème.",
            ], 403);
        }
        $theme = Theme::find($theme);
        
        if (!$theme) {
            return response()->json([
                'Message' => 'Thème non trouvé'
            ], 404);
        }
        $validated = $request->validate([
            "title" => "sometimes|string|min:2|max:255|unique:themes,title",
            "score" => "sometimes|integer|min:0|max:100",
            'phase_id' => "sometimes|integer|exists:phases,id",
        ]);
        $theme->update($validated);
        return response()->json([
            'Message' => 'Thème mis à jour avec succès',
            'Theme' => $theme
        ], 200);
    }
    
    public function destroy(Request $request, string $theme)
    {
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
                "message" => "Non autorisé à supprimer ce thème.",
            ], 403);
        }
        $theme = Theme::where('phase_id', $theme)->get();
        if (!$theme) {
            return response()->json([
                'Message' => 'Thème non trouvé'
            ], 404);
        }
        $theme->delete();
        return response()->json([
            'Message' => 'Thème supprimé avec succès'
        ], 200);
    }
    public function themeByPhase (string $phase)
    {
        $themes = Theme::where('phase_id', $phase)->get();
        return response()->json([
            'Message' => 'Liste des thèmes de ' . Phase::where('id', $phase)->first()->title,
            'Themes' => $themes,
            'count' => $themes->count(),
        ], 200);
    }
}
