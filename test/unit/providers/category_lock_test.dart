import 'package:flutter_test/flutter_test.dart';
import 'package:nihongo/data/models/phrase.dart';
import 'package:nihongo/presentation/providers/phrase_provider.dart';

void main() {
  final ts = DateTime.parse('2026-06-07T00:00:00.000Z');

  Phrase makePhrase(int id, int categoryId, {String? packId}) => Phrase(
        id: id,
        japanese: 'フレーズ$id',
        romaji: 'Fureezu$id',
        indonesian: 'Frasa $id',
        categoryId: categoryId,
        packId: packId,
        createdAt: ts,
        updatedAt: ts,
      );

  group('カテゴリロック判定（computeLockedCategoryIds）テスト', () {
    test('無料フレーズのみのカテゴリはロックされない', () {
      final phrases = [
        makePhrase(1, 1),
        makePhrase(2, 1),
      ];
      expect(computeLockedCategoryIds(phrases, {}), isEmpty);
    });

    test('有料フレーズのみのカテゴリは未購入時ロックされる', () {
      final phrases = [
        makePhrase(1, 1),
        makePhrase(331, 6, packId: 'kaigo'),
        makePhrase(332, 6, packId: 'kaigo'),
      ];
      expect(computeLockedCategoryIds(phrases, {}), {6});
    });

    test('購入済みパックのカテゴリはロックされない', () {
      final phrases = [
        makePhrase(331, 6, packId: 'kaigo'),
      ];
      expect(computeLockedCategoryIds(phrases, {'kaigo'}), isEmpty);
    });

    test('無料と有料が混在するカテゴリはロックされない', () {
      // 無料コンテンツが1件でもあれば通常表示（ロック表示は全有料カテゴリのみ）
      final phrases = [
        makePhrase(1, 2),
        makePhrase(331, 2, packId: 'kaigo'),
      ];
      expect(computeLockedCategoryIds(phrases, {}), isEmpty);
    });

    test('複数の有料カテゴリを個別に判定できる', () {
      final phrases = [
        makePhrase(1, 1),
        makePhrase(331, 6, packId: 'kaigo'),
        makePhrase(500, 7, packId: 'kensetsu'),
      ];
      expect(computeLockedCategoryIds(phrases, {'kaigo'}), {7});
    });
  });
}
