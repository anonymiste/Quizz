<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Question extends Model
{
    use HasFactory;

    protected $fillable = [
        'quizz_id',
        'text',
        'options',
        'correct_answer_index',
        'explanation',
        'code_snippet',
        'type',
        'points',
        'time_limit',
        'order',
    ];

    protected $casts = [
        'options' => 'array',
    ];

    // Relations
    public function quiz()
    {
        return $this->belongsTo(Quizz::class);
    }

    // Accessors
    public function getCorrectAnswerAttribute()
    {
        return $this->options[$this->correct_answer_index] ?? null;
    }

    public function getHasCodeSnippetAttribute()
    {
        return !empty($this->code_snippet);
    }

    public function getIsTimedAttribute()
    {
        return !is_null($this->time_limit);
    }
}
