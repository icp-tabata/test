# 健康応援口座システム（healthsupportbank）

> ⚠️ 本システムは健康情報（要配慮個人情報）を扱う。個人情報の取り扱いについては
> 「[セキュリティ・個人情報の取り扱い](#セキュリティ個人情報の取り扱い)」を必ず読むこと。

## 概要

セルフメディケーション推進アプリ「健康応援口座システム」（LINEミニアプリ）。
健康行動（eラーニング・アンケート）→ OTC薬への切替 → 医療費適正化（データヘルス計画の成果指標）に寄与する。
LINE公式アカウントは健保ごとに開設するマルチテナント構成。詳細は要件定義の参照フォルダ（プロジェクト外。場所は各自の `CLAUDE.local.md` に書く）にある要件定義書 `要件定義書_第1版.docx` を正とする。

## 技術スタック

| 領域 | 採用技術 |
| --- | --- |
| フロントエンド | React + Vite + TypeScript + LIFF（会員はスマホのLINEアプリ内限定） |
| バックエンド | PHP 8.3以上（`composer.json` の制約。CI・開発環境は 8.4 / 8.5）+ Laravel 13 |
| ORM / DB | Eloquent / PostgreSQL（設計は更新Master・参照Slave。※read/write 分離は未実装） |
| Lint / Format | Laravel Pint（Laravel 既定プリセット＝PER/PSR-12 ベース）／ Prettier + ESLint |
| テスト | PHPUnit（`php artisan test`） |
| 決済 | 決済代行ペイジェント（リンク型・カード非保持・EMV 3-Dセキュア） |
| ポイント交換 | giftee for business |
| 実行環境 | さくらのクラウド（ISMAP）・医療情報ガイドライン第7版準拠 |

> バックエンドは 2026-09-16 に Python（FastAPI / SQLAlchemy）から PHP / Laravel へ変更した。
> 経緯は [`docs/ARCHITECTURE.md`](./docs/ARCHITECTURE.md) の「決定ログ」を参照。

## ディレクトリ構成（目標）

```
.
├── backend/                 # PHP / Laravel（app/Features/<機能名>/ ＋ app/Support/）
├── frontend/                # TypeScript / React（src/features/<機能名>/）
├── docs/ARCHITECTURE.md     # 構成・レイヤ設計・データモデル・決定ログ
├── docs/CODING_GUIDELINES.md# コーディング規約（PHP・Laravel / TypeScript・React）
├── .claude/                 # Claude Code の権限設定・スキル・サブエージェント（チーム共有）
└── .github/                 # CI・Dependabot・各種テンプレート
```

レイヤ構成（`Controller → Service → (Model / Gateway)`）と依存の向きの制約は
[`docs/ARCHITECTURE.md`](./docs/ARCHITECTURE.md) の §3・§4 が正。

**設計書は、次の3つの参照先（プロジェクト外。場所は各自の `CLAUDE.local.md` に書く）に置く。**

- 要件定義の参照フォルダ：要件定義書本体（`要件定義書_第1版.docx`）・画面一覧（`画面一覧.xlsx`）
- 基本設計の参照フォルダ：画面設計・DB設計・API設計・決済設計・セキュリティ設計など要件定義書からブレイクダウンした設計書一式（作成状況の進捗管理表は `00_設計書一覧.xlsx`）
- 画面モックの参照先：画面モックアップ（`screen-mock.html`）

## 現在のリポジトリの状態

**このリポジトリはまだ PHP / Laravel の実体を含んでいない。** 以下は未作成である。

- `backend/` / `frontend/` / `composer.json` / `package.json` / `artisan` / `vendor/`
- `.github/`（CI ワークフローを含む）

一方で、Python 時代の雛形（`pyproject.toml` / `requirements*.txt` / `src/healthsupportbank/` / `tests/test_smoke.py`）が残っている。
**下記「セットアップ」「開発コマンド」は `backend/` / `frontend/` 作成後に有効になる。** 現時点で実行できる検査・テストのコマンドは存在しない。

この節は事実の記述であり規範ではない。実体を作成した際は、コードと同じ PR でこの節を更新する。

## セットアップ

```powershell
# backend（PHP / Laravel）
cd backend
composer install
Copy-Item .env.example .env      # .env はコミットしない
php artisan key:generate
php artisan migrate

# frontend（TypeScript / React）
cd ../frontend
npm install
Copy-Item .env.example .env
```

## 開発コマンド

```powershell
# backend（backend/ ディレクトリ内で実行）
vendor/bin/pint                  # 整形
vendor/bin/pint --test           # 整形確認（変更しない）
vendor/bin/pint --dirty --format agent   # 変更ファイルのみ（エージェント用）
php artisan test --compact       # テスト
php artisan test tests/Feature/<機能名>/<機能>Test.php   # テスト（個別）
```

```powershell
# frontend（frontend/ ディレクトリ内で実行）
npx prettier --write .           # 整形
npx eslint .                     # 検査
```

コミット前にまとめて確認する場合:

```powershell
vendor/bin/pint --test ; php artisan test --compact
```

## 環境変数

`.env.example` を参照。実値は `.env` に記載し、**絶対にコミットしない**。
本番の資格情報は GitHub の Environment secrets で管理する。
外部連携（LINE・ペイジェント・giftee・白石薬品）のエンドポイント・トークンは、
コードに直書きせず **`config/services.php` 経由**で `.env` から読む。

現在のルートの `.env.example` は Python 時代のもので、以下の2件のみを定義している。

| 変数名 | 説明 |
| --- | --- |
| `APP_ENV` | 実行環境（`local` / `staging` / `production`） |
| `DATABASE_URL` | DB 接続文字列 |

`backend/` 作成時に、Laravel 規約のキー（`APP_KEY` / `DB_CONNECTION` / `DB_HOST` / `DB_DATABASE` 等）と
外部連携用のキーへ差し替える。

## 開発フロー

1. `main` から作業ブランチを作成する
   - 機能追加: `feature/<機能名>`
   - 不具合修正: `fix/<内容>`
   - その他: `chore/<内容>`
2. コミットメッセージは `<種別>: <要約>`（日本語）
   - 種別: `feat` / `fix` / `refactor` / `test` / `docs` / `chore`
   - 例: `feat: ポイント付与APIを追加`
3. Pull Request を作成する（テンプレートに従って記入）
4. CI が緑 かつ レビュー承認1件以上でマージ可能（※CI は未整備。`.github/workflows/` 作成時に有効化する）
5. マージは **Squash merge**。マージ後はブランチを自動削除

`main` への直接 push は禁止。

## セキュリティ・個人情報の取り扱い

- **秘密情報をコミットしない。** APIキー・パスワード・接続文字列は `.env`（→ `config/services.php`）または GitHub Secrets へ
- **本番の個人情報を開発・テスト・ログに持ち込まない。** テストデータはダミー値を使う
- **要配慮個人情報（健診結果・服薬情報等）をアプリ層のログに出力しない**（識別は `member_id` などの非PIIで行う）
- **カード情報はアプリ・DBに保持しない**（決済代行でトークン化する）
- **業務クエリはテナント（保険者ID）で絞る**（Model 層の Eloquent スコープで強制。テナント越境禁止）
- 誤って秘密情報を push した場合は、**まず該当の資格情報を失効・再発行**してから履歴の対応を行う
  （push 済みの情報は履歴を書き換えても漏洩したものとして扱う）

## コーディング規約・設計

- 開発ガイド（優先順位・禁止事項・ワークフロー）: [`CLAUDE.md`](./CLAUDE.md)
- 構成・レイヤ設計・データモデル・決定ログ: [`docs/ARCHITECTURE.md`](./docs/ARCHITECTURE.md)
- コーディング規約（PHP・Laravel / TypeScript・React）: [`docs/CODING_GUIDELINES.md`](./docs/CODING_GUIDELINES.md)
- 要件定義書・設計書一式・画面モック（正）: 要件定義の参照フォルダ・基本設計の参照フォルダ・画面モックの参照先（プロジェクト外。場所は各自の `CLAUDE.local.md` に書く）
