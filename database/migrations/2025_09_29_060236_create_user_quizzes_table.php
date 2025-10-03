<?php

use App\Enums\QuizzCategory;
use App\Enums\QuizzDifficulty;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('user_quizzes', function (Blueprint $table) {
             $table->id();
            $table->string('title');
            $table->text('description')->nullable();
            $table->enum('category', QuizzCategory::values());
            $table->enum('difficulty', QuizzDifficulty::values());
            $table->integer('time_limit')->default(30); // en minutes
            $table->boolean('is_published')->default(false);
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->json('tags')->nullable();
            $table->integer('participants_count')->default(0);
            $table->float('rating')->default(0);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('user_quizzes');
    }
};
