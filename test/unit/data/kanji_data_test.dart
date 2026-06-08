import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nihongo/data/models/kanji_word.dart';

void main() {
  group('kanji.json データ整合性テスト', () {
    late Map<String, dynamic> jsonData;

    setUpAll(() {
      final file = File('assets/data/kanji.json');
      jsonData = json.decode(file.readAsStringSync()) as Map<String, dynamic>;
    });

    test('data_versionが定義されている', () {
      expect(jsonData['data_version'], isA<int>());
      expect(jsonData['data_version'], greaterThanOrEqualTo(3));
    });

    test('すべての漢字語がKanjiWordモデルにパースできる', () {
      final words = (jsonData['kanji_words'] as List)
          .map((w) => KanjiWord.fromJson(w as Map<String, dynamic>))
          .toList();
      expect(words, hasLength(100));
    });

    test('漢字語IDに重複がない', () {
      final ids = (jsonData['kanji_words'] as List)
          .map((w) => (w as Map<String, dynamic>)['id'])
          .toList();
      expect(ids.toSet().length, ids.length);
    });

    test('表示語に重複がない', () {
      final words = (jsonData['kanji_words'] as List)
          .map((w) => (w as Map<String, dynamic>)['word'])
          .toList();
      expect(words.toSet().length, words.length);
    });

    test('すべてのカテゴリキーが定義済みカテゴリを参照している', () {
      final validKeys = KanjiCategory.all.map((c) => c.key).toSet();
      for (final w in jsonData['kanji_words'] as List) {
        final word = w as Map<String, dynamic>;
        expect(validKeys, contains(word['category']),
            reason: '漢字語ID ${word['id']} のカテゴリキーが不正です');
      }
    });

    test('各カテゴリに20語ずつ収録されている', () {
      final counts = <String, int>{};
      for (final w in jsonData['kanji_words'] as List) {
        final category = (w as Map<String, dynamic>)['category'] as String;
        counts[category] = (counts[category] ?? 0) + 1;
      }
      for (final category in KanjiCategory.all) {
        expect(counts[category.key], 20,
            reason: 'カテゴリ ${category.key} の語数が20ではありません');
      }
    });

    test('単漢字辞書: すべての収録語の構成漢字を網羅している', () {
      final characters = (jsonData['kanji_characters'] as List)
          .cast<Map<String, dynamic>>();
      final provided =
          characters.map((c) => c['character'] as String).toSet();

      // 漢字の重複なし
      expect(provided.length, characters.length);

      // 全語の構成漢字をカバー
      final kanjiPattern = RegExp(r'[一-鿿]');
      for (final w in jsonData['kanji_words'] as List) {
        final word = (w as Map<String, dynamic>)['word'] as String;
        for (final ch in word.split('')) {
          if (kanjiPattern.hasMatch(ch)) {
            expect(provided.contains(ch), isTrue,
                reason: '「$word」の構成漢字「$ch」が単漢字辞書にありません');
          }
        }
      }
    });

    test('単漢字辞書: 全エントリがkanji_dictパックで、読みと意味を持つ', () {
      final characters = (jsonData['kanji_characters'] as List)
          .cast<Map<String, dynamic>>();
      expect(characters, isNotEmpty);

      for (final c in characters) {
        expect(c['pack_id'], 'kanji_dict',
            reason: '「${c['character']}」のpack_idが不正です');
        final on = (c['on_readings'] as String? ?? '');
        final kun = (c['kun_readings'] as String? ?? '');
        expect(on.isNotEmpty || kun.isNotEmpty, isTrue,
            reason: '「${c['character']}」に読みが1つもありません');
        expect((c['meaning_id'] as String).trim().isNotEmpty, isTrue,
            reason: '「${c['character']}」の意味が空です');
      }
    });

    test('すべての漢字語に読み・ローマ字・説明（両言語）が設定されている', () {
      for (final w in jsonData['kanji_words'] as List) {
        final word = w as Map<String, dynamic>;
        expect((word['reading'] as String).isNotEmpty, isTrue,
            reason: '漢字語ID ${word['id']} の読みが空です');
        expect((word['romaji'] as String).isNotEmpty, isTrue,
            reason: '漢字語ID ${word['id']} のローマ字が空です');
        expect((word['indonesian'] as String).isNotEmpty, isTrue,
            reason: '漢字語ID ${word['id']} のインドネシア語訳が空です');
        expect(word['description_ja'], isNotNull,
            reason: '漢字語ID ${word['id']} の日本語説明がありません');
        expect(word['description_id'], isNotNull,
            reason: '漢字語ID ${word['id']} のインドネシア語説明がありません');
      }
    });
  });
}
