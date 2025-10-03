<?php
namespace App\Http\Controllers\Api;

use App\Enums\QuizzDifficulty;
use App\Models\Quizz;
use App\Models\Question;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;
use Laravel\Sanctum\PersonalAccessToken;

class TeacherQuizzController extends Controller
{
    /**
     * Récupérer tous les quiz du teacher
     */
    public function getTeacherQuizzes($teacherId): JsonResponse
    {
        try {
            $quizzes =  User::findOrFail($teacherId)
                ->quizzes()
                ->with(['questions']) // Charger seulement les questions
                ->orderBy('created_at', 'desc')
                ->get()
                ->map(function ($quiz) {
                    return [
                        'id' => $quiz->id,
                        'title' => $quiz->title,
                        'description' => $quiz->description,
                        'category' => $quiz->category,
                        'difficulty' => $quiz->difficulty,
                        'status' => $quiz->status,
                        'time_limit' => $quiz->time_limit,
                        'created_at' => $quiz->created_at,
                        'updated_at' => $quiz->updated_at,
                        'participants' => $quiz->participants_count ?? 0,
                        'rating' => $quiz->average_rating ?? 0.0,
                        'questions_count' => $quiz->questions->count(),
                    ];
                });

            return response()->json([
                'success' => true,
                'data' => $quizzes
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors du chargement des quiz',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Créer un nouveau quiz
     */
    public function store(Request $request): JsonResponse
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
            

            $validated = $request->validate([
                'title' => 'required|string|max:255',
                'description' => 'required|string',
                'category' => 'required|string|max:255',
                'difficulty' => 'required|in:' . implode(',', QuizzDifficulty::values()),
                'time_limit' => 'required|integer|min:1',
                'tags' => 'sometimes|array',
                'questions' => 'sometimes|array',
                'questions.*.text' => 'required|string',
                'questions.*.options' => 'required|array|min:2',
                'questions.*.correct_answer_index' => 'required|integer|min:0',
                'questions.*.explanation' => 'sometimes|string',
                'questions.*.type' => 'sometimes|string',
                'questions.*.points' => 'sometimes|integer|min:1',
                'questions.*.time_limit' => 'sometimes|integer|min:0',
            ]);

            DB::beginTransaction();

            $quizz = Quizz::create([
                'title' => $validated['title'],
                'description' => $validated['description'],
                'category' => $validated['category'],
                'difficulty' => $validated['difficulty'],
                'time_limit' => $validated['time_limit'],
                'user_id' => $currentUser->id,
                'tags' => $validated['tags'] ?? [],
                'is_published' => false,
            ]);

            // Créer les questions si fournies
            if (isset($validated['questions'])) {
                foreach ($validated['questions'] as $index => $questionData) {
                    Question::create([
                        'quizz_id' => $quizz->id,
                        'text' => $questionData['text'],
                        'options' => $questionData['options'],
                        'correct_answer_index' => $questionData['correct_answer_index'],
                        'explanation' => $questionData['explanation'] ?? null,
                        'type' => $questionData['type'] ?? 'multiple_choice',
                        'points' => $questionData['points'] ?? 1,
                        'time_limit' => $questionData['time_limit'] ?? null,
                        'order' => $index,
                    ]);
                }
            }

            // Mettre à jour le compteur de questions
            $quizz->update(['question_count' => $quizz->questions()->count()]);

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Quiz créé avec succès',
                'data' => $quizz->load('questions')
            ], 201);

        } catch (\Illuminate\Validation\ValidationException $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Erreur de validation',
                'errors' => $e->errors()
            ], 422);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la création du quiz',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Mettre à jour un quiz
     */
    public function update(Request $request, $quizId): JsonResponse
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
            
            $quiz = Quizz::where('user_id', $currentUser->id)->findOrFail($quizId);

            $validated = $request->validate([
                'title' => 'sometimes|string|max:255',
                'description' => 'sometimes|string',
                'category' => 'sometimes|string|max:255',
                'difficulty' => 'sometimes|in:' . implode(',', QuizzDifficulty::values()),
                'time_limit' => 'sometimes|integer|min:1',
                'tags' => 'sometimes|array',
                'is_published' => 'sometimes|boolean',
            ]);

            $quiz->update($validated);

            return response()->json([
                'success' => true,
                'message' => 'Quiz mis à jour avec succès',
                'data' => $quiz->load('questions')
            ]);

        } catch (ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur de validation',
                'errors' => $e->errors()
            ], 422);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la mise à jour du quiz',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Dupliquer un quiz
     */
    public function duplicate(Request $request, $quizzId): JsonResponse
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

            
            DB::beginTransaction();

            $originalQuizz = Quizz::with('questions')
                ->where('user_id', $currentUser->id)
                ->findOrFail($quizzId);

            // Créer la copie du quiz
            $duplicatedQuiz = $originalQuizz->replicate();
            $duplicatedQuiz->title = $originalQuizz->title . ' (Copie)';
            $duplicatedQuiz->is_published = false;
            $duplicatedQuiz->participants_count = 0;
            $duplicatedQuiz->rating = 0;
            $duplicatedQuiz->save();

            // Dupliquer les questions
            foreach ($originalQuizz->questions as $question) {
                $duplicatedQuestion = $question->replicate();
                $duplicatedQuestion->quizz_id = $duplicatedQuiz->id;
                $duplicatedQuestion->save();
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Quiz dupliqué avec succès',
                'data' => $duplicatedQuiz->load('questions')
            ], 201);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la duplication du quiz',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Mettre à jour le statut d'un quiz
     */
    public function updateStatus(Request $request, $quizzId): JsonResponse
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
            
            $quizz = Quizz::where('user_id', $currentUser->id)->findOrFail($quizzId);

            $validated = $request->validate([
                'status' => 'required|in:published,draft,archived'
            ]);

            $quizz->update([
                'is_published' => $validated['status'] === 'published'
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Statut du quiz mis à jour avec succès',
                'quizz' => $quizz
            ]);

        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur de validation',
                'errors' => $e->errors()
            ], 422);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la mise à jour du statut',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Supprimer un quiz
     */
    public function destroy(Request $request, $quizzId): JsonResponse
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

            $quiz = Quizz::where('user_id', $currentUser->id)->findOrFail($quizzId);

            // Supprimer les questions associées
            $quiz->questions()->delete();
            $quiz->delete();

            return response()->json([
                'success' => true,
                'message' => 'Quiz supprimé avec succès'
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la suppression du quiz',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Récupérer les statistiques d'un quiz
     */
    public function statistics(Request $request, $quizzId): JsonResponse
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

            $quizz = Quizz::with(['attempts', 'attempts.user'])
                ->where('user_id', $currentUser->id)
                ->findOrFail($quizzId);

            $attempts = $quizz->attempts;
            $totalAttempts = $attempts->count();
            $averageScore = $totalAttempts > 0 ? $attempts->avg('score') : 0;
            $completionRate = $totalAttempts > 0 ? 
                ($attempts->whereNotNull('completed_at')->count() / $totalAttempts) * 100 : 0;

            $statistics = [
                'quizz' => [
                    'id' => $quizz->id,
                    'title' => $quizz->title,
                    'total_attempts' => $totalAttempts,
                    'average_score' => round($averageScore, 2),
                    'completion_rate' => round($completionRate, 2),
                    'participants_count' => $quizz->participants_count,
                    'rating' => $quizz->rating,
                ],
                'score_distribution' => [
                    'excellent' => $attempts->where('score', '>=', 90)->count(),
                    'good' => $attempts->whereBetween('score', [70, 89])->count(),
                    'average' => $attempts->whereBetween('score', [50, 69])->count(),
                    'poor' => $attempts->where('score', '<', 50)->count(),
                ],
                'recent_attempts' => $attempts->take(10)->map(function ($attempt) {
                    return [
                        'user_name' => $attempt->user->name,
                        'score' => $attempt->score,
                        'time_spent' => $attempt->time_spent,
                        'completed_at' => $attempt->completed_at,
                    ];
                })
            ];

            return response()->json([
                'success' => true,
                'statistics' => $statistics
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors du chargement des statistiques',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}