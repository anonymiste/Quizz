<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Reponse extends Model
{
    protected $fillable = [
        'body',
        'value',
        'check',
        'question_id',
    ];

    public function question() : BelongsTo
    {
        return $this->belongsTo(Question::class);
    }
}
