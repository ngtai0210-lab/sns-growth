#!/usr/bin/env bash
# Slack通知スクリプト（VPS / Cursor / cron など Slack MCPが無い環境用）
# 使い方: ./scripts/notify-slack.sh "メッセージ本文"
# 事前準備: 環境変数 SLACK_WEBHOOK_URL を設定（または リポジトリ直下の .env に記載）
#   例) .env に  SLACK_WEBHOOK_URL=https://hooks.slack.com/services/XXX/YYY/ZZZ
#   ※ .env は .gitignore 済み。Webhook URLは秘密情報なので絶対にコミットしない。
set -euo pipefail

MSG="${1:-}"
if [ -z "$MSG" ]; then
  echo "usage: notify-slack.sh <message>" >&2
  exit 1
fi

# 環境変数優先。無ければ .env から読む
DIR="$(cd "$(dirname "$0")/.." && pwd)"
if [ -z "${SLACK_WEBHOOK_URL:-}" ] && [ -f "$DIR/.env" ]; then
  SLACK_WEBHOOK_URL="$(grep -E '^SLACK_WEBHOOK_URL=' "$DIR/.env" | head -1 | cut -d= -f2- | tr -d '\r' || true)"
fi
if [ -z "${SLACK_WEBHOOK_URL:-}" ]; then
  echo "SLACK_WEBHOOK_URL not set (env も .env も未設定)" >&2
  exit 1
fi

# 本文をJSON文字列に安全にエンコード
if command -v python3 >/dev/null 2>&1; then
  PAYLOAD=$(printf '%s' "$MSG" | python3 -c 'import json,sys; print(json.dumps({"text": sys.stdin.read()}))')
else
  # python3が無い場合の簡易フォールバック（改行・ダブルクオートのみ対応）
  ESC=$(printf '%s' "$MSG" | sed 's/\\/\\\\/g; s/"/\\"/g' | awk 'BEGIN{ORS="\\n"}{print}')
  PAYLOAD="{\"text\": \"$ESC\"}"
fi

curl -sS -X POST -H 'Content-type: application/json' --data "$PAYLOAD" "$SLACK_WEBHOOK_URL" >/dev/null \
  && echo "slack: sent" \
  || { echo "slack: failed" >&2; exit 1; }
