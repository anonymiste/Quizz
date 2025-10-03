<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Quizz extends Model
{
    use HasFactory;

    protected $table = 'user_quizzes';

    protected $fillable = [
        'title',
        'description',
        'category',
        'difficulty',
        'time_limit',
        'is_published',
        'user_id',
        'tags',
        'participants_count',
        'rating',
    ];

    protected $casts = [
        'tags' => 'array',
        'is_published' => 'boolean',
    ];

    // Relations
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function questions()
    {
        return $this->hasMany(Question::class);
    }

    public function attempts()
    {
        return $this->hasMany(UserQuizzAttempt::class);
    }

    // Scopes
    public function scopePublished($query)
    {
        return $query->where('is_published', true);
    }

    public function scopeByCategory($query, $category)
    {
        return $query->where('category', $category);
    }

    public function scopeByDifficulty($query, $difficulty)
    {
        return $query->where('difficulty', $difficulty);
    }

    // Accessors
    public function getQuestionCountAttribute()
    {
        return $this->questions()->count();
    }

    public function getEstimatedTimeAttribute()
    {
        return $this->time_limit . ' min';
    }

    // Méthodes
    public function incrementParticipants()
    {
        $this->increment('participants_count');
    }

    public function updateRating($newRating)
    {
        $currentTotal = $this->rating * max(1, $this->participants_count - 1);
        $this->rating = ($currentTotal + $newRating) / $this->participants_count;
        $this->save();
    }

}
