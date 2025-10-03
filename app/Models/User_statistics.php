<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

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
        'average_score',
    ];

    protected $casts = [
        'success_rate' => 'decimal:2',
        'average_score' => 'decimal:2',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}