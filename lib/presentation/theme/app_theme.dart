import 'package:flutter/material.dart';

/// JIS安全色ベースのカラーパレット
///
/// 工場の現場標識で使われる色をそのままデザインシステムとして採用する。
/// ユーザー（技能実習生）が毎日見ている視覚言語とアプリをつなげる。
class AppColors {
  AppColors._();

  /// JIS安全色: 黄（注意）— メインアクセント
  static const Color safetyYellow = Color(0xFFF6C700);

  /// 墨色 — 標識の文字・枠の色
  static const Color ink = Color(0xFF1C1F26);

  /// JIS安全色: 赤（禁止・防火）
  static const Color jisRed = Color(0xFFE60012);

  /// JIS安全色: 青（指示）
  static const Color jisBlue = Color(0xFF0068B7);

  /// JIS安全色: 緑（安全状態・避難）
  static const Color jisGreen = Color(0xFF00B06B);

  /// 明るい紙色 — ライトモード背景（コンクリートに貼られた掲示の白）
  static const Color paper = Color(0xFFF7F5EF);

  /// ダークモードのサーフェス
  static const Color darkSurface = Color(0xFF22252D);

  /// 漢字カテゴリ → JIS安全色のマッピング
  ///
  /// 現実の標識の配色規則に合わせる:
  /// 安全標識=黄（注意）、設備・操作=青（指示）、場所・案内=緑（避難・案内）、
  /// 品質・作業=墨（一般掲示）、勤怠・書類=赤（重要・期限）
  static Color kanjiCategoryColor(String categoryKey) {
    switch (categoryKey) {
      case 'safety':
        return safetyYellow;
      case 'equipment':
        return jisBlue;
      case 'place':
        return jisGreen;
      case 'work':
        return ink;
      case 'attendance':
        return jisRed;
      default:
        return ink;
    }
  }

  /// カテゴリ色の上に置く文字色
  static Color onKanjiCategoryColor(String categoryKey) {
    // 黄のみ墨色文字、他は白文字（実際の標識と同じコントラスト規則）
    return categoryKey == 'safety' ? ink : Colors.white;
  }
}

/// アプリ全体のテーマ定義
class AppTheme {
  AppTheme._();

  /// 見出しフォント
  static const String displayFont = 'ZenMaruGothic';

  /// 本文フォント
  static const String bodyFont = 'BIZUDPGothic';

  /// ライトテーマ
  static ThemeData get light {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.ink,
      onPrimary: AppColors.safetyYellow,
      primaryContainer: AppColors.safetyYellow,
      onPrimaryContainer: AppColors.ink,
      secondary: AppColors.safetyYellow,
      onSecondary: AppColors.ink,
      secondaryContainer: AppColors.ink,
      onSecondaryContainer: AppColors.safetyYellow,
      tertiary: AppColors.jisGreen,
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFD3F2E2),
      onTertiaryContainer: Color(0xFF00451F),
      error: AppColors.jisRed,
      onError: Colors.white,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),
      surface: AppColors.paper,
      onSurface: AppColors.ink,
      surfaceContainerHighest: Color(0xFFE9E6DD),
      onSurfaceVariant: Color(0xFF55585F),
      outline: Color(0xFF85878C),
      outlineVariant: Color(0xFFD5D2C9),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: AppColors.ink,
      onInverseSurface: AppColors.paper,
      inversePrimary: AppColors.safetyYellow,
    );
    return _base(scheme, cardColor: Colors.white);
  }

  /// ダークテーマ
  static ThemeData get dark {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.safetyYellow,
      onPrimary: AppColors.ink,
      primaryContainer: AppColors.safetyYellow,
      onPrimaryContainer: AppColors.ink,
      secondary: AppColors.safetyYellow,
      onSecondary: AppColors.ink,
      secondaryContainer: Color(0xFF3A3E48),
      onSecondaryContainer: AppColors.safetyYellow,
      tertiary: AppColors.jisGreen,
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFF00513A),
      onTertiaryContainer: Color(0xFFD3F2E2),
      error: Color(0xFFFF5A52),
      onError: Colors.white,
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
      surface: AppColors.ink,
      onSurface: Color(0xFFEDEBE4),
      surfaceContainerHighest: Color(0xFF31353E),
      onSurfaceVariant: Color(0xFFB5B7BC),
      outline: Color(0xFF8E9095),
      outlineVariant: Color(0xFF43464E),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: Color(0xFFEDEBE4),
      onInverseSurface: AppColors.ink,
      inversePrimary: AppColors.ink,
    );
    return _base(scheme, cardColor: AppColors.darkSurface);
  }

  /// 共通テーマ定義
  static ThemeData _base(ColorScheme scheme, {required Color cardColor}) {
    final isLight = scheme.brightness == Brightness.light;

    final textTheme = const TextTheme(
      // 見出し系: 丸ゴシック
      displayLarge: TextStyle(fontFamily: displayFont, fontWeight: FontWeight.w900),
      displayMedium: TextStyle(fontFamily: displayFont, fontWeight: FontWeight.w900),
      displaySmall: TextStyle(fontFamily: displayFont, fontWeight: FontWeight.w700),
      headlineLarge: TextStyle(fontFamily: displayFont, fontWeight: FontWeight.w900),
      headlineMedium: TextStyle(fontFamily: displayFont, fontWeight: FontWeight.w700),
      headlineSmall: TextStyle(fontFamily: displayFont, fontWeight: FontWeight.w700),
      titleLarge: TextStyle(fontFamily: displayFont, fontWeight: FontWeight.w700),
      titleMedium: TextStyle(fontFamily: displayFont, fontWeight: FontWeight.w700),
      titleSmall: TextStyle(fontFamily: displayFont, fontWeight: FontWeight.w700),
      // 本文系: UDゴシック
      bodyLarge: TextStyle(fontFamily: bodyFont),
      bodyMedium: TextStyle(fontFamily: bodyFont),
      bodySmall: TextStyle(fontFamily: bodyFont),
      labelLarge: TextStyle(fontFamily: bodyFont, fontWeight: FontWeight.w700),
      labelMedium: TextStyle(fontFamily: bodyFont, fontWeight: FontWeight.w700),
      labelSmall: TextStyle(fontFamily: bodyFont),
    ).apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      fontFamily: bodyFont,
      textTheme: textTheme,

      // AppBar: 墨色の標識バー + 黄色文字
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.ink,
        foregroundColor: AppColors.safetyYellow,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: displayFont,
          fontWeight: FontWeight.w900,
          fontSize: 20,
          color: AppColors.safetyYellow,
        ),
      ),

      // カード: 標識らしい角丸と細い枠線
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: scheme.outlineVariant),
        ),
        margin: EdgeInsets.zero,
      ),

      // チップ: 選択時はセーフティイエロー地 × 墨文字（標識スタイル）
      // 文字色は選択状態に応じて自動で解決される（ダークモードでも黄地に墨文字を保証）
      chipTheme: ChipThemeData(
        backgroundColor: cardColor,
        selectedColor: AppColors.safetyYellow,
        labelStyle: TextStyle(
          fontFamily: bodyFont,
          fontWeight: FontWeight.w700,
          color: WidgetStateColor.resolveWith((states) =>
              states.contains(WidgetState.selected)
                  ? AppColors.ink
                  : scheme.onSurface),
        ),
        secondaryLabelStyle: const TextStyle(
          fontFamily: bodyFont,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
        side: BorderSide(color: scheme.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        showCheckmark: false,
      ),

      // ボタン: 黄地に墨文字（押せる標識）
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.safetyYellow,
          foregroundColor: AppColors.ink,
          elevation: 0,
          textStyle: const TextStyle(
            fontFamily: displayFont,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),

      // ボトムナビ: 墨色バー + 黄色アクティブ
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.ink,
        selectedItemColor: AppColors.safetyYellow,
        unselectedItemColor: isLight ? const Color(0xFF8E9095) : const Color(0xFF6E7077),
        selectedLabelStyle: const TextStyle(
          fontFamily: bodyFont,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(fontFamily: bodyFont, fontSize: 12),
        type: BottomNavigationBarType.fixed,
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.safetyYellow,
      ),

      dividerTheme: DividerThemeData(color: scheme.outlineVariant),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? AppColors.ink : null),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? AppColors.safetyYellow : null),
      ),
    );
  }
}

/// ハザードストライプ（黄/墨の斜めストライプ）
///
/// 工事現場のトラ柄。ヒーローヘッダーやカードのアクセントに使う。
class HazardStripe extends StatelessWidget {
  final double height;
  final double stripeWidth;

  const HazardStripe({super.key, this.height = 8, this.stripeWidth = 14});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _HazardStripePainter(stripeWidth: stripeWidth),
      ),
    );
  }
}

class _HazardStripePainter extends CustomPainter {
  final double stripeWidth;

  _HazardStripePainter({required this.stripeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final yellowPaint = Paint()..color = AppColors.safetyYellow;
    final inkPaint = Paint()..color = AppColors.ink;

    // 背景を黄で塗り、墨の斜めストライプを重ねる
    canvas.drawRect(Offset.zero & size, yellowPaint);

    final path = Path();
    for (double x = -size.height; x < size.width + size.height; x += stripeWidth * 2) {
      path.moveTo(x, size.height);
      path.lineTo(x + size.height, 0);
      path.lineTo(x + size.height + stripeWidth, 0);
      path.lineTo(x + stripeWidth, size.height);
      path.close();
    }
    canvas.drawPath(path, inkPaint);
  }

  @override
  bool shouldRepaint(covariant _HazardStripePainter oldDelegate) =>
      oldDelegate.stripeWidth != stripeWidth;
}
