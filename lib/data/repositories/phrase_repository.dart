import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/phrase.dart';
import '../models/category.dart';
import '../datasources/local/database_helper.dart';

/// フレーズリポジトリ
/// データソース（JSON、DB）からフレーズデータを取得・管理
class PhraseRepository {
  final DatabaseHelper _dbHelper;

  /// データバージョンを保存する設定キー
  static const String _dataVersionKey = 'data_version';

  PhraseRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  /// JSONファイルから初期データをロード
  Future<void> loadInitialData() async {
    try {
      final jsonData = await _loadJsonData();

      // カテゴリをDBに挿入
      final List<dynamic> categoriesJson = jsonData['categories'];
      for (var categoryJson in categoriesJson) {
        final category = Category.fromJson(categoryJson);
        await _dbHelper.insertCategory(category.toMap());
      }

      // フレーズをDBに挿入
      final List<dynamic> phrasesJson = jsonData['phrases'];
      for (var phraseJson in phrasesJson) {
        final phrase = Phrase.fromJson(phraseJson);
        await _dbHelper.insertPhrase(phrase.toMap());
      }

      // ロードしたデータバージョンを保存
      await _dbHelper.saveSetting(
        _dataVersionKey,
        _jsonDataVersion(jsonData).toString(),
      );
    } catch (e) {
      throw Exception('初期データのロードに失敗しました: $e');
    }
  }

  /// JSONのデータバージョンがDBより新しい場合のみ、データを同期する
  ///
  /// アプリ更新でフレーズが追加された際、既存ユーザーのDBにも
  /// 新しいフレーズを反映するために起動時に呼び出す。
  /// お気に入り（favorites）はphrasesと別テーブルのため影響を受けない。
  Future<void> syncDataIfNeeded() async {
    try {
      final jsonData = await _loadJsonData();
      final jsonVersion = _jsonDataVersion(jsonData);

      final storedVersionStr = await _dbHelper.getSetting(_dataVersionKey);
      final storedVersion = int.tryParse(storedVersionStr ?? '') ?? 1;

      if (jsonVersion <= storedVersion) return;

      // カテゴリを同期（既存IDは置き換え、新規IDは追加）
      final List<dynamic> categoriesJson = jsonData['categories'];
      for (var categoryJson in categoriesJson) {
        final category = Category.fromJson(categoryJson);
        await _dbHelper.upsertCategory(category.toMap());
      }

      // フレーズを同期（既存IDは置き換え、新規IDは追加）
      final List<dynamic> phrasesJson = jsonData['phrases'];
      for (var phraseJson in phrasesJson) {
        final phrase = Phrase.fromJson(phraseJson);
        await _dbHelper.upsertPhrase(phrase.toMap());
      }

      // JSONから削除されたフレーズをDBからも削除（お気に入りも連動）
      final jsonIds = phrasesJson
          .map((p) => (p as Map<String, dynamic>)['id'] as int)
          .toList();
      await _dbHelper.deletePhrasesNotIn(jsonIds);

      await _dbHelper.saveSetting(_dataVersionKey, jsonVersion.toString());
    } catch (e) {
      throw Exception('データの同期に失敗しました: $e');
    }
  }

  /// アセットのJSONデータを読み込む
  Future<Map<String, dynamic>> _loadJsonData() async {
    final String jsonString =
        await rootBundle.loadString('assets/data/phrases.json');
    return json.decode(jsonString) as Map<String, dynamic>;
  }

  /// JSONデータのバージョンを取得（未定義の場合は1）
  int _jsonDataVersion(Map<String, dynamic> jsonData) {
    return jsonData['data_version'] as int? ?? 1;
  }

  /// データが既にロードされているか確認
  Future<bool> isDataLoaded() async {
    final phrases = await _dbHelper.getAllPhrases();
    return phrases.isNotEmpty;
  }

  /// データベースを削除して再初期化（開発用）
  Future<void> resetDatabase() async {
    await _dbHelper.deleteDatabase();
    await loadInitialData();
  }

  /// すべてのフレーズを取得
  Future<List<Phrase>> getAllPhrases() async {
    final phraseMaps = await _dbHelper.getAllPhrases();
    return phraseMaps.map((map) => Phrase.fromMap(map)).toList();
  }

  /// カテゴリIDでフレーズを取得
  Future<List<Phrase>> getPhrasesByCategory(int categoryId) async {
    final phraseMaps = await _dbHelper.getPhrasesByCategory(categoryId);
    return phraseMaps.map((map) => Phrase.fromMap(map)).toList();
  }

  /// IDでフレーズを取得
  Future<Phrase?> getPhraseById(int id) async {
    final phraseMap = await _dbHelper.getPhraseById(id);
    return phraseMap != null ? Phrase.fromMap(phraseMap) : null;
  }

  /// ランダムにN件のフレーズを取得
  Future<List<Phrase>> getRandomPhrases(int count) async {
    final phraseMaps = await _dbHelper.getRandomPhrases(count);
    return phraseMaps.map((map) => Phrase.fromMap(map)).toList();
  }

  /// フレーズを検索
  Future<List<Phrase>> searchPhrases(String query) async {
    final phraseMaps = await _dbHelper.searchPhrases(query);
    return phraseMaps.map((map) => Phrase.fromMap(map)).toList();
  }

  /// すべてのカテゴリを取得
  Future<List<Category>> getAllCategories() async {
    final categoryMaps = await _dbHelper.getAllCategories();
    return categoryMaps.map((map) => Category.fromMap(map)).toList();
  }

  /// IDでカテゴリを取得
  Future<Category?> getCategoryById(int id) async {
    final categoryMap = await _dbHelper.getCategoryById(id);
    return categoryMap != null ? Category.fromMap(categoryMap) : null;
  }

  /// お気に入りフレーズを取得
  Future<List<Phrase>> getFavoritePhrases() async {
    final phraseMaps = await _dbHelper.getFavoritePhrases();
    return phraseMaps.map((map) => Phrase.fromMap(map)).toList();
  }

  /// お気に入りに追加
  Future<void> addFavorite(int phraseId) async {
    await _dbHelper.addFavorite(phraseId);
  }

  /// お気に入りから削除
  Future<void> removeFavorite(int phraseId) async {
    await _dbHelper.removeFavorite(phraseId);
  }

  /// お気に入りかどうか確認
  Future<bool> isFavorite(int phraseId) async {
    return await _dbHelper.isFavorite(phraseId);
  }
}
