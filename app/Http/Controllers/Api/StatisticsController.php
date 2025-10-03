<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\QuizzStatistics;
use App\Models\User;
use App\Models\UserQuizzAttempt;
use App\Models\UserStatistics;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Laravel\Sanctum\PersonalAccessToken;

class StatisticsController extends Controller
{
    /**
     * Récupérer les statistiques de l'utilisateur connecté
     */
    public function getUserStatistics(Request $request, string $id): JsonResponse
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
            if (!$user) {
                return response()->json([
                    "message" => "Utilisateur non trouvé !",
                ], 404);
            }

            // Vérification que l'utilisateur peut modifier ce profil
            if ($currentUser->role !== 'admin'&& $currentUser->id != $user->id) {
                return response()->json([
                    "message" => "Non autorisé à modifier cet utilisateur.",
                ], 403);
            }

            
            if (!$user) {
                return response()->json([
                    'message' => 'Utilisateur non authentifié.'
                ], 401);
            }

            $statistics = UserStatistics::where('user_id', $user->id)->first();

            return response()->json([
                'message' => 'Statistiques récupérées avec succès.',
                'statistics' => $statistics,
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erreur lors de la récupération des statistiques.',
                'error' => config('app.debug') ? $e->getMessage() : 'Erreur interne'
            ], 500);
        }
    }

    /**
     * Mettre à jour les statistiques après un quiz
     */
    public function updateAfterQuiz(Request $request): JsonResponse
    {
        try {
            $request->validate([
                'points' => 'required|integer|min:0',
                'correct_answers' => 'required|integer|min:0',
                'total_questions' => 'required|integer|min:1',
                'time_spent_minutes' => 'required|integer|min:1',
                'phase_name' => 'sometimes|string|max:255',
                'phase_progress' => 'sometimes|integer|min:0|max:100',
            ]);

            $user = Auth::user();
            
            if (!$user) {
                return response()->json([
                    'message' => 'Utilisateur non authentifié.'
                ], 401);
            }

            $statistics = UserStatistics::firstOrCreate(
                ['user_id' => $user->id],
                $this->getDefaultStatistics()
            );

            // Mettre à jour les statistiques générales
            $statistics->updateAfterQuiz(
                $request->points,
                $request->correct_answers,
                $request->total_questions,
                $request->time_spent_minutes
            );

            // Mettre à jour la progression de phase si fournie
            if ($request->has('phase_name') && $request->has('phase_progress')) {
                $statistics->updatePhaseProgress(
                    $request->phase_name,
                    $request->phase_progress,
                    $request->points
                );
            }

            return response()->json([
                'message' => 'Statistiques mises à jour avec succès.',
                'data' => $statistics->toApiFormat()
            ], 200);

        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'message' => 'Erreur de validation.',
                'errors' => $e->errors()
            ], 422);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erreur lors de la mise à jour des statistiques.',
                'error' => config('app.debug') ? $e->getMessage() : 'Erreur interne'
            ], 500);
        }
    }

    /**
     * Statistiques détaillées pour l'admin
     */
    public function getAdminStatistics(Request $request): JsonResponse
    {
        try {
            $user = Auth::user();
            
            if (!$user || $user->role !== 'admin') {
                return response()->json([
                    'message' => 'Accès non autorisé.'
                ], 403);
            }

            $totalUsers = User::count();
            $totalQuizzes = UserStatistics::sum('quizzes_completed');
            $totalPoints = UserStatistics::sum('total_points');
            $averageSuccessRate = UserStatistics::avg('success_rate');

            $recentActivity = UserStatistics::with('user')
                ->orderBy('updated_at', 'DESC')
                ->limit(5)
                ->get()
                ->map(function ($stats) {
                    return [
                        'user' => $stats->user->name,
                        'points' => $stats->total_points,
                        'quizzes' => $stats->quizzes_completed,
                        'last_activity' => $stats->updated_at->diffForHumans(),
                    ];
                });

            return response()->json([
                'message' => 'Statistiques admin récupérées avec succès.',
                'data' => [
                    'platform_stats' => [
                        'total_users' => $totalUsers,
                        'total_quizzes_completed' => $totalQuizzes,
                        'total_points_earned' => $totalPoints,
                        'average_success_rate' => round((float) $averageSuccessRate, 2),
                    ],
                    'recent_activity' => $recentActivity,
                ]
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erreur lors de la récupération des statistiques admin.',
                'error' => config('app.debug') ? $e->getMessage() : 'Erreur interne'
            ], 500);
        }
    }

    /**
     * Réinitialiser les statistiques d'un utilisateur (admin seulement)
     */
    public function resetUserStatistics(Request $request, int $userId): JsonResponse
    {
        try {
            $adminUser = Auth::user();
            
            if (!$adminUser || $adminUser->role !== 'admin') {
                return response()->json([
                    'message' => 'Accès non autorisé.'
                ], 403);
            }

            $userStatistics = UserStatistics::where('user_id', $userId)->first();
            
            if (!$userStatistics) {
                return response()->json([
                    'message' => 'Statistiques non trouvées pour cet utilisateur.'
                ], 404);
            }

            $userStatistics->update($this->getDefaultStatistics());

            return response()->json([
                'message' => 'Statistiques réinitialisées avec succès.'
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erreur lors de la réinitialisation des statistiques.',
                'error' => config('app.debug') ? $e->getMessage() : 'Erreur interne'
            ], 500);
        }
    }

    /**
     * Statistiques par défaut pour un nouvel utilisateur
     */
    private function getDefaultStatistics(): array
    {
        return [
            'total_points' => 0,
            'quizzes_completed' => 0,
            'correct_answers' => 0,
            'incorrect_answers' => 0,
            'success_rate' => 0,
            'current_streak' => 0,
            'best_streak' => 0,
            'total_time_spent' => 0,
            'phases_progress' => [],
        ];
    }

        public function getUserStats(Request $request): JsonResponse
    {
        $user = $request->user();
        $stats = $user->statistics()->firstOrCreate();

        // Meilleurs scores par catégorie
        $categoryStats = UserQuizzAttempt::with('quiz')
            ->select('quizzes.category', DB::raw('MAX(score) as best_score'))
            ->join('quizzes', 'user_quiz_attempts.quiz_id', '=', 'quizzes.id')
            ->where('user_quiz_attempts.user_id', $user->id)
            ->whereNotNull('completed_at')
            ->groupBy('quizzes.category')
            ->get()
            ->pluck('best_score', 'category');

        return response()->json([
            'success' => true,
            'data' => [
                'statistics' => $stats,
                'category_best_scores' => $categoryStats,
                'rank' => $this->calculateUserRank($user),
                'recent_activity' => $this->getRecentActivity($user),
            ]
        ]);
    }

    // Classement général
    public function getLeaderboard(Request $request): JsonResponse
    {
        $limit = $request->get('limit', 10);

        $leaderboard = QuizzStatistics::with('user:id,name,email')
            ->select('user_id', 'total_quizzes_completed', 'average_score', 'success_rate')
            ->where('total_quizzes_completed', '>', 0)
            ->orderBy('average_score', 'desc')
            ->orderBy('total_quizzes_completed', 'desc')
            ->limit($limit)
            ->get()
            ->map(function($stat, $index) {
                return [
                    'rank' => $index + 1,
                    'user_name' => $stat->user->name,
                    'user_email' => $stat->user->email,
                    'total_quizzes_completed' => $stat->total_quizzes_completed,
                    'average_score' => $stat->average_score,
                    'success_rate' => $stat->success_rate,
                ];
            });

        return response()->json([
            'success' => true,
            'data' => $leaderboard
        ]);
    }

    private function calculateUserRank($user)
    {
        $userScore = $user->statistics->average_score ?? 0;
        
        $betterUsers = QuizzStatistics::where('average_score', '>', $userScore)
            ->where('total_quizzes_completed', '>', 0)
            ->count();

        $totalUsers = QuizzStatistics::where('total_quizzes_completed', '>', 0)->count();

        if ($totalUsers === 0) return 1;

        $rank = $betterUsers + 1;
        $percentile = (($totalUsers - $rank) / $totalUsers) * 100;

        return [
            'rank' => $rank,
            'total_users' => $totalUsers,
            'percentile' => round($percentile, 1),
            'level' => $this->calculateLevel($userScore),
        ];
    }

    private function calculateLevel($score)
    {
        if ($score >= 90) return 'Expert';
        if ($score >= 75) return 'Avancé';
        if ($score >= 60) return 'Intermédiaire';
        return 'Débutant';
    }

    private function getRecentActivity($user)
    {
        return UserQuizzAttempt::with('quiz:id,title,category')
            ->where('user_id', $user->id)
            ->whereNotNull('completed_at')
            ->orderBy('completed_at', 'desc')
            ->limit(5)
            ->get()
            ->map(function($attempt) {
                return [
                    'quiz_title' => $attempt->quiz->title,
                    'category' => $attempt->quiz->category,
                    'score' => $attempt->score,
                    'date' => $attempt->completed_at->format('Y-m-d H:i'),
                ];
            });
    }

}