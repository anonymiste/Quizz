<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Question;
use App\Models\Theme;
use Illuminate\Http\Request;
use Laravel\Sanctum\PersonalAccessToken;

class QuestionController extends Controller
{
    public function index()
    {
        $questions = Question::all();
        return response()->json([
            'Message' => 'Liste des questions',
            'Questions' => $questions,
            'count' => $questions->count(),
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
        // // Vérification que l'utilisateur peut modifier cette phase
        if ($currentUser->role !== 'admin') {
            return response()->json([
                "message" => "Non autorisé à créer cette question.",
            ], 403);
        }
        $request->validate([
            "tag" => "required|string|min:2|max:255",
            "mark" => "sometimes|string|max:3",
            'theme_id' => "sometimes|integer|exists:themes,id",
        ]);
        
        $question = Question::create([
            "tag" => $request->tag,
            "mark" => $request->mark ?? '0',
            "theme_id" => $request->theme_id ?? 3,
        ]);

        return response()->json([
            'Message' => 'Question créée avec succès',
            'Question' => $question
        ], 201);
    }
    
    public function show(string $question)
    {
        $question = Question::find($question);
        if (!$question) {
            return response()->json(["message" => "Question non trouvée."], 404);
        }

        return response()->json([
            'Message' => 'Détails de la question',
            'Question' => $question
        ], 200);
    }

    public function update(Request $request, string $question)
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
                "message" => "Non autorisé à mettre à jour cette question.",
            ], 403);
        }
        
        $validated = $request->validate([
            "tag" => "sometimes|string|min:2|max:255|unique:phases,title",
            "mark" => "sometimes|string|min:0|max:3",
            'theme_id' => "sometimes|integer|exists:themes,id",
        ]);

        $question = Question::find($question);

        if(!$question)
            return response()->json(["message" => "Question non trouvée."], 404);

        $question->update($validated);
        return response()->json([
            'Message' => 'Question mise à jour avec succès',
            'Question' => $question
        ], 200);
    }

    public function destroy(Request $request, string $question)
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
        // if ($currentUser->role !== 'admin') {
        //     return response()->json([
        //         "message" => "Non autorisé à supprimer cette question.",
        //     ], 403);
        // }

        $question = Question::where('id', $question)->first();

        if(!$question)
            return response()->json(["message" => "Question non trouvée."], 404);

        $question->delete();
        return response()->json([
            'Message' => 'Question supprimée avec succès'
        ], 200);
    }

    public function questionsByTheme(string $theme)
    {
        $questions = Question::where('theme_id', $theme)->get();
        return response()->json([
            'Message' => 'Liste des questions de ' . Theme::where('id', $theme)->first()->title,
            'Questions' => $questions,
            'count' => $questions->count(),
        ], 200);
    }
}
