import 'package:flutter_test/flutter_test.dart';
import 'package:nihongo/data/models/phrase.dart';

void main() {
  group('Phrase Model Tests', () {
    test('Phraseモデルが正しく作成される', () {
      final phrase = Phrase(
        id: 1,
        japanese: 'おはようございます',
        romaji: 'Ohayou gozaimasu',
        indonesian: 'Selamat pagi',
        categoryId: 1,
        jlptLevel: 'N5',
        importance: 5,
        usageContext: '朝の挨拶',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      expect(phrase.id, 1);
      expect(phrase.japanese, 'おはようございます');
      expect(phrase.romaji, 'Ohayou gozaimasu');
      expect(phrase.indonesian, 'Selamat pagi');
      expect(phrase.categoryId, 1);
      expect(phrase.jlptLevel, 'N5');
      expect(phrase.importance, 5);
      expect(phrase.usageContext, '朝の挨拶');
    });

    test('PhraseがJSONからデシリアライズできる', () {
      final json = {
        'id': 1,
        'japanese': 'こんにちは',
        'romaji': 'Konnichiwa',
        'indonesian': 'Halo',
        'category_id': 1,
        'jlpt_level': 'N5',
        'importance': 4,
        'usage_context': '日中の挨拶',
        'created_at': '2024-01-01T00:00:00.000',
        'updated_at': '2024-01-01T00:00:00.000',
      };

      final phrase = Phrase.fromJson(json);

      expect(phrase.id, 1);
      expect(phrase.japanese, 'こんにちは');
      expect(phrase.romaji, 'Konnichiwa');
      expect(phrase.indonesian, 'Halo');
      expect(phrase.categoryId, 1);
      expect(phrase.jlptLevel, 'N5');
      expect(phrase.importance, 4);
      expect(phrase.usageContext, '日中の挨拶');
    });

    test('PhraseがJSONにシリアライズできる', () {
      final phrase = Phrase(
        id: 1,
        japanese: 'ありがとうございます',
        romaji: 'Arigatou gozaimasu',
        indonesian: 'Terima kasih',
        categoryId: 1,
        jlptLevel: 'N5',
        importance: 5,
        usageContext: '感謝の表現',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final json = phrase.toJson();

      expect(json['id'], 1);
      expect(json['japanese'], 'ありがとうございます');
      expect(json['romaji'], 'Arigatou gozaimasu');
      expect(json['indonesian'], 'Terima kasih');
      expect(json['category_id'], 1);
      expect(json['jlpt_level'], 'N5');
      expect(json['importance'], 5);
      expect(json['usage_context'], '感謝の表現');
    });

    test('PhraseがMapからデシリアライズできる', () {
      final map = {
        'id': 2,
        'japanese': 'すみません',
        'romaji': 'Sumimasen',
        'indonesian': 'Permisi',
        'category_id': 1,
        'jlpt_level': 'N5',
        'importance': 5,
        'usage_context': '謝罪・呼びかけ',
        'created_at': '2024-01-01T00:00:00.000',
        'updated_at': '2024-01-01T00:00:00.000',
      };

      final phrase = Phrase.fromMap(map);

      expect(phrase.id, 2);
      expect(phrase.japanese, 'すみません');
      expect(phrase.romaji, 'Sumimasen');
      expect(phrase.indonesian, 'Permisi');
      expect(phrase.usageContext, '謝罪・呼びかけ');
    });

    test('PhraseがMapにシリアライズできる', () {
      final phrase = Phrase(
        id: 3,
        japanese: 'お疲れ様です',
        romaji: 'Otsukaresama desu',
        indonesian: 'Terima kasih atas kerja kerasnya',
        categoryId: 2,
        jlptLevel: 'N4',
        importance: 4,
        usageContext: '仕事終わりの挨拶',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final map = phrase.toMap();

      expect(map['id'], 3);
      expect(map['japanese'], 'お疲れ様です');
      expect(map['romaji'], 'Otsukaresama desu');
      expect(map['indonesian'], 'Terima kasih atas kerja kerasnya');
      expect(map['category_id'], 2);
      expect(map['jlpt_level'], 'N4');
      expect(map['importance'], 4);
      expect(map['usage_context'], '仕事終わりの挨拶');
    });

    test('copyWithメソッドが正しく動作する', () {
      final phrase = Phrase(
        id: 1,
        japanese: 'テスト',
        romaji: 'Tesuto',
        indonesian: 'Tes',
        categoryId: 1,
        jlptLevel: 'N5',
        importance: 3,
        usageContext: 'テスト',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final updatedPhrase = phrase.copyWith(
        importance: 5,
        usageContext: '更新されたテスト',
      );

      expect(updatedPhrase.id, 1);
      expect(updatedPhrase.japanese, 'テスト');
      expect(updatedPhrase.importance, 5);
      expect(updatedPhrase.usageContext, '更新されたテスト');
      // その他のフィールドは変更されていない
      expect(updatedPhrase.romaji, 'Tesuto');
      expect(updatedPhrase.categoryId, 1);
    });

    test('audioPathとusageContextがnullの場合も正しく処理される', () {
      final phrase = Phrase(
        id: 1,
        japanese: 'テスト',
        romaji: 'Tesuto',
        indonesian: 'Tes',
        categoryId: 1,
        jlptLevel: 'N5',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      expect(phrase.audioPath, null);
      expect(phrase.usageContext, null);

      final map = phrase.toMap();
      expect(map['audio_path'], null);
      expect(map['usage_context'], null);

      final deserializedPhrase = Phrase.fromMap(map);
      expect(deserializedPhrase.audioPath, null);
      expect(deserializedPhrase.usageContext, null);
    });
  });
}
