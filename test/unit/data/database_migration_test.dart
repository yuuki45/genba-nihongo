import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:nihongo/data/datasources/local/database_helper.dart';
import 'package:nihongo/data/repositories/purchase_repository.dart';

/// DBマイグレーション（v5→v6）と購入テーブルのテスト
///
/// sqflite_common_ffi でホストマシン上のSQLiteを使用する。
void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('v5からv6へのアップグレードでpack_id列とpurchasesテーブルが追加され、既存データが保持される',
      () async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'nihongo.db');
    await databaseFactory.deleteDatabase(path);

    // ---- v5相当のスキーマでDBを作成し、既存データを投入 ----
    var db = await openDatabase(
      path,
      version: 5,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE phrases (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            japanese TEXT NOT NULL,
            romaji TEXT NOT NULL,
            indonesian TEXT NOT NULL,
            category_id INTEGER NOT NULL,
            audio_path TEXT,
            importance INTEGER DEFAULT 1,
            usage_context TEXT,
            jlpt_level TEXT DEFAULT 'N5',
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE quizzes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            question TEXT NOT NULL,
            question_id TEXT NOT NULL,
            options TEXT NOT NULL,
            correct_answer_index INTEGER NOT NULL,
            explanation TEXT NOT NULL,
            explanation_id TEXT NOT NULL,
            category TEXT NOT NULL,
            jlpt_level TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE user_settings (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            key TEXT UNIQUE NOT NULL,
            value TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE categories (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name_ja TEXT NOT NULL,
            name_id TEXT NOT NULL,
            icon TEXT,
            sort_order INTEGER DEFAULT 0,
            created_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE favorites (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            phrase_id INTEGER NOT NULL,
            created_at TEXT NOT NULL,
            UNIQUE(phrase_id)
          )
        ''');
        await db.execute('''
          CREATE TABLE quiz_results (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            quiz_id INTEGER NOT NULL,
            user_answer_index INTEGER NOT NULL,
            is_correct INTEGER NOT NULL,
            answered_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE kanji_words (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            word TEXT NOT NULL,
            reading TEXT NOT NULL,
            romaji TEXT NOT NULL,
            indonesian TEXT NOT NULL,
            category TEXT NOT NULL,
            description_ja TEXT,
            description_id TEXT,
            importance INTEGER DEFAULT 1,
            jlpt_level TEXT DEFAULT 'N4',
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE kanji_favorites (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            kanji_word_id INTEGER NOT NULL,
            created_at TEXT NOT NULL,
            UNIQUE(kanji_word_id)
          )
        ''');
      },
    );

    await db.insert('phrases', {
      'id': 1,
      'japanese': 'おはようございます',
      'romaji': 'Ohayou gozaimasu',
      'indonesian': 'Selamat pagi',
      'category_id': 1,
      'created_at': '2026-06-07T00:00:00.000Z',
      'updated_at': '2026-06-07T00:00:00.000Z',
    });
    await db.close();

    // ---- DatabaseHelper（v6）で開き、onUpgradeを発火させる ----
    final helper = DatabaseHelper.instance;
    final phrases = await helper.getAllPhrases();

    // 既存データが保持され、pack_idはNULL（無料）
    expect(phrases, hasLength(1));
    expect(phrases.first['japanese'], 'おはようございます');
    expect(phrases.first['pack_id'], isNull);

    // quizzesにもpack_id列が追加されている
    final quizColumns = await (await helper.database)
        .rawQuery("PRAGMA table_info('quizzes')");
    expect(
      quizColumns.map((c) => c['name']),
      contains('pack_id'),
    );

    // purchasesテーブルが作成され、リポジトリ経由で使える
    final repository = PurchaseRepository(dbHelper: helper);
    expect(await repository.getUnlockedPackIds(), isEmpty);

    await repository.unlockPack(
      'com.genba.nihongo.pack.jlpt_n3n2',
      'jlpt_n3n2',
      restored: false,
    );
    expect(await repository.isPackUnlocked('jlpt_n3n2'), isTrue);

    // 同一商品の再書き込み（復元）は冪等
    await repository.unlockPack(
      'com.genba.nihongo.pack.jlpt_n3n2',
      'jlpt_n3n2',
      restored: true,
    );
    expect(await repository.getUnlockedPackIds(), hasLength(1));

    await helper.close();
  });
}
