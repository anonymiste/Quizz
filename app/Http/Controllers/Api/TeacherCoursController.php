<?php
namespace App\Http\Controllers\Api;

use App\Enums\PhaseLevel;
use App\Enums\QuizzCategory;
use App\Models\User;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Models\Phase;
use App\Models\Theme;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;
use Laravel\Sanctum\PersonalAccessToken;

class TeacherCoursController extends Controller
{
    /**
     * Récupérer tous les "cours" du teacher (basé sur les phases)
     */
    public function getTeacherCourses($teacherId): JsonResponse
    {
        try {
            $courses = Phase::with(['themes', 'themes.questions'])
                ->where('user_id', $teacherId)
                ->orderBy('created_at', 'desc')
                ->get()
                ->map(function ($phase) {
                    return [
                        'id' => $phase->id,
                        'title' => $phase->title,
                        'description' => 'Phase ' . $phase->level->value,
                        'category' => 'Phase',
                        'teacher_id' => $phase->user_id,
                        'student_count' => 0,
                        'quiz_count' => $phase->themes->count(),
                        'status' => 'active',
                        'average' => $phase->average,
                        'level' => $phase->level->value,
                        'created_at' => $phase->created_at->toISOString(),
                        'updated_at' => $phase->updated_at->toISOString(),
                    ];
                });

            return response()->json([
                'success' => true,
                'data' => $courses
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors du chargement des cours',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Créer un nouveau "cours" (phase)
     */
    public function store(Request $request): JsonResponse
    {
        try {
            $token = $request->bearerToken();
            
            if (!$token) {
                return response()->json(["message" => "Token manquant."], 401);
            }

            $accessToken = PersonalAccessToken::findToken($token);
            
            if (!$accessToken) {
                return response()->json(["message" => "Token invalide."], 401);
            }

            $currentUser = $accessToken->tokenable;

            $validated = $request->validate([
                'title' => 'required|string|max:255',
                'category' => 'required|string|in:' . implode(',', QuizzCategory::values()), 
                'level' => 'required|string|in:' . implode(',', PhaseLevel::values()), 
                'average' => 'sometimes|numeric|min:0|max:20',
            ]);

            $phase = Phase::create([
                'title' => $validated['title'],
                'level' => $validated['level'],
                'average' => $validated['average'] ?? 0,
                'user_id' => $currentUser->id,
            ]);

            $courseData = [
                'id' => $phase->id,
                'title' => $phase->title,
                'description' => 'Phase ' . $phase->level->value,
                'category' => 'Phase',
                'teacher_id' => $phase->user_id,
                'student_count' => 0,
                'quiz_count' => 0,
                'status' => 'active',
                'average' => $phase->average,
                'level' => $phase->level->value,
                'created_at' => $phase->created_at->toISOString(),
                'updated_at' => $phase->updated_at->toISOString(),
            ];

            return response()->json([
                'success' => true,
                'message' => 'Cours créé avec succès',
                'data' => $courseData
            ], 201);

        } catch (ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur de validation',
                'errors' => $e->errors()
            ], 422);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la création du cours',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Mettre à jour un "cours" (phase)
     */
    public function update(Request $request, $courseId): JsonResponse
    {
        try {
            $token = $request->bearerToken();
            
            if (!$token) {
                return response()->json(["message" => "Token manquant."], 401);
            }

            $accessToken = PersonalAccessToken::findToken($token);
            
            if (!$accessToken) {
                return response()->json(["message" => "Token invalide."], 401);
            }

            $currentUser = $accessToken->tokenable;

            $phase = Phase::where('user_id', $currentUser->id)->findOrFail($courseId);

            $validated = $request->validate([
                'title' => 'sometimes|string|max:255',
                'category' => 'sometimes|string|in:' . implode(',', QuizzCategory::values()), 
                'level' => 'sometimes|string|in:' . implode(',', PhaseLevel::values()), 
                'average' => 'sometimes|numeric|min:0|max:20',
            ]);

            $phase->update($validated);

            return response()->json([
                'success' => true,
                'message' => 'Cours mis à jour avec succès',
                'data' => $phase
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
                'message' => 'Erreur lors de la mise à jour du cours',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Mettre à jour le statut d'un "cours"
     */
    public function updateStatus(Request $request, $courseId): JsonResponse
    {
        try {
            $token = $request->bearerToken();
            
            if (!$token) {
                return response()->json(["message" => "Token manquant."], 401);
            }

            $accessToken = PersonalAccessToken::findToken($token);
            
            if (!$accessToken) {
                return response()->json(["message" => "Token invalide."], 401);
            }

            $currentUser = $accessToken->tokenable;

            $phase = Phase::where('user_id', $currentUser->id)->findOrFail($courseId);

            $validated = $request->validate([
                'status' => 'required|in:active,archived,draft'
            ]);

            $phase->update($validated);
            
            return response()->json([
                'success' => true,
                'message' => 'Statut du cours mis à jour avec succès',
                'data' => $phase
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
                'message' => 'Erreur lors de la mise à jour du statut',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Récupérer les statistiques d'un "cours"
     */
    public function statistics(Request $request, $courseId): JsonResponse
    {
        try {
            $token = $request->bearerToken();
            
            if (!$token) {
                return response()->json(["message" => "Token manquant."], 401);
            }

            $accessToken = PersonalAccessToken::findToken($token);
            
            if (!$accessToken) {
                return response()->json(["message" => "Token invalide."], 401);
            }

            $currentUser = $accessToken->tokenable;

            $phase = Phase::with(['themes', 'themes.questions'])
                ->where('user_id', $currentUser->id)
                ->findOrFail($courseId);

            $totalThemes = $phase->themes->count();
            $totalQuestions = $phase->themes->sum(function ($theme) {
                return $theme->questions->count();
            });

            $statistics = [
                'course' => [
                    'id' => $phase->id,
                    'title' => $phase->title,
                    'level' => $phase->level->value,
                    'total_themes' => $totalThemes,
                    'total_questions' => $totalQuestions,
                    'average_score' => $phase->average,
                ],
                'themes_progress' => $phase->themes->map(function ($theme) {
                    return [
                        'title' => $theme->title,
                        'score' => $theme->score,
                        'questions_count' => $theme->questions->count(),
                    ];
                })
            ];

            return response()->json([
                'success' => true,
                'data' => $statistics
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