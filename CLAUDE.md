# CLAUDE.md — sns-growth

SNS（X / Threads）運用自動化プロジェクト。Claude Code は起動時にこのファイルを読み、毎回の前提として扱う。

## プロジェクト概要

- 目的: SNS投稿の生成・スケジュール・リンクページ/ショート生成・Slack通知の自動化
- 技術: TypeScript（`tsx` / `tsc`）, `@anthropic-ai/sdk`, `commander`, `luxon`, `dotenv`
- リポジトリ: `github.com/omochi-ai/sns-growth`（ブランチ: `master`）
- git ID: おもち / `omochi@users.noreply.github.com`（noreplyメールを維持＝実メールをコミットしない）

## よく使うコマンド

- `npm run typecheck` … 型チェック（`tsc --noEmit`）。変更後はまずこれ。
- `npm run build` … TypeScriptビルド
- `npm run autopost` … 投稿処理（`tsx src/cli.ts`）。**実投稿につながるので必ず確認してから実行**
- `npm run build:linkpage` … リンクページ生成

## ディレクトリ規約

```
src/        … コード本体（autopost / linkpage / shorts / cli.ts）
content/    … 投稿原稿・素材（md）
strategy/   … 戦略ドキュメント
data/       … 入力データ（posts.json はGit管理外）
handoff/    … 引き継ぎ。SPEC_*, STATUS.md, TASKS.md, DECISIONS.md
linkpage/   … リンクページ設定
scripts/    … 運用スクリプト（notify-slack.sh など）
exports/, output/, logs/ … 生成物（Git管理外）
```

作業を始める前に `handoff/STATUS.md` と `handoff/TASKS.md` を確認し、続きから進める。仕様は `handoff/SPEC_*.md` を参照する。

## 秘密情報の扱い（最重要）

- `.env` は **読み上げ・出力・コミットしない**。`.gitignore` で保護済み（この設定を弱めない）。
- 新しいキーが要るときは `.env.example` にキー名だけ追記し、実値はユーザーが `.env` に入れる。
- APIキー・トークンが必要な確認では、値ではなく「キー名と有無」だけを報告する。

## Git運用

- `master` への直接 push はしない。push 前に差分を提示して確認を取る。
- `git push --force` / `git reset --hard` / `git filter-branch` は実行しない（提案のみ、ユーザー確認後）。
- コミット前に `git status` と `git diff` を確認し、`.env` や `logs/`・`output/`・`exports/` の生成物が混入していないか点検する。

## 自動投稿・通知の安全ルール

- 実際のSNS投稿は慎重に。まず下書き/スケジュール（`exports/x-scheduler.csv` 等）を作り、実投稿はユーザー確認後。
- `scripts/notify-slack.sh` は実際にSlackへ送信する。テスト送信も含め、送る前に内容と送信先を確認する。

## 応答スタイル

- 日本語。結論を先に、理由は後。
- 3ステップ以上の作業は手順を先に提示してから着手。
- 完了時は「やったこと」を1〜2文で。長い再説明はしない。

## やってはいけないこと

- 秘密情報の出力・コミット
- ユーザー確認なしの 実投稿 / Slack送信 / push / 削除 / 公開
- `.gitignore` の秘密保護ルールを弱めること
