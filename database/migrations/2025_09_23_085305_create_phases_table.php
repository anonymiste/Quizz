<?php

use App\Enums\PhaseLevel;
use App\Enums\QuizzCategory;
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
        Schema::create('phases', function (Blueprint $table) {
            $table->id();
            $table->string('title')->unique();
            $table->enum('level',PhaseLevel::values())->default(PhaseLevel::UNDEFINED->value);
            $table->enum('category',QuizzCategory::values())->default(QuizzCategory::PROGRAMMING->value);
            $table->string('status')->default('published');
            $table->integer('average')->nullable()->default('0');
            $table->unsignedBigInteger('user_id');
            $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
            $table->timestamps();
        });
    } 

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('phases');
    }
};
