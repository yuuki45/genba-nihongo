import 'package:flutter_test/flutter_test.dart';
import 'package:nihongo/data/models/phrase.dart';
import 'package:nihongo/presentation/providers/phrase_provider.dart';

void main() {
  final ts = DateTime.parse('2026-06-07T00:00:00.000Z');

  Phrase makePhrase(int id, int categoryId,
          {String? packId, String jlptLevel = 'N5'}) =>
      Phrase(
        id: id,
        japanese: 'フレーズ$id',
        romaji: 'Fureezu$id',
        indonesian: 'Frasa $id',
        categoryId: categoryId,
        packId: packId,
        jlptLevel: jlptLevel,
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

  group('ロック中プレビュー選定（selectLockedPreviewPhrases）テスト', () {
    final phrases = [
      makePhrase(1, 6, packId: 'kaigo', jlptLevel: 'N5'),
      makePhrase(2, 6, packId: 'kaigo', jlptLevel: 'N4'),
      makePhrase(3, 6, packId: 'kaigo', jlptLevel: 'N5'),
      makePhrase(4, 6, packId: 'kaigo', jlptLevel: 'N3'),
      makePhrase(5, 6, packId: 'kaigo', jlptLevel: 'N5'),
      makePhrase(6, 6, packId: 'kaigo', jlptLevel: 'N5'),
      makePhrase(7, 6, packId: 'kaigo', jlptLevel: 'N5'),
      makePhrase(8, 6, packId: 'kaigo', jlptLevel: 'N5'),
      makePhrase(9, 6, packId: 'kaigo', jlptLevel: 'N2'),
    ];

    test('「すべて」タブではN5のみ最大5件', () {
      final preview = selectLockedPreviewPhrases(phrases, null);
      expect(preview, hasLength(5));
      expect(preview.every((p) => p.jlptLevel == 'N5'), isTrue);
    });

    test('N5タブでもN5のみ最大5件', () {
      final n5Only = phrases.where((p) => p.jlptLevel == 'N5').toList();
      final preview = selectLockedPreviewPhrases(n5Only, 'N5');
      expect(preview, hasLength(5));
      expect(preview.every((p) => p.jlptLevel == 'N5'), isTrue);
    });

    test('N4以上のタブではプレビューなし', () {
      for (final level in ['N4', 'N3', 'N2']) {
        final byLevel = phrases.where((p) => p.jlptLevel == level).toList();
        expect(selectLockedPreviewPhrases(byLevel, level), isEmpty,
            reason: '$level タブでプレビューが表示されています');
      }
    });

    test('N5が5件未満ならある分だけ返す', () {
      final few = [
        makePhrase(1, 6, packId: 'kaigo', jlptLevel: 'N5'),
        makePhrase(2, 6, packId: 'kaigo', jlptLevel: 'N4'),
      ];
      expect(selectLockedPreviewPhrases(few, null), hasLength(1));
    });
  });
}
