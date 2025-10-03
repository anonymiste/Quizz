<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UserStatistics extends Model
{
    use HasFactory;

    protected $table = 'user_statistics';

    protected $fillable = [
        'user_id',
        'total_points',
        'quizzes_completed',
        'correct_answers',
        'incorrect_answers',
        'success_rate',
        'current_streak',
        'best_streak',
        'total_time_spent',
        'phases_progress',
    ];

    protected $casts = [
        'success_rate' => 'decimal:2',
        'phases_progress' => 'array',
        'total_points' => 'integer',
        'quizzes_completed' => 'integer',
        'correct_answers' => 'integer',
        'incorrect_answers' => 'integer',
        'current_streak' => 'integer',
        'best_streak' => 'integer',
        'total_time_spent' => 'integer',
    ];

    /**
     * Relation avec l'utilisateur
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Calculer le taux de réussite
     */
    public function calculateSuccessRate(): float
    {
        $totalAnswers = $this->correct_answers + $this->incorrect_answers;
        
        if ($totalAnswers === 0) {
            return 0;
        }
        
        return round(($this->correct_answers / $totalAnswers) * 100, 2);
    }

    /**
     * Mettre à jour les statistiques après un quiz
     */
    public function updateAfterQuiz(int $points, int $correctAnswers, int $totalQuestions, int $timeSpentMinutes): void
    {
        $this->total_points += $points;
        $this->quizzes_completed += 1;
        $this->correct_answers += $correctAnswers;
        $this->incorrect_answers += ($totalQuestions - $correctAnswers);
        $this->success_rate = $this->calculateSuccessRate();
        $this->total_time_spent += $timeSpentMinutes;
        
        // Mettre à jour la série actuelle
        $this->current_streak += 1;
        if ($this->current_streak > $this->best_streak) {
            $this->best_streak = $this->current_streak;
        }
        
        $this->save();
    }

    /**
     * Réinitialiser la série (en cas d'échec)
     */
    public function resetStreak(): void
    {
        $this->current_streak = 0;
        $this->save();
    }

    /**
     * Mettre à jour la progression d'une phase
     */
    public function updatePhaseProgress(string $phaseName, int $progress, int $points): void
    {
        $phasesProgress = $this->phases_progress ?? [];
        
        $phasesProgress[$phaseName] = [
            'progress' => $progress,
            'points' => $points,
            'updated_at' => now()->toISOString(),
        ];
        
        $this->phases_progress = $phasesProgress;
        $this->save();
    }

    /**
     * Récupérer la progression d'une phase spécifique
     */
    public function getPhaseProgress(string $phaseName): ?array
    {
        return $this->phases_progress[$phaseName] ?? null;
    }

    /**
     * Statistiques formatées pour l'API
     */
    public function toApiFormat(): array
    {
        return [
            'user' => [
                'id' => $this->user->id,
                'name' => $this->user->name,
                'email' => $this->user->email,
                'role' => $this->user->role,
            ],
            'statistics' => [
                'total_points' => $this->total_points,
                'quizzes_completed' => $this->quizzes_completed,
                'correct_answers' => $this->correct_answers,
                'incorrect_answers' => $this->incorrect_answers,
                'success_rate' => (float) $this->success_rate,
                'current_streak' => $this->current_streak,
                'best_streak' => $this->best_streak,
                'total_time_spent' => $this->total_time_spent,
                'average_score' => $this->quizzes_completed > 0 
                    ? round($this->total_points / $this->quizzes_completed, 2) 
                    : 0,
            ],
            'phases_progress' => $this->formatPhasesProgress(),
            'rank' => $this->calculateRank(),
            'level' => $this->calculateLevel(),
        ];
    }

    /**
     * Formater la progression des phases pour l'API
     */
    private function formatPhasesProgress(): array
    {
        $phases = $this->phases_progress ?? [];
        $formatted = [];
        
        foreach ($phases as $phaseName => $progress) {
            $formatted[] = [
                'phase' => $phaseName,
                'progress' => $progress['progress'] ?? 0,
                'points' => $progress['points'] ?? 0,
                'updated_at' => $progress['updated_at'] ?? null,
            ];
        }
        
        return $formatted;
    }

    /**
     * Calculer le rang de l'utilisateur
     */
    private function calculateRank(): string
    {
        $points = $this->total_points;
        
        if ($points >= 2000) return 'Expert';
        if ($points >= 1000) return 'Avancé';
        if ($points >= 500) return 'Intermédiaire';
        if ($points >= 100) return 'Débutant';
        
        return 'Nouveau';
    }

    /**
     * Calculer le niveau basé sur les points
     */
    private function calculateLevel(): int
    {
        return (int) ($this->total_points / 100) + 1;
    }
}