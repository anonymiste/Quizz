<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('quizz_statistics', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            
            // Statistiques globales
            $table->integer('total_points')->default(0);
            $table->integer('quizzes_completed')->default(0);
            $table->integer('correct_answers')->default(0);
            $table->integer('incorrect_answers')->default(0);
            $table->decimal('success_rate', 5, 2)->default(0);
            $table->integer('current_streak')->default(0);
            $table->integer('best_streak')->default(0);
            $table->integer('total_time_spent')->default(0);
            
            // Progression par phase
            $table->json('phases_progress')->nullable(); 
            
            // Timestamps
            $table->timestamps();
            
            // Index pour les performances
            $table->index('user_id');
            $table->index('total_points');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('quizz_statistics');
    }
};