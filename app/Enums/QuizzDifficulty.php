<?php

namespace App\Enums;

enum QuizzDifficulty: string
{
    case BEGINNER = 'beginner';
    case INTERMEDIATE = 'intermediate';
    case ADVANCED = 'advanced';
    case EXPERT = 'expert';

    public function label(): string
    {
        return match($this) {
            self::BEGINNER => "Débutant",
            self::INTERMEDIATE => "Intermediaire",
            self::ADVANCED => "Avancé",
            self::EXPERT => "Expert"
        };
    }

    public static function values(): array
    {
        return array_column(self::cases(), 'value');
    }
}
