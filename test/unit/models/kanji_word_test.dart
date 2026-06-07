import 'package:flutter_test/flutter_test.dart';
import 'package:nihongo/data/models/kanji_word.dart';

void main() {
  group('KanjiWord Model Tests', () {
    final testKanjiWord = KanjiWord(
      id: 1,
      word: '立入禁止',
      reading: 'たちいりきんし',
      romaji: 'Tachiiri kinshi',
      indonesian: 'Dilarang masuk',
      category: 'safety',
      descriptionJa: '入ってはいけない場所の標識',
      descriptionId: 'Rambu area yang tidak boleh dimasuki',
      importance: 3,
      jlptLevel: 'N3',
      createdAt: DateTime.parse('2026-06-06T00:00:00.000Z'),
      updatedAt: DateTime.parse('2026-06-06T00:00:00.000Z'),
    );

    test('KanjiWordモデルが正しく作成される', () {
      expect(testKanjiWord.id, 1);
      expect(testKanjiWord.word, '立入禁止');
      expect(testKanjiWord.reading, 'たちいりきんし');
      expect(testKanjiWord.indonesian, 'Dilarang masuk');
      expect(testKanjiWord.category, 'safety');
      expect(testKanjiWord.importance, 3);
      expect(testKanjiWord.jlptLevel, 'N3');
    });

    test('KanjiWordがJSONからデシリアライズできる', () {
      final json = {
        'id': 1,
        'word': '立入禁止',
        'reading': 'たちいりきんし',
        'romaji': 'Tachiiri kinshi',
        'indonesian': 'Dilarang masuk',
        'category': 'safety',
        'description_ja': '入ってはいけない場所の標識',
        'description_id': 'Rambu area yang tidak boleh dimasuki',
        'importance': 3,
        'jlpt_level': 'N3',
        'created_at': '2026-06-06T00:00:00.000Z',
        'updated_at': '2026-06-06T00:00:00.000Z',
      };

      final kanjiWord = KanjiWord.fromJson(json);
      expect(kanjiWord, testKanjiWord);
    });

    test('KanjiWordがJSONにシリアライズできる', () {
      final json = testKanjiWord.toJson();

      expect(json['word'], '立入禁止');
      expect(json['reading'], 'たちいりきんし');
      expect(json['category'], 'safety');
      expect(json['jlpt_level'], 'N3');
    });

    test('KanjiWordがMapと相互変換できる', () {
      final map = testKanjiWord.toMap();
      final restored = KanjiWord.fromMap(map);

      expect(restored, testKanjiWord);
    });

    test('オプション項目がnullの場合も正しく処理される', () {
      final json = {
        'word': '危険',
        'reading': 'きけん',
        'romaji': 'Kiken',
        'indonesian': 'Bahaya',
        'category': 'safety',
        'created_at': '2026-06-06T00:00:00.000Z',
        'updated_at': '2026-06-06T00:00:00.000Z',
      };

      final kanjiWord = KanjiWord.fromJson(json);
      expect(kanjiWord.id, isNull);
      expect(kanjiWord.descriptionJa, isNull);
      expect(kanjiWord.descriptionId, isNull);
      expect(kanjiWord.importance, 1);
      expect(kanjiWord.jlptLevel, 'N4');
    });

    test('copyWithメソッドが正しく動作する', () {
      final copied = testKanjiWord.copyWith(word: '危険', importance: 1);

      expect(copied.word, '危険');
      expect(copied.importance, 1);
      expect(copied.reading, testKanjiWord.reading);
      expect(copied.category, testKanjiWord.category);
    });
  });

  group('KanjiCategory Tests', () {
    test('カテゴリは5種類定義されている', () {
      expect(KanjiCategory.all, hasLength(5));
    });

    test('キーからカテゴリを取得できる', () {
      final category = KanjiCategory.fromKey('safety');
      expect(category, isNotNull);
      expect(category!.nameJa, '安全標識');
      expect(category.nameId, 'Rambu Keselamatan');
    });

    test('存在しないキーはnullを返す', () {
      expect(KanjiCategory.fromKey('unknown'), isNull);
    });
  });
}
