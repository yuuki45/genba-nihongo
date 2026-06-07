import 'package:flutter_test/flutter_test.dart';
import 'package:nihongo/data/models/category.dart';

void main() {
  group('Category Model Tests', () {
    test('Categoryモデルが正しく作成される', () {
      final category = Category(
        id: 1,
        nameJa: 'あいさつ',
        nameId: 'Salam',
        icon: '👋',
        sortOrder: 1,
        createdAt: DateTime(2024, 1, 1),
      );

      expect(category.id, 1);
      expect(category.nameJa, 'あいさつ');
      expect(category.nameId, 'Salam');
      expect(category.icon, '👋');
      expect(category.sortOrder, 1);
    });

    test('CategoryがJSONからデシリアライズできる', () {
      final json = {
        'id': 1,
        'name_ja': '安全',
        'name_id': 'Keselamatan',
        'icon': '⚠️',
        'sort_order': 2,
        'created_at': '2024-01-01T00:00:00.000',
      };

      final category = Category.fromJson(json);

      expect(category.id, 1);
      expect(category.nameJa, '安全');
      expect(category.nameId, 'Keselamatan');
      expect(category.icon, '⚠️');
      expect(category.sortOrder, 2);
    });

    test('CategoryがJSONにシリアライズできる', () {
      final category = Category(
        id: 1,
        nameJa: '作業指示',
        nameId: 'Instruksi Kerja',
        icon: '🔧',
        sortOrder: 3,
        createdAt: DateTime(2024, 1, 1),
      );

      final json = category.toJson();

      expect(json['id'], 1);
      expect(json['name_ja'], '作業指示');
      expect(json['name_id'], 'Instruksi Kerja');
      expect(json['icon'], '🔧');
      expect(json['sort_order'], 3);
    });

    test('CategoryがMapからデシリアライズできる', () {
      final map = {
        'id': 4,
        'name_ja': '日常会話',
        'name_id': 'Percakapan Sehari-hari',
        'icon': '💬',
        'sort_order': 4,
        'created_at': '2024-01-01T00:00:00.000',
      };

      final category = Category.fromMap(map);

      expect(category.id, 4);
      expect(category.nameJa, '日常会話');
      expect(category.nameId, 'Percakapan Sehari-hari');
      expect(category.icon, '💬');
      expect(category.sortOrder, 4);
    });

    test('CategoryがMapにシリアライズできる', () {
      final category = Category(
        id: 5,
        nameJa: '緊急',
        nameId: 'Darurat',
        icon: '🚨',
        sortOrder: 5,
        createdAt: DateTime(2024, 1, 1),
      );

      final map = category.toMap();

      expect(map['id'], 5);
      expect(map['name_ja'], '緊急');
      expect(map['name_id'], 'Darurat');
      expect(map['icon'], '🚨');
      expect(map['sort_order'], 5);
    });

    test('iconがnullの場合も正しく処理される', () {
      final category = Category(
        id: 6,
        nameJa: 'その他',
        nameId: 'Lainnya',
        sortOrder: 99,
        createdAt: DateTime(2024, 1, 1),
      );

      expect(category.icon, null);

      final json = category.toJson();
      expect(json.containsKey('icon'), true);
      expect(json['icon'], null);

      final map = category.toMap();
      expect(map.containsKey('icon'), true);
      expect(map['icon'], null);
    });

    test('copyWithメソッドが正しく動作する', () {
      final category = Category(
        id: 1,
        nameJa: 'テスト',
        nameId: 'Tes',
        icon: '🧪',
        sortOrder: 1,
        createdAt: DateTime(2024, 1, 1),
      );

      final updatedCategory = category.copyWith(
        nameJa: '更新されたテスト',
        sortOrder: 10,
      );

      expect(updatedCategory.id, 1);
      expect(updatedCategory.nameJa, '更新されたテスト');
      expect(updatedCategory.sortOrder, 10);
      // その他のフィールドは変更されていない
      expect(updatedCategory.nameId, 'Tes');
      expect(updatedCategory.icon, '🧪');
    });
  });
}
