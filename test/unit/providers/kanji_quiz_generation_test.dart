import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:nihongo/data/models/kanji_word.dart';
import 'package:nihongo/presentation/providers/kanji_provider.dart';

void main() {
  group('漢字クイズ動的生成テスト', () {
    /// テスト用の漢字語を生成
    KanjiWord makeWord(int id) {
      return KanjiWord(
        id: id,
        word: '漢字$id',
        reading: 'よみ$id',
        romaji: 'Yomi$id',
        indonesian: 'Arti $id',
        category: 'safety',
        createdAt: DateTime.parse('2026-06-06T00:00:00.000Z'),
        updatedAt: DateTime.parse('2026-06-06T00:00:00.000Z'),
      );
    }

    final words = List.generate(30, (i) => makeWord(i + 1));

    test('指定問題数のクイズが生成される', () {
      final questions = generateKanjiQuizQuestions(
        words,
        KanjiQuizMode.reading,
        random: Random(42),
      );
      expect(questions, hasLength(kanjiQuizQuestionCount));
    });

    test('各問題は4つの重複しない選択肢を持つ', () {
      final questions = generateKanjiQuizQuestions(
        words,
        KanjiQuizMode.reading,
        random: Random(42),
      );
      for (final question in questions) {
        expect(question.options, hasLength(kanjiQuizOptionCount));
        expect(question.options.toSet().length, kanjiQuizOptionCount,
            reason: '選択肢が重複しています: ${question.options}');
      }
    });

    test('読みクイズのcorrectIndexは出題語の読みを指す', () {
      final questions = generateKanjiQuizQuestions(
        words,
        KanjiQuizMode.reading,
        random: Random(42),
      );
      for (final question in questions) {
        expect(question.options[question.correctIndex], question.word.reading);
      }
    });

    test('意味クイズのcorrectIndexは出題語の意味を指す', () {
      final questions = generateKanjiQuizQuestions(
        words,
        KanjiQuizMode.meaning,
        random: Random(42),
      );
      for (final question in questions) {
        expect(
          question.options[question.correctIndex],
          question.word.indonesian,
        );
      }
    });

    test('出題語に重複がない', () {
      final questions = generateKanjiQuizQuestions(
        words,
        KanjiQuizMode.reading,
        random: Random(42),
      );
      final ids = questions.map((q) => q.word.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('同じ読みの語（同音語）は誤答に含まれない', () {
      // 出題語と同じ読みを持つ別の語を用意
      final homophone = makeWord(99).copyWith(reading: 'よみ1');
      final wordsWithHomophone = [...words, homophone];

      for (var seed = 0; seed < 20; seed++) {
        final questions = generateKanjiQuizQuestions(
          wordsWithHomophone,
          KanjiQuizMode.reading,
          random: Random(seed),
        );
        for (final question in questions) {
          // 正答の読みが選択肢に1回しか現れないこと
          final correctReading = question.word.reading;
          final occurrences =
              question.options.where((o) => o == correctReading).length;
          expect(occurrences, 1,
              reason: '正答と同じ読みが複数含まれています: ${question.options}');
        }
      }
    });
  });
}
