# リリース提出チェックリスト（v1.1.0 / iOS）

作成: 2026-06-08 / アプリ: 現場にほんご（com.genba.nihongo）

## コード側の状態（検証済み 2026-06-08）

- [x] バージョン: `1.1.0+2`（pubspec.yaml）
- [x] RevenueCat 公開SDKキー設定済み（revenuecat_config.dart）
- [x] data_version: phrases=5 / quizzes=8 / kanji=3
- [x] `dart analyze` クリーン / `flutter test` 全98パス
- [x] `flutter build ios --release --no-codesign` 成功（コンパイル確認済み）
- [ ] develop → main マージ + タグ `v1.1.0`（リリース確定時に実施）

## アップロード手順（Xcode）

1. Xcodeで `ios/Runner.xcworkspace` を開く
2. **スキームの StoreKit Configuration が「None」** であることを確認（Edit Scheme > Run > Options）
3. 上部のデバイス選択を **「Any iOS Device (arm64)」** に
4. **Signing & Capabilities**: Team を選び「Automatically manage signing」が有効か確認
5. メニュー **Product > Archive**（Flutter側は `flutter build ipa` でも可。出力 build/ios/ipa/）
6. Organizer が開いたら **Distribute App > App Store Connect > Upload**
7. アップロード完了後、ASCの TestFlight に表示されるまで数分〜十数分待つ

## App Store Connect での設定

### アプリ情報・ローカリゼーション（必須）
- [ ] **言語を2つ追加**: 日本語 と **インドネシア語**（Bahasa Indonesia）
      ※ id を追加しないと、インドネシア語端末ユーザーに日本語テキストが表示される
- [ ] 名前・サブタイトル・キーワード: [store-listing.md](./store-listing.md) を ja/id それぞれに貼る
- [ ] プロモーション・説明文・リリースノート: [store-text.md](./store-text.md) を ja/id それぞれに貼る

### URL（必須）
- [ ] **サポートURL**: 問い合わせ先（メール `web-studio@ymail.ne.jp`）を載せたWebページ
- [ ] **プライバシーポリシーURL**: アプリ内と同内容のWebページ（GitHub Pages等）
      ※ App内テキストだけでは不可。Web掲載が必須
- [ ] マーケティングURL（任意）

### スクリーンショット（必須）
- [ ] 6.7インチ（必須サイズ）。可能なら6.5/5.5も
- [ ] 公開用スクショ（ホーム・フレーズ・漢字・演習・ストア等）※別途構成案で作成予定

### App内課金（IAP）
- [ ] 3商品とも「送信準備完了」になっているか
      （com.genba.nihongo.pack.jlpt_n3n2 / .kaigo / .kanji_dict、各¥200）
- [ ] 各商品に **審査用スクリーンショット**（コンテンツパック画面）と審査メモを設定
- [ ] バージョンの「App内課金」セクションで **3商品を選択**してから提出

### App Privacy（プライバシーラベル）
- [ ] データ収集: **購入（Purchases）→ アプリ機能のため、ユーザーに紐付けない**
      （RevenueCat経由でレシート情報を送信。氏名・連絡先は収集しない）
- [ ] トラッキング: なし

### 審査メモ（App Reviewへの情報）
```
本アプリは日本で働くインドネシア人向けの日本語学習アプリです。
学習機能は完全オフラインで動作します。
アプリ内課金（コンテンツパック）はRevenueCat経由でApp Storeと通信します。
購入導線: ホーム > JLPT演習問題 > N2カード、または 設定 > コンテンツパック。
購入の復元: ストア画面下部および設定タブ。
サンドボックステスト済み。
```

## 提出
- [ ] ビルドを選択 → 「審査へ提出」
- [ ] 初回はIAPとアプリ本体を**同時に審査提出**
