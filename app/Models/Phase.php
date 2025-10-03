<?php

namespace App\Models;

use App\Enums\PhaseLevel;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Phase extends Model
{
    protected $fillable = [
        'title',
        'level',
        'category',
        'status',
        'average',
        'user_id',
    ];

    protected $casts = [
        'level' => PhaseLevel::class,
    ];

    public function themes() : HasMany
    {
        return $this->hasMany(Theme::class);
    }
    public function user() : BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
