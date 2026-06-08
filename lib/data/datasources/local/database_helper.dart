import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

/// データベースヘルパークラス
/// sqfliteを使用したローカルデータベース管理
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  /// データベースインスタンスを取得
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('nihongo.db');
    return _database!;
  }

  /// データベースの初期化
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 8,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  /// データベーステーブルの作成
  Future<void> _createDB(Database db, int version) async {
    // カテゴリテーブル
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

    // フレーズテーブル
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
        pack_id TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories(id)
      )
    ''');

    // お気に入りテーブル
    await db.execute('''
      CREATE TABLE favorites (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        phrase_id INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (phrase_id) REFERENCES phrases(id),
        UNIQUE(phrase_id)
      )
    ''');

    // ユーザー設定テーブル
    await db.execute('''
      CREATE TABLE user_settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        key TEXT UNIQUE NOT NULL,
        value TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // クイズテーブル
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
        pack_id TEXT,
        options_romaji TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // クイズ結果テーブル
    await db.execute('''
      CREATE TABLE quiz_results (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        quiz_id INTEGER NOT NULL,
        user_answer_index INTEGER NOT NULL,
        is_correct INTEGER NOT NULL,
        answered_at TEXT NOT NULL,
        FOREIGN KEY (quiz_id) REFERENCES quizzes(id)
      )
    ''');

    // 漢字語テーブル
    await db.execute(_createKanjiWordsTableSql);

    // 苦手漢字テーブル
    await db.execute(_createKanjiFavoritesTableSql);

    // 購入テーブル
    await db.execute(_createPurchasesTableSql);

    // 単漢字辞書テーブル
    await db.execute(_createKanjiCharactersTableSql);
  }

  /// 単漢字辞書テーブルの作成SQL（漢字辞書パック）
  static const String _createKanjiCharactersTableSql = '''
    CREATE TABLE kanji_characters (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      character TEXT NOT NULL UNIQUE,
      on_readings TEXT NOT NULL,
      kun_readings TEXT NOT NULL,
      meaning_id TEXT NOT NULL,
      jlpt_level TEXT,
      pack_id TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
  ''';

  /// 購入テーブルの作成SQL
  ///
  /// コンテンツパック買い切り(non-consumable)の解錠状態を保持する。
  /// 解錠判定はこのテーブルのみを参照するため、オフラインでも
  /// 購入済みコンテンツが利用できる。
  static const String _createPurchasesTableSql = '''
    CREATE TABLE purchases (
      product_id TEXT PRIMARY KEY,
      pack_id TEXT NOT NULL,
      purchased_at TEXT NOT NULL,
      source TEXT NOT NULL
    )
  ''';

  /// 漢字語テーブルの作成SQL
  static const String _createKanjiWordsTableSql = '''
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
  ''';

  /// 苦手漢字テーブルの作成SQL
  static const String _createKanjiFavoritesTableSql = '''
    CREATE TABLE kanji_favorites (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      kanji_word_id INTEGER NOT NULL,
      created_at TEXT NOT NULL,
      FOREIGN KEY (kanji_word_id) REFERENCES kanji_words(id),
      UNIQUE(kanji_word_id)
    )
  ''';

  /// データベースのアップグレード
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // バージョン1から2へのアップグレード: jlpt_level列を追加
      await db.execute('''
        ALTER TABLE phrases ADD COLUMN jlpt_level TEXT DEFAULT 'N5'
      ''');
    }

    if (oldVersion < 3) {
      // バージョン2から3へのアップグレード: learning_history テーブルを削除
      await db.execute('DROP TABLE IF EXISTS learning_history');
    }

    if (oldVersion < 4) {
      // バージョン3から4へのアップグレード: クイズテーブルを追加
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
        CREATE TABLE quiz_results (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          quiz_id INTEGER NOT NULL,
          user_answer_index INTEGER NOT NULL,
          is_correct INTEGER NOT NULL,
          answered_at TEXT NOT NULL,
          FOREIGN KEY (quiz_id) REFERENCES quizzes(id)
        )
      ''');
    }

    if (oldVersion < 5) {
      // バージョン4から5へのアップグレード: 漢字学習テーブルを追加
      await db.execute(_createKanjiWordsTableSql);
      await db.execute(_createKanjiFavoritesTableSql);
    }

    if (oldVersion < 6) {
      // バージョン5から6へのアップグレード: コンテンツパック課金対応
      // 既存データはpack_id = NULL（無料）のまま維持される
      await db.execute('ALTER TABLE phrases ADD COLUMN pack_id TEXT');
      await db.execute('ALTER TABLE quizzes ADD COLUMN pack_id TEXT');
      await db.execute(_createPurchasesTableSql);
    }

    if (oldVersion < 7) {
      // バージョン6から7へのアップグレード: 単漢字辞書テーブルを追加
      await db.execute(_createKanjiCharactersTableSql);
    }

    if (oldVersion < 8) {
      // バージョン7から8へのアップグレード: 選択肢のローマ字読み列を追加
      await db.execute('ALTER TABLE quizzes ADD COLUMN options_romaji TEXT');
    }
  }

  /// データベースを閉じる
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  /// データベースを削除（開発用）
  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'nihongo.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }

  // ==================== Categories ====================

  /// カテゴリを挿入
  Future<int> insertCategory(Map<String, dynamic> category) async {
    final db = await database;
    return await db.insert('categories', category);
  }

  /// カテゴリを挿入または更新（同一IDがあれば置き換え）
  Future<int> upsertCategory(Map<String, dynamic> category) async {
    final db = await database;
    return await db.insert(
      'categories',
      category,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// すべてのカテゴリを取得（ソート順）
  Future<List<Map<String, dynamic>>> getAllCategories() async {
    final db = await database;
    return await db.query(
      'categories',
      orderBy: 'sort_order ASC',
    );
  }

  /// IDでカテゴリを取得
  Future<Map<String, dynamic>?> getCategoryById(int id) async {
    final db = await database;
    final results = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  // ==================== Phrases ====================

  /// フレーズを挿入
  Future<int> insertPhrase(Map<String, dynamic> phrase) async {
    final db = await database;
    return await db.insert('phrases', phrase);
  }

  /// フレーズを挿入または更新（同一IDがあれば置き換え）
  Future<int> upsertPhrase(Map<String, dynamic> phrase) async {
    final db = await database;
    return await db.insert(
      'phrases',
      phrase,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// すべてのフレーズを取得
  Future<List<Map<String, dynamic>>> getAllPhrases() async {
    final db = await database;
    return await db.query('phrases');
  }

  /// カテゴリIDでフレーズを取得
  Future<List<Map<String, dynamic>>> getPhrasesByCategory(int categoryId) async {
    final db = await database;
    return await db.query(
      'phrases',
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );
  }

  /// IDでフレーズを取得
  Future<Map<String, dynamic>?> getPhraseById(int id) async {
    final db = await database;
    final results = await db.query(
      'phrases',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// ランダムにN件のフレーズを取得
  Future<List<Map<String, dynamic>>> getRandomPhrases(int count) async {
    final db = await database;
    return await db.rawQuery(
      'SELECT * FROM phrases ORDER BY RANDOM() LIMIT ?',
      [count],
    );
  }

  /// フレーズを検索
  Future<List<Map<String, dynamic>>> searchPhrases(String query) async {
    final db = await database;
    return await db.query(
      'phrases',
      where: 'japanese LIKE ? OR romaji LIKE ? OR indonesian LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
    );
  }

  /// JLPTレベルでフレーズを取得
  Future<List<Map<String, dynamic>>> getPhrasesByJlptLevel(String jlptLevel) async {
    final db = await database;
    return await db.query(
      'phrases',
      where: 'jlpt_level = ?',
      whereArgs: [jlptLevel],
    );
  }

  /// 指定IDリストに含まれないフレーズを削除（お気に入りも連動して削除）
  ///
  /// データ同期でJSONから削除されたフレーズをDBにも反映するために使用する。
  Future<void> deletePhrasesNotIn(List<int> ids) async {
    if (ids.isEmpty) return;
    final db = await database;
    final placeholders = List.filled(ids.length, '?').join(',');
    // 削除対象フレーズへの参照が残らないよう、お気に入りを先に削除
    await db.delete(
      'favorites',
      where: 'phrase_id NOT IN ($placeholders)',
      whereArgs: ids,
    );
    await db.delete(
      'phrases',
      where: 'id NOT IN ($placeholders)',
      whereArgs: ids,
    );
  }

  // ==================== Favorites ====================

  /// お気に入りを追加
  Future<int> addFavorite(int phraseId) async {
    final db = await database;
    return await db.insert(
      'favorites',
      {
        'phrase_id': phraseId,
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  /// お気に入りを削除
  Future<int> removeFavorite(int phraseId) async {
    final db = await database;
    return await db.delete(
      'favorites',
      where: 'phrase_id = ?',
      whereArgs: [phraseId],
    );
  }

  /// お気に入りかどうかを確認
  Future<bool> isFavorite(int phraseId) async {
    final db = await database;
    final result = await db.query(
      'favorites',
      where: 'phrase_id = ?',
      whereArgs: [phraseId],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  /// すべてのお気に入りフレーズを取得
  Future<List<Map<String, dynamic>>> getFavoritePhrases() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT p.* FROM phrases p
      INNER JOIN favorites f ON p.id = f.phrase_id
      ORDER BY f.created_at DESC
    ''');
  }

  // ==================== User Settings ====================

  /// 設定を保存
  Future<int> saveSetting(String key, String value) async {
    final db = await database;
    return await db.insert(
      'user_settings',
      {
        'key': key,
        'value': value,
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 設定を取得
  Future<String?> getSetting(String key) async {
    final db = await database;
    final results = await db.query(
      'user_settings',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    return results.isNotEmpty ? results.first['value'] as String? : null;
  }

  /// すべての設定を取得
  Future<Map<String, String>> getAllSettings() async {
    final db = await database;
    final results = await db.query('user_settings');
    return {
      for (var row in results) row['key'] as String: row['value'] as String
    };
  }

  // ==================== Kanji Words ====================

  /// 漢字語を挿入または更新（同一IDがあれば置き換え）
  Future<int> upsertKanjiWord(Map<String, dynamic> kanjiWord) async {
    final db = await database;
    return await db.insert(
      'kanji_words',
      kanjiWord,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// すべての漢字語を取得
  Future<List<Map<String, dynamic>>> getAllKanjiWords() async {
    final db = await database;
    return await db.query('kanji_words');
  }

  /// カテゴリで漢字語を取得
  Future<List<Map<String, dynamic>>> getKanjiWordsByCategory(String category) async {
    final db = await database;
    return await db.query(
      'kanji_words',
      where: 'category = ?',
      whereArgs: [category],
    );
  }

  /// ランダムにN件の漢字語を取得
  Future<List<Map<String, dynamic>>> getRandomKanjiWords(int count) async {
    final db = await database;
    return await db.rawQuery(
      'SELECT * FROM kanji_words ORDER BY RANDOM() LIMIT ?',
      [count],
    );
  }

  /// 漢字語を検索（表示語・読み・ローマ字・インドネシア語の部分一致）
  Future<List<Map<String, dynamic>>> searchKanjiWords(String query) async {
    final db = await database;
    return await db.query(
      'kanji_words',
      where: 'word LIKE ? OR reading LIKE ? OR romaji LIKE ? OR indonesian LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%', '%$query%'],
    );
  }

  // ==================== Kanji Characters ====================

  /// 単漢字エントリを挿入または更新（同一IDがあれば置き換え）
  Future<int> upsertKanjiCharacter(Map<String, dynamic> character) async {
    final db = await database;
    return await db.insert(
      'kanji_characters',
      character,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// すべての単漢字エントリを取得
  Future<List<Map<String, dynamic>>> getAllKanjiCharacters() async {
    final db = await database;
    return await db.query('kanji_characters');
  }

  // ==================== Kanji Favorites ====================

  /// 苦手漢字を追加
  Future<int> addKanjiFavorite(int kanjiWordId) async {
    final db = await database;
    return await db.insert(
      'kanji_favorites',
      {
        'kanji_word_id': kanjiWordId,
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  /// 苦手漢字を削除
  Future<int> removeKanjiFavorite(int kanjiWordId) async {
    final db = await database;
    return await db.delete(
      'kanji_favorites',
      where: 'kanji_word_id = ?',
      whereArgs: [kanjiWordId],
    );
  }

  /// 苦手漢字かどうかを確認
  Future<bool> isKanjiFavorite(int kanjiWordId) async {
    final db = await database;
    final result = await db.query(
      'kanji_favorites',
      where: 'kanji_word_id = ?',
      whereArgs: [kanjiWordId],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  /// すべての苦手漢字を取得
  Future<List<Map<String, dynamic>>> getKanjiFavorites() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT k.* FROM kanji_words k
      INNER JOIN kanji_favorites f ON k.id = f.kanji_word_id
      ORDER BY f.created_at DESC
    ''');
  }

  // ==================== Quizzes ====================

  /// クイズを挿入
  Future<int> insertQuiz(Map<String, dynamic> quiz) async {
    final db = await database;
    return await db.insert('quizzes', quiz);
  }

  /// クイズを挿入または更新（同一IDがあれば置き換え）
  Future<int> upsertQuiz(Map<String, dynamic> quiz) async {
    final db = await database;
    return await db.insert(
      'quizzes',
      quiz,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// すべてのクイズを取得
  Future<List<Map<String, dynamic>>> getAllQuizzes() async {
    final db = await database;
    return await db.query('quizzes');
  }

  /// JLPTレベルでクイズを取得
  Future<List<Map<String, dynamic>>> getQuizzesByJlptLevel(String jlptLevel) async {
    final db = await database;
    return await db.query(
      'quizzes',
      where: 'jlpt_level = ?',
      whereArgs: [jlptLevel],
    );
  }

  /// カテゴリでクイズを取得
  Future<List<Map<String, dynamic>>> getQuizzesByCategory(String category) async {
    final db = await database;
    return await db.query(
      'quizzes',
      where: 'category = ?',
      whereArgs: [category],
    );
  }

  /// ランダムにN件のクイズを取得
  Future<List<Map<String, dynamic>>> getRandomQuizzes(int count, String jlptLevel) async {
    final db = await database;
    return await db.rawQuery(
      'SELECT * FROM quizzes WHERE jlpt_level = ? ORDER BY RANDOM() LIMIT ?',
      [jlptLevel, count],
    );
  }

  /// IDでクイズを取得
  Future<Map<String, dynamic>?> getQuizById(int id) async {
    final db = await database;
    final results = await db.query(
      'quizzes',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  // ==================== Purchases ====================

  /// 購入を保存（同一商品IDは置き換え＝冪等）
  Future<int> upsertPurchase(Map<String, dynamic> purchase) async {
    final db = await database;
    return await db.insert(
      'purchases',
      purchase,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// すべての購入を取得
  Future<List<Map<String, dynamic>>> getAllPurchases() async {
    final db = await database;
    return await db.query('purchases');
  }

  // ==================== Quiz Results ====================

  /// クイズ結果を保存
  Future<int> saveQuizResult(Map<String, dynamic> result) async {
    final db = await database;
    return await db.insert('quiz_results', result);
  }

  /// すべてのクイズ結果を取得
  Future<List<Map<String, dynamic>>> getAllQuizResults() async {
    final db = await database;
    return await db.query('quiz_results', orderBy: 'answered_at DESC');
  }

  /// 特定のクイズの結果を取得
  Future<List<Map<String, dynamic>>> getQuizResultsByQuizId(int quizId) async {
    final db = await database;
    return await db.query(
      'quiz_results',
      where: 'quiz_id = ?',
      whereArgs: [quizId],
      orderBy: 'answered_at DESC',
    );
  }

  /// クイズの正解率を取得
  Future<Map<String, int>> getQuizStatistics() async {
    final db = await database;
    final results = await db.rawQuery('''
      SELECT
        COUNT(*) as total,
        SUM(is_correct) as correct
      FROM quiz_results
    ''');

    if (results.isEmpty || results.first['total'] == null) {
      return {'total': 0, 'correct': 0};
    }

    return {
      'total': results.first['total'] as int,
      'correct': results.first['correct'] as int,
    };
  }
}
