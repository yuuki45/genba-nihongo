import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/phrases/phrase_scene_screen.dart';
import 'presentation/screens/favorites/favorites_screen.dart';
import 'presentation/screens/settings/settings_screen.dart';
import 'presentation/services/tts_service.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/providers/purchase_provider.dart';
import 'presentation/theme/app_theme.dart';
import 'data/repositories/phrase_repository.dart';
import 'data/repositories/quiz_repository.dart';
import 'data/repositories/kanji_repository.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 日付フォーマット用ロケールを初期化（日本語・インドネシア語）
  await initializeDateFormatting('ja_JP', null);
  await initializeDateFormatting('id', null);

  // TTSサービスを初期化
  await TtsService().initialize();

  // 初期データをロード
  final repository = PhraseRepository();
  final quizRepository = QuizRepository();

  // 初回起動時はデータをロード、それ以降はバージョン差分を同期
  final isDataLoaded = await repository.isDataLoaded();
  if (!isDataLoaded) {
    await repository.loadInitialData();
  } else {
    await repository.syncDataIfNeeded();
  }

  // クイズデータのロード（初回はフルロード、以降はバージョン差分を同期）
  final isQuizDataLoaded = await quizRepository.isQuizDataLoaded();
  if (!isQuizDataLoaded) {
    await quizRepository.loadInitialQuizData();
  } else {
    await quizRepository.syncDataIfNeeded();
  }

  // 漢字データの同期（初回ロードと差分同期の両方を担う）
  final kanjiRepository = KanjiRepository();
  await kanjiRepository.syncDataIfNeeded();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 起動直後に購入ストリームの購読を開始する
    // （前回中断したトランザクションやアプリ外での購入完了を回収するため）
    ref.watch(entitlementProvider);

    final settingsAsync = ref.watch(settingsProvider);

    return settingsAsync.when(
      data: (settings) => MaterialApp(
        title: '現場にほんご',
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ja'),
          Locale('id'),
        ],
        locale: Locale(settings.languageCode),
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        home: const MainScreen(),
        debugShowCheckedModeBanner: false,
      ),
      loading: () => const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (_, __) => const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('エラーが発生しました')),
        ),
      ),
    );
  }
}

/// メイン画面（BottomNavigationBar付き）
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    HomeScreen(),
    PhraseSceneScreen(),
    FavoritesScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: l10n.navHome,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.list),
            label: l10n.navPhrases,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.favorite),
            label: l10n.navFavorites,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: l10n.navSettings,
          ),
        ],
      ),
    );
  }
}
