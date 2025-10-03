<?php

namespace App\Enums;

enum QuizzCategory: string
{
    case PROGRAMMING = 'programming';
    case MAINTENANCE = 'maintenance';
    case CYBERSECURITY = 'cybersecurity';
    case NETWORKING = 'networking';
    case DATABASE = 'database';
    case WEB = 'web';
    case MOBILE = 'mobile';
    case CLOUD = 'cloud';
    case AI = 'ai';

    public function label(): string
    {
        return match($this) {
            self::PROGRAMMING => "programmation",
            self::MAINTENANCE => "maintenance",
            self::CYBERSECURITY => "cybersécurité",
            self::NETWORKING => "réseaux",
            self::DATABASE => "base de données",
            self::WEB => "web",
            self::MOBILE => "mobile",
            self::CLOUD => "cloud",
            self::AI => "intelligence artificielle",
        };
    }

    public static function values(): array
    {
        return array_column(self::cases(), 'value');
    }
}