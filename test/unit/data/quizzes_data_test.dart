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

    test('data_versionが6以上である', () {
      expect(jsonData['data_version'], isA<int>());
      expect(jsonData['data_version'], greaterThanOrEqualTo(6));
    });

    test('全問題の選択肢にローマ字読みが付いている', () {
      for (final q in quizzes) {
        final options = (q['options'] as List).cast<String>();
        final romaji = (q['options_romaji'] as List?)?.cast<String>();
        expect(romaji, isNotNull,
            reason: 'id ${q['id']} にoptions_romajiがありません');
        expect(romaji, hasLength(options.length),
            reason: 'id ${q['id']} のローマ字数が選択肢数と一致しません');
        for (var i = 0; i < romaji!.length; i++) {
          expect(romaji[i].trim().isNotEmpty, isTrue,
              reason: 'id ${q['id']} の選択肢${i + 1}「${options[i]}」のローマ字が空です');
          // ローマ字はASCIIで構成されること（変換漏れの検出）
          expect(RegExp(r'^[a-zA-Z\s/]+$').hasMatch(romaji[i]), isTrue,
              reason:
                  'id ${q['id']} の「${options[i]}」のローマ字「${romaji[i]}」に非ASCII文字が含まれています');
        }
      }
    });

    test('すべてのクイズがQuizモデルにパースできる', () {
      final parsed = quizzes.map(Quiz.fromJson).toList();
      expect(parsed, hasLength(240));
    });

    test('クイズIDに重複がない', () {
      final ids = quizzes.map((q) => q['id']).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('無料120問・対策パック120問が収録されている', () {
      final free = quizzes.where((q) => q['pack_id'] == null).length;
      final paid = quizzes.where((q) => q['pack_id'] == 'jlpt_n3n2').length;
      expect(free, 120);
      expect(paid, 120);
    });

    test('N3の漢字読みは無料である（ハブUIとの一貫性）', () {
      final n3Reading = quizzes.where(
          (q) => q['jlpt_level'] == 'N3' && q['category'] == '漢字読み');
      expect(n3Reading, isNotEmpty);
      expect(n3Reading.every((q) => q['pack_id'] == null), isTrue,
          reason: 'N3の漢字読みに有料問題が混ざっています');
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

    test('対策パックはN3:50問（文法25+語彙25）+ N2:70問（文法25+語彙25+漢字読み20）', () {
      final packQuizzes =
          quizzes.where((q) => q['pack_id'] == 'jlpt_n3n2').toList();
      final n3 = packQuizzes.where((q) => q['jlpt_level'] == 'N3').toList();
      final n2 = packQuizzes.where((q) => q['jlpt_level'] == 'N2').toList();
      expect(n3, hasLength(50));
      expect(n2, hasLength(70));

      expect(n3.where((q) => q['category'] == '文法').length, 25);
      expect(n3.where((q) => q['category'] == '語彙').length, 25);
      expect(n3.where((q) => q['category'] == '漢字読み').length, 0,
          reason: 'N3の漢字読みは無料のはずです');

      expect(n2.where((q) => q['category'] == '文法').length, 25);
      expect(n2.where((q) => q['category'] == '語彙').length, 25);
      expect(n2.where((q) => q['category'] == '漢字読み').length, 20);
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

        // 文法・語彙は全問ドリル形式（空欄＿あり）。漢字読みは「読み方はどれですか」形式
        if (q['category'] != '漢字読み') {
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

    test('全問題の解説に正答が明記されている（解説と答えの不一致を防ぐ）', () {
      // 解説フォーマット「正解は「○○」。」の○○が実際の正答と一致するか検証
      for (final q in quizzes) {
        final options = (q['options'] as List).cast<String>();
        final correct = options[q['correct_answer_index'] as int];
        expect((q['explanation'] as String).startsWith('正解は「$correct」'), isTrue,
            reason: 'id ${q['id']} の解説と正答が一致しません');
      }
    });

    test('無料の語彙正答は対策パックの語彙正答と重複しない', () {
      String answerOf(Map<String, dynamic> q) =>
          ((q['options'] as List).cast<String>())[q['correct_answer_index'] as int];

      final freeVocab = quizzes
          .where((q) => q['pack_id'] == null && q['category'] == '語彙')
          .map(answerOf)
          .toSet();
      final paidVocab = quizzes
          .where((q) => q['pack_id'] != null && q['category'] == '語彙')
          .map(answerOf)
          .toSet();

      expect(freeVocab.intersection(paidVocab), isEmpty,
          reason: '無料と有料で同じ語彙が正答になっています');
    });
  });
}
