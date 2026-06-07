# 収益化戦略・アプリ内課金(IAP)仕様

作成日: 2026-06-07

## 収益化方針

### 前提: ユーザー特性
- 技能実習生(手取り12〜15万円程度、母国送金あり)→ **価格感度が極めて高い**
- 学習ニーズは切実(安全・キャリア・在留資格に直結)→ 役立つコンテンツへの支払い動機は強い
- 完全オフライン・サーバーレス → ランニングコストがなく、**買い切りが誠実**

### 決定事項
- **モデル**: コンテンツパック買い切り(non-consumable、¥300〜600想定)
- **既存コンテンツは全部無料のまま維持**(既存ユーザーから何も取り上げない)
- サブスク・広告は採用しない(価格感度・学習体験・プライバシーポリシーとの整合のため)
- まずiOS(App Store)。実装は両OS対応のin_app_purchaseを使用し、将来のAndroid展開に備える

### 商品ロードマップ
| フェーズ | 商品 | packId | 状態 |
|---------|------|--------|------|
| 1 | JLPT N3/N2対策パック | `jlpt_n3n2` | **コンテンツ実装済み**（クイズ100問: N3文法25+語彙25 / N2文法25+語彙25）。App Store Connect商品登録待ち |
| 2 | 介護フレーズパック | `kaigo` | 未着手 |
| 2 | 建設フレーズパック | `kensetsu` | 未着手 |
| 2 | 食品製造フレーズパック | `shokuhin` | 未着手 |

### JLPT N3/N2対策パックの内容（quizzes.json data_version: 3）
- 無料: N3クイズ100問（従来どおり）
- 有料（pack_id: jlpt_n3n2）: **計140問**
  - N3対策70問: 文法25（id 101-125）+ 語彙25（id 126-150）+ 漢字読み20（id 201-220）
  - N2対策70問: 文法25（id 151-175）+ 語彙25（id 176-200）+ 漢字読み20（id 221-240）
- 現場文脈の出題（〜ざるを得ない、〜かねない、是正・手配・稼働などの実務語彙）
- 漢字読み問題の語は既存の漢字カード100語と重複しない（テストで担保）
- ホームに「N2クイズに挑戦」カード（JIS青）。未購入時はロック表示→ストアへ誘導
- N3クイズは無料100問+解錠時170問に自動拡大（randomQuizzesProviderの解錠フィルタ）

### 本試験との対応（誠実な説明のために）
| JLPTセクション | カバー | 備考 |
|--------------|:---:|------|
| 文字・語彙（漢字読み） | ✅ | 漢字読み40問 |
| 文字・語彙（文脈規定など） | ✅ | 語彙50問 |
| 文法（文法形式の判断） | ✅ | 文法50問 |
| 文法（並べ替え）・読解・聴解 | ❌ | 商品説明で「文法・語彙・漢字のドリル」と明記すること |

## 技術仕様

### アーキテクチャ
```
lib/data/iap/
├── product_catalog.dart      # 商品ID ⇔ packId の対応表（ここに商品を追加する）
└── purchase_service.dart     # in_app_purchaseの薄いラッパー（テスト時はモック）
lib/data/repositories/
└── purchase_repository.dart  # 解錠状態のローカル永続化（purchasesテーブル）
lib/presentation/providers/
└── purchase_provider.dart    # EntitlementNotifier（解錠集合+購入フロー状態）
lib/presentation/screens/store/
└── store_screen.dart         # パック一覧・購入・復元
lib/presentation/widgets/
└── locked_content_banner.dart # ロックコンテンツの共通バナー
```

### 解錠の仕組み(サーバーレス)
1. コンテンツはアプリに同梱(`phrases.json` / `quizzes.json` の `pack_id` フィールド、null=無料)
2. 起動時の既存data_version同期で全データ(無料+有料)をDBに投入
3. 購入完了時に `purchases` テーブルへ書き込み(冪等)
4. **表示時に解錠フィルタ**(`isContentUnlocked` / `filterUnlockedContent` 純粋関数)で出し分け
5. 解錠判定はローカルDBのみ参照 → **オフラインでも購入済みコンテンツが使える**

### 購入フローの要点
- 起動直後に `purchaseStream` を購読(`main.dart` で `entitlementProvider` をwatch)
  → 中断したトランザクションやアプリ外での購入完了を回収
- `purchased`/`restored` → DB書き込み → `completePurchase`(必須)
- `canceled` → 静かにidleへ / `pending` → 承認待ち表示 / `error` → エラー表示+トランザクション解放
- 「購入を復元」はストア画面と設定画面の2箇所(App Store審査の必須要件)

### 新パック追加の手順
1. `product_catalog.dart` の `ProductCatalog.all` に `ContentPack` を追加
2. App Store Connect に同じproductIdでNon-Consumable商品を登録
3. `phrases.json` / `quizzes.json` に `pack_id` 付きコンテンツを追記し `data_version` をインクリメント
4. 必要に応じてロックゲートUI(`LockedContentBanner`)を該当画面に設置

## App Store対応チェックリスト

- [ ] App Store Connect: Non-Consumable商品登録(jlpt_n3n2)
- [ ] Agreements / Tax / Banking 完了
- [ ] App Privacy(Nutrition Label)の更新
- [x] 「購入を復元」ボタン(ストア画面 + 設定画面)
- [x] 買い切りである旨の明示(ストア画面の説明文)
- [x] プライバシーポリシー更新(課金時のApple通信について)
- [x] 利用規約更新(第8条/Pasal 8: 有料コンテンツ・返金はAppleポリシー準拠)

## テスト

- ユニットテスト: `test/unit/providers/entitlement_test.dart`(購入ステータス処理)、
  `test/unit/models/pack_id_test.dart`(モデルround-trip)、
  `test/unit/data/database_migration_test.dart`(DB v5→v6)
- StoreKit Testing: Xcodeで `.storekit` 構成ファイルを作成し、購入/復元/キャンセル/pendingをシミュレート
- Sandbox: 実機+Sandbox Apple IDで実購入→解錠→再インストール→復元→機内モードで利用確認
