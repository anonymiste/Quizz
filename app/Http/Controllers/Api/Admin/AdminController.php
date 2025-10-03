<?php

namespace App\Http\Controllers\Api\Admin;

use App\Enums\UserRole;
use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\UserStatistics;
use App\Models\Quizz;
use App\Models\UserQuizzAttempt;
use App\Models\Phase;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Validation\Rule;

class AdminController extends Controller
{
    /**
     * Get admin dashboard statistics
     */
    public function getDashboardStats(): JsonResponse
    {
        try {
            $stats = [
                'total_users' => (int) User::count(),
                'total_teachers' => (int) User::where('role', 'teacher')->count(),
                'total_students' => (int) User::where('role', 'student')->count(),
                'total_quizzes' => (int) Quizz::count(),
                'total_phases' => (int) Phase::count(),
                'total_quiz_attempts' => (int) UserQuizzAttempt::count(),
                'online_users' => (int) User::where('last_activity_at', '>=', now()->subMinutes(5))->count(),
                'total_points_distributed' => (int) UserStatistics::sum('total_points') ?? 0,
                'average_success_rate' => (int) UserStatistics::avg('success_rate') ?? 0,
            ];

            return response()->json([
                'success' => true,
                'stats' => $stats
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la récupération des statistiques',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get all users with pagination
     */
    public function getUsers(Request $request): JsonResponse
    {
        try {
            $perPage = $request->get('per_page', 10);
            $search = $request->get('search');
            $role = $request->get('role');

            $users = User::with(['userstatistics', 'phases', 'quizzes'])
                ->when($search, function ($query) use ($search) {
                    $query->where('name', 'like', "%{$search}%")
                          ->orWhere('email', 'like', "%{$search}%");
                })
                ->when($role, function ($query) use ($role) {
                    $query->where('role', $role);
                })
                ->orderBy('created_at', 'desc')
                ->paginate($perPage);

            return response()->json([
                'success' => true,
                'users' => $users
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la récupération des utilisateurs',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Create new user
     */
    public function createUser(Request $request)
    {
        try {
            $request->validate([
                'name' => 'sometimes|string|max:255',
                'email' => 'required|string|unique:users',
                'role' => 'required|in:' . implode(',', UserRole::values()),
                'total' => 'sometimes',
            ]);

            $user = User::create([
                'name' => $request->name,
                'email' => $request->email,
                'role' => $request->role,
                'total' => $request->total ?? 0,
            ]);

            // Créer des statistiques vides pour le nouvel utilisateur
            UserStatistics::create([
                'user_id' => $user->id,
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

            return response()->json([
                'success' => true,
                'message' => 'Utilisateur créé avec succès',
                'user' => $user->load('userstatistics')
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la création de l\'utilisateur',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Update user
     */
    public function updateUser(Request $request, $userId): JsonResponse
    {
        try {
            $user = User::findOrFail($userId);

            $request->validate([
                'name' => 'sometimes|string|max:255',
                'email' => 'sometimes|string|email|max:255|unique:users,email,' . $userId,
                'role' => ['sometimes', Rule::in(['admin', 'teacher', 'student', 'user'])],
                'total' => 'sometimes|integer|max:255',
            ]);

            $user->update($request->only(['name', 'email', 'role', 'total']));

            return response()->json([
                'success' => true,
                'message' => 'Utilisateur mis à jour avec succès',
                'user' => $user->load('userstatistics')
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la mise à jour de l\'utilisateur',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Delete user
     */
    public function deleteUser($userId): JsonResponse
    {
        try {
            $user = User::findOrFail($userId);
            
            // Supprimer les données associées
            if ($user->userstatistics) {
                $user->userstatistics->delete();
            }

            // $user->quizzes()->delete();
            // $user->quizAttempts()->delete();
            // $user->phases()->delete();

            $user->delete();

            return response()->json([
                'success' => true,
                'message' => 'Utilisateur supprimé avec succès'
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la suppression de l\'utilisateur',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get system analytics
     */
    public function getSystemAnalytics(): JsonResponse
    {
        try {
            $analytics = [
                'users_growth' => $this->getUsersGrowth(),
                'quizzes_analytics' => $this->getQuizzesAnalytics(),
                'performance_metrics' => $this->getPerformanceMetrics(),
                'recent_activity' => $this->getRecentActivity(),
            ];

            return response()->json([
                'success' => true,
                'analytics' => $analytics
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la récupération des analytics',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get quizzes management
     */
    public function getQuizzes(Request $request): JsonResponse
    {
        try {
            $perPage = $request->get('per_page', 10);
            $search = $request->get('search');

            $quizzes = Quizz::with(['user', 'questions'])
                ->when($search, function ($query) use ($search) {
                    $query->where('title', 'like', "%{$search}%")
                          ->orWhere('description', 'like', "%{$search}%");
                })
                ->orderBy('created_at', 'desc')
                ->paginate($perPage);

            return response()->json([
                'success' => true,
                'quizz' => $quizzes
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la récupération des quizzes',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    private function getUsersGrowth()
    {
        return [
            'today' => User::whereDate('created_at', today())->count(),
            'this_week' => User::where('created_at', '>=', now()->startOfWeek())->count(),
            'this_month' => User::where('created_at', '>=', now()->startOfMonth())->count(),
            'total' => User::count(),
        ];
    }

    private function getQuizzesAnalytics()
    {
        return [
            'total_quizzes' => Quizz::count(),
            'quizzes_today' => Quizz::whereDate('created_at', today())->count(),
            'average_questions_per_quiz' => Quizz::withCount('questions')->get()->avg('questions_count'),
            'most_popular_quiz' => UserQuizzAttempt::select('quizz_id')
                ->selectRaw('COUNT(*) as attempts')
                ->groupBy('quizz_id')
                ->orderBy('attempts', 'desc')
                ->first(),
        ];
    }

    private function getPerformanceMetrics()
    {
        return [
            'average_success_rate' => UserStatistics::avg('success_rate') ?? 0,
            'total_quiz_attempts' => UserQuizzAttempt::count(),
            'average_time_per_quiz' => UserQuizzAttempt::avg('time_spent') ?? 0,
            'completion_rate' => $this->calculateCompletionRate(),
        ];
    }

    private function getRecentActivity()
    {
        return [
            'recent_users' => User::with('userstatistics')
                ->orderBy('created_at', 'desc')
                ->limit(5)
                ->get()
                ->map(function ($user) {
                    return [
                        'name' => $user->name,
                        'email' => $user->email,
                        'role' => $user->role,
                        'joined_at' => $user->created_at,
                        'points' => $user->userstatistics->total_points ?? 0,
                    ];
                }),
            'recent_quizzes' => Quizz::with('user')
                ->orderBy('created_at', 'desc')
                ->limit(5)
                ->get()
                ->map(function ($quiz) {
                    return [
                        'title' => $quiz->title,
                        'creator' => $quiz->user->name,
                        'questions_count' => $quiz->questions->count(),
                        'created_at' => $quiz->created_at,
                    ];
                }),
        ];
    }

    private function calculateCompletionRate()
    {
        $totalUsers = User::count();
        $usersWithAttempts = User::has('quizAttempts')->count();
        
        return $totalUsers > 0 ? ($usersWithAttempts / $totalUsers) * 100 : 0;
    }
}