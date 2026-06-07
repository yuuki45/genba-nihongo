import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/phrase_provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/language_segmented_control.dart';
import '../../../data/models/phrase.dart';
import '../phrase_detail/phrase_detail_screen.dart';
import '../quiz/jlpt_home_screen.dart';
import '../kanji/kanji_home_screen.dart';
import '../../services/tts_service.dart';
import '../../../l10n/app_localizations.dart';

/// ホーム画面
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TtsService _ttsService = TtsService();

  /// 再生中フレーズのID（再生インジケーター用）
  int? _playingPhraseId;

  @override
  void initState() {
    super.initState();
    // 読み上げ終了・停止時に再生中表示を解除
    _ttsService.setOnComplete(() {
      if (mounted) setState(() => _playingPhraseId = null);
    });
  }

  @override
  void dispose() {
    _ttsService.setOnComplete(null);
    _ttsService.stop();
    super.dispose();
  }

  /// 時間帯に応じたあいさつを返す
  /// （5-10時: 朝 / 10-15時: 昼 / 15-18時: 夕方 / それ以外: 夜）
  String _greetingForHour(AppLocalizations l10n, int hour) {
    if (hour >= 5 && hour < 10) return l10n.homeGreetingMorning;
    if (hour >= 10 && hour < 15) return l10n.homeGreetingDay;
    if (hour >= 15 && hour < 18) return l10n.homeGreetingAfternoon;
    return l10n.homeGreetingNight;
  }

  @override
  Widget build(BuildContext context) {
    final dailyPhrasesAsync = ref.watch(dailyPhrasesProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヒーローヘッダー（墨色の掲示板 + ハザードストライプ）
            _StaggeredFadeIn(
              index: 0,
              child: _buildHeroHeader(context, ref),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 今日の3フレーズ
                  _StaggeredFadeIn(
                    index: 1,
                    child: _buildSectionHeader(context, l10n.homeDailyPhrases),
                  ),
                  const SizedBox(height: 12),
                  _StaggeredFadeIn(
                    index: 2,
                    child: dailyPhrasesAsync.when(
                      data: (phrases) => _buildDailyPhrases(context, phrases),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, stack) => Center(
                        child: Text('${l10n.errorOccurred}: $error'),
                      ),
                    ),
                  ),

                  // 漢字学習ブロック
                  const SizedBox(height: 24),
                  _StaggeredFadeIn(
                    index: 3,
                    child: _buildKanjiBlock(context),
                  ),

                  // JLPT演習問題ブロック
                  const SizedBox(height: 12),
                  _StaggeredFadeIn(
                    index: 4,
                    child: _buildJlptBlock(context),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ヒーローヘッダー（日付・あいさつ・言語切替を載せた墨色の掲示板）
  Widget _buildHeroHeader(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();

    // 日付は表示言語の形式に追従させる
    final languageCode = ref.watch(settingsProvider).maybeWhen(
          data: (settings) => settings.languageCode,
          orElse: () => 'id',
        );
    final dateText = languageCode == 'ja'
        ? DateFormat('yyyy年MM月dd日(E)', 'ja_JP').format(now)
        : DateFormat('EEEE, d MMMM yyyy', 'id').format(now);

    return Column(
      children: [
        Container(
          width: double.infinity,
          color: AppColors.ink,
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 日付（標識の管理番号風の小ラベル）
              Text(
                dateText,
                style: const TextStyle(
                  fontFamily: AppTheme.bodyFont,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.safetyYellow,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              // あいさつ（時間帯に応じて切り替わる）
              Text(
                _greetingForHour(l10n, now.hour),
                style: const TextStyle(
                  fontFamily: AppTheme.displayFont,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),
              // 言語切替
              const LanguageSegmentedControl(onDarkBackground: true),
            ],
          ),
        ),
        // トラ柄ストライプでヘッダーを締める
        const HazardStripe(height: 8),
      ],
    );
  }

  /// セクション見出し（黄色のタグ + 見出し）
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 22,
          decoration: BoxDecoration(
            color: AppColors.safetyYellow,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: 20,
              ),
        ),
      ],
    );
  }

  /// 今日のフレーズ一覧
  Widget _buildDailyPhrases(BuildContext context, List<Phrase> phrases) {
    if (phrases.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text(AppLocalizations.of(context)!.noPhrases),
          ),
        ),
      );
    }

    return Column(
      children: phrases.asMap().entries.map((entry) {
        final index = entry.key;
        final phrase = entry.value;
        return Padding(
          key: ValueKey(phrase.id), // パフォーマンス向上のためキーを追加
          padding: const EdgeInsets.only(bottom: 12.0),
          child: _buildPhraseCard(context, phrase, index + 1),
        );
      }).toList(),
    );
  }

  /// フレーズカード
  Widget _buildPhraseCard(BuildContext context, Phrase phrase, int number) {
    final l10n = AppLocalizations.of(context)!;
    final isPlaying = _playingPhraseId != null && _playingPhraseId == phrase.id;

    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PhraseDetailScreen(phrase: phrase),
            ),
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // 番号（黄色の角形バッジ — 標識の管理番号）
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.safetyYellow,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '$number',
                    style: const TextStyle(
                      fontFamily: AppTheme.displayFont,
                      color: AppColors.ink,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // フレーズ内容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      phrase.japanese,
                      style: const TextStyle(
                        fontFamily: AppTheme.displayFont,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      phrase.romaji,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      phrase.indonesian,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              // 再生ボタン（再生中はアイコンと色で示す）
              IconButton(
                icon: Icon(
                  isPlaying ? Icons.stop_circle : Icons.play_circle_outline,
                ),
                iconSize: 32,
                color: isPlaying
                    ? AppColors.jisGreen
                    : Theme.of(context).colorScheme.primary,
                tooltip: isPlaying ? l10n.stopAudio : l10n.playAudio,
                onPressed: () async {
                  if (isPlaying) {
                    await _ttsService.stop();
                    if (mounted) {
                      setState(() => _playingPhraseId = null);
                    }
                  } else {
                    // 別フレーズの再生中なら止めてから開始（多重発話防止）
                    await _ttsService.stop();
                    if (mounted) {
                      setState(() => _playingPhraseId = phrase.id);
                    }
                    await _ttsService.speak(phrase.japanese);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 漢字学習ブロック（JIS緑 — 案内標識パネル）
  ///
  /// 漢字ハブ（カード学習・各種クイズ・カテゴリー別クイズ）へ遷移する。
  Widget _buildKanjiBlock(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _SignPanelCard(
      backgroundColor: AppColors.jisGreen,
      iconBlockColor: Colors.white,
      icon: Icons.menu_book,
      iconColor: AppColors.jisGreen,
      title: l10n.homeKanjiBlockTitle,
      titleColor: Colors.white,
      description: l10n.homeKanjiBlockDesc,
      descriptionColor: Colors.white.withValues(alpha: 0.85),
      chevronColor: Colors.white,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const KanjiHomeScreen()),
        );
      },
    );
  }

  /// JLPT演習問題ブロック（墨色の標識パネル）
  ///
  /// JLPTハブ（N3/N2 × 分野選択）へ遷移する。N2のロックはハブ側で扱う。
  Widget _buildJlptBlock(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _SignPanelCard(
      backgroundColor: AppColors.ink,
      iconBlockColor: AppColors.safetyYellow,
      icon: Icons.quiz,
      iconColor: AppColors.ink,
      title: l10n.homeJlptBlockTitle,
      titleColor: Colors.white,
      description: l10n.homeJlptBlockDesc,
      descriptionColor: Colors.white70,
      chevronColor: AppColors.safetyYellow,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const JlptHomeScreen()),
        );
      },
    );
  }
}

/// 標識パネル風の機能カード
class _SignPanelCard extends StatelessWidget {
  final Color backgroundColor;
  final Color iconBlockColor;
  final IconData icon;
  final Color iconColor;
  final String title;
  final Color titleColor;
  final String description;
  final Color descriptionColor;
  final Color chevronColor;
  final VoidCallback onTap;

  const _SignPanelCard({
    required this.backgroundColor,
    required this.iconBlockColor,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.titleColor,
    required this.description,
    required this.descriptionColor,
    required this.chevronColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Row(
            children: [
              // ピクトグラムブロック
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: iconBlockColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 30, color: iconColor),
              ),
              const SizedBox(width: 16),
              // テキスト
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: AppTheme.displayFont,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: descriptionColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: chevronColor, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

/// 段階フェードイン（ページ表示時に上から順に現れる）
class _StaggeredFadeIn extends StatelessWidget {
  final int index;
  final Widget child;

  const _StaggeredFadeIn({required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    final delayMs = 80 * index;
    final totalMs = 400 + delayMs;
    final start = delayMs / totalMs;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: totalMs),
      curve: Interval(start, 1.0, curve: Curves.easeOutCubic),
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 16 * (1 - value)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
