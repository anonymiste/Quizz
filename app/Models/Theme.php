<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Theme extends Model
{
     protected $fillable = [
        'title',
        'score',
        'phase_id',
    ];

    public function phase() : BelongsTo
    {
        return $this->belongsTo(Phase::class);
    }

    public function questions() : HasMany
    {
        return $this->hasMany(Phase::class);
    }
}
