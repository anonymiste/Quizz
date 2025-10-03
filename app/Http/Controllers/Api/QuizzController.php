<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Quizz;
use App\Models\UserQuizzAttempt;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class QuizzController extends Controller
{
    // Liste des quizzes avec filtres
    public function index(Request $request): JsonResponse
    {
        $query = Quizz::with(['user:id,name', 'questions'])
                    ->published()
                    ->withCount('questions');

        // Filtres
        if ($request->has('category') && $request->category !== 'all') {
            $query->byCategory($request->category);
        }

        if ($request->has('difficulty') && $request->difficulty !== 'all') {
            $query->byDifficulty($request->difficulty);
        }

        if ($request->has('search')) {
            $query->where(function($q) use ($request) {
                $q->where('title', 'like', '%' . $request->search . '%')
                  ->orWhere('description', 'like', '%' . $request->search . '%');
            });
        }

        // Tri
        $sortBy = $request->get('sort_by', 'created_at');
        $sortOrder = $request->get('sort_order', 'desc');

        $quizzes = $query->orderBy($sortBy, $sortOrder)
                        ->paginate(12);

        return response()->json([
            'success' => true,
            'data' => $quizzes->items(),
            'meta' => [
                'current_page' => $quizzes->currentPage(),
                'total' => $quizzes->total(),
                'per_page' => $quizzes->perPage(),
            ]
        ]);
    }

    // Détails d'un quiz
    public function show($id): JsonResponse
    {
        $quiz = Quizz::with(['questions' => function($query) {
            $query->orderBy('order');
        }])->published()->findOrFail($id);

        return response()->json([
            'success' => true,
            'data' => $quiz
        ]);
    }

    // Soumettre un quiz
    public function submit(Request $request, $id): JsonResponse
    {
        $request->validate([
            'answers' => 'required|array',
            'time_spent' => 'required|integer',
        ]);

        $quiz = Quizz::with('questions')->published()->findOrFail($id);
        $user = $request->user();

        return DB::transaction(function() use ($quiz, $user, $request) {
            // Calculer le score
            $score = $this->calculateScore($quiz, $request->answers);
            
            // Enregistrer la tentative
            $attempt = UserQuizzAttempt::create([
                'user_id' => $user->id,
                'quiz_id' => $quiz->id,
                'score' => $score,
                'time_spent' => $request->time_spent,
                'answers' => $request->answers,
                'completed_at' => now(),
            ]);

            // Mettre à jour les statistiques
            $this->updateUserStatistics($user, $attempt);

            // Incrémenter le compteur de participants
            $quiz->incrementParticipants();

            return response()->json([
                'success' => true,
                'data' => [
                    'score' => $score,
                    'passed' => $score >= 60,
                    'correct_answers' => $this->countCorrectAnswers($quiz, $request->answers),
                    'total_questions' => $quiz->questions->count(),
                    'attempt_id' => $attempt->id,
                ]
            ]);
        });
    }

    private function calculateScore(Quizz $quiz, array $userAnswers): float
    {
        $correctCount = 0;
        
        foreach ($quiz->questions as $question) {
            $userAnswer = $userAnswers[$question->id] ?? null;
            if ($userAnswer === $question->correct_answer_index) {
                $correctCount++;
            }
        }

        return ($correctCount / $quiz->questions->count()) * 100;
    }

    private function countCorrectAnswers(Quizz $quiz, array $userAnswers): int
    {
        $correctCount = 0;
        
        foreach ($quiz->questions as $question) {
            $userAnswer = $userAnswers[$question->id] ?? null;
            if ($userAnswer === $question->correct_answer_index) {
                $correctCount++;
            }
        }

        return $correctCount;
    }

    private function updateUserStatistics($user, UserQuizzAttempt $attempt)
    {
        $stats = $user->statistics()->firstOrCreate();

        // Compter les bonnes/mauvaises réponses
        $correctAnswers = 0;
        $incorrectAnswers = 0;
        
        $quiz = $attempt->quiz;
        foreach ($quiz->questions as $question) {
            $userAnswer = $attempt->answers[$question->id] ?? null;
            if ($userAnswer === $question->correct_answer_index) {
                $correctAnswers++;
            } else {
                $incorrectAnswers++;
            }
        }

        $stats->total_correct_answers += $correctAnswers;
        $stats->total_incorrect_answers += $incorrectAnswers;
        $stats->updateStatistics($attempt);
    }
}