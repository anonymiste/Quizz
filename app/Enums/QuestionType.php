<?php

namespace App\Enums;

enum QuestionType: string
{
    case MULTIPLE_CHOICE = 'multiple_choice';
    case TRUE_FALSE = 'true_false';
    case CODE = 'code';
    case PRATICAL = 'practical';

    public function label(): string
    {
        return match($this) {
            self::MULTIPLE_CHOICE => "Question à choix multiples",
            self::TRUE_FALSE => "Vraie ou faux",
            self::CODE => "Code",
            self::PRATICAL => "Pratique"
        };
    }

    public static function values(): array
    {
        return array_column(self::cases(), 'value');
    }
}
