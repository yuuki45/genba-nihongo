import 'package:flutter_test/flutter_test.dart';
import 'package:nihongo/data/models/phrase.dart';
import 'package:nihongo/presentation/providers/phrase_provider.dart';

void main() {
  final ts = DateTime.parse('2026-06-06T00:00:00.000Z');

  Phrase makePhrase(int id) => Phrase(
        id: id,
        japanese: 'フレーズ$id',
        romaji: 'Fureezu$id',
        indonesian: 'Frasa $id',
        categoryId: 1,
        createdAt: ts,
        updatedAt: ts,
      );

  group('今日のフレーズ（日替わり選択）テスト', () {
    final phrases = List.generate(100, (i) => makePhrase(i + 1));

    test('同じ日付なら同じ3フレーズが選ばれる', () {
      final date = DateTime(2026, 6, 7, 9, 30); // 時刻が違っても日付が同じならOK
      final a = selectDailyPhrases(phrases, date, 3);
      final b = selectDailyPhrases(phrases, DateTime(2026, 6, 7, 22, 5), 3);

      expect(a.map((p) => p.id), b.map((p) => p.id));
      expect(a, hasLength(3));
    });

    test('選ばれたフレーズに重複がない', () {
      final result = selectDailyPhrases(phrases, DateTime(2026, 6, 7), 3);
      expect(result.map((p) => p.id).toSet().length, 3);
    });

    test('日付が変わると選ばれるフレーズが変わる', () {
      final today = selectDailyPhrases(phrases, DateTime(2026, 6, 7), 3);
      final tomorrow = selectDailyPhrases(phrases, DateTime(2026, 6, 8), 3);

      expect(
        today.map((p) => p.id).toList(),
        isNot(tomorrow.map((p) => p.id).toList()),
      );
    });

    test('空リストの場合は空を返す', () {
      expect(selectDailyPhrases([], DateTime(2026, 6, 7), 3), isEmpty);
    });

    test('フレーズ数がcount未満でも安全に動作する', () {
      final few = List.generate(2, (i) => makePhrase(i + 1));
      final result = selectDailyPhrases(few, DateTime(2026, 6, 7), 3);
      expect(result, hasLength(2));
    });
  });
}
