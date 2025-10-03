<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('user_statistics', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->integer('total_points')->default(0);
            $table->integer('quizzes_completed')->default(0);
            $table->integer('correct_answers')->default(0);
            $table->integer('incorrect_answers')->default(0);
            $table->decimal('success_rate', 5, 2)->default(0);
            $table->integer('current_streak')->default(0);
            $table->integer('best_streak')->default(0);
            $table->integer('total_time_spent')->default(0); // en minutes
            $table->integer('phases_progress')->nullable()->default(0); // en minutes
            $table->decimal('average_score', 5, 2)->default(0);
            $table->timestamps();

            $table->unique('user_id');
        });
    }

    public function down()
    {
        Schema::dropIfExists('user_statistics');
    }
};