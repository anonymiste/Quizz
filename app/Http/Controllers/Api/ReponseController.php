<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Question;
use App\Models\Reponse;
use Illuminate\Http\Request;
use Laravel\Sanctum\PersonalAccessToken;

class ReponseController extends Controller
{
    
    public function index()
    {
        $reponses = Reponse::all();
        return response()->json([
            'Message' => 'Liste des réponses',
            'Réponses' => $reponses,
            'count' => $reponses->count(),
        ], 200);
    }

    public function questionResponses(string $question_id)
    {
        $question = Question::find($question_id);
        if (!$question) {
            return response()->json(["message" => "Question non trouvée."], 404);
        }

        $reponses = Reponse::where('question_id', $question_id)->get();
        return response()->json([
            'Message' => 'Liste des réponses',
            'Réponses' => $reponses,
            'count' => $reponses->count(),
        ], 200);
    }

    public function store(Request $request)
    {
        $token = $request->bearerToken();

        if (!$token) {
            return response()->json(["message" => "Token manquant."], 401);
        }

        $accessToken = PersonalAccessToken::findToken($token);

        if (!$accessToken) {
            return response()->json(["message" => "Token invalide."], 401);
        }

        $currentUser = $accessToken->tokenable;

        if (!$currentUser) {
            return response()->json(["message" => "Utilisateur non trouvé."], 401);
        }

        if ($currentUser->role !== 'admin') {
            return response()->json([
                "message" => "Non autorisé à créer cette réponse.",
            ], 403);
        }

        $request->validate([
            "body" => "required|string|min:1|max:255",
            "value" => "sometimes|string|max:3",
            "check" => "sometimes|boolean",
            "question_id" => "required|integer|exists:questions,id",
        ]);

        $reponse = Reponse::create([
            "body" => $request->body,
            "value" => $request->value ?? '0',
            "check" => $request->check ?? false,
            "question_id" => $request->question_id,
        ]);

        return response()->json([
            'Message' => 'Réponse créée avec succès',
            'Réponse' => $reponse
        ], 201);
    }

    public function show(string $reponse)
    {
        $reponse = Reponse::find($reponse);
        if (!$reponse) {
            return response()->json(["message" => "Réponse non trouvée."], 404);
        }

        return response()->json([
            'Message' => 'Détails de la réponse',
            'Réponse' => $reponse
        ], 200);
    }

    public function update(Request $request, string $reponse)
    {
        $token = $request->bearerToken();

        if (!$token) {
            return response()->json(["message" => "Token manquant."], 401);
        }

        $accessToken = PersonalAccessToken::findToken($token);

        if (!$accessToken) {
            return response()->json(["message" => "Token invalide."], 401);
        }

        $currentUser = $accessToken->tokenable;

        if (!$currentUser) {
            return response()->json(["message" => "Utilisateur non trouvé."], 401);
        }

        // if ($currentUser->role !== 'admin') {
        //     return response()->json([
        //         "message" => "Non autorisé à mettre à jour cette réponse.",
        //     ], 403);
        // }
        
        $reponse = Reponse::find($reponse);

        if (!$reponse) {
            return response()->json(["message" => "Réponse non trouvée."], 404);
        }

        $validated = $request->validate([
            "body" => "sometimes|required|string|min:1|max:255",
            "value" => "sometimes|string|max:3",
            "check" => "sometimes|boolean",
            "question_id" => "sometimes|integer|exists:questions,id",
        ]);

        $reponse->update($validated);
        
        return response()->json([
            'Message' => 'Réponse mise à jour avec succès',
            'Réponse' => $reponse
        ], 200);
    }

    public function destroy(Request $request, string $reponse)
    {
        $token = $request->bearerToken();

        if (!$token) {
            return response()->json(["message" => "Token manquant."], 401);
        }

        $accessToken = PersonalAccessToken::findToken($token);

        if (!$accessToken) {
            return response()->json(["message" => "Token invalide."], 401);
        }

        $currentUser = $accessToken->tokenable;

        if (!$currentUser) {
            return response()->json(["message" => "Utilisateur non trouvé."], 401);
        }

        if ($currentUser->role !== 'admin') {
            return response()->json([
                "message" => "Non autorisé à supprimer cette réponse.",
            ], 403);
        }

        $reponse = Reponse::where('id', $reponse)->first();

        if (!$reponse)
            return response()->json(["message" => "Réponse non trouvée."], 404);

        $reponse->delete();
        return response()->json([
            'Message' => 'Réponse supprimée avec succès'
        ], 200);
    }
}
