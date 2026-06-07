import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/phrase.dart';
import '../../../data/models/category.dart';
import '../../providers/phrase_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/tts_service.dart';
import '../../../l10n/app_localizations.dart';

/// ローマ字からひらがなへの変換マップ（静的データ）
const Map<String, String> _romajiMap = {
  // 5母音
  'a': 'あ', 'i': 'い', 'u': 'う', 'e': 'え', 'o': 'お',

  // か行
  'ka': 'か', 'ki': 'き', 'ku': 'く', 'ke': 'け', 'ko': 'こ',
  'kya': 'きゃ', 'kyu': 'きゅ', 'kyo': 'きょ',

  // が行
  'ga': 'が', 'gi': 'ぎ', 'gu': 'ぐ', 'ge': 'げ', 'go': 'ご',
  'gya': 'ぎゃ', 'gyu': 'ぎゅ', 'gyo': 'ぎょ',

  // さ行
  'sa': 'さ', 'shi': 'し', 'su': 'す', 'se': 'せ', 'so': 'そ',
  'sha': 'しゃ', 'shu': 'しゅ', 'sho': 'しょ',

  // ざ行
  'za': 'ざ', 'ji': 'じ', 'zu': 'ず', 'ze': 'ぜ', 'zo': 'ぞ',
  'ja': 'じゃ', 'ju': 'じゅ', 'jo': 'じょ',

  // た行
  'ta': 'た', 'chi': 'ち', 'tsu': 'つ', 'te': 'て', 'to': 'と',
  'cha': 'ちゃ', 'chu': 'ちゅ', 'cho': 'ちょ',

  // だ行
  'da': 'だ', 'di': 'ぢ', 'du': 'づ', 'de': 'で', 'do': 'ど',

  // な行
  'na': 'な', 'ni': 'に', 'nu': 'ぬ', 'ne': 'ね', 'no': 'の',
  'nya': 'にゃ', 'nyu': 'にゅ', 'nyo': 'にょ',

  // は行
  'ha': 'は', 'hi': 'ひ', 'fu': 'ふ', 'he': 'へ', 'ho': 'ほ',
  'hya': 'ひゃ', 'hyu': 'ひゅ', 'hyo': 'ひょ',

  // ば行
  'ba': 'ば', 'bi': 'び', 'bu': 'ぶ', 'be': 'べ', 'bo': 'ぼ',
  'bya': 'びゃ', 'byu': 'びゅ', 'byo': 'びょ',

  // ぱ行
  'pa': 'ぱ', 'pi': 'ぴ', 'pu': 'ぷ', 'pe': 'ぺ', 'po': 'ぽ',
  'pya': 'ぴゃ', 'pyu': 'ぴゅ', 'pyo': 'ぴょ',

  // ま行
  'ma': 'ま', 'mi': 'み', 'mu': 'む', 'me': 'め', 'mo': 'も',
  'mya': 'みゃ', 'myu': 'みゅ', 'myo': 'みょ',

  // や行
  'ya': 'や', 'yu': 'ゆ', 'yo': 'よ',

  // ら行
  'ra': 'ら', 'ri': 'り', 'ru': 'る', 're': 'れ', 'ro': 'ろ',
  'rya': 'りゃ', 'ryu': 'りゅ', 'ryo': 'りょ',

  // わ行
  'wa': 'わ', 'wi': 'ゐ', 'we': 'ゑ', 'wo': 'を',

  // ん
  'n': 'ん',
};

/// フレーズ詳細画面
class PhraseDetailScreen extends ConsumerStatefulWidget {
  final Phrase phrase;

  const PhraseDetailScreen({
    super.key,
    required this.phrase,
  });

  @override
  ConsumerState<PhraseDetailScreen> createState() => _PhraseDetailScreenState();
}

class _PhraseDetailScreenState extends ConsumerState<PhraseDetailScreen> {
  final TtsService _ttsService = TtsService();
  bool _isPlaying = false;

  @override
  void dispose() {
    _ttsService.stop();
    super.dispose();
  }

  /// ローマ字をひらがなに変換
  String _romajiToHiragana(String romaji) {
    String result = '';
    String lower = romaji.toLowerCase();
    int i = 0;

    while (i < lower.length) {
      bool found = false;

      // 3文字マッチを試す
      if (i + 3 <= lower.length) {
        String threeChar = lower.substring(i, i + 3);
        if (_romajiMap.containsKey(threeChar)) {
          result += _romajiMap[threeChar]!;
          i += 3;
          found = true;
        }
      }

      // 2文字マッチを試す
      if (!found && i + 2 <= lower.length) {
        String twoChar = lower.substring(i, i + 2);
        if (_romajiMap.containsKey(twoChar)) {
          result += _romajiMap[twoChar]!;
          i += 2;
          found = true;
        }
      }

      // 1文字マッチを試す
      if (!found && i + 1 <= lower.length) {
        String oneChar = lower.substring(i, i + 1);
        if (_romajiMap.containsKey(oneChar)) {
          result += _romajiMap[oneChar]!;
          i += 1;
          found = true;
        }
      }

      // スペースはそのまま
      if (!found) {
        if (lower[i] == ' ') {
          result += ' ';
        }
        i++;
      }
    }

    return result;
  }

  Future<void> _playAudio() async {
    setState(() {
      _isPlaying = true;
    });

    await _ttsService.speak(widget.phrase.japanese);

    // 再生が完了したら状態を更新
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      setState(() {
        _isPlaying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(allCategoriesProvider);
    final isFavorite = ref.watch(favoriteStateProvider(widget.phrase.id!));
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.phraseDetail),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.pink : null,
            ),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final wasFavorite = isFavorite;

              await ref.read(favoriteStateProvider(widget.phrase.id!).notifier).toggle();

              if (!mounted) return;
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    wasFavorite ? l10n.favoriteRemoved : l10n.favoriteAdded,
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // カテゴリバッジ
            categoriesAsync.when(
              data: (categories) {
                final category = categories.firstWhere(
                  (c) => c.id == widget.phrase.categoryId,
                  orElse: () => Category(
                    id: 0,
                    nameJa: '未分類',
                    nameId: 'Tidak Dikategorikan',
                    sortOrder: 999,
                    createdAt: DateTime.now(),
                  ),
                );
                return _buildCategoryBadge(context, category);
              },
              loading: () => const SizedBox(height: 60),
              error: (_, __) => const SizedBox(height: 60),
            ),

            // メインコンテンツ
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 日本語
                  _buildSectionTitle(context, l10n.labelJapanese),
                  const SizedBox(height: 8),
                  _buildMainText(context, widget.phrase.japanese),
                  const SizedBox(height: 16),

                  // ひらがな（ローマ字から生成）
                  _buildHiraganaText(context, widget.phrase.romaji),
                  const SizedBox(height: 32),

                  // ローマ字
                  _buildSectionTitle(context, l10n.labelRomaji),
                  const SizedBox(height: 8),
                  _buildSubText(context, widget.phrase.romaji),
                  const SizedBox(height: 32),

                  // インドネシア語
                  _buildSectionTitle(context, l10n.labelIndonesian),
                  const SizedBox(height: 8),
                  _buildSubText(context, widget.phrase.indonesian),
                  const SizedBox(height: 32),

                  // 再生ボタン
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _isPlaying ? null : _playAudio,
                      icon: Icon(
                        _isPlaying ? Icons.volume_up : Icons.play_arrow,
                        size: 32,
                      ),
                      label: Text(
                        _isPlaying ? l10n.playing : l10n.playAudio,
                        style: const TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 20,
                        ),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey,
                        disabledForegroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(BuildContext context, Category category) {
    // カテゴリ名は表示言語に追従させる
    final isJapanese = ref.watch(settingsProvider).maybeWhen(
          data: (settings) => settings.languageCode == 'ja',
          orElse: () => false,
        );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (category.icon != null) ...[
            Text(
              category.icon!,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            isJapanese ? category.nameJa : category.nameId,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
    );
  }

  Widget _buildMainText(BuildContext context, String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        height: 1.5,
      ),
    );
  }

  Widget _buildSubText(BuildContext context, String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 24,
        height: 1.5,
      ),
    );
  }

  Widget _buildHiraganaText(BuildContext context, String romaji) {
    final hiragana = _romajiToHiragana(romaji);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        hiragana,
        style: TextStyle(
          fontSize: 20,
          color: Colors.grey[700],
          height: 1.5,
        ),
      ),
    );
  }
}
