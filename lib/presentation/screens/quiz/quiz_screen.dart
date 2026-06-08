import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/quiz.dart';
import '../../providers/quiz_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/locked_content_banner.dart';
import '../../../l10n/app_localizations.dart';

/// JLPT演習問題画面（N3: 無料 / N2: 対策パック）
class QuizScreen extends ConsumerStatefulWidget {
  /// 出題するJLPTレベル（'N3' または 'N2'）
  final String jlptLevel;

  /// 出題分野（'文法'・'語彙'・'漢字読み'。null=全分野）
  final String? category;

  const QuizScreen({super.key, this.jlptLevel = 'N3', this.category});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int? _selectedAnswer;
  bool _hasAnswered = false;
  bool _isLoading = false;

  /// 次の問題へ進んだとき問題文（上部）へ戻すためのコントローラ
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// 問題文がすぐ読めるようスクロール位置を先頭へ戻す
  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  @override
  void initState() {
    super.initState();
    // 画面表示時にクイズセッションをリセットして開始
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quizSessionProvider.notifier).reset();
      _startQuizSession();
    });
  }

  Future<void> _startQuizSession() async {
    setState(() => _isLoading = true);

    final quizzes = await ref.read(
      randomQuizzesProvider(
        (count: 10, level: widget.jlptLevel, category: widget.category),
      ).future,
    );
    await ref.read(quizSessionProvider.notifier).startSession(quizzes);

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  /// 画面タイトル（レベルに応じて切り替え）
  String _title(AppLocalizations l10n) {
    return widget.jlptLevel == 'N2' ? l10n.quizTitleN2 : l10n.quizTitle;
  }

  void _handleAnswerSelect(int index) {
    if (_hasAnswered) return;
    setState(() {
      _selectedAnswer = index;
    });
  }

  Future<void> _submitAnswer() async {
    if (_selectedAnswer == null) return;

    final session = ref.read(quizSessionProvider);
    final currentQuiz = session.quizzes[session.currentIndex];

    await ref
        .read(quizSessionProvider.notifier)
        .submitAnswer(currentQuiz.id!, _selectedAnswer!);

    setState(() {
      _hasAnswered = true;
    });
  }

  void _nextQuestion() {
    ref.read(quizSessionProvider.notifier).nextQuestion();
    setState(() {
      _selectedAnswer = null;
      _hasAnswered = false;
    });
    // 次の問題の問題文がすぐ読めるよう先頭へ戻す
    _scrollToTop();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(quizSessionProvider);
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_title(l10n)),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // 出題できるクイズがない（未購入パックのレベルに直接来た場合など）
    if (session.quizzes.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_title(l10n)),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ),
        body: const Padding(
          padding: EdgeInsets.all(24.0),
          child: Center(child: LockedContentBanner()),
        ),
      );
    }

    if (session.isCompleted) {
      return _buildResultScreen(context, session);
    }

    final currentQuiz = session.quizzes[session.currentIndex];
    return _buildQuizScreen(context, currentQuiz, session);
  }

  /// クイズ画面
  Widget _buildQuizScreen(
    BuildContext context,
    Quiz quiz,
    QuizSession session,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final settingsAsync = ref.watch(settingsProvider);
    final languageCode = settingsAsync.maybeWhen(
      data: (settings) => settings.languageCode,
      orElse: () => 'ja',
    );
    final isJapanese = languageCode == 'ja';

    return Scaffold(
      appBar: AppBar(
        title: Text(_title(l10n)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 進捗バー
          _buildProgressBar(context, session),

          // クイズコンテンツ
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 問題番号とカテゴリ
                  _buildQuestionHeader(context, session, quiz, isJapanese),
                  const SizedBox(height: 24),

                  // 問題文
                  _buildQuestionText(quiz, isJapanese),
                  const SizedBox(height: 32),

                  // 選択肢
                  _buildOptions(quiz),
                  const SizedBox(height: 32),

                  // 解説（回答後のみ表示）
                  if (_hasAnswered) ...[
                    _buildExplanation(context, quiz, isJapanese),
                    const SizedBox(height: 24),
                  ],

                  // ボタン
                  _buildActionButton(context, session),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 進捗バー
  Widget _buildProgressBar(BuildContext context, QuizSession session) {
    final progress = (session.currentIndex + 1) / session.totalQuestions;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${session.currentIndex + 1} / ${session.totalQuestions}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  /// 問題ヘッダー
  Widget _buildQuestionHeader(
    BuildContext context,
    QuizSession session,
    Quiz quiz,
    bool isJapanese,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            quiz.category,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            quiz.jlptLevel,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ),
        ),
      ],
    );
  }

  /// 問題文
  Widget _buildQuestionText(Quiz quiz, bool isJapanese) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              quiz.question,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              quiz.questionId,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 選択肢のローマ字読みを取得（データに含まれる options_romaji を使用）
  String? _optionRomaji(Quiz quiz, int index) {
    final romajiList = quiz.optionsRomaji;
    if (romajiList == null || index >= romajiList.length) return null;
    final romaji = romajiList[index];
    return romaji.isEmpty ? null : romaji;
  }

  /// 選択肢
  Widget _buildOptions(Quiz quiz) {
    return Column(
      children: List.generate(quiz.options.length, (index) {
        final option = quiz.options[index];
        final isSelected = _selectedAnswer == index;
        final isCorrect = index == quiz.correctAnswerIndex;

        Color? backgroundColor;
        Color? borderColor;
        IconData? icon;

        if (_hasAnswered) {
          if (isCorrect) {
            backgroundColor = Colors.green[50];
            borderColor = Colors.green;
            icon = Icons.check_circle;
          } else if (isSelected && !isCorrect) {
            backgroundColor = Colors.red[50];
            borderColor = Colors.red;
            icon = Icons.cancel;
          }
        } else if (isSelected) {
          backgroundColor = Theme.of(context).colorScheme.primaryContainer;
          borderColor = Theme.of(context).colorScheme.primary;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: InkWell(
            onTap: () => _handleAnswerSelect(index),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: backgroundColor ?? Colors.white,
                border: Border.all(
                  color: borderColor ?? Colors.grey[300]!,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          option,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                          ),
                        ),
                        if (_optionRomaji(quiz, index) != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            _optionRomaji(quiz, index)!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              height: 1.3,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (icon != null) ...[
                    const SizedBox(width: 8),
                    Icon(
                      icon,
                      color: isCorrect ? Colors.green : Colors.red,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  /// 解説
  Widget _buildExplanation(BuildContext context, Quiz quiz, bool isJapanese) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb,
                  color: Colors.blue[700],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.quizExplanation,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              isJapanese ? quiz.explanation : quiz.explanationId,
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// アクションボタン
  Widget _buildActionButton(
    BuildContext context,
    QuizSession session,
  ) {
    final l10n = AppLocalizations.of(context)!;

    if (!_hasAnswered) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _selectedAnswer != null ? _submitAnswer : null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey[300],
            disabledForegroundColor: Colors.grey[600],
          ),
          child: Text(
            l10n.quizAnswer,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    final isLastQuestion = session.currentIndex == session.totalQuestions - 1;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _nextQuestion,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ),
        child: Text(
          isLastQuestion ? l10n.quizViewResults : l10n.quizNext,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /// 結果画面
  Widget _buildResultScreen(
    BuildContext context,
    QuizSession session,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final notifier = ref.read(quizSessionProvider.notifier);
    final correctCount = notifier.correctCount;
    final totalQuestions = session.totalQuestions;
    final percentage = (correctCount / totalQuestions * 100).toInt();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.quizResultTitle),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                percentage >= 70 ? Icons.emoji_events : Icons.sentiment_neutral,
                size: 100,
                color: percentage >= 70 ? Colors.amber : Colors.grey,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.quizCompleted,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Text(
                        l10n.quizYourScore,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '$correctCount / $totalQuestions',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$percentage%',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    notifier.reset();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    l10n.quizBackToHome,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
