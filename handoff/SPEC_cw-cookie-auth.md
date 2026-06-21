# AJ向け指示：CWログインを「クッキー方式」に変更（パスワード非保存）

> 対象：Yserver/aio-os の `/root/aio-os/scripts/cw/save_session.py` ＋ watcher
> 目的：**CWのパスワードをVPSに平文保存しない**。社長が自分のPCでログイン→クッキーをVPSに置く方式へ。
> 背景：現状 `save_session.py` は `CROWDWORKS_USERNAME/PASSWORD` を要求する。これを廃し、クッキー読込に変更。

## 変更内容
1. **`CROWDWORKS_USERNAME/PASSWORD` への依存を削除**（自動ログインしない）。
2. **クッキーファイルを読み込んでセッションを確立**する方式に変更：
   - 既定パス：`/root/aio-os/scripts/cw/cw_cookies.json`（`.gitignore` に追加・**コミット禁止**）
   - 対応フォーマット：ブラウザ拡張「Cookie-Editor」のJSONエクスポート形式（`[{name,value,domain,path,...}]`）を想定。
3. HTTPクライアントに応じて注入：
   - **requests系**なら：`session.cookies.set(name, value, domain=..., path=...)` をループで投入。
   - **Playwright/Selenium系**なら：`context.add_cookies([...])`。
4. **疎通確認**：クッキー投入後、CWのログイン必須ページ（例：マイページ/メッセージ一覧）を1回GETし、ログイン状態かを判定。
   - OK → `cw_session.json`（既存の保存先）にセッション保存し「✅ CWセッション確立」。
   - NG → 「⚠️ CWクッキー無効/期限切れ。再エクスポート要」を返す。

## watcher 連携
- watcher は保存済みセッション/クッキーで動作（送信なし・通知のみは維持）。
- **クッキー期限切れを検知したら Slack に通知**：
  `notify_slack("⚠️ CWセッション切れ。PCで再ログイン→cw_cookies.json再アップロードを")`
- 既存スレッド返信の自動送信は**引き続き不実装**（NEVER_DO_THIS_AGAIN遵守）。

## 社長の運用（人手・パスワードはVPSに渡らない）
1. 自分のPCのブラウザでCW（crowdworks.jp）にログイン（2FAもここで完了）。
2. 拡張「Cookie-Editor」等で crowdworks.jp のクッキーを **JSONでエクスポート**。
3. その内容を VPS の `/root/aio-os/scripts/cw/cw_cookies.json` に保存（scp/nano等）。
4. `python3 /root/aio-os/scripts/cw/save_session.py` を実行 → 「✅ CWセッション確立」を確認。

## セキュリティ
- `cw_cookies.json` と `cw_session.json` は `.gitignore`・**コミット禁止**。
- クッキーは期限あり。切れたら 1〜3 を再実行（watcherが切れを通知）。

## 完了報告
実装・疎通できたら `handoff/STATUS.md` に「CWクッキー方式 実装完了」を1行記載
（→ post-commitフックで社長へ自動Slack通知）。
