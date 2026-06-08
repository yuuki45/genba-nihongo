import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ボトムナビゲーションのタブ番号
class AppTabs {
  static const int home = 0;
  static const int phrases = 1;
  static const int kanji = 2;
  static const int quiz = 3;
}

/// 選択中のボトムナビタブを管理するProvider
///
/// ホーム画面の機能ブロックなど、ボトムナビ以外からも
/// タブを切り替えられるようProvider化している。
final selectedTabProvider = StateProvider<int>((ref) => AppTabs.home);
