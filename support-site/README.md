# support-site — サポート / プライバシーポリシー 公開用ページ

App Store Connect の **サポートURL** と **プライバシーポリシーURL** に使う静的Webページ。

- `index.html` … サポートページ（問い合わせ先・FAQ）
- `privacy.html` … プライバシーポリシー（アプリ内表記と同内容）

日本語/インドネシア語の切り替えボタンつき。端末がインドネシア語なら初期表示が id になる。

## GitHub Pages で公開する手順

1. GitHubリポジトリの **Settings > Pages** を開く
2. 「Build and deployment」の Source を **Deploy from a branch** に
3. Branch を `main`（または `develop`）、フォルダを **`/ (root)`** ではなく **`/docs`** にはできないので、
   いずれかの方法で公開する：
   - **方法A（簡単）**: このリポジトリの Pages を有効化し、`support-site/` のファイルに
     `https://<ユーザー名>.github.io/<リポジトリ名>/support-site/index.html` でアクセス
   - **方法B**: `support-site/` の中身を `gh-pages` ブランチのルートに置く
4. 公開URLを App Store Connect に登録：
   - サポートURL → `.../support-site/index.html`
   - プライバシーポリシーURL → `.../support-site/privacy.html`

> 反映に数分かかることがあります。公開後、両URLがブラウザで開けることを必ず確認してください。

## 内容を更新したら
アプリ内のプライバシーポリシー（`lib/presentation/screens/legal/privacy_policy_screen.dart`）と
このページの内容は**一致させる**こと。最終更新日も両方そろえる。
