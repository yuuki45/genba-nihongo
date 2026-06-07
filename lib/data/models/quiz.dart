/// クイズ問題モデル
class Quiz {
  final int? id;
  final String question; // 問題文
  final String questionId; // インドネシア語の問題文
  final List<String> options; // 選択肢（4つ）
  final int correctAnswerIndex; // 正解のインデックス（0-3）
  final String explanation; // 解説（日本語）
  final String explanationId; // 解説（インドネシア語）
  final String category; // カテゴリ（文法/語彙）
  final String jlptLevel; // JLPTレベル（N3）
  final String? packId; // コンテンツパックID（null = 無料）
  final DateTime createdAt;

  Quiz({
    this.id,
    required this.question,
    required this.questionId,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
    required this.explanationId,
    required this.category,
    required this.jlptLevel,
    this.packId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// JSONからQuizオブジェクトを作成
  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'] as int?,
      question: json['question'] as String,
      questionId: json['question_id'] as String,
      options: (json['options'] as List<dynamic>).cast<String>(),
      correctAnswerIndex: json['correct_answer_index'] as int,
      explanation: json['explanation'] as String,
      explanationId: json['explanation_id'] as String,
      category: json['category'] as String,
      jlptLevel: json['jlpt_level'] as String,
      packId: json['pack_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  /// QuizオブジェクトをJSONに変換
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'question': question,
      'question_id': questionId,
      'options': options,
      'correct_answer_index': correctAnswerIndex,
      'explanation': explanation,
      'explanation_id': explanationId,
      'category': category,
      'jlpt_level': jlptLevel,
      'pack_id': packId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// データベース用のMapに変換
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'question': question,
      'question_id': questionId,
      'options': options.join('|||'), // リストを文字列に変換
      'correct_answer_index': correctAnswerIndex,
      'explanation': explanation,
      'explanation_id': explanationId,
      'category': category,
      'jlpt_level': jlptLevel,
      'pack_id': packId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// データベースのMapからQuizオブジェクトを作成
  factory Quiz.fromMap(Map<String, dynamic> map) {
    return Quiz(
      id: map['id'] as int?,
      question: map['question'] as String,
      questionId: map['question_id'] as String,
      options: (map['options'] as String).split('|||'), // 文字列をリストに変換
      correctAnswerIndex: map['correct_answer_index'] as int,
      explanation: map['explanation'] as String,
      explanationId: map['explanation_id'] as String,
      category: map['category'] as String,
      jlptLevel: map['jlpt_level'] as String,
      packId: map['pack_id'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// コピーを作成
  Quiz copyWith({
    int? id,
    String? question,
    String? questionId,
    List<String>? options,
    int? correctAnswerIndex,
    String? explanation,
    String? explanationId,
    String? category,
    String? jlptLevel,
    String? packId,
    DateTime? createdAt,
  }) {
    return Quiz(
      id: id ?? this.id,
      question: question ?? this.question,
      questionId: questionId ?? this.questionId,
      options: options ?? this.options,
      correctAnswerIndex: correctAnswerIndex ?? this.correctAnswerIndex,
      explanation: explanation ?? this.explanation,
      explanationId: explanationId ?? this.explanationId,
      category: category ?? this.category,
      jlptLevel: jlptLevel ?? this.jlptLevel,
      packId: packId ?? this.packId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// クイズの回答結果モデル
class QuizResult {
  final int quizId;
  final int userAnswerIndex;
  final bool isCorrect;
  final DateTime answeredAt;

  QuizResult({
    required this.quizId,
    required this.userAnswerIndex,
    required this.isCorrect,
    DateTime? answeredAt,
  }) : answeredAt = answeredAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'quiz_id': quizId,
      'user_answer_index': userAnswerIndex,
      'is_correct': isCorrect ? 1 : 0,
      'answered_at': answeredAt.toIso8601String(),
    };
  }

  factory QuizResult.fromMap(Map<String, dynamic> map) {
    return QuizResult(
      quizId: map['quiz_id'] as int,
      userAnswerIndex: map['user_answer_index'] as int,
      isCorrect: (map['is_correct'] as int) == 1,
      answeredAt: DateTime.parse(map['answered_at'] as String),
    );
  }
}
