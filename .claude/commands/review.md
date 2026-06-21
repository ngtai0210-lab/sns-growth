---
description: 未コミット変更をレビュー（型・セキュリティ・不要コード）
---
現在の未コミット変更（`git diff` と `git status`）をレビューし、日本語で報告して：

1. 変更点の要約
2. セキュリティ：`.env`・APIキー・トークン・Webhook URL の混入やハードコードがないか
3. 型チェック：`npm run typecheck` を実行し、エラーがあれば該当箇所を指摘
4. 不要・重複コード、明らかなバグ

注意：このプロジェクトに lint / test スクリプトは未定義（`package.json` は `typecheck` と `build` のみ）。実行は `npm run typecheck`（必要なら `npm run build`）に限る。ファイルは変更しない（指摘のみ）。秘密情報の値は表示しない。
