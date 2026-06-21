# SPEC — Cursor/VPS から Slack へリアルタイム通知

対象タスク：T-008
目的：Slack MCPが無い環境（VPS・cron・Cursorのシェル）からでも、
`#omochi_デプロイ` に直接通知を飛ばし、社長がスマホでリアルタイムに気づけるようにする。

## 仕組み
Slack **Incoming Webhook** ＋ `scripts/notify-slack.sh`。
- Claude Code は Slack MCP で投稿（既存）。
- Cursor / VPS / cron は **この webhook スクリプト**で投稿。
- 投稿先は同じチャンネル `#omochi_デプロイ`（webhook作成時にこのチャンネルへ紐付け）。

## セットアップ（1回・社長＋実装）
1. （社長）Slackで Incoming Webhook を作成し、`#omochi_デプロイ` に紐付け、URLを取得
   - api.slack.com/apps → Create New App → Incoming Webhooks をON → Add New Webhook to Workspace → チャンネル選択 → URLコピー
2. （社長）取得した URL を **`.env`** に記載（ローカル＋VPS両方）：
   ```
   SLACK_WEBHOOK_URL=https://hooks.slack.com/services/XXX/YYY/ZZZ
   ```
   ※ `.env` は `.gitignore` 済み。**公開リポジトリに絶対コミットしない。**
3. （VPS）`chmod +x scripts/notify-slack.sh`

## 使い方
```
./scripts/notify-slack.sh "📊 T-001 完了 — Threadsアダプタ実装、dry-run確認OK"
```

## いつ呼ぶか（Cursor）
- 📊 `STATUS.md` に「完了」「要相談」を追記したとき
- 🔴 `DECISIONS.md` に「要承認」を追記したとき（要点＋GitHub全文リンク）
- ⚠️ 作業を止めて社長の判断を待つとき
→ STATUS/DECISIONS への追記と**セットで** notify-slack.sh を1回呼ぶ。

## メッセージ書式（推奨）
先頭に絵文字で種別を示す：`🔴要承認` / `📊進捗` / `⚠️停止`。
要承認は必ず「何を・なぜ・金額/リスク・GitHub全文リンク」を含める。

## セキュリティ
- Webhook URL = 秘密情報。`.env` のみ。コミット・ログ出力・Slack本文に含めない。
- お金が動く操作・CW返信送信は「通知するだけ」。実行は社長の手（不変ルール）。

## フォールバック
webhook未設定／投稿失敗の場合は、Cursorは `STATUS.md` に `[要Slack通知]` と明記。
Claude Code が次サイクルで Slack MCP 経由で代理投稿する（取りこぼし防止）。
