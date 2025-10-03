<?php

namespace App\Enums;

enum UserRole: string
{
    case ADMIN = 'admin';
    case TEACHER = 'teacher';
    case STUDENT = 'student';
    case USER = 'user';

    public static function values(): array
    {
        return array_column(self::cases(), 'value');
    }

    public static function toArray(): array
    {
        return [
            'admin' => 'Administrateur',
            'teacher' => 'Enseignant',
            'student' => 'Étudiant',
            'user' => 'Utilisateur',
        ];
    }
}