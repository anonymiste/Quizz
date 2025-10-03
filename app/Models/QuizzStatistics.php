<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class QuizzStatistics extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'total_quizzes_completed',
        'average_score',
        'total_correct_answers',
        'total_incorrect_answers',
        'success_rate',
        'current_streak',
        'best_streak',
        'total_time_spent',
        'category_stats',
    ];

    protected $casts = [
        'category_stats' => 'array',
    ];

    // Relations
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    // Méthodes
    public function updateStatistics(UserQuizzAttempt $attempt)
    {
        $this->total_quizzes_completed += 1;
        
        // Mettre à jour la moyenne des scores
        $totalScore = $this->average_score * ($this->total_quizzes_completed - 1) + $attempt->score;
        $this->average_score = $totalScore / $this->total_quizzes_completed;

        // Mettre à jour le streak
        if ($attempt->score >= 60) {
            $this->current_streak += 1;
            $this->best_streak = max($this->best_streak, $this->current_streak);
        } else {
            $this->current_streak = 0;
        }

        // Mettre à jour le temps total
        $this->total_time_spent += $attempt->time_spent / 60; // Conversion en minutes

        $this->save();
    }

    public function getSuccessRateAttribute()
    {
        $total = $this->total_correct_answers + $this->total_incorrect_answers;
        return $total > 0 ? ($this->total_correct_answers / $total) * 100 : 0;
    }
}
