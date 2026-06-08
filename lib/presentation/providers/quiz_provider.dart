import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/quiz.dart';
import '../../data/repositories/quiz_repository.dart';
import 'purchase_provider.dart';

/// QuizRepositoryのProvider
final quizRepositoryProvider = Provider<QuizRepository>((ref) {
  return QuizRepository();
});

/// すべてのクイズを取得するProvider
final allQuizzesProvider = FutureProvider<List<Quiz>>((ref) async {
  ref.keepAlive(); // クイズデータをキャッシュ
  final repository = ref.watch(quizRepositoryProvider);
  return await repository.getAllQuizzes();
});

/// ランダムにクイズを取得するProvider（レベル・分野指定・解錠フィルタ付き）
///
/// [category] を指定すると文法・語彙・漢字読みなど分野を絞って出題する（null=全分野）。
/// 未購入パックのクイズは出題対象から除外される。
/// autoDisposeを使用して毎回新しいランダムクイズを取得。
final randomQuizzesProvider = FutureProvider.autoDispose
    .family<List<Quiz>, ({int count, String level, String? category})>(
        (ref, params) async {
  final repository = ref.watch(quizRepositoryProvider);
  // 解錠状態を監視（購入直後にクイズプールへ即反映される）
  final unlockedPackIds = ref.watch(
    entitlementProvider.select((state) => state.unlockedPackIds),
  );

  var all = await repository.getQuizzesByJlptLevel(params.level);
  if (params.category != null) {
    all = all.where((quiz) => quiz.category == params.category).toList();
  }
  final available = filterUnlockedContent(
    all,
    (quiz) => quiz.packId,
    unlockedPackIds,
  )..shuffle();

  return available.take(params.count).toList();
});

/// クイズセッション管理用のStateNotifier
class QuizSessionNotifier extends StateNotifier<QuizSession> {
  final QuizRepository repository;

  QuizSessionNotifier(this.repository)
      : super(QuizSession(
          quizzes: [],
          currentIndex: 0,
          answers: {},
          isCompleted: false,
        ));

  /// クイズセッションを開始
  Future<void> startSession(List<Quiz> quizzes) async {
    state = QuizSession(
      quizzes: quizzes,
      currentIndex: 0,
      answers: {},
      isCompleted: false,
    );
  }

  /// 回答を送信
  Future<void> submitAnswer(int quizId, int answerIndex) async {
    final currentQuiz = state.quizzes[state.currentIndex];
    final isCorrect = answerIndex == currentQuiz.correctAnswerIndex;

    // 回答を保存
    state = state.copyWith(
      answers: {...state.answers, quizId: answerIndex},
    );

    // データベースに結果を保存
    final result = QuizResult(
      quizId: quizId,
      userAnswerIndex: answerIndex,
      isCorrect: isCorrect,
    );
    await repository.saveQuizResult(result);
  }

  /// 次の問題へ
  void nextQuestion() {
    if (state.currentIndex < state.quizzes.length - 1) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    } else {
      state = state.copyWith(isCompleted: true);
    }
  }

  /// セッションをリセット
  void reset() {
    state = QuizSession(
      quizzes: [],
      currentIndex: 0,
      answers: {},
      isCompleted: false,
    );
  }

  /// 現在の問題を取得
  Quiz? get currentQuiz {
    if (state.quizzes.isEmpty || state.currentIndex >= state.quizzes.length) {
      return null;
    }
    return state.quizzes[state.currentIndex];
  }

  /// スコアを計算
  int get correctCount {
    int count = 0;
    for (var i = 0; i < state.quizzes.length; i++) {
      final quiz = state.quizzes[i];
      final userAnswer = state.answers[quiz.id];
      if (userAnswer == quiz.correctAnswerIndex) {
        count++;
      }
    }
    return count;
  }
}

/// QuizSessionのProvider
final quizSessionProvider =
    StateNotifierProvider<QuizSessionNotifier, QuizSession>((ref) {
  final repository = ref.watch(quizRepositoryProvider);
  return QuizSessionNotifier(repository);
});

/// クイズ統計情報のProvider
final quizStatisticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.watch(quizRepositoryProvider);
  final stats = await repository.getQuizStatistics();
  final accuracy = await repository.getAccuracyRate();

  return {
    'total': stats['total'] ?? 0,
    'correct': stats['correct'] ?? 0,
    'accuracy': accuracy,
  };
});

/// クイズセッションの状態
class QuizSession {
  final List<Quiz> quizzes;
  final int currentIndex;
  final Map<int, int> answers; // quiz_id -> user_answer_index
  final bool isCompleted;

  QuizSession({
    required this.quizzes,
    required this.currentIndex,
    required this.answers,
    required this.isCompleted,
  });

  QuizSession copyWith({
    List<Quiz>? quizzes,
    int? currentIndex,
    Map<int, int>? answers,
    bool? isCompleted,
  }) {
    return QuizSession(
      quizzes: quizzes ?? this.quizzes,
      currentIndex: currentIndex ?? this.currentIndex,
      answers: answers ?? this.answers,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  int get totalQuestions => quizzes.length;
  int get answeredCount => answers.length;
  double get progress =>
      totalQuestions > 0 ? answeredCount / totalQuestions : 0.0;
}
