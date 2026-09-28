# コーディング規約（PHP・Laravel / TypeScript・React）

「健康応援口座システム」（healthsupportbank）の**コードの書き方**に関する規約。

本書は **PHP・Laravel（backend）** と **TypeScript / React（frontend）** の**コーディング規約に限定**する。
アーキテクチャ・インフラ・DB構成・CI/運用・Git運用フローは対象外とし、以下を参照する。

- 全体構成・レイヤ設計・決定ログ: [ARCHITECTURE.md](ARCHITECTURE.md)
- セットアップ・開発コマンド・Git運用: [../README.md](../README.md) / [../CLAUDE.md](../CLAUDE.md)
- 要件定義書（正・Box）: `要件定義書_第1版.docx`

---

## 1. 目的・適用範囲

- **目的**：社内・協力会社・Claude Code が同じ書き方でコードを書けるようにする。レビューを「内容」に集中させ、スタイルの指摘を自動化で無くす。
- **適用範囲**：`backend/`（PHP/Laravel）・`frontend/`（TypeScript/React）配下の実装コード。
- **優先順位**：本書 < 要件定義書・CLAUDE.md（矛盾する場合は上位が優先）。設計・運用ルールは各別文書が優先。

> **本書で扱わないもの**（別文書で規定）：features ごとのディレクトリ構成・レイヤ設計思想（ARCHITECTURE.md）、DBのMaster/Slave構成、監査ログ運用、法令適合、CIゲート、ブランチ戦略（README/CLAUDE.md）。
> ただし「コードの書き方に現れる部分」（例：Model層でのテナント絞り、冪等キーの実装、PIIをログに出さない）は本書で扱う。
---

## 2. 共通方針（両言語）

### 2.1 記述言語

- **コメント・docstring・コミットメッセージ・ドキュメントは日本語**。
- **識別子（変数・関数・クラス・型・ファイル名）は英語**。ローマ字表記は避ける（`kaiin` ではなく `member`）。

### 2.2 ツールで自動強制する

- 人手でスタイルを指摘しない。**PHP＝Laravel Pint**、**TypeScript＝Prettier + ESLint** で整形・検査する。
- コミット前に整形・検査を通す（`vendor/bin/pint` / `vendor/bin/pint --test` / `prettier --write` / `eslint`）。

### 2.3 秘密情報・個人情報を「コード」と「ログ」に出さない（最重要・両言語共通）

要件定義書 §6.2 / §6.3 / §7.2 に基づく、コードとして必ず守るルール。

- **秘密情報（APIキー・接続文字列・トークン・暗号鍵）をソースに直書きしない**。環境変数／`.env`（`.gitignore` 済み）／GitHub Secrets から読む。
- **PII・要配慮個人情報（氏名・住所・生年月日・受診情報・カード番号）をログ・例外メッセージ・レスポンス・URLクエリに出さない**。
- 開発・テストは**ダミー／匿名化データ**で行う（本番PIIをコード・テストデータ・ログに持ち込まない）。
- 突合キーは**正規化＋ハッシュ**で扱い、平文で保存・ログ出力しない。

---

## 3. PHP / Laravel（backend）

### 3.1 ツール設定（Laravel Pint）

本リポジトリには `pint.json` は未作成。**Laravel既定プリセット**（PER Coding Style／PSR-12ベース）にそのまま従う。個別ルールを追加する場合は `pint.json` を作成し、変更理由をコメントで残す。

導入：`composer require --dev laravel/pint`（本リポジトリは導入済み）
整形：`vendor/bin/pint`　／　検査のみ（変更しない）：`vendor/bin/pint --test`
エージェントが実行する場合は `vendor/bin/pint --dirty --format agent` を使う（変更したファイルのみ対象。詳細は本リポジトリの `CLAUDE.md` の Boost 規約を参照）。

### 3.2 スタイル

- **文字列はシングルクォート**（`'text'`）。変数展開やエスケープが必要な場合のみダブルクォート可（Pint既定と一致）。
- **制御構造は必ず波括弧**（1行の `if`/`foreach` でも省略しない。PSR-12で規定される一般標準）。
- **引数・戻り値の型宣言必須**（`function isAccessible(User $user, ?string $path = null): bool`）。nullableは `?Type` で明示。
- **PHP 8のコンストラクタプロパティ昇格を使う**（`public function __construct(public GitHub $github) {}`）。空の `__construct()` は残さない（`private` コンストラクタ（シングルトン等でのインスタンス化制御目的）は例外）。
- **PHPDocはインラインコメントより優先**。インラインコメントは複雑なロジックにのみ付ける。配列の形は `@param array{id: int, name: string} $data` のように array shape で示す。
- **Enumのキーは TitleCase**（`FavoritePerson`, `Monthly`）。
- 1メソッドは1つの責務。長くなったら分割する。

### 3.3 命名

| 対象 | 規則 | 例 |
|---|---|---|
| 変数・メソッド | `camelCase` | `$memberId`, `grantPoints()` |
| クラス | `PascalCase` | `PointLedger`, `GifteeGateway` |
| 定数 | `UPPER_SNAKE_CASE` | `STOCK_OUT_THRESHOLD` |
| ファイル | PSR-4（クラス名と一致、`StudlyCase.php`） | `app/Features/Point/Services/PointService.php` |
| DBテーブル・カラム | `snake_case`、**ARCHITECTURE.md §5 のデータモデルに合わせる**（要件定義書 §7.1 の個人情報分離方針に基づく設計。テーブル設計自体は要件定義書の対象外＝別ファイル「テーブル設計書」の管轄） | `app_users`, `consents`, `orders`, `health_account`, `exchanges` |

- システム名「健康応援口座システム」と、ポイント機能 `health_account` を混同しない（コード上は機能名 `health_account`）。

### 3.4 ディレクトリ・アーキテクチャの一般規約

ディレクトリの全体設計・レイヤ設計は [ARCHITECTURE.md](ARCHITECTURE.md) §3/§4 が正（本節はコードの書き方の観点のみ）。
ARCHITECTURE.md の定める **`app/Features/<機能名>/{Http/Controllers, Http/Requests, Http/Resources, Services, Models, Gateways, Exceptions}`＋`app/Support/`** が本リポジトリの承認済み構成であり、Laravelの既定（`app/Http/Controllers` 等のフラット配置）から離れているのは意図的な設計判断である。**新しいベースフォルダを承認なく作らない**という原則は、この `Features/`・`Support/` 構成の**外側**に新設フォルダを追加する場合に適用する（例：`app/Legacy/` を新たに作る等）。`Features/<機能名>/` 配下に上記のサブディレクトリを作ること自体は、既に承認された構成に沿った作業であり許可を要しない。

- **Controllerは薄く保つ**。入力検証・DB操作・業務ロジックを直接書かない。
- **入力検証はForm Requestに書く**（`php artisan make:request`）。Controllerでの手書きバリデーションは避ける。
- **APIレスポンスの整形はEloquent API Resourceを使う**（`php artisan make:resource`）。配列を直接 `response()->json()` に渡さない（`HealthController` のような固定フォーマットの単純なヘルスチェック応答は例外）。
- **複雑な業務ロジック（決済・付与・在庫判定等）はServiceクラスに切り出す**。Controller・Modelに直接書かない。
- **外部API呼び出しはGatewayクラスに隔離する**（ARCHITECTURE.md §4）。Serviceから直接HTTPクライアントを叩かない。
- ファイル・クラスは `php artisan make:*` で作成し、生成先を `Features/<機能名>/` 配下の対応するサブディレクトリに移す（Laravelの生成コマンドは既定でフラット配置に出力するため、配置は都度確認する）。
- **機能間の直接参照は禁止**（ARCHITECTURE.md §4）。複数機能で共有するコードのみ `app/Support/` に置く。

### 3.5 Eloquent・マイグレーションの一般規約

- **マスアサインメント保護**：Modelには `$fillable`（許可リスト）を明示する。`$guarded = []` で無条件許可にしない。
- **N+1クエリ対策**：関連を事前に使うとわかっている場合は `with()` で eager loading する。ループ内で関連にアクセスしない。
- **マイグレーションは `php artisan make:migration` で作成**し、既存の命名パターン（例：`0001_01_01_000000_create_users_table.php`）に合わせる。
- **モデルを新規作成する際はfactory・seederも作る**（テストで使うため）。

### 3.6 例外・エラーハンドリング

- 業務エラーは**独自例外**を、機能固有なら `App\Features\<機能名>\Exceptions`、複数機能で共有するなら `App\Support\Exceptions` に定義して投げる。呼び出し側で種別ごとに扱えるようにする。
- 例外を握りつぶさない（`catch (Throwable) {}` で何もしないのは禁止）。捕捉したら**記録するか再送出**する（`HealthController` のようにフラグ化して呼び出し元に返す設計は許容される）。
- **例外メッセージにPII・秘密情報を含めない**。

```php
// OK: 種別を持つ独自例外・PIIを載せない
namespace App\Features\Member\Exceptions;

class MemberNotFoundException extends \Exception
{
    // 加入者マスタ突合で本人が特定できなかった。
}

// app/Features/Member/Services/MemberVerificationService.php
public function verifyMember(string $keyHash): string
{
    $memberId = Member::query()->where('key_hash', $keyHash)->value('id');
    if ($memberId === null) {
        throw new MemberNotFoundException(); // 入力値（氏名・生年月日）は載せない
    }
    return $memberId;
}
```

### 3.7 ログ

- `dd()` / `var_dump()` / `echo` を本番コードに残さない。`Illuminate\Support\Facades\Log` を使う。
- **ログにPII・カード番号・トークン・突合キー平文を出さない**。`context` 配列にも含めない。識別は `member_id`（非PII）で行う。
- 外部連携やお金の処理は、**成否と冪等キー**を残す（PIIは残さない）。

```php
// NG: PII・トークンをログに出している
Log::info("登録: 氏名={$name} 生年月日={$birthday} token={$accessToken}");

// OK: 非PIIの識別子と結果のみ
Log::info('会員登録に成功', ['member_id' => $memberId, 'tenant_id' => $tenantId]);
```

### 3.8 冪等・トランザクションの書き方

お金・ポイント・発注・外部通知は**冪等キー必須**（要件 §5.2.2 / §5.2.3）。

- 冪等キーを**メソッドの引数として明示**し、二重実行時は1回分になるよう実装する。
- 残高は直接更新せず、**台帳（明細）に追記して導出**する。
- 整合が必要な処理は**1トランザクション**にまとめる（`DB::transaction(function () { ... })`）。

```php
// OK: 冪等キー付き・トランザクション・台帳追記
public function grantPoints(string $memberId, int $amount, string $idempotencyKey): int
{
    return DB::transaction(function () use ($memberId, $amount, $idempotencyKey) {
        if ($this->ledgerExists($idempotencyKey)) {
            return $this->currentBalance($memberId); // 二重付与しない
        }
        $this->appendLedger($memberId, $amount, $idempotencyKey);
        return $this->currentBalance($memberId);
    });
}
```

### 3.9 外部連携クライアントの書き方

giftee for business / ペイジェント / 白石薬品CSV / LINE の呼び出しは**専用クライアント（gateway）に隔離**する（要件 §8）。

- **エンドポイント・トークンは `config/services.php` 経由で環境変数から取得**（直書き禁止）。
- 呼び出しは**冪等キー**を渡す。失敗・不明時は**残高/状態をロールバック**（または保留→突合で確定）。
- リトライは**冪等な操作に限定**。タイムアウトを必ず設定する。
- **カード情報はアプリを通さず決済代行（ペイジェント）へ直接**送る（アプリ・DBに保持しない）。

```php
// config/services.php に設定を集約（直書きしない）
// 'giftee' => ['base_url' => env('GIFTEE_BASE_URL'), 'token' => env('GIFTEE_TOKEN')],

use Illuminate\Support\Facades\Http;

public function issueGifteeBox(string $configCode, string $issueIdentity, int $initialPoint): GifteeBoxResult
{
    $response = Http::withToken(config('services.giftee.token'))
        ->timeout(10)
        ->post(config('services.giftee.base_url') . '/api/giftee_boxes', [
            'giftee_box_config_code' => $configCode,
            'issue_identity' => $issueIdentity, // 冪等キー
            'initial_point' => $initialPoint,
        ]);

    $response->throw();
    return $this->parseResult($response->json());
}
```

### 3.10 SQL の書き方（インジェクション対策・テナント絞り）

- **文字列連結・埋め込みでSQLを組み立てない**。Eloquent／Query Builderの**バインディング**を使う（`where('member_id', $memberId)` や `whereRaw('... = ?', [$value])`）。
- 列名・テーブル名を動的にする場合は**ホワイトリスト検証**してから使う。
- 業務クエリは**必ずテナント（保険者ID）で絞る**。テナント越境アクセスを禁止（要件 §6.3 / §7.2）。Model層（Eloquentのグローバル／ローカルスコープ）でテナント条件を強制する。

```php
// NG: 文字列に値を埋め込む（SQLインジェクション）
DB::select("select * from orders where member_id = '{$memberId}'");

// OK: バインディング＋Model層のテナントスコープで強制
Order::query()
    ->forTenant($tenantId) // ローカルスコープ。テナント条件を書き忘れない
    ->where('member_id', $memberId)
    ->get();
```

### 3.11 型変換・お金/ポイントの扱い

- **お金・ポイントは `float` の変数・プロパティ・DBカラムとして保持・蓄積・比較しない**。引数・戻り値・保存先は常に整数（最小単位＝円・ポイント）で扱う。
- 例外的に、**丸め処理の内部で率（rate）を掛ける一時的な計算式にのみ** `float` が経由することを許容する（`round()` 自体が `float` を扱う関数のため）。その結果は直後に整数へ丸め、以降は `float` の値を一切保持・比較・DB保存しない。
- 外部APIやDBから取得した数値は、使う前に想定した型（`int`）であることを確認してからキャストする。

### 3.12 お金・ポイントの丸め（銀行丸め）

金額・ポイントの端数処理は **銀行丸め（round half to even＝偶数丸め）** を使う。**四捨五入（round half up）は使わない**。

- 端数処理は PHP の `round()` に **`PHP_ROUND_HALF_EVEN`（銀行丸め）** モードを明示して行う。`PHP_ROUND_HALF_UP`（四捨五入、PHPの `round()` の既定モード）は使わない。
- 理由：丸め方向の偏りをなくし、多数の明細を集計したときの系統誤差を抑えるため。PHPの `round()` は既定では四捨五入（`PHP_ROUND_HALF_UP`）になるため、**モードを省略しない**。
- ただし**外部仕様（決済・税・白石薬品の連携等）で丸め方が指定されている場合は、その仕様に従う**（その旨をコメントで明記する）。

```php
// OK: 入出力はint（最小単位）。率を掛ける一時計算のみfloatを経由し、直後に整数へ丸める。
// $rateBasisPoints は万分率（例: 1000 = 10%）。float型の変数は作らずreturn式の中だけで完結させる。
function toDiscountPoints(int $amountYen, int $rateBasisPoints): int
{
    return (int) round($amountYen * $rateBasisPoints / 10000, 0, PHP_ROUND_HALF_EVEN);
}
```

### 3.13 テスト（PHPUnit）

- 配置は `tests/Feature/<機能名>/<機能>Test.php`（HTTP経由の挙動）／ `tests/Unit/<機能名>/<対象>Test.php`（単体）。`ARCHITECTURE.md` §3のディレクトリ構成（features ごとのテスト配置）に合わせる。作成は `php artisan make:test --phpunit {name}`（Feature）／ `--unit` オプション（Unit）。`make:test` の既定出力先はフラット配置（`tests/Feature/{name}.php`）のため、§3.4と同様に生成後は対応する `<機能名>/` サブディレクトリへ移す。
- **テストメソッド名は `test_snake_case` とする**（例：`test_health_returns_ok_when_database_is_reachable`）。これは既存コードの慣習であり、**PSR-1が定めるメソッド名camelCase原則とは異なる、Laravelエコシステム固有の例外**（Laravel Pintの既定プリセットもテストメソッドはこのルールの対象外にしている）。
- Model用のテストデータはfactoryを使う（手動で `new Model()` して埋めない）。
- **お金・ポイント・発注は冪等性をテスト**（同じ操作を2回実行しても二重にならない）。

```php
public function test_grant_is_idempotent(): void
{
    $key = 'evt-123';
    $this->service->grantPoints('m1', 100, $key);
    $this->service->grantPoints('m1', 100, $key); // 2回目

    $this->assertSame(100, $this->service->currentBalance('m1')); // 二重付与されない
}
```

### 3.14 禁止事項（PHP）

- ❌ 秘密情報・接続文字列・トークンの直書き（`config/services.php` 経由で `.env` から取得する）
- ❌ PII・カード番号・トークンをログ／例外メッセージに出す
- ❌ 文字列連結・埋め込みでのSQL組み立て（Eloquent／Query Builderのバインディングを使う）
- ❌ テナント条件を省いた業務クエリ
- ❌ `catch (Throwable) {}` 等での例外の握りつぶし
- ❌ 型宣言（引数・戻り値）無しのメソッド
- ❌ お金・ポイントを `float` 型の変数・プロパティ・DBカラムとして保持・蓄積・比較する（§3.11の丸め計算の一時式を除く）
- ❌ お金・ポイントの丸めに四捨五入（`PHP_ROUND_HALF_UP`、PHPの `round()` の既定）を使う（銀行丸め＝`PHP_ROUND_HALF_EVEN` を使う）

---

## 4. TypeScript / React（frontend）

### 4.1 ツール設定（`.prettierrc`）

```json
{
  "singleQuote": true,
  "semi": false,
  "printWidth": 100
}
```

導入：`npm install -D prettier eslint` ／ 整形：`npx prettier --write .` ／ 検査：`npx eslint .`

- `tsconfig.json` は **`strict: true`**。

### 4.2 スタイル

- **シングルクォート**、**セミコロン無し**（Prettier設定に従う）。
- **`any` 禁止**。型が不明なときは `unknown` で受けて絞り込む。
- 非同期は **async/await**。`.then()` チェーンは避ける。

### 4.3 命名

| 対象 | 規則 | 例 |
|---|---|---|
| コンポーネント | `PascalCase` | `PointBalance`, `OtcProductList` |
| フック | `useX`（camelCase） | `usePointBalance` |
| 変数・関数 | `camelCase` | `memberId`, `fetchProducts()` |
| 定数 | `UPPER_SNAKE_CASE` | `MAX_RETRY_COUNT` |
| 型・インターフェース | `PascalCase` | `Product`, `ExchangeResult` |
| ファイル | コンポーネント=`PascalCase.tsx`、その他=`camelCase.ts` | `PointBalance.tsx`, `api.ts` |

### 4.4 型

- API のレスポンス／リクエストは**型を定義**して使う（`any` で受けない）。
- サーバの型と重複する場合も、フロントで扱う形（表示用）の型を明示する。

```ts
// OK: レスポンス型を定義
type ExchangeResult = {
  exchangeId: string
  giftUrl: string
  remainingPoints: number
}

async function exchange(giftId: string): Promise<ExchangeResult> {
  return postJson<ExchangeResult>('/rewards/exchange', { giftId })
}
```

### 4.5 コンポーネント / フック

- **関数コンポーネント**のみ（クラスコンポーネント不可）。
- フックは**トップレベルで呼ぶ**（条件分岐・ループの中で呼ばない）。
- props は型で定義する。1コンポーネントが大きくなったら分割する。

### 4.6 状態・副作用

- `useEffect` の依存配列を正しく書く（ESLint の `exhaustive-deps` に従う）。
- 副作用（API呼び出し等）はイベントハンドラ or `useEffect` に閉じる。描画関数内で直接呼ばない。

### 4.7 API 呼び出しの集約

- API 呼び出しは **`features/<機能>/api.ts` に集約**する。コンポーネントから直接 `fetch` しない。
- 共通のリクエストラッパ（ベースURL・ヘッダ・エラー整形）を1か所に置く。
- エラーは呼び出し側（コンポーネント）で扱い、ユーザーに適切な表示を出す。

```ts
// features/points/api.ts に集約
export async function fetchBalance(): Promise<number> {
  const res = await apiClient.get<{ balance: number }>('/me/health-account')
  return res.balance
}
```

### 4.8 LIFF の作法

- `liff.init()` はアプリ入口で1回。`LIFF_ID` は **`import.meta.env.VITE_LIFF_ID`** から注入（直書きしない）。
- **IDトークンの検証は必ずサーバー側**で行う前提。フロントの判定を認可の根拠にしない。
- **スマホ限定ガード（`liff.isInClient()` / `getOS()`）はUX（正しい導線への誘導）であって、セキュリティ境界ではない**（改変可能）。保護は認証・認可で担保する（要件 §4.2 / §6.5）。

### 4.9 表示テキスト（医療・OTC）

- **スイッチOTCの対象・提示文言・注意喚起は医療監修データ由来**（サーバ／設定から取得）。**コードに治療助言的な文言を直書きしない**（要件 §4.3 / §9）。
- 「受診をやめない／薬剤師に相談」等の**注意喚起・相談導線は必須表示**として実装する。

### 4.10 セキュリティ（フロント）

- **PII を `console.log` に出さない／URLクエリに載せない**（要件のプライバシー方針）。
- トークン等の秘密情報を localStorage に不用意に置かない。
- 秘密値・エンドポイントは `import.meta.env` 経由（`VITE_` プレフィックスの値はビルドに埋まる＝公開前提なので、**本当の秘密はフロントに置かない**）。

### 4.11 禁止事項（TypeScript / React）

- ❌ `any` の使用
- ❌ コンポーネントからの直接 `fetch`（`features/<機能>/api.ts` に集約する）
- ❌ IDトークン・端末判定をフロントだけで認可の根拠にする
- ❌ 医療・OTCの提示文言をハードコード
- ❌ PII を `console.log`／URLに出す
- ❌ フックを条件分岐・ループ内で呼ぶ

---

## 5. 付録

### 5.1 コード観点のレビュー・チェックリスト

コードを書く／レビューするときに確認する（設計・運用の観点は ARCHITECTURE.md / README を参照）。

- [ ] 秘密情報・接続文字列を直書きしていない（env経由）
- [ ] PII・カード番号・トークンをログ／例外／レスポンス／URLに出していない
- [ ] お金・ポイント・発注・外部通知は冪等キー付きで、整合はトランザクション
- [ ] 業務クエリにテナント（保険者ID）条件がある
- [ ] SQL はバインドパラメータ（文字列連結していない）
- [ ] お金・ポイントの丸めは銀行丸め（`PHP_ROUND_HALF_EVEN`）で、四捨五入していない
- [ ] PHP：型宣言・シングルクォート・波括弧必須（Pint が緑）
- [ ] TS：`any` 無し・API は `api.ts` 集約（ESLint/Prettier が緑）
- [ ] 医療・OTC文言をハードコードしていない
- [ ] テスト（機能単位・冪等）がある

### 5.2 整形・検査コマンド

```powershell
# PHP / Laravel（backend）
vendor/bin/pint
vendor/bin/pint --test
php artisan test --compact
```

```powershell
# TypeScript / React（frontend）
npx prettier --write .
npx eslint .
```

### 5.3 用語

| 用語 | 意味 |
|---|---|
| PII | 個人を特定できる情報（氏名・住所・生年月日等） |
| 要配慮個人情報 | 健康・受診情報等、取扱いに特に配慮を要する個人情報 |
| 冪等 | 同じ操作を複数回実行しても結果が1回分になる性質 |
| 突合キー | 入力情報を正規化・ハッシュ化して加入者マスタと照合する鍵 |
| テナント | 健保（保険者ID）。マルチアカウント／マルチテナントの識別単位 |
| hold / capture / release | ポイント値引きの押さえ／確定／解放 |
