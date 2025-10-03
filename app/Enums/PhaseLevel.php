<?php

namespace App\Enums;

enum PhaseLevel: string
{
    case UNDEFINED = 'undefined';
    case EASY = 'easy';
    case MEDIUM = 'medium';
    case HARD = 'hard';

    public function label(): string
    {
        return match($this) {
            self::UNDEFINED => "Indefinie",
            self::EASY => "Facile",
            self::MEDIUM => "Moyen",
            self::HARD => "Difficile"
        };
    }
    public function color(): string
    {
        return match($this) {
            self::UNDEFINED  => "grey",
            self::EASY => "green",
            self::MEDIUM => "yellow",
            self::HARD => "red"
        };
    }

    public static function values(): array
    {
        return array_column(self::cases(), 'value');
    }
}
