import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/quiz.dart';
import '../../providers/quiz_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/locked_content_banner.dart';
import '../../../l10n/app_localizations.dart';

/// JLPTクイズ画面（N3: 無料 / N2: 対策パック）
class QuizScreen extends ConsumerStatefulWidget {
  /// 出題するJLPTレベル（'N3' または 'N2'）
  final String jlptLevel;

  const QuizScreen({super.key, this.jlptLevel = 'N3'});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int? _selectedAnswer;
  bool _hasAnswered = false;
  bool _isLoading = false;

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
      randomQuizzesProvider((count: 10, level: widget.jlptLevel)).future,
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
    final session = ref.read(quizSessionProvider);
    final isLastQuestion = session.currentIndex == session.totalQuestions - 1;

    if (isLastQuestion) {
      // 最後の問題の場合は完了状態に移行
      ref.read(quizSessionProvider.notifier).nextQuestion();
      setState(() {
        _selectedAnswer = null;
        _hasAnswered = false;
      });
    } else {
      // 通常の次の問題へ移行
      ref.read(quizSessionProvider.notifier).nextQuestion();
      setState(() {
        _selectedAnswer = null;
        _hasAnswered = false;
      });
    }
  }

  /// 選択肢のローマ字を取得
  String? _getOptionRomaji(String option) {
    // クイズの全選択肢のローマ字マッピング
    final romajiMap = {
      // 動詞の活用形
      '壊れない': 'kowarenai',
      '壊れる': 'kowareru',
      '壊した': 'kowashita',
      '壊して': 'kowashite',
      '壊す': 'kowasu',
      '壊れた': 'kowareta',
      '始める': 'hajimeru',
      '始めた': 'hajimeta',
      '始めて': 'hajimete',
      '始めている': 'hajimeteiru',
      '運ぶ': 'hakobu',
      '運んだ': 'hakonda',
      '運んで': 'hakonde',
      '運ばない': 'hakobanai',
      '見つけた': 'mitsuketa',
      '見つける': 'mitsukeru',
      '見つけて': 'mitsukete',
      '見つけない': 'mitsukenai',
      '使い': 'tsukai',
      '使う': 'tsukau',
      '使って': 'tsukatte',
      '使った': 'tsukatta',
      'かぶって': 'kabutte',
      'かぶる': 'kaburu',
      'かぶった': 'kabutta',
      'かぶり': 'kaburi',
      '修理した': 'shuuri shita',
      '修理する': 'shuuri suru',
      '修理して': 'shuuri shite',
      '修理しない': 'shuuri shinai',
      '締め': 'shime',
      '締める': 'shimeru',
      '締めて': 'shimete',
      '締めた': 'shimeta',
      '作る': 'tsukuru',
      '発見した': 'hakken shita',
      '発見する': 'hakken suru',
      '発見して': 'hakken shite',
      '発見しない': 'hakken shinai',
      '完成する': 'kansei suru',
      '完成させ': 'kansei sase',
      '完成し': 'kansei shi',
      '完成': 'kansei',
      '上げる': 'ageru',
      '上がる': 'agaru',
      '上げて': 'agete',
      '上がって': 'agatte',
      '終わる': 'owaru',
      '終わり': 'owari',
      '終わって': 'owatte',
      '終わった': 'owatta',
      '着る': 'kiru',
      '着た': 'kita',
      '着て': 'kite',
      '着ている': 'kiteiru',
      '履かない': 'hakanai',
      '履いて': 'haite',
      '履く': 'haku',
      '履いた': 'haita',
      '起こる': 'okoru',
      '起こった': 'okotta',
      '起きた': 'okita',
      '起こり': 'okori',
      'やり': 'yari',
      'やる': 'yaru',
      'やって': 'yatte',
      'やった': 'yatta',
      '確認し': 'kakunin shi',
      '確認する': 'kakunin suru',
      '確認して': 'kakunin shite',
      '確認した': 'kakunin shita',

      // 形容詞
      '悪い': 'warui',
      '悪そう': 'warusou',
      '悪く': 'waruku',
      '悪かった': 'warukatta',
      '高い': 'takai',
      '高く': 'takaku',
      '高ければ': 'takakereba',
      '高かった': 'takakatta',
      '強い': 'tsuyoi',
      '弱い': 'yowai',
      '強く': 'tsuyoku',
      '弱く': 'yowaku',

      // 助詞・接続詞
      'から': 'kara',
      'のに': 'noni',
      'ので': 'node',
      'けど': 'kedo',
      'けれども': 'keredomo',
      'ら': 'ra',
      'と': 'to',
      'なら': 'nara',
      'たら': 'tara',
      'だから': 'dakara',
      'なのに': 'nanoni',
      'が': 'ga',
      'ば': 'ba',
      'ても': 'temo',
      'に': 'ni',
      'で': 'de',
      'を': 'wo',
      'な': 'na',
      'の': 'no',

      // サ変動詞
      'して': 'shite',
      'されて': 'sarete',
      'する': 'suru',
      'した': 'shita',
      'され': 'sare',
      'し': 'shi',
      'せず': 'sezu',
      'せざるを': 'sezaruwo',
      'しない': 'shinai',
      'しなくて': 'shinakute',
      'ず': 'zu',
      'ないで': 'naide',

      // 名詞・フレーズ
      'パーツを合わせて完成させる': 'paatsu wo awasete kansei saseru',
      '品質や不良をチェックする': 'hinshitsu ya furyou wo chekku suru',
      '良い製品': 'yoi seihin',
      '新しい製品': 'atarashii seihin',
      '品質が悪い製品': 'hinshitsu ga warui seihin',
      '古い製品': 'furui seihin',
      '作業の準備と手順': 'sagyou no junbi to tejun',
      '休憩時間': 'kyuukei jikan',
      '給料': 'kyuuryou',
      '機械の名前': 'kikai no namae',
      '取る': 'toru',
      '外す': 'hazusu',
      '設置する・装着する': 'secchi suru / souchaku suru',
      'ペンキを塗る': 'penki wo nuru',
      '洗う': 'arau',
      '磨く': 'migaku',
      '切る': 'kiru',
      '開ける': 'akeru',
      '箱に詰める': 'hako ni tsumeru',
      '金属をつなぎ合わせる': 'kinzoku wo tsunagiawaseru',
      '測る': 'hakaru',
      '最後まで完成させる': 'saigo made kansei saseru',
      '準備する': 'junbi suru',
      '計画する': 'keikaku suru',
      '表面を滑らかにする': 'hyoumen wo namerakani suru',
      '曲げる': 'mageru',
      '穴を開ける': 'ana wo akeru',
      '不良品の数': 'furyouhin no kazu',
      '良品の割合': 'ryouhin no wariai',
      '作業時間': 'sagyou jikan',
      '開始時間': 'kaishi jikan',
      '終了期限': 'shuuryou kigen',
      '給料日': 'kyuuryou bi',
      '品質管理': 'hinshitsu kanri',
      '製造の各段階を管理すること': 'seizou no kakudankai wo kanri suru koto',
      '在庫管理': 'zaiko kanri',
      '人事管理': 'jinji kanri',
      '不良品の比率': 'furyouhin no hiritsu',
      '作業速度': 'sagyou sokudo',
      '残業時間': 'zangyou jikan',
      '他に': 'hoka ni',
      '他の': 'hoka no',
      '別に': 'betsu ni',
      '外に': 'soto ni',
      '完成品': 'kansei hin',
      '組み立てに使う材料・部品': 'kumitate ni tsukau zairyou / buhin',
      '工具': 'kougu',
      '機械': 'kikai',
      '重さ': 'omosa',
      '壊れにくさ': 'kowarenikusa',
      '速さ': 'hayasa',
      '大きさ': 'ookisa',
      '契約書': 'keiyakusho',
      '製品の詳細が書かれた文書': 'seihin no shousai ga kakareta bunsho',
      '請求書': 'seikyuusho',
      '報告書': 'houkokusho',
      '結果': 'kekka',
      '作業の進め方': 'sagyou no susume kata',
      '道具': 'dougu',
      '材料': 'zairyou',
      'でき': 'deki',
      '注文': 'chuumon',
      '保管されている商品': 'hokan sareteiru shouhin',
      '価格': 'kakaku',
      '販売': 'hanbai',
      'て': 'te',
      'なって': 'natte',
      '製造日': 'seizou bi',
      '商品を納める期限': 'shouhin wo osameru kigen',
      '発注日': 'hatchuu bi',
      '検査日': 'kensa bi',
      '製造に使う元の材料': 'seizou ni tsukau moto no zairyou',
      '廃棄物': 'haiki butsu',
      '品質が高い': 'hinshitsu ga takai',
      '品質が高く': 'hinshitsu ga takaku',
      '品質の高い': 'hinshitsu no takai',
      '品質高い': 'hinshitsu takai',
      '少量生産': 'shouryou seisan',
      '大量に製造すること': 'tairyou ni seizou suru koto',
      '試作': 'shisaku',
      '設計': 'sekkei',
      '通り': 'toori',
      '通りに': 'toori ni',
      'どおり': 'doori',
      'どおりに': 'doori ni',
      '成功': 'seikou',
      '問題・困った事態': 'mondai / komatta jitai',
      '改善': 'kaizen',
      'ため': 'tame',
      'ように': 'you ni',
      'ことに': 'koto ni',
      'ほどに': 'hodo ni',
      '故障率': 'koshou ritsu',
      '機械が実際に動いている割合': 'kikai ga jissai ni ugoiteiru wariai',
      '不良率': 'furyou ritsu',
      '生産速度': 'seisan sokudo',
      '次第': 'shidai',
      'ながら': 'nagara',
      '最中': 'saichuu',
      '途中': 'tochuu',
      'には': 'niwa',
      'ことは': 'koto wa',
      'ては': 'tewa',
      'のは': 'nowa',
      'べきは': 'beki wa',
      '前に': 'mae ni',
      '後に': 'ato ni',
      '時に': 'toki ni',
      'まで': 'made',
      '工場': 'koujou',
      '同じ条件で生産された製品のまとまり': 'onaji jouken de seisan sareta seihin no matomari',
      '利点': 'riten',
      '正常に機能しない状態': 'seijou ni kinou shinai joutai',
      '価格保証': 'kakaku hoshou',
      '製品の品質を保証すること': 'seihin no hinshitsu wo hoshou suru koto',
      '納期保証': 'nouki hoshou',
      '数量保証': 'suuryou hoshou',
      '社内で製造': 'shanai de seizou',
      '外部の会社に依頼': 'gaibu no kaisha ni irai',
      '輸出': 'yushutsu',
      '輸入': 'yunyuu',
      '問題': 'mondai',
      'より良くするための提案': 'yori yoku suru tame no teian',
      '評価': 'hyouka',
      '大きさ・サイズ': 'ookisa / saizu',
      '色': 'iro',
      '温度': 'ondo',
      '作業の正しい手順や方法': 'sagyou no tadashii tejun ya houhou',
      '作業場所': 'sagyou basho',
      '作業服': 'sagyou fuku',
      '保管する': 'hokan suru',
      '材料を目的の形にする': 'zairyou wo mokuteki no katachi ni suru',
      '捨てる': 'suteru',
      '数える': 'kazoeru',
    };

    // マップにない選択肢（対策パックの新規問題など）はローマ字行を表示しない
    return romajiMap[option];
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
                        if (_getOptionRomaji(option) != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            _getOptionRomaji(option)!,
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
