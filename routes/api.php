<?php

use App\Http\Controllers\Auth\AuthController;
use App\Http\Controllers\Api\Admin\AdminController;
use App\Http\Controllers\Api\PhaseController;
use App\Http\Controllers\Api\QuestionController;
use App\Http\Controllers\Api\QuizzController;
use App\Http\Controllers\Api\ReponseController;
use App\Http\Controllers\Api\StatisticsController;
use App\Http\Controllers\Api\TeacherCoursController;
use App\Http\Controllers\Api\TeacherQuizzController;
use App\Http\Controllers\Api\ThemeController;
use Illuminate\Support\Facades\Route;

Route::get('/login', function () {
    return response()->json(['message' => 'Please log in.'], 401);
})->name('login');

Route::prefix('auth')->group(function () {
    Route::post('/login', [AuthController::class, 'login']);
    

    Route::post('/logout/{id}', [AuthController::class, 'logout'])->middleware('auth:sanctum');
    Route::post('/me', [AuthController::class, 'me']);
    Route::put('/profile/{id}', [AuthController::class, 'update'])->middleware('auth:sanctum');
    Route::delete('/profile/{id}', [AuthController::class, 'delete'])->middleware('auth:sanctum');
});
Route::middleware('auth:sanctum')->group(function () {
    Route::apiResource('phases', PhaseController::class);
    Route::apiResource('themes', ThemeController::class);
    Route::apiResource('questions', QuestionController::class);
    Route::apiResource('reponses', ReponseController::class);

    Route::get('/phases/level/{level}', [PhaseController::class, 'byLevel']);
    Route::get('/users/{userId}/phases', [PhaseController::class, 'byUser']);

    Route::get('/phases/{phase}/themes', [ThemeController::class, 'themeByPhase']);
    Route::get('/themes/{theme}/questions', [QuestionController::class, 'questionsByTheme']);
    Route::get('/questions/{question}/reponses', [ReponseController::class, 'questionResponses']);
    
    Route::get('/statistics/leaderboard', [StatisticsController::class, 'getLeaderboard']);
    
    Route::get('/quizzes', [QuizzController::class, 'index']);
    Route::get('/quizzes/{id}', [QuizzController::class, 'show']);
    Route::post('/quizzes/{id}/submit', [QuizzController::class, 'submit']);

    Route::get('/statistics/{userId}', [StatisticsController::class, 'getUserStatistics']);
    Route::get('/statistics/leaderboard', [StatisticsController::class, 'getLeaderboard']);
    Route::post('/statistics/update-quiz', [StatisticsController::class, 'updateAfterQuiz']);
    
    // Statistiques admin (protégées)
    Route::middleware('admin')->group(function () {
        Route::get('/admin/statistics', [StatisticsController::class, 'getAdminStatistics']);
        Route::post('/admin/statistics/reset/{userId}', [StatisticsController::class, 'resetUserStatistics']);
    });


    Route::prefix('admin')->group(function () {
        // Dashboard
        Route::get('/dashboard-stats', [AdminController::class, 'getDashboardStats']);
        Route::get('/system-analytics', [AdminController::class, 'getSystemAnalytics']);

        // Gestion utilisateurs
        Route::get('/users', [AdminController::class, 'getUsers']);
        Route::post('/users', [AdminController::class, 'createUser']);
        Route::put('/users/{userId}', [AdminController::class, 'updateUser']);
        Route::delete('/users/{userId}', [AdminController::class, 'deleteUser']);

        // Gestion quizzes
        Route::get('/quizzes', [AdminController::class, 'getQuizzes']);
     });
});


Route::middleware(['auth:sanctum'])->group(function () {
    
    // Routes pour les quiz du teacher
    Route::get('/teachers/{teacher}/quizzes', [TeacherQuizzController::class, 'getTeacherQuizzes']);
    Route::get('/quizzes/{quiz}/statistics', [TeacherQuizzController::class, 'statistics']);
    Route::post('/quizzes/{quiz}/duplicate', [TeacherQuizzController::class, 'duplicate']);
    
    // Routes CRUD pour les quiz
    Route::apiResource('quizzes', TeacherQuizzController::class)->except(['show']);
    Route::patch('/quizzes/{quiz}', [TeacherQuizzController::class, 'updateStatus']);
    
    // Routes pour les "cours" (phases) du teacher
    Route::get('/teachers/{teacher}/courses', [TeacherCoursController::class, 'getTeacherCourses']);
    Route::get('/courses/{course}/statistics', [TeacherCoursController::class, 'statistics']);
    Route::patch('/courses/{course}/status', [TeacherCoursController::class, 'updateStatus']);
    Route::post('/courses/{course}/quizzes', [TeacherCoursController::class, 'assignQuiz']);
    
    // Routes CRUD pour les cours
    Route::apiResource('courses', TeacherCoursController::class)->except(['show']);
    Route::patch('/courses/{course}', [TeacherCoursController::class, 'updateStatus']);
});

