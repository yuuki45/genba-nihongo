import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nihongo/data/models/category.dart' as model;
import 'package:nihongo/data/models/phrase.dart';
import 'package:nihongo/data/models/phrase_scene.dart';

void main() {
  group('phrases.json データ整合性テスト', () {
    late Map<String, dynamic> jsonData;

    setUpAll(() {
      final file = File('assets/data/phrases.json');
      jsonData = json.decode(file.readAsStringSync()) as Map<String, dynamic>;
    });

    test('data_versionが定義されている', () {
      expect(jsonData['data_version'], isA<int>());
      expect(jsonData['data_version'], greaterThanOrEqualTo(4));
    });

    test('すべてのカテゴリがCategoryモデルにパースできる', () {
      final categories = (jsonData['categories'] as List)
          .map((c) => model.Category.fromJson(c as Map<String, dynamic>))
          .toList();
      expect(categories, hasLength(6));
    });

    test('すべてのフレーズがPhraseモデルにパースできる', () {
      final phrases = (jsonData['phrases'] as List)
          .map((p) => Phrase.fromJson(p as Map<String, dynamic>))
          .toList();
      expect(phrases, hasLength(429));
    });

    test('pack_idはnullまたはkaigoのみ', () {
      final packIds = (jsonData['phrases'] as List)
          .map((p) => (p as Map<String, dynamic>)['pack_id'])
          .toSet();
      expect(packIds, {null, 'kaigo'});
    });

    test('介護パックは100件で、すべてカテゴリ6に属する', () {
      final kaigo = (jsonData['phrases'] as List)
          .where((p) => (p as Map<String, dynamic>)['pack_id'] == 'kaigo')
          .cast<Map<String, dynamic>>()
          .toList();
      expect(kaigo, hasLength(100));
      expect(kaigo.every((p) => p['category_id'] == 6), isTrue);
    });

    test('カテゴリ6（介護）のフレーズはすべて有料パックに属する', () {
      // 無料フレーズが混ざるとカテゴリロック表示が崩れるため
      final category6Free = (jsonData['phrases'] as List)
          .cast<Map<String, dynamic>>()
          .where((p) => p['category_id'] == 6 && p['pack_id'] == null)
          .toList();
      expect(category6Free, isEmpty);
    });

    test('フレーズIDに重複がない', () {
      final ids = (jsonData['phrases'] as List)
          .map((p) => (p as Map<String, dynamic>)['id'])
          .toList();
      expect(ids.toSet().length, ids.length);
    });

    test('日本語テキストに重複フレーズがない', () {
      final seen = <String, int>{};
      for (final p in jsonData['phrases'] as List) {
        final phrase = p as Map<String, dynamic>;
        final japanese = phrase['japanese'] as String;
        expect(seen.containsKey(japanese), isFalse,
            reason:
                '「$japanese」が重複しています (id ${seen[japanese]} と id ${phrase['id']})');
        seen[japanese] = phrase['id'] as int;
      }
    });

    test('JLPTレベルはN5〜N2のいずれかである', () {
      const validLevels = {'N5', 'N4', 'N3', 'N2'};
      final phrases = (jsonData['phrases'] as List)
          .map((p) => Phrase.fromJson(p as Map<String, dynamic>))
          .toList();
      for (final phrase in phrases) {
        expect(validLevels, contains(phrase.jlptLevel),
            reason: 'フレーズID ${phrase.id} のJLPTレベルが不正です');
      }
    });

    test('無料のN2フレーズが49件存在する', () {
      final n2Count = (jsonData['phrases'] as List)
          .cast<Map<String, dynamic>>()
          .where((p) => p['jlpt_level'] == 'N2' && p['pack_id'] == null)
          .length;
      expect(n2Count, 49);
    });

    test('全カテゴリがちょうど1つのシーンに属する', () {
      final categoryIds = (jsonData['categories'] as List)
          .map((c) => (c as Map<String, dynamic>)['id'] as int)
          .toSet();

      final sceneCategoryIds = <int>[];
      for (final scene in PhraseScene.all) {
        sceneCategoryIds.addAll(scene.categoryIds);
      }

      // 複数シーンへの重複割当なし
      expect(sceneCategoryIds.toSet().length, sceneCategoryIds.length,
          reason: '複数のシーンに重複して割り当てられたカテゴリがあります');
      // 未割当・存在しないカテゴリなし
      expect(sceneCategoryIds.toSet(), categoryIds,
          reason: 'シーン未割当、または存在しないカテゴリIDがあります');
    });

    test('すべてのフレーズのカテゴリIDが存在するカテゴリを参照している', () {
      final categoryIds = (jsonData['categories'] as List)
          .map((c) => (c as Map<String, dynamic>)['id'])
          .toSet();
      for (final p in jsonData['phrases'] as List) {
        final phrase = p as Map<String, dynamic>;
        expect(categoryIds, contains(phrase['category_id']),
            reason: 'フレーズID ${phrase['id']} のカテゴリIDが不正です');
      }
    });
  });
}
