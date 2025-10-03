<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\UserStatistics;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class StatisticsController extends Controller
{
    /**
     * Get user statistics
     */
    public function getUserStatistics($userId): JsonResponse
    {
        try {
            // Vérifier que l'utilisateur existe
            $user = User::find($userId);
            if (!$user) {
                return response()->json([
                    'message' => 'Utilisateur non trouvé',
                    'error' => 'User not found'
                ], 404);
            }

            // Récupérer ou créer les statistiques
            $statistics = UserStatistics::firstOrCreate(
                ['user_id' => $userId],
                [
                    'total_points' => 0,
                    'quizzes_completed' => 0,
                    'correct_answers' => 0,
                    'incorrect_answers' => 0,
                    'success_rate' => 0,
                    'current_streak' => 0,
                    'best_streak' => 0,
                    'total_time_spent' => 0,
                    'average_score' => 0,
                ]
            );

            return response()->json([
                'statistiques' => [
                    'user' => [
                        'id' => $user->id,
                        'name' => $user->name,
                        'email' => $user->email,
                        'role' => $user->role,
                    ],
                    'statistics' => [
                        'total_points' => $statistics->total_points,
                        'quizzes_completed' => $statistics->quizzes_completed,
                        'correct_answers' => $statistics->correct_answers,
                        'incorrect_answers' => $statistics->incorrect_answers,
                        'success_rate' => (float) $statistics->success_rate,
                        'current_streak' => $statistics->current_streak,
                        'best_streak' => $statistics->best_streak,
                        'total_time_spent' => $statistics->total_time_spent,
                        'average_score' => (float) $statistics->average_score,
                    ],
                    'phases_progress' => $this->getPhasesProgress($userId),
                    'rank' => $this->calculateRank($statistics->total_points),
                    'recent_activity' => $this->getRecentActivity($userId),
                ]
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erreur lors de la récupération des statistiques',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get leaderboard
     */
    public function getLeaderboard(Request $request): JsonResponse
    {
        try {
            $limit = $request->get('limit', 10);

            $leaderboard = UserStatistics::with('user')
                ->orderBy('total_points', 'DESC')
                ->limit($limit)
                ->get()
                ->map(function ($stat, $index) {
                    return [
                        'rank' => $index + 1,
                        'user_name' => $stat->user->name,
                        'user_email' => $stat->user->email,
                        'total_points' => $stat->total_points,
                        'quizzes_completed' => $stat->quizzes_completed,
                        'success_rate' => (float) $stat->success_rate,
                    ];
                });

            return response()->json($leaderboard, 200);

        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erreur lors de la récupération du classement',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Update statistics after quiz
     */
    public function updateAfterQuiz(Request $request): JsonResponse
    {
        try {
            $request->validate([
                'user_id' => 'required|exists:users,id',
                'points' => 'required|integer',
                'correct_answers' => 'required|integer',
                'total_questions' => 'required|integer',
                'time_spent_minutes' => 'required|integer',
            ]);

            $userId = $request->user_id;
            $statistics = UserStatistics::where('user_id', $userId)->first();

            if (!$statistics) {
                $statistics = UserStatistics::create([
                    'user_id' => $userId,
                    'total_points' => 0,
                    'quizzes_completed' => 0,
                    'correct_answers' => 0,
                    'incorrect_answers' => 0,
                    'success_rate' => 0,
                    'current_streak' => 0,
                    'best_streak' => 0,
                    'total_time_spent' => 0,
                    'average_score' => 0,
                ]);
            }

            // Mettre à jour les statistiques
            $statistics->total_points += $request->points;
            $statistics->quizzes_completed += 1;
            $statistics->correct_answers += $request->correct_answers;
            $statistics->incorrect_answers += ($request->total_questions - $request->correct_answers);
            $statistics->total_time_spent += $request->time_spent_minutes;

            // Calculer le taux de réussite
            $totalAnswers = $statistics->correct_answers + $statistics->incorrect_answers;
            $statistics->success_rate = $totalAnswers > 0 
                ? ($statistics->correct_answers / $totalAnswers) * 100 
                : 0;

            // Calculer le score moyen
            $statistics->average_score = $statistics->quizzes_completed > 0
                ? ($statistics->total_points / $statistics->quizzes_completed)
                : 0;

            // Gérer les séries
            $currentScore = ($request->correct_answers / $request->total_questions) * 100;
            if ($currentScore >= 70) {
                $statistics->current_streak += 1;
                $statistics->best_streak = max($statistics->best_streak, $statistics->current_streak);
            } else {
                $statistics->current_streak = 0;
            }

            $statistics->save();

            return response()->json([
                'message' => 'Statistiques mises à jour avec succès',
                'statistics' => $statistics
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erreur lors de la mise à jour des statistiques',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Calculate user rank based on points
     */
    private function calculateRank(int $totalPoints): array
    {
        if ($totalPoints >= 5000) {
            return ['rank' => 'Expert', 'level' => 5];
        } elseif ($totalPoints >= 2000) {
            return ['rank' => 'Avancé', 'level' => 4];
        } elseif ($totalPoints >= 1000) {
            return ['rank' => 'Intermédiaire', 'level' => 3];
        } elseif ($totalPoints >= 500) {
            return ['rank' => 'Débutant Confirmé', 'level' => 2];
        } else {
            return ['rank' => 'Nouveau', 'level' => 1];
        }
    }

    /**
     * Get phases progress (à adapter selon votre logique métier)
     */
    private function getPhasesProgress($userId): array
    {
        // Exemple de données - à remplacer par votre logique
        return [
            [
                'phase' => 'Phase 1 - Débutant',
                'progress' => 100,
                'points' => 500,
                'updated_at' => now()->subDays(2)->toISOString(),
            ],
            [
                'phase' => 'Phase 2 - Intermédiaire',
                'progress' => 75,
                'points' => 750,
                'updated_at' => now()->subDays(1)->toISOString(),
            ],
            [
                'phase' => 'Phase 3 - Avancé',
                'progress' => 25,
                'points' => 250,
                'updated_at' => now()->toISOString(),
            ],
        ];
    }

    /**
     * Get recent activity (à adapter selon votre logique métier)
     */
    private function getRecentActivity($userId): array
    {
        // Exemple de données - à remplacer par votre logique
        return [
            [
                'quiz' => 'Introduction à Dart',
                'score' => 85,
                'date' => now()->subDays(1)->format('Y-m-d'),
            ],
            [
                'quiz' => 'Flutter Basics',
                'score' => 92,
                'date' => now()->subDays(2)->format('Y-m-d'),
            ],
            [
                'quiz' => 'State Management',
                'score' => 78,
                'date' => now()->subDays(3)->format('Y-m-d'),
            ],
        ];
    }
}