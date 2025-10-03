<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class UserQuizzAttempt extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'quiz_id',
        'score',
        'time_spent',
        'answers',
        'completed_at',
    ];

    protected $casts = [
        'answers' => 'array',
        'completed_at' => 'datetime',
    ];

    // Relations
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function quiz()
    {
        return $this->belongsTo(Quizz::class);
    }

    // Scopes
    public function scopeCompleted($query)
    {
        return $query->whereNotNull('completed_at');
    }

    public function scopeBestScores($query)
    {
        return $query->whereIn('id', function($query) {
            $query->selectRaw('MAX(id)')
                  ->from('user_quiz_attempts')
                  ->groupBy(['user_id', 'quiz_id']);
        });
    }

    // Méthodes
    public function markAsCompleted()
    {
        $this->completed_at = now();
        $this->save();
    }

    public function isPassed($passingScore = 60)
    {
        return $this->score >= $passingScore;
    }
}