# App Store Connect 課金登録ガイド

作成日: 2026-06-07 / 対象: コンテンツパック3商品（すべて買い切り・¥200）

## 0. 前提チェックリスト

- [ ] Apple Developer Program に加入済み
- [ ] **Paid Applications 契約**: App Store Connect > Agreements, Tax, and Banking で
      「Paid Apps」契約に同意し、銀行口座・税務情報を登録（**これが終わらないとIAPは作れない**）
- [ ] アプリ本体のApp record作成: My Apps > + > New App
      （Bundle ID: `com.genba.nihongo`、SKU任意、プライマリ言語: 日本語）

## 1. 登録する3商品（コピペ用）

すべて **タイプ: 非消耗型（Non-Consumable）/ 価格: ¥200**

### 商品1: JLPT対策パック

| 項目 | 値 |
|------|-----|
| 参照名（Reference Name） | `JLPT N3/N2 Pack` |
| 製品ID（Product ID） | `com.genba.nihongo.pack.jlpt_n3n2` |
| 価格 | ¥200 |
| 表示名（日本語） | JLPT N3/N2対策パック |
| 説明（日本語） | N3・N2の文法・語彙・漢字読みドリル120問を解錠 |
| 表示名（インドネシア語） | Paket Latihan JLPT N3/N2 |
| 説明（インドネシア語） | 120 soal tata bahasa, kosakata, kanji N3/N2 |

### 商品2: 介護フレーズパック

| 項目 | 値 |
|------|-----|
| 参照名 | `Kaigo Phrase Pack` |
| 製品ID | `com.genba.nihongo.pack.kaigo` |
| 価格 | ¥200 |
| 表示名（日本語） | 介護フレーズパック |
| 説明（日本語） | 介護現場の声かけ・介助フレーズ100件を解錠 |
| 表示名（インドネシア語） | Paket Frasa Perawatan |
| 説明（インドネシア語） | 100 frasa perawatan: sapaan & bantuan kerja |

### 商品3: 漢字辞書パック

| 項目 | 値 |
|------|-----|
| 参照名 | `Kanji Dictionary Pack` |
| 製品ID | `com.genba.nihongo.pack.kanji_dict` |
| 価格 | ¥200 |
| 表示名（日本語） | 漢字辞書パック |
| 説明（日本語） | 単漢字167字の音訓読み・意味・逆引きを解錠 |
| 表示名（インドネシア語） | Paket Kamus Kanji |
| 説明（インドネシア語） | 167 kanji: on-kun, arti, dan kata terkait |

> ⚠️ **製品IDは登録後に変更・再利用できません**。`lib/data/iap/product_catalog.dart` の
> 値と1文字も違わないようコピペしてください。

## 2. App Store Connect での登録手順

1. My Apps > （アプリ）> 左メニュー「**収益化 > App内課金**」> 「+」
2. タイプ: **非消耗型** を選択
3. 参照名・製品IDを上の表からコピペ → 作成
4. 価格表（Price Schedule）: **¥200** を選択
5. ローカリゼーション: 「+」で **日本語** と **インドネシア語** を追加し、表示名・説明を貼り付け
6. **審査用スクリーンショット**: アプリのストア画面（設定 > コンテンツパック）のスクショをアップ
   - シミュレータ(iPhone 6.5インチ以上)でストア画面を開いて ⌘S で撮ればOK
7. **審査メモ（Review Notes）** に以下を貼り付け:
   ```
   購入導線: ホーム > JLPT演習問題 > N2カードの「解錠する」ボタン、
   またはホーム > 設定タブ > コンテンツパック からストア画面を開けます。
   購入の復元はストア画面下部および設定タブにあります。
   コンテンツは買い切りでアプリ内に同梱されており、購入後はオフラインで利用できます。
   ```
8. ステータスが「**送信準備完了（Ready to Submit）**」になればOK
9. 3商品とも同様に登録

> 📌 **初回のIAPはアプリ本体の審査と一緒に提出します**。
> App Storeの「バージョン情報」ページ下部の「App内課金」セクションで
> 3商品を選択してからアプリを審査提出してください。

## 3. ローカルテスト（ASC登録前でも可能）

`ios/Products.storekit` に3商品定義済み。Xcodeでの設定:

1. Xcodeで `Runner.xcworkspace` を開く
2. **Product > Scheme > Edit Scheme... > Run > Options**
3. 「StoreKit Configuration」で **Products.storekit** を選択
4. ⌘R で実行 → ストア画面に¥200の商品が表示され、**実際の課金なしで購入フローをテスト**できる

テスト操作:
- 購入 → パックが解錠されることを確認
- **Xcode > Debug > StoreKit > Manage Transactions** で購入の削除（解錠状態のリセットはアプリ削除）・返金・購入失敗のシミュレーションが可能
- 「購入を復元」もこの構成で動作確認できる

> ⚠️ StoreKit Configurationを設定したままだと**本物のApp Storeに接続しない**ので、
> Sandbox/本番テストの際はSchemeの設定を「None」に戻すこと。

## 4. Sandboxテスト（ASC登録後・実機）

1. App Store Connect > **ユーザとアクセス > Sandboxテスター** でテストアカウント作成
   （実在しないメールでOK。本物のApple IDは使わない）
2. 実機: 設定 > App Store > 下部の「サンドボックスアカウント」にサインイン
3. アプリから購入 → `[Environment: Sandbox]` 付きの購入ダイアログが出れば成功
4. 確認項目:
   - [ ] 購入 → 即解錠（N2演習問題・介護カテゴリ・構成漢字）
   - [ ] アプリ削除 → 再インストール → 「購入を復元」で再解錠
   - [ ] 機内モードで購入済みコンテンツが利用できる
   - [ ] 別パックは独立してロックされたまま

## 5. 提出前の最終チェック

- [ ] App Privacy（ASC）: データ収集「なし」のまま、購入はAppleが処理する旨に整合
- [ ] アプリ説明文にコンテンツパックの紹介を追加（読解・聴解は含まない旨を誠実に）
- [ ] `flutter build ipa` でリリースビルド → ASCへアップロード
