/// RevenueCatのAPIキー設定
///
/// RevenueCatダッシュボード > Project Settings > API keys の
/// 「Apple App Store」の公開SDKキー（appl_ で始まる）を貼り付ける。
///
/// ※ 公開SDKキーはアプリに埋め込む前提のキーのため、リポジトリに
///   含めて問題ない。Secret keyは絶対にここに書かないこと。
const String revenueCatAppleApiKey = 'appl_ekcecTtBemOogNhARVqTNPydOmU';

/// APIキーが設定済みかどうか
bool get isRevenueCatConfigured =>
    !revenueCatAppleApiKey.contains('REPLACE_WITH');
