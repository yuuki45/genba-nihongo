import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nihongo/data/models/quiz.dart';

void main() {
  group('quizzes.json データ整合性テスト', () {
    late Map<String, dynamic> jsonData;
    late List<Map<String, dynamic>> quizzes;

    setUpAll(() {
      final file = File('assets/data/quizzes.json');
      jsonData = json.decode(file.readAsStringSync()) as Map<String, dynamic>;
      quizzes = (jsonData['quizzes'] as List).cast<Map<String, dynamic>>();
    });

    test('data_versionが3以上である', () {
      expect(jsonData['data_version'], isA<int>());
      expect(jsonData['data_version'], greaterThanOrEqualTo(3));
    });

    test('すべてのクイズがQuizモデルにパースできる', () {
      final parsed = quizzes.map(Quiz.fromJson).toList();
      expect(parsed, hasLength(240));
    });

    test('クイズIDに重複がない', () {
      final ids = quizzes.map((q) => q['id']).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('無料100問・対策パック140問が収録されている', () {
      final free = quizzes.where((q) => q['pack_id'] == null).length;
      final paid = quizzes.where((q) => q['pack_id'] == 'jlpt_n3n2').length;
      expect(free, 100);
      expect(paid, 140);
    });

    test('pack_idはnullまたはjlpt_n3n2のみ', () {
      final packIds = quizzes.map((q) => q['pack_id']).toSet();
      expect(packIds, {null, 'jlpt_n3n2'});
    });

    test('N2クイズはすべて対策パックに属する', () {
      final n2Free = quizzes
          .where((q) => q['jlpt_level'] == 'N2' && q['pack_id'] == null)
          .toList();
      expect(n2Free, isEmpty,
          reason: 'N2クイズに無料のものが含まれています: ${n2Free.map((q) => q['id'])}');
    });

    test('対策パックはN3:70問 + N2:70問（文法25+語彙25+漢字読み20）', () {
      final packQuizzes =
          quizzes.where((q) => q['pack_id'] == 'jlpt_n3n2').toList();
      final n3 = packQuizzes.where((q) => q['jlpt_level'] == 'N3').length;
      final n2 = packQuizzes.where((q) => q['jlpt_level'] == 'N2').length;
      expect(n3, 70);
      expect(n2, 70);

      for (final level in ['N3', 'N2']) {
        final byLevel =
            packQuizzes.where((q) => q['jlpt_level'] == level).toList();
        expect(byLevel.where((q) => q['category'] == '文法').length, 25,
            reason: '$level 文法の問題数が想定と異なります');
        expect(byLevel.where((q) => q['category'] == '語彙').length, 25,
            reason: '$level 語彙の問題数が想定と異なります');
        expect(byLevel.where((q) => q['category'] == '漢字読み').length, 20,
            reason: '$level 漢字読みの問題数が想定と異なります');
      }
    });

    test('漢字読み問題の語は漢字カード（kanji.json）と重複しない', () {
      final kanjiJson = json.decode(
              File('assets/data/kanji.json').readAsStringSync())
          as Map<String, dynamic>;
      final cardWords = (kanjiJson['kanji_words'] as List)
          .map((w) => (w as Map<String, dynamic>)['word'] as String)
          .toSet();

      final readingQuizzes =
          quizzes.where((q) => q['category'] == '漢字読み').toList();
      expect(readingQuizzes, isNotEmpty);

      for (final q in readingQuizzes) {
        // 問題文「「○○」の読み方はどれですか。」から語を抽出
        final match =
            RegExp('「(.+?)」').firstMatch(q['question'] as String);
        expect(match, isNotNull, reason: 'id ${q['id']} の問題文形式が不正です');
        final word = match!.group(1)!;
        expect(cardWords.contains(word), isFalse,
            reason: 'id ${q['id']} の「$word」は漢字カードと重複しています');
      }
    });

    test('全問題の構造が正しい（4択・重複なし・正解index範囲内・本文あり）', () {
      for (final q in quizzes) {
        final id = q['id'];
        final options = (q['options'] as List).cast<String>();

        expect(options, hasLength(4), reason: 'id $id の選択肢が4つではありません');
        expect(options.toSet().length, 4, reason: 'id $id の選択肢に重複があります');
        expect(options.every((o) => o.trim().isNotEmpty), isTrue,
            reason: 'id $id に空の選択肢があります');

        final correct = q['correct_answer_index'] as int;
        expect(correct, inInclusiveRange(0, 3),
            reason: 'id $id の正解indexが範囲外です');

        // 空欄（＿）形式のチェックは対策パックの文法・語彙のみ
        // （漢字読みは「読み方はどれですか」形式、既存の無料問題には定義形式もある）
        if (q['pack_id'] == 'jlpt_n3n2' && q['category'] != '漢字読み') {
          expect((q['question'] as String).contains('＿'), isTrue,
              reason: 'id $id の問題文に空欄（＿）がありません');
        }
        expect((q['question_id'] as String).trim().isNotEmpty, isTrue,
            reason: 'id $id のインドネシア語問題文が空です');
        expect((q['explanation'] as String).trim().isNotEmpty, isTrue,
            reason: 'id $id の解説が空です');
        expect((q['explanation_id'] as String).trim().isNotEmpty, isTrue,
            reason: 'id $id のインドネシア語解説が空です');
      }
    });

    test('対策パックの解説には正答が明記されている', () {
      // 解説フォーマット「正解は「○○」。」の○○が実際の正答と一致するか検証
      for (final q in quizzes.where((q) => q['pack_id'] == 'jlpt_n3n2')) {
        final options = (q['options'] as List).cast<String>();
        final correct = options[q['correct_answer_index'] as int];
        expect((q['explanation'] as String).contains('「$correct」'), isTrue,
            reason: 'id ${q['id']} の解説と正答が一致しません');
      }
    });
  });
}
