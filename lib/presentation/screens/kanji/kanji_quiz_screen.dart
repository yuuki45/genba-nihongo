import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/kanji_provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';
import '../../../data/models/kanji_word.dart';
import '../../../l10n/app_localizations.dart';

/// 漢字クイズ画面（読みクイズ・意味クイズ・苦手クイズ・カテゴリ別クイズ共通）
///
/// 問題は漢字語データから動的に生成される（kanjiQuizQuestionsProvider）。
/// [mode] がnullの場合は読み/意味ミックスで出題する。
/// [favoritesOnly] がtrueの場合は苦手漢字のみから出題する。
/// [category] を指定するとそのカテゴリの語のみから出題する。
/// 結果はDBに保存せず、セッション内のみで完結する。
class KanjiQuizScreen extends ConsumerStatefulWidget {
  final KanjiQuizMode? mode;
  final bool favoritesOnly;
  final String? category;

  const KanjiQuizScreen({
    super.key,
    this.mode,
    this.favoritesOnly = false,
    this.category,
  });

  @override
  ConsumerState<KanjiQuizScreen> createState() => _KanjiQuizScreenState();
}

class _KanjiQuizScreenState extends ConsumerState<KanjiQuizScreen> {
  int _currentIndex = 0;
  int? _selectedAnswer;
  bool _hasAnswered = false;
  int _correctCount = 0;
  bool _isCompleted = false;

  /// 間違えた問題（結果画面で苦手登録を促す）
  final List<KanjiQuizQuestion> _wrongQuestions = [];

  String get _title {
    final l10n = AppLocalizations.of(context)!;
    if (widget.favoritesOnly) return l10n.kanjiFavoritesQuiz;
    // カテゴリ別クイズはカテゴリ名をタイトルにする
    if (widget.category != null) {
      final category = KanjiCategory.fromKey(widget.category!);
      if (category != null) {
        final isJapanese = ref.read(settingsProvider).maybeWhen(
              data: (settings) => settings.languageCode == 'ja',
              orElse: () => false,
            );
        return '${category.icon} '
            '${isJapanese ? category.nameJa : category.nameId}';
      }
    }
    return widget.mode == KanjiQuizMode.meaning
        ? l10n.kanjiMenuMeaningQuiz
        : l10n.kanjiMenuReadingQuiz;
  }

  void _handleAnswerSelect(int index) {
    if (_hasAnswered) return;
    setState(() => _selectedAnswer = index);
  }

  void _submitAnswer(KanjiQuizQuestion question) {
    if (_selectedAnswer == null) return;
    setState(() {
      _hasAnswered = true;
      if (_selectedAnswer == question.correctIndex) {
        _correctCount++;
      } else {
        _wrongQuestions.add(question);
      }
    });
  }

  void _nextQuestion(int totalQuestions) {
    setState(() {
      if (_currentIndex == totalQuestions - 1) {
        _isCompleted = true;
      } else {
        _currentIndex++;
      }
      _selectedAnswer = null;
      _hasAnswered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final questionsAsync = ref.watch(kanjiQuizQuestionsProvider(
      (
        mode: widget.mode,
        favoritesOnly: widget.favoritesOnly,
        category: widget.category,
      ),
    ));

    return questionsAsync.when(
      data: (questions) {
        if (questions.isEmpty) {
          return _buildScaffold(
            body: Center(
              child: Text(
                widget.favoritesOnly ? l10n.kanjiNoFavorites : l10n.kanjiNoWords,
              ),
            ),
          );
        }
        if (_isCompleted) {
          return _buildResultScreen(context, questions.length);
        }
        return _buildQuizScreen(context, questions);
      },
      loading: () => _buildScaffold(
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => _buildScaffold(
        body: Center(child: Text('${l10n.errorOccurred}: $error')),
      ),
    );
  }

  Scaffold _buildScaffold({required Widget body}) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: body,
    );
  }

  /// クイズ画面
  Widget _buildQuizScreen(
    BuildContext context,
    List<KanjiQuizQuestion> questions,
  ) {
    final question = questions[_currentIndex];

    return _buildScaffold(
      body: Column(
        children: [
          _buildProgressBar(context, questions.length),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 問題（漢字語）
                  _buildQuestionCard(context, question),
                  const SizedBox(height: 32),

                  // 選択肢
                  _buildOptions(question),
                  const SizedBox(height: 32),

                  // 解説（回答後のみ表示）
                  if (_hasAnswered) ...[
                    _buildExplanation(context, question),
                    const SizedBox(height: 24),
                  ],

                  // ボタン
                  _buildActionButton(context, question, questions.length),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 進捗バー
  Widget _buildProgressBar(BuildContext context, int totalQuestions) {
    final progress = (_currentIndex + 1) / totalQuestions;

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
                '${_currentIndex + 1} / $totalQuestions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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

  /// 問題カード（漢字語を大きく表示）
  Widget _buildQuestionCard(BuildContext context, KanjiQuizQuestion question) {
    final l10n = AppLocalizations.of(context)!;
    // ミックス出題に対応するため、問題ごとのモードで文言を切り替える
    final questionText = question.mode == KanjiQuizMode.reading
        ? l10n.kanjiQuizQuestionReading
        : l10n.kanjiQuizQuestionMeaning;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              questionText,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                question.word.word,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 選択肢
  Widget _buildOptions(KanjiQuizQuestion question) {
    return Column(
      children: List.generate(question.options.length, (index) {
        final option = question.options[index];
        final isSelected = _selectedAnswer == index;
        final isCorrect = index == question.correctIndex;

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
                    child: Text(
                      option,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
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

  /// 解説（語の読み・意味・使用場面）
  Widget _buildExplanation(BuildContext context, KanjiQuizQuestion question) {
    final l10n = AppLocalizations.of(context)!;
    final settingsAsync = ref.watch(settingsProvider);
    final isJapanese = settingsAsync.maybeWhen(
      data: (settings) => settings.languageCode == 'ja',
      orElse: () => true,
    );
    final word = question.word;
    final description = isJapanese ? word.descriptionJa : word.descriptionId;

    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.blue[700], size: 20),
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
              '${word.word}（${word.reading} / ${word.romaji}）',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              word.indonesian,
              style: const TextStyle(fontSize: 14, height: 1.6),
            ),
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
            ],
            // 苦手登録トグル（その場で復習リストに入れられる）
            if (word.id != null) ...[
              const SizedBox(height: 8),
              _buildFavoriteToggleRow(word),
            ],
          ],
        ),
      ),
    );
  }

  /// 苦手登録トグル（解説カード内）
  Widget _buildFavoriteToggleRow(KanjiWord word) {
    final l10n = AppLocalizations.of(context)!;
    final isFavorite = ref.watch(kanjiFavoriteStateProvider(word.id!));

    return InkWell(
      onTap: () {
        ref.read(kanjiFavoriteStateProvider(word.id!).notifier).toggle();
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isFavorite ? Icons.star : Icons.star_border,
              color: isFavorite ? const Color(0xFFEEA000) : Colors.grey,
              size: 22,
            ),
            const SizedBox(width: 6),
            Text(
              l10n.kanjiMarkDifficult,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.grey[700],
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
    KanjiQuizQuestion question,
    int totalQuestions,
  ) {
    final l10n = AppLocalizations.of(context)!;

    if (!_hasAnswered) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed:
              _selectedAnswer != null ? () => _submitAnswer(question) : null,
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

    final isLastQuestion = _currentIndex == totalQuestions - 1;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _nextQuestion(totalQuestions),
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
  Widget _buildResultScreen(BuildContext context, int totalQuestions) {
    final l10n = AppLocalizations.of(context)!;
    final percentage = (_correctCount / totalQuestions * 100).toInt();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.quizResultTitle),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              percentage >= 70 ? Icons.emoji_events : Icons.sentiment_neutral,
              size: 100,
              color: percentage >= 70 ? Colors.amber : Colors.grey,
            ),
            const SizedBox(height: 24),
            Text(
              l10n.quizCompleted,
              textAlign: TextAlign.center,
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
                      '$_correctCount / $totalQuestions',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$percentage%',
                      textAlign: TextAlign.center,
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

            // 間違えた語（苦手登録を促す）
            if (_wrongQuestions.isNotEmpty) ...[
              const SizedBox(height: 32),
              Text(
                l10n.kanjiWrongAnswers,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ..._wrongQuestions.map((q) => _buildWrongAnswerTile(q.word)),
            ],

            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
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
          ],
        ),
      ),
    );
  }

  /// 間違えた語のタイル（星タップで苦手登録）
  Widget _buildWrongAnswerTile(KanjiWord word) {
    final l10n = AppLocalizations.of(context)!;
    final signColor = AppColors.kanjiCategoryColor(word.category);
    final isFavorite =
        word.id != null && ref.watch(kanjiFavoriteStateProvider(word.id!));

    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: Container(
          width: 10,
          height: 40,
          decoration: BoxDecoration(
            color: signColor,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        title: Text(
          word.word,
          style: const TextStyle(
            fontFamily: AppTheme.displayFont,
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        subtitle: Text('${word.reading} / ${word.indonesian}'),
        trailing: IconButton(
          tooltip: l10n.kanjiMarkDifficult,
          icon: Icon(
            isFavorite ? Icons.star : Icons.star_border,
            color: isFavorite ? const Color(0xFFEEA000) : Colors.grey,
            size: 28,
          ),
          onPressed: word.id == null
              ? null
              : () {
                  ref
                      .read(kanjiFavoriteStateProvider(word.id!).notifier)
                      .toggle();
                },
        ),
      ),
    );
  }
}
