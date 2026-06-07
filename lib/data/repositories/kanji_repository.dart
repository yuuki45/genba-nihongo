import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/kanji_character.dart';
import '../models/kanji_word.dart';
import '../datasources/local/database_helper.dart';

/// 漢字語リポジトリ
/// データソース（JSON、DB）から現場の漢字データを取得・管理
class KanjiRepository {
  final DatabaseHelper _dbHelper;

  /// 漢字データバージョンを保存する設定キー
  static const String _dataVersionKey = 'kanji_data_version';

  KanjiRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  /// JSONのデータバージョンがDBより新しい場合のみ、データを同期する
  ///
  /// 初回起動時（DBが空・保存バージョンなし）も含めて、
  /// 起動時に毎回呼び出すだけで初期ロードと差分同期の両方を担う。
  /// 苦手漢字（kanji_favorites）は別テーブルのため影響を受けない。
  Future<void> syncDataIfNeeded() async {
    try {
      final jsonData = await _loadJsonData();
      final jsonVersion = jsonData['data_version'] as int? ?? 1;

      final storedVersionStr = await _dbHelper.getSetting(_dataVersionKey);
      final storedVersion = int.tryParse(storedVersionStr ?? '') ?? 0;

      if (jsonVersion <= storedVersion) return;

      // 漢字語を同期（既存IDは置き換え、新規IDは追加）
      final List<dynamic> kanjiWordsJson = jsonData['kanji_words'];
      for (var kanjiWordJson in kanjiWordsJson) {
        final kanjiWord = KanjiWord.fromJson(kanjiWordJson);
        await _dbHelper.upsertKanjiWord(kanjiWord.toMap());
      }

      // 単漢字辞書を同期（漢字辞書パック）
      final List<dynamic> charactersJson =
          jsonData['kanji_characters'] as List<dynamic>? ?? [];
      for (var characterJson in charactersJson) {
        final character = KanjiCharacter.fromJson(characterJson);
        await _dbHelper.upsertKanjiCharacter(character.toMap());
      }

      await _dbHelper.saveSetting(_dataVersionKey, jsonVersion.toString());
    } catch (e) {
      throw Exception('漢字データの同期に失敗しました: $e');
    }
  }

  /// アセットのJSONデータを読み込む
  Future<Map<String, dynamic>> _loadJsonData() async {
    final String jsonString =
        await rootBundle.loadString('assets/data/kanji.json');
    return json.decode(jsonString) as Map<String, dynamic>;
  }

  /// すべての漢字語を取得
  Future<List<KanjiWord>> getAllKanjiWords() async {
    final maps = await _dbHelper.getAllKanjiWords();
    return maps.map((map) => KanjiWord.fromMap(map)).toList();
  }

  /// カテゴリで漢字語を取得
  Future<List<KanjiWord>> getKanjiWordsByCategory(String category) async {
    final maps = await _dbHelper.getKanjiWordsByCategory(category);
    return maps.map((map) => KanjiWord.fromMap(map)).toList();
  }

  /// ランダムにN件の漢字語を取得
  Future<List<KanjiWord>> getRandomKanjiWords(int count) async {
    final maps = await _dbHelper.getRandomKanjiWords(count);
    return maps.map((map) => KanjiWord.fromMap(map)).toList();
  }

  /// 漢字語を検索
  Future<List<KanjiWord>> searchKanjiWords(String query) async {
    final maps = await _dbHelper.searchKanjiWords(query);
    return maps.map((map) => KanjiWord.fromMap(map)).toList();
  }

  /// すべての単漢字エントリを取得（漢字辞書パック）
  Future<List<KanjiCharacter>> getAllKanjiCharacters() async {
    final maps = await _dbHelper.getAllKanjiCharacters();
    return maps.map((map) => KanjiCharacter.fromMap(map)).toList();
  }

  /// 苦手漢字を取得
  Future<List<KanjiWord>> getFavoriteKanjiWords() async {
    final maps = await _dbHelper.getKanjiFavorites();
    return maps.map((map) => KanjiWord.fromMap(map)).toList();
  }

  /// 苦手漢字に追加
  Future<void> addFavorite(int kanjiWordId) async {
    await _dbHelper.addKanjiFavorite(kanjiWordId);
  }

  /// 苦手漢字から削除
  Future<void> removeFavorite(int kanjiWordId) async {
    await _dbHelper.removeKanjiFavorite(kanjiWordId);
  }

  /// 苦手漢字かどうか確認
  Future<bool> isFavorite(int kanjiWordId) async {
    return await _dbHelper.isKanjiFavorite(kanjiWordId);
  }
}
