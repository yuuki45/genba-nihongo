import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/quiz.dart';
import '../datasources/local/database_helper.dart';

/// クイズリポジトリ
/// データソース（JSON、DB）からクイズデータを取得・管理
class QuizRepository {
  final DatabaseHelper _dbHelper;

  /// クイズデータバージョンを保存する設定キー
  static const String _dataVersionKey = 'quiz_data_version';

  QuizRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  /// JSONファイルからクイズ初期データをロード
  Future<void> loadInitialQuizData() async {
    try {
      final jsonData = await _loadJsonData();

      // クイズをDBに挿入
      final List<dynamic> quizzesJson = jsonData['quizzes'];
      for (var quizJson in quizzesJson) {
        final quiz = Quiz.fromJson(quizJson);
        await _dbHelper.insertQuiz(quiz.toMap());
      }

      // ロードしたデータバージョンを保存
      await _dbHelper.saveSetting(
        _dataVersionKey,
        _jsonDataVersion(jsonData).toString(),
      );
    } catch (e) {
      throw Exception('クイズデータのロードに失敗しました: $e');
    }
  }

  /// JSONのデータバージョンがDBより新しい場合のみ、クイズを同期する
  ///
  /// 有料パックを含む新規クイズの追加を既存ユーザーのDBにも反映する。
  /// クイズ結果（quiz_results）がクイズIDを参照しているため、削除同期は行わない
  /// （JSONから消す運用はせず、追加・更新のみを想定）。
  Future<void> syncDataIfNeeded() async {
    try {
      final jsonData = await _loadJsonData();
      final jsonVersion = _jsonDataVersion(jsonData);

      final storedVersionStr = await _dbHelper.getSetting(_dataVersionKey);
      final storedVersion = int.tryParse(storedVersionStr ?? '') ?? 0;

      if (jsonVersion <= storedVersion) return;

      // クイズを同期（既存IDは置き換え、新規IDは追加）
      final List<dynamic> quizzesJson = jsonData['quizzes'];
      for (var quizJson in quizzesJson) {
        final quiz = Quiz.fromJson(quizJson);
        await _dbHelper.upsertQuiz(quiz.toMap());
      }

      await _dbHelper.saveSetting(_dataVersionKey, jsonVersion.toString());
    } catch (e) {
      throw Exception('クイズデータの同期に失敗しました: $e');
    }
  }

  /// アセットのJSONデータを読み込む
  Future<Map<String, dynamic>> _loadJsonData() async {
    final String jsonString =
        await rootBundle.loadString('assets/data/quizzes.json');
    return json.decode(jsonString) as Map<String, dynamic>;
  }

  /// JSONデータのバージョンを取得（未定義の場合は1）
  int _jsonDataVersion(Map<String, dynamic> jsonData) {
    return jsonData['data_version'] as int? ?? 1;
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
