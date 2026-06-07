/// カテゴリデータモデル
class Category {
  final int? id;
  final String nameJa;
  final String nameId;
  final String? icon;
  final int sortOrder;
  final DateTime createdAt;

  Category({
    this.id,
    required this.nameJa,
    required this.nameId,
    this.icon,
    this.sortOrder = 0,
    required this.createdAt,
  });

  /// JSONからCategoryオブジェクトを生成
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int?,
      nameJa: json['name_ja'] as String,
      nameId: json['name_id'] as String,
      icon: json['icon'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// CategoryオブジェクトをJSONに変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_ja': nameJa,
      'name_id': nameId,
      'icon': icon,
      'sort_order': sortOrder,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// データベースMap形式からCategoryオブジェクトを生成
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      nameJa: map['name_ja'] as String,
      nameId: map['name_id'] as String,
      icon: map['icon'] as String?,
      sortOrder: map['sort_order'] as int? ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// CategoryオブジェクトをデータベースMap形式に変換
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name_ja': nameJa,
      'name_id': nameId,
      'icon': icon,
      'sort_order': sortOrder,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// イミュータブルなコピーを作成
  Category copyWith({
    int? id,
    String? nameJa,
    String? nameId,
    String? icon,
    int? sortOrder,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      nameJa: nameJa ?? this.nameJa,
      nameId: nameId ?? this.nameId,
      icon: icon ?? this.icon,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Category(id: $id, nameJa: $nameJa, nameId: $nameId, sortOrder: $sortOrder)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Category &&
        other.id == id &&
        other.nameJa == nameJa &&
        other.nameId == nameId &&
        other.icon == icon &&
        other.sortOrder == sortOrder &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      nameJa,
      nameId,
      icon,
      sortOrder,
      createdAt,
    );
  }
}
