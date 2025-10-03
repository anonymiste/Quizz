<?php

use App\Enums\QuestionType;
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
        Schema::create('questions', function (Blueprint $table) {
        $table->id();
        $table->foreignId('quizz_id')->constrained()->onDelete('cascade');
        $table->text('text');
        $table->json('options'); // Stocke les options sous forme de JSON
        $table->integer('correct_answer_index'); // Index de la bonne réponse
        $table->text('explanation')->nullable();
        $table->text('code_snippet')->nullable();
        $table->enum('type', QuestionType::values())->default(QuestionType::MULTIPLE_CHOICE->value);
        $table->integer('points')->default(10);
        $table->integer('time_limit')->nullable(); // en secondes
        $table->integer('order')->default(0);
        $table->timestamps();

        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('questions');
    }
};
