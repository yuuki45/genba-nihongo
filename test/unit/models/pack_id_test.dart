import 'package:flutter_test/flutter_test.dart';
import 'package:nihongo/data/models/phrase.dart';
import 'package:nihongo/data/models/quiz.dart';

void main() {
  final ts = DateTime.parse('2026-06-07T00:00:00.000Z');

  group('Phrase packId テスト', () {
    test('pack_idなしのJSONはnull（無料）になる', () {
      final phrase = Phrase.fromJson({
        'japanese': 'おはようございます',
        'romaji': 'Ohayou gozaimasu',
        'indonesian': 'Selamat pagi',
        'category_id': 1,
        'created_at': ts.toIso8601String(),
        'updated_at': ts.toIso8601String(),
      });
      expect(phrase.packId, isNull);
    });

    test('pack_id付きJSONのround-trip（fromJson→toMap→fromMap）', () {
      final phrase = Phrase.fromJson({
        'id': 1000,
        'japanese': '介護のフレーズ',
        'romaji': 'Kaigo no fureezu',
        'indonesian': 'Frasa perawatan',
        'category_id': 1,
        'pack_id': 'kaigo',
        'created_at': ts.toIso8601String(),
        'updated_at': ts.toIso8601String(),
      });
      expect(phrase.packId, 'kaigo');

      final restored = Phrase.fromMap(phrase.toMap());
      expect(restored.packId, 'kaigo');
      expect(restored, phrase);
      expect(phrase.toJson()['pack_id'], 'kaigo');
    });

    test('copyWithでpackIdを変更できる', () {
      final phrase = Phrase.fromJson({
        'japanese': 'テスト',
        'romaji': 'Tesuto',
        'indonesian': 'Tes',
        'category_id': 1,
        'created_at': ts.toIso8601String(),
        'updated_at': ts.toIso8601String(),
      });
      final copied = phrase.copyWith(packId: 'jlpt_n3n2');
      expect(copied.packId, 'jlpt_n3n2');
      expect(copied.japanese, phrase.japanese);
    });
  });

  group('Quiz packId テスト', () {
    Map<String, dynamic> baseQuizJson() => {
          'id': 200,
          'question': '問題',
          'question_id': 'Pertanyaan',
          'options': ['a', 'b', 'c', 'd'],
          'correct_answer_index': 0,
          'explanation': '解説',
          'explanation_id': 'Penjelasan',
          'category': '文法',
          'jlpt_level': 'N2',
          'created_at': ts.toIso8601String(),
        };

    test('pack_idなしのJSONはnull（無料）になる', () {
      final quiz = Quiz.fromJson(baseQuizJson());
      expect(quiz.packId, isNull);
    });

    test('pack_id付きJSONのround-trip（fromJson→toMap→fromMap）', () {
      final json = baseQuizJson()..['pack_id'] = 'jlpt_n3n2';
      final quiz = Quiz.fromJson(json);
      expect(quiz.packId, 'jlpt_n3n2');

      final restored = Quiz.fromMap(quiz.toMap());
      expect(restored.packId, 'jlpt_n3n2');
      expect(restored.options, quiz.options);
      expect(quiz.toJson()['pack_id'], 'jlpt_n3n2');
    });

    test('copyWithでpackIdを変更できる', () {
      final quiz = Quiz.fromJson(baseQuizJson());
      final copied = quiz.copyWith(packId: 'jlpt_n3n2');
      expect(copied.packId, 'jlpt_n3n2');
      expect(copied.question, quiz.question);
    });
  });
}
