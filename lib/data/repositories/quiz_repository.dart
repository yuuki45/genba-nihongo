import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/quiz.dart';
import '../datasources/local/database_helper.dart';

/// クイズリポジトリ
/// データソース（JSON、DB）からクイズデータを取得・管理
class QuizRepository {
  final DatabaseHelper _dbHelper;

  QuizRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  /// JSONファイルからクイズ初期データをロード
  Future<void> loadInitialQuizData() async {
    try {
      // JSONファイルを読み込み
      final String jsonString =
          await rootBundle.loadString('assets/data/quizzes.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      // クイズをDBに挿入
      final List<dynamic> quizzesJson = jsonData['quizzes'];
      for (var quizJson in quizzesJson) {
        final quiz = Quiz.fromJson(quizJson);
        await _dbHelper.insertQuiz(quiz.toMap());
      }
    } catch (e) {
      throw Exception('クイズデータのロードに失敗しました: $e');
    }
  }

  /// クイズデータが既にロードされているか確認
  Future<bool> isQuizDataLoaded() async {
    final quizzes = await _dbHelper.getAllQuizzes();
    return quizzes.isNotEmpty;
  }

  /// すべてのクイズを取得
  Future<List<Quiz>> getAllQuizzes() async {
    final quizMaps = await _dbHelper.getAllQuizzes();
    return quizMaps.map((map) => Quiz.fromMap(map)).toList();
  }

  /// JLPTレベルでクイズを取得
  Future<List<Quiz>> getQuizzesByJlptLevel(String jlptLevel) async {
    final quizMaps = await _dbHelper.getQuizzesByJlptLevel(jlptLevel);
    return quizMaps.map((map) => Quiz.fromMap(map)).toList();
  }

  /// カテゴリでクイズを取得
  Future<List<Quiz>> getQuizzesByCategory(String category) async {
    final quizMaps = await _dbHelper.getQuizzesByCategory(category);
    return quizMaps.map((map) => Quiz.fromMap(map)).toList();
  }

  /// ランダムにN件のクイズを取得
  Future<List<Quiz>> getRandomQuizzes(int count, String jlptLevel) async {
    final quizMaps = await _dbHelper.getRandomQuizzes(count, jlptLevel);
    return quizMaps.map((map) => Quiz.fromMap(map)).toList();
  }

  /// IDでクイズを取得
  Future<Quiz?> getQuizById(int id) async {
    final quizMap = await _dbHelper.getQuizById(id);
    return quizMap != null ? Quiz.fromMap(quizMap) : null;
  }

  /// クイズ結果を保存
  Future<void> saveQuizResult(QuizResult result) async {
    await _dbHelper.saveQuizResult(result.toMap());
  }

  /// すべてのクイズ結果を取得
  Future<List<QuizResult>> getAllQuizResults() async {
    final resultMaps = await _dbHelper.getAllQuizResults();
    return resultMaps.map((map) => QuizResult.fromMap(map)).toList();
  }

  /// 特定のクイズの結果を取得
  Future<List<QuizResult>> getQuizResultsByQuizId(int quizId) async {
    final resultMaps = await _dbHelper.getQuizResultsByQuizId(quizId);
    return resultMaps.map((map) => QuizResult.fromMap(map)).toList();
  }

  /// クイズの統計情報を取得
  Future<Map<String, int>> getQuizStatistics() async {
    return await _dbHelper.getQuizStatistics();
  }

  /// クイズの正解率を計算
  Future<double> getAccuracyRate() async {
    final stats = await getQuizStatistics();
    final total = stats['total'] ?? 0;
    final correct = stats['correct'] ?? 0;

    if (total == 0) return 0.0;
    return (correct / total) * 100;
  }
}
