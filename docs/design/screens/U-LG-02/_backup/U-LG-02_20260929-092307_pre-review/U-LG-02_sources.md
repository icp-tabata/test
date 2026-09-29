# U-LG-02 メールアドレス登録 出典

| 該当箇所 | 項番 | 種別 | 出典ファイル | 出典箇所 | 補足 |
|---|---|---|---|---|---|
| 先頭の属性 `id`・`name` | 1 | 明記 | C:\test6\healthsupportbank\hld\要件定義\画面一覧.xlsx | シート「画面一覧」3行目（B3・E3） | |
| 先頭の属性 `category` | 2 | 明記 | C:\test6\healthsupportbank\hld\要件定義\画面一覧.xlsx | シート「画面一覧」3行目（D3） | |
| 先頭の属性 `authority` | 3 | 明記 | C:\test6\healthsupportbank\hld\要件定義\画面一覧.xlsx | シート「画面一覧」3行目（C3） | |
| 先頭の属性 `path` | 4 | 規約 | C:\test6\healthsupportbank\docs\design\README.md | 5章 画面の書き方 表「先頭の属性」の行（「決まっていなければ「未定」」） | 04 4.3【パス】（シート「画面設計」R64）は基点（/）のみを定め、本画面のパスを定めていない |
| 先頭の属性 `mock_id` | 5 | 明記 | C:\test6\healthsupportbank\hld\temp\screen-mock.html | 枠 U-LG-02（`span.id`「U-LG-02」） | |
| 先頭の属性 `screens` U-LG-01 | 6 | 明記 | C:\test6\healthsupportbank\hld\06_API設計.xlsx | シート「API設計」グループ1【本人確認の流れ】R190〜R191、【突合結果の扱い】R199 | 画面一覧.xlsx シート「遷移図（一般）」の図形「本人確認情報入力利用規約・ポリシー同意」→「加入者情報確認」→「メールアドレス登録 2回入力」の矢印とも一致する。画面名は画面一覧 2行目（E2） |
| 先頭の属性 `screens` U-LG-03 | 7 | 明記 | C:\test6\healthsupportbank\hld\要件定義\画面一覧.xlsx | シート「遷移図（一般）」の図形「メールアドレス登録 2回入力」から「確認コード入力」への矢印 | 06 シート「API設計」R168（A105 の画面欄に U-LG-03）・R193 とも一致する。画面名は画面一覧 4行目（E4） |
| 先頭の属性 `apis` A105 のメソッド・パス | 8 | 明記 | C:\test6\healthsupportbank\hld\06_API設計.xlsx | シート「API設計」R168（A105・POST・/api/member-verifications/email・画面 U-LG-02） | 名称は【TBD-001】 |
| 先頭の属性 `tables` TBL-CM-04: C | 9 | 導出 | C:\test6\healthsupportbank\hld\06_API設計.xlsx | シート「API定義」■A105 R203 | 受け取ったアドレスを暗号化してワンタイムパスワードの行に保持するため、行を作成する。テーブルIDは 05 シート「テーブル一覧」R5。新規登録では A104 は確認コードを送らない（シート「API定義」R163）ため、本画面の初回の要求の時点で行はない |
| 先頭の属性 `tables` TBL-CM-06: C | 10 | 明記 | C:\test6\healthsupportbank\hld\11_セキュリティ・個人情報保護.xlsx | シート「監査ログ対応表」R8（otp_send）・R63（POST /api/member-verifications/email） | テーブルIDは 05 シート「テーブル一覧」R7 |
| 1章「新規登録の手続きにおいて、本人のメールアドレスを登録し、確認コードの送信を求める画面である」 | 11 | 明記 | C:\test6\healthsupportbank\hld\06_API設計.xlsx | シート「API設計」グループ1【本人確認の流れ】R191（No.3） | 03 シート「認証・本人確認設計」3.2【登録フロー】R94〜R95、画面一覧 3行目（F3）とも一致する |
| 1章「本人確認情報入力での突合により、手続きが新規登録と確定した場合に表示する」 | 12 | 明記 | C:\test6\healthsupportbank\hld\06_API設計.xlsx | シート「API設計」グループ1【突合結果の扱い】R199、【本人確認の流れ】R190〜R191 | |
| 1章「再紐付けの場合は本画面を経由しない」 | 13 | 明記 | C:\test6\healthsupportbank\hld\06_API設計.xlsx | シート「API設計」グループ1【本人確認の流れ】R192 | |
| 1章「確認コードの送信先となり、個別の通知の送信先となる」 | 14 | 明記 | C:\test6\healthsupportbank\hld\06_API設計.xlsx | シート「API定義」■A105 R211（email の説明） | |
| 1章「登録の完了（06 A103）まで、暗号化してワンタイムパスワードの行に保持する。プロフィールは登録の完了まで作らない」 | 15 | 明記 | C:\test6\healthsupportbank\hld\06_API設計.xlsx | シート「API定義」■A105 R203〜R204 | |
| 1章「メールアドレスは2回入力させる」 | 16 | 明記 | C:\test6\healthsupportbank\hld\要件定義\画面一覧.xlsx | シート「遷移図（一般）」の図形「メールアドレス登録 2回入力」 | モックの枠 U-LG-02 の注記（「2回入力方式は遷移図に「メールアドレス登録 2回入力」と明記」）とも一致する |
| 1章「メールアドレスを、パス・問い合わせ文字列に含めない」 | 17 | 明記 | C:\test6\healthsupportbank\hld\04_画面設計.xlsx | シート「画面設計」4.3【個人を識別する値】R68 | |
| 1章「タブバーを表示しない」 | 18 | 明記 | C:\test6\healthsupportbank\hld\04_画面設計.xlsx | シート「画面設計」4.2【タブバー】R47 | モックの枠 U-LG-02 の `.screen` にも `data-tab` がない |
| 1章「主たるボタンを画面の下端へ固定しない」 | 19 | 導出 | C:\test6\healthsupportbank\hld\04_画面設計.xlsx | シート「画面設計」4.2【スクロール】R52〜R53 | 固定するのは U-SM-02・U-SM-04・U-SM-05 に限り、入力の画面では固定しないとするため |
| 2章「モック：`screen-mock.html` の U-LG-02 の枠（通常）」 | 20 | 明記 | C:\test6\healthsupportbank\hld\temp\screen-mock.html | 枠 U-LG-02（表題「メールアドレス登録」） | 呼び出しで渡された枠。モックに U-LG-02 の枠は1つのみ |
| 3章 一次トークン（手続きの種別：新規登録）の行（値・受け取る元） | 21 | 明記 | C:\test6\healthsupportbank\hld\06_API設計.xlsx | シート「API定義」■A104 R180〜R181（procedure・verification_token） | 手続きの種別と加入者IDを確定した一次トークンを A104 の応答で受け取る |
| 3章 一次トークン（手続きの種別：新規登録）の行（用いるイベント E02） | 22 | 明記 | C:\test6\healthsupportbank\hld\06_API設計.xlsx | シート「API定義」■A105 R206〜R207（認証：一次（手続きの種別が新規登録であること）） | |
| 3章 一次トークン（手続きの種別：新規登録）の行（「確認コード入力でも用いる。06 A102・A103 の認証は一次」） | 23 | 明記 | C:\test6\healthsupportbank\hld\06_API設計.xlsx | シート「API設計」R164〜R165（A102・A103 の認証「一次」・画面 U-LG-03）、【手続きと確認コードの対応】R218〜R220 | |
| 3章 入力したメールアドレスの行（値・受け取る元・用いるイベント E02） | 24 | 導出 | C:\test6\healthsupportbank\hld\temp\screen-mock.html | 枠 U-LG-02（「メールアドレス」「メールアドレス（確認）」の入力欄） | 本画面で入力を受け、E02 で A105 の email として送るため（06 シート「API定義」R211） |
| 3章 送信先のメールアドレス（伏せ字）・確認コードの有効期間の行（値・受け取る元 E02） | 25 | 明記 | C:\test6\healthsupportbank\hld\06_API設計.xlsx | シート「API定義」■A105 R215〜R216 | |
| 3章 送信先のメールアドレス（伏せ字）・確認コードの有効期間の行（用いるイベント 確認コード入力） | 26 | 導出 | C:\test6\healthsupportbank\hld\06_API設計.xlsx | シート「API設計」R168（A105 の画面欄に U-LG-02 と U-LG-03） | 応答の2項目は、本画面では表示しない（モックの枠 U-LG-02 に表示の要素がない）。A105 の画面欄にある本画面以外の画面は確認コード入力のみであり、本画面の遷移先も確認コード入力のみ（項番65）であるため、確認コード入力で用いる値として引き継ぐ |
| 3章の注記「メールアドレスは PII であり、サーバーでは可逆暗号化して保存する」 | 27 | 明記 | C:\test6\healthsupportbank\hld\11_セキュリティ・個人情報保護.xlsx | シート「セキュリティ・個人情報保護」11.1【保存】R38（PII（表示・配送）・メールアドレス・可逆暗号化） | |
| 4章 前文「初期値は、初期表示（E01）を終えた時点の値・文言とする。表示・活性の状態は 4.2 に示す。」 | 28 | 規約 | C:\test6\healthsupportbank\docs\design\README.md | 6章 画面の雛形「## 4. 表示項目」の前文 | |
| 4章 前文「固定の表記は画面のモックを正とする」 | 29 | 規約 | C:\test6\healthsupportbank\docs\design\README.md | 4.4 文言（「初期値の欄に画面のモックの表記を写す」）、1章（画面の配置等は画面のモックを正とする） | 04 との食い違いは【TBD-002】 |
| 4章 前文「入力の項目（No.3・No.4）は、項目名に「必須」を添えて示す」 | 30 | 明記 | C:\test6\healthsupportbank\hld\temp\screen-mock.html | 枠 U-LG-02（「メールアドレス」「メールアドレス（確認）」の `span.req`「必須」） | 04 シート「画面設計」4.4【必須】R102（必須である旨は画面に示す）による |
| 4章 No.1（項目・種類・取得元・初期値） | 31 | 明記 | C:\test6\healthsupportbank\hld\temp\screen-mock.html | 枠 U-LG-02（`h1`「メールアドレスの登録」） | 種類・取得元は 04 シート「画面設計」4.4【種類】R90・【取得元】R95 による |
| 4章 No.2（項目・種類） | 32 | 明記 | C:\test6\healthsupportbank\hld\temp\screen-mock.html | 枠 U-LG-02（見出しの下の説明文 `p.cp`） | 種類「説明文」は 04 シート「画面設計」4.4【種類】R90 から選んだ。取得元のメッセージIDは【TBD-003】 |
| 4章 No.2（初期値「メッセージの文言」） | 33 | 規約 | C:\test6\healthsupportbank\hld\04_画面設計.xlsx | シート「画面設計」4.4【取得元】R94、4.8【参照】R198〜R199 | 文言そのものを md に書かない |
| 4章 No.3（項目・初期値の項目名・プレースホルダ・未入力） | 34 | 明記 | C:\test6\healthsupportbank\hld\temp\screen-mock.html | 枠 U-LG-02（`label`「メールアドレス」、`div.in`「example@mail.jp」） | |
| 4章 No.3・No.4（種類「入力（テキスト）」） | 35 | 導出 | C:\test6\healthsupportbank\hld\04_画面設計.xlsx | シート「画面設計」4.4【種類】R90 | 入力は テキスト・数値・日付 から選ぶ。メールアドレスは数値・日付ではなく、06 A105 の email は string（シート「API定義」R211）であるため、テキストに一意に定まる |
| 4章 No.3・No.4（取得元「固定（項目名）」） | 36 | 規約 | C:\test6\healthsupportbank\hld\04_画面設計.xlsx | シート「画面設計」4.4【取得元】R95 | 項目名は画面の表記として固定とする。値は加入者が入力する |
| 4章 No.4（項目・初期値の項目名・プレースホルダ・未入力） | 37 | 明記 | C:\test6\healthsupportbank\hld\temp\screen-mock.html | 枠 U-LG-02（`label`「メールアドレス（確認）」、`div.in`「もう一度入力してください」） | |
| 4章 No.5（項目・種類・取得元 メッセージ I019） | 38 | 明記 | C:\test6\healthsupportbank\hld\15_メッセージ一覧.xlsx | シート「メッセージ」R44（I019・案内・①インライン） | モックの枠 U-LG-02 の `span.hint`「確認のため、同じアドレスを入力してください」と文言が一致する |
| 4章 No.5・No.6（初期値「メッセージの文言」） | 39 | 規約 | C:\test6\healthsupportbank\hld\04_画面設計.xlsx | シート「画面設計」4.8【参照】R198〜R199 | |
| 4章 No.6（項目・種類「表示（②画面内アラート）」・取得元 メッセージ I003） | 40 | 明記 | C:\test6\healthsupportbank\hld\15_メッセージ一覧.xlsx | シート「メッセージ」R28（I003・案内・②画面内アラート・埋め込み「送信元のドメイン」） | モックの枠 U-LG-02 の `div.alert`「受信設定のご確認」と文言が一致する。埋め込みの値は【TBD-004】 |
| 4章 No.7（項目・種類・取得元・初期値） | 41 | 明記 | C:\test6\healthsupportbank\hld\temp\screen-mock.html | 枠 U-LG-02（`div.btn`「確認コードを送信する」） | 取得元は 04 シート「画面設計」4.4【取得元】R95 による |
| 4.1 No.3（型「文字列」） | 42 | 明記 | C:\test6\healthsupportbank\hld\06_API設計.xlsx | シート「API定義」■A105 R211（email・string） | |
| 4.1 No.3・No.4（必須） | 43 | 明記 | C:\test6\healthsupportbank\hld\temp\screen-mock.html | 枠 U-LG-02（`span.req`「必須」） | 06 シート「API定義」R211 の email の必須「○」とも一致する |
| 4.1 No.4（型「文字列」・桁数「No.3 と同じ」・形式「No.3 と一致すること」） | 44 | 導出 | C:\test6\healthsupportbank\hld\temp\screen-mock.html | 枠 U-LG-02（`span.hint`「確認のため、同じアドレスを入力してください」） | 確認のため同じアドレスを入力させる欄であり（画面一覧 シート「遷移図（一般）」「メールアドレス登録 2回入力」）、No.3 と同じ値であることを要するため |
| 4.1 の注記「検証はクライアントとサーバーの双方で行い、サーバーの検証を正とする」 | 45 | 明記 | C:\test6\healthsupportbank\hld\04_画面設計.xlsx | シート「画面設計」4.4【入力の規則】R99 | |
| 4.1 の注記「No.4 は（06 A105）へ送らない。No.3 との一致の検証は画面で行う」 | 46 | 導出 | C:\test6\healthsupportbank\hld\06_API設計.xlsx | シート「API定義」■A105 R210〜R211 | A105 の要求の項目は email のみであり、確認の入力を受け取る項目がないため |
| 4.2 No.1〜6（初期の表示・表示の条件「常時」・活性「−」） | 47 | 導出 | C:\test6\healthsupportbank\hld\temp\screen-mock.html | 枠 U-LG-02（h1・p.cp・入力欄2つ・span.hint・div.alert） | 枠は1つ（通常）のみで、表示を切り替える条件の定めが出典にないため常時とする。表記は 04 シート「画面設計」4.4【表示条件】R104。見出し・説明文・入力・表示はボタン・リンクではないため活性の条件を持たない（4.4【活性の条件】R107） |
| 4.2 No.7（初期の表示「表示」・表示の条件「常時」） | 48 | 規約 | C:\test6\healthsupportbank\hld\04_画面設計.xlsx | シート「画面設計」4.4【活性の条件】R107〜R108 | ボタンは押せない状態でも消さずに非活性とする |
| 4.2 No.7（初期の活性「非活性」） | 49 | 明記 | C:\test6\healthsupportbank\hld\temp\screen-mock.html | 枠 U-LG-02（`div.btn.dis`「確認コードを送信する」） | 活性とする条件は【TBD-008】 |
| 4.2 No.7（非活性とする条件「E02 の応答を受け取るまで」） | 50 | 規約 | C:\test6\healthsupportbank\hld\04_画面設計.xlsx | シート「画面設計」4.9【二重送信】R217〜R218 | |
| 4.3「本画面に一覧はない」 | 51 | 明記 | C:\test6\healthsupportbank\hld\temp\screen-mock.html | 枠 U-LG-02（全要素） | 枠に一覧の要素がない |
| 4.4 前文「本画面は API から取得した値を表示しない」 | 52 | 導出 | C:\test6\healthsupportbank\hld\06_API設計.xlsx | シート「API設計」R161〜R169（グループ1の一覧で、画面欄に U-LG-02 を持つのは A104・A105 のみ） | A104 は本人確認情報入力で呼び、本画面では呼ばない（シート「API設計」R190）。A105 の応答は本画面に表示する項目を持たない（モックの枠 U-LG-02 に伏せ字・有効期間の表示がない） |
| 4.4 No.3（API の項目「メールアドレス」（`email`）） | 53 | 明記 | C:\test6\healthsupportbank\hld\06_API設計.xlsx | シート「API定義」■A105 R211 | |
| 4.4 No.3（テーブル・列・変換「暗号化する」） | 54 | 明記 | C:\test6\healthsupportbank\hld\06_API設計.xlsx | シート「API定義」■A105 R203 | 列は 05 シート「ワンタイムパスワード」R12（メールアドレス・mail_address・text・暗号化） |
| 4.4 送信先のメールアドレス（伏せ字）の行（API の項目） | 55 | 明記 | C:\test6\healthsupportbank\hld\06_API設計.xlsx | シート「API定義」■A105 R215（masked_email・送信先のメールアドレスを伏せ字で示す） | 名称は説明から「送信先のメールアドレス（伏せ字）」とした |
| 4.4 送信先のメールアドレス（伏せ字）の行（変換・算出） | 56 | 明記 | C:\test6\healthsupportbank\hld\06_API設計.xlsx | シート「API定義」【表記の規則】R36 | 送信先は受け取ったアドレス（R203「登録の完了（A103）までの送信先とする」） |
| 4.4 確認コードの有効期間の行（API の項目・「秒で示す」） | 57 | 明記 | C:\test6\healthsupportbank\hld\06_API設計.xlsx | シート「API定義」■A105 R216（otp_expires_in・integer・確認コードの有効期間（秒）） | |
| 4.4 送信先のメールアドレス（伏せ字）・確認コードの有効期間の行（「本画面では表示せず、確認コード入力へ引き継ぐ」） | 58 | 導出 | C:\test6\healthsupportbank\hld\06_API設計.xlsx | シート「API設計」R168（A105 の画面欄） | 項番26と同じ |
| 4.4 対象の行「ワンタイムパスワードは、一次トークンの加入者ID（`member_id`）の行とする」 | 59 | 導出 | C:\test6\healthsupportbank\hld\06_API設計.xlsx | シート「API設計」6.1【トークンの管理】R77（一次トークンは手続き種別・加入者ID・健保コードを保持） | A105 の要求は加入者IDを持たない（シート「API定義」R210〜R211）ため、加入者IDは一次トークンから引く。列は 05 シート「ワンタイムパスワード」R10 |
| 4.4「並び順：なし」 | 60 | 導出 | C:\test6\healthsupportbank\hld\06_API設計.xlsx | シート「API定義」■A105 R213〜R216 | 応答に一覧の項目がない |
| 5章 イベントの表 E01（契機・対象・API・遷移先） | 61 | 規約 | C:\test6\healthsupportbank\hld\04_画面設計.xlsx | シート「画面設計」4.5【表示時のイベント】R137〜R138、【API】R129、【遷移先】R133 | E01 を初期表示時とするのは書き方ルール 5章 表「5. イベント」の行 |
| 5章 イベントの表 E02（契機「ボタンの押下」・対象 No.7） | 62 | 明記 | C:\test6\healthsupportbank\hld\temp\screen-mock.html | 枠 U-LG-02（`div.btn`「確認コードを送信する」） | 契機は 04 シート「画面設計」4.5【契機】R119 から選んだ |
| 5章 イベントの表 E02（API） | 63 | 明記 | C:\test6\healthsupportbank\hld\06_API設計.xlsx | シート「API設計」グループ1【本人確認の流れ】R191（メールアドレス登録・POST /api/member-verifications/email） | |
| 5章 イベントの表 E02（「冪等キーを付与しない」）、E02 処理の内容 3「冪等キーは付与しない」 | 64 | 導出 | C:\test6\healthsupportbank\hld\06_API設計.xlsx | シート「API設計」6.1【冪等キー】R97〜R107 | 冪等キーで二重の実行を防ぐ API を7つ（A402・A406・A503・A708・A405・A611・A711）とし、A105 を含まない。共通のヘッダー（シート「API定義」R28）も 6.1【冪等キー】に定めるものに付与するとする |
| 5章 イベントの表 E02（遷移先 確認コード入力）、E02 処理の内容 4「確認コード入力へ遷移する」 | 65 | 明記 | C:\test6\healthsupportbank\hld\要件定義\画面一覧.xlsx | シート「遷移図（一般）」の図形「メールアドレス登録 2回入力」から「確認コード入力」への矢印 | 06 シート「API設計」【本人確認の流れ】R191・R193 とも一致する |
| E01 遷移元「本人確認情報入力（突合により手続きが新規登録と確定した場合）」 | 66 | 明記 | C:\test6\healthsupportbank\hld\06_API設計.xlsx | シート「API設計」グループ1【突合結果の扱い】R199 | |
| E01 前提条件「一次トークン（手続きの種別：新規登録）を保持している」 | 67 | 導出 | C:\test6\healthsupportbank\hld\06_API設計.xlsx | シート「API定義」■A105 R206〜R207 | 本画面が呼ぶ A105 は、手続きの種別が新規登録の一次トークンを要するため |
| E01 処理の内容 1「API を呼ばない。本画面は表示の時点で取得を行わない」 | 68 | 導出 | C:\test6\healthsupportbank\hld\04_画面設計.xlsx | シート「画面設計」4.5【表示時のイベント】R138 | 本画面が呼ぶ API は A105（E02）のみであり（4.4 前文の項番52）、表示の時点で取得する値がないため |
| E01 処理の内容 2「本人確認情報入力から遷移した場合は、No.3・No.4 を未入力とし、No.7 を非活性として表示する」 | 69 | 導出 | C:\test6\healthsupportbank\hld\temp\screen-mock.html | 枠 U-LG-02（入力欄のプレースホルダ表示・`div.btn.dis`） | A104 の応答は新規登録の場合にメールアドレスを返さない（06 シート「API定義」R180〜R183）ため、初期値となる値がない |
| E01 エラー時「なし（API を呼ばないため）」 | 70 | 導出 | C:\test6\healthsupportbank\hld\04_画面設計.xlsx | シート「画面設計」4.5【表示時のイベント】R138 | E01 は API を呼ばないため |
| E02 前提条件「No.7 が活性である」 | 71 | 規約 | C:\test6\healthsupportbank\hld\04_画面設計.xlsx | シート「画面設計」4.5【前提条件】R121〜R123 | 4.4 の活性の条件と対応させる |
| E02 処理の内容 2「No.7 を非活性とし、処理中である旨を示す」 | 72 | 規約 | C:\test6\healthsupportbank\hld\04_画面設計.xlsx | シート「画面設計」4.9【二重送信】R217 | |
| E02 処理の内容 3「No.3 の値を「メールアドレス」（`email`）として送る」 | 73 | 明記 | C:\test6\healthsupportbank\hld\06_API設計.xlsx | シート「API定義」■A105 R210〜R211 | |
| E02 処理の内容 3「一次トークンを Authorization: Bearer で付与する」 | 74 | 明記 | C:\test6\healthsupportbank\hld\06_API設計.xlsx | シート「API定義」■A105 R207（認証：一次）、【共通のヘッダー】R27、シート「API設計」【認証欄の凡例】R67 | |
| E02 処理の内容 3「No.4 は送らない」 | 75 | 導出 | C:\test6\healthsupportbank\hld\06_API設計.xlsx | シート「API定義」■A105 R210〜R211 | 項番46と同じ |
| E02 処理の内容 4「応答の「送信先のメールアドレス（伏せ字）」・「確認コードの有効期間」を保持し」 | 76 | 導出 | C:\test6\healthsupportbank\hld\06_API設計.xlsx | シート「API定義」■A105 R215〜R216 | 項番26と同じ。保持する場所は【TBD-009】 |
| E02 前提条件を満たさない場合「操作を受け付けない」 | 77 | 規約 | C:\test6\healthsupportbank\hld\04_画面設計.xlsx | シート「画面設計」4.5【前提条件】R122 | |
| E02 エラー時「7章による」 | 78 | 規約 | C:\test6\healthsupportbank\docs\design\README.md | 6章 画面の雛形「### E01 初期表示時」の「エラー時：7章による。」 | |
| 6章 前文「イベントが呼ぶ API による、テーブルの読み書きを示す（C：作成、R：参照、U：更新、D：削除）」 | 79 | 規約 | C:\test6\healthsupportbank\docs\design\README.md | 6章 画面の雛形「## 6. データの読み書き」の前文 | |
| 6章 ワンタイムパスワードの行（操作 C・対象の行 1行） | 80 | 導出 | C:\test6\healthsupportbank\hld\06_API設計.xlsx | シート「API定義」■A105 R203 | 項番9と同じ |
| 6章 ワンタイムパスワードの行（内容：加入者ID・一次トークンから引く） | 81 | 導出 | C:\test6\healthsupportbank\hld\05_DB設計書.xlsx | シート「ワンタイムパスワード」R10（加入者ID・member_id） | 加入者IDは一次トークンから引く（項番59と同じ） |
| 6章 ワンタイムパスワードの行（内容：メールアドレス・暗号化） | 82 | 明記 | C:\test6\healthsupportbank\hld\06_API設計.xlsx | シート「API定義」■A105 R203 | 列は 05 シート「ワンタイムパスワード」R12 |
| 6章 ワンタイムパスワードの行（内容：ワンタイムパスワード・ハッシュ） | 83 | 導出 | C:\test6\healthsupportbank\hld\05_DB設計書.xlsx | シート「ワンタイムパスワード」R13（ワンタイムパスワード・otp・NotNull・ハッシュ） | A105 は確認コードを送信し（06 シート「API定義」R202）、その行の ワンタイムパスワード は NotNull であるため、行を作成するときに記録する。確認コードはハッシュ化する（11 シート「セキュリティ・個人情報保護」R40） |
| 6章 ワンタイムパスワードの行（内容：有効期限日時・確認コードの有効期限は10分） | 84 | 導出 | C:\test6\healthsupportbank\hld\03_認証・本人確認設計.xlsx | シート「認証・本人確認設計」3.1【確認コードの仕様】R36（有効期限 10分） | 列は 05 シート「ワンタイムパスワード」R14（有効期限日時・NotNull）。13 シート「メール一覧」R5 も新規登録の確認コードの有効期限を10分とする |
| 6章 ワンタイムパスワードの行（内容：登録日時） | 85 | 導出 | C:\test6\healthsupportbank\hld\05_DB設計書.xlsx | シート「ワンタイムパスワード」R15（登録日時・insert_datetime・NotNull） | 行を作成するときに NotNull の列を記録するため |
| 6章 監査ログの行 | 86 | 明記 | C:\test6\healthsupportbank\hld\11_セキュリティ・個人情報保護.xlsx | シート「監査ログ対応表」R8（No.3 otp_send・確認コード発行）・R63（No.5 POST /api/member-verifications/email・otp_send・新規登録でメールアドレスを登録し確認コードを送信したとき） | 05 シート「監査ログ」R15（イベント種類・event_type） |
| 6章 注記「確認コードのメールは、API の処理の中でブラストエンジンの API を呼び出して送信する」 | 87 | 明記 | C:\test6\healthsupportbank\hld\13_運用・保守.xlsx | シート「運用・保守」13.7【送信の方式】R168 | 12 シート「バッチ・非同期処理」12.3【メール送信】R169 とも一致する |
| 6章 注記「メール送信依頼の行は作成しない」 | 88 | 導出 | C:\test6\healthsupportbank\hld\12_バッチ・非同期処理.xlsx | シート「バッチ・非同期処理」12.1 No.11 R73（確認コードは対象としない（APIの中で送信する）） | 13 シート「運用・保守」13.7【送信の方式】R168 は、データベースに記録した送信の依頼による送信を確認コード以外の通知に限る |
| 6章 注記「本画面のイベントでは、削除を行わない」 | 89 | 導出 | C:\test6\healthsupportbank\hld\06_API設計.xlsx | シート「API定義」■A105 R200〜R225 | A105 に行の削除の定めがない。本画面が呼ぶ API は A105 のみ |
| 6章 注記「プロフィールは作成しない。登録の完了（06 A103）のときに、ワンタイムパスワードの行に保持したアドレスをプロフィールへ移す」 | 90 | 明記 | C:\test6\healthsupportbank\hld\06_API設計.xlsx | シート「API定義」■A105 R204、■A103 R134 | |
| 7章 前文 | 91 | 規約 | C:\test6\healthsupportbank\hld\04_画面設計.xlsx | シート「画面設計」4.6【共通のエラー】R168〜R172 | 前文の文面は書き方ルール 6章 画面の雛形「## 7. エラー時」による |
| 7章 COM-0001 の行（エラー（コード）「形式が誤っている」） | 92 | 明記 | C:\test6\healthsupportbank\hld\06_API設計.xlsx | シート「API定義」■A105 R220 | |
| 7章 COM-0001 の行（型「①インライン」） | 93 | 導出 | C:\test6\healthsupportbank\hld\04_画面設計.xlsx | シート「画面設計」4.6【①インライン】R145〜R147 | 入力値の誤りであり、直す対象（No.3）がその場にあるため |
| 7章 COM-0001 の行（画面の動き「`details[].field` が `email` のものを No.3 の直下に示す」） | 94 | 導出 | C:\test6\healthsupportbank\hld\04_画面設計.xlsx | シート「画面設計」4.8【項目ごとのエラー】R209〜R210 | details[].field は対象の項目名である（06 シート「API定義」【共通の応答形式】R22）。A105 の要求の項目は email のみ（R211）であり、画面の No.3 に対応する。入力欄の直下に示すのは 4.6【①インライン】R147 |
| 7章 COM-0001 の行（画面の動き「入力した値を残す。No.7 の活性は 4.2 による」） | 95 | 導出 | C:\test6\healthsupportbank\hld\04_画面設計.xlsx | シート「画面設計」4.6【①インライン】R146、4.9【二重送信】R218 | 直す対象がその場にある型であるため入力した値を残す。応答を受け取った後の No.7 の活性は 4.2 の条件による |
| 7章 MEMBER-0101 の行（エラー（コード）） | 96 | 明記 | C:\test6\healthsupportbank\hld\06_API設計.xlsx | シート「API定義」■A105 R222 | |
| 7章 AUTH-0103 の行（エラー（コード）） | 97 | 明記 | C:\test6\healthsupportbank\hld\06_API設計.xlsx | シート「API定義」■A105 R223 | |
| 7章 AUTH-0103 の行（画面の動き「本画面に留まる。手続きの状態は変わらず、同じ操作のやり直しを受け付ける」） | 98 | 導出 | C:\test6\healthsupportbank\hld\06_API設計.xlsx | シート「API定義」■A105 R223 | 同じ操作（E02）のやり直しを受け付けるため、本画面に留まる。13 シート「運用・保守」13.7【失敗時】R170（加入者は同じ操作をやり直す）とも一致する |
| 7章 応答を受け取れない場合の行（エラー（コード）「応答を受け取れない（通信の失敗・タイムアウト）」） | 99 | 明記 | C:\test6\healthsupportbank\hld\04_画面設計.xlsx | シート「画面設計」4.9【冪等】R223（応答を受け取れなかった場合（通信の失敗・タイムアウト）） | 事象の記載のみを用いた。扱いは【TBD-015】 |
| 8章 通常（設ける） | 100 | 規約 | C:\test6\healthsupportbank\hld\04_画面設計.xlsx | シート「画面設計」4.7【3つの状態】R176 | |
| 8章 読込中・失敗・空（設けない） | 101 | 導出 | C:\test6\healthsupportbank\hld\04_画面設計.xlsx | シート「画面設計」4.7【3つの状態】R176〜R177 | 3つの状態は一覧または取得した値を表示する画面に定める。本画面は一覧を持たず、取得した値を表示しない（4.3・4.4 前文・E01） |
| 8章 送信中（設ける・内容） | 102 | 規約 | C:\test6\healthsupportbank\hld\04_画面設計.xlsx | シート「画面設計」4.9【二重送信】R217〜R218 | |
| 9章「加入者（一般）のみ利用できる」 | 103 | 明記 | C:\test6\healthsupportbank\hld\要件定義\画面一覧.xlsx | シート「画面一覧」3行目（C3 一般） | |
| 9章「スマートフォンの LINE アプリ内でのみ利用できる」 | 104 | 明記 | C:\test6\healthsupportbank\hld\04_画面設計.xlsx | シート「画面設計」4.10【加入者】R255 | |
| 9章「一次トークン（手続きの種別：新規登録）を要する」 | 105 | 明記 | C:\test6\healthsupportbank\hld\06_API設計.xlsx | シート「API定義」■A105 R206〜R207 | |
| 10章 画面一覧の画面一覧 #2、遷移図（一般） | 106 | 明記 | C:\test6\healthsupportbank\hld\要件定義\画面一覧.xlsx | シート「画面一覧」3行目、シート「遷移図（一般）」 | 本書で参照した箇所 |
| 10章 03 3.1【確認コードの仕様】、3.2【追加照合】【登録フロー】 | 107 | 明記 | C:\test6\healthsupportbank\hld\03_認証・本人確認設計.xlsx | シート「認証・本人確認設計」R33〜R42、R48〜R49、R88〜R96 | 本書で参照した箇所 |
| 10章 04 の各節 | 108 | 明記 | C:\test6\healthsupportbank\hld\04_画面設計.xlsx | シート「画面設計」4.2（R44〜R53）、4.3（R63〜R68）、4.4（R82〜R111）、4.5（R113〜R138）、4.6（R140〜R172）、4.7（R174〜R194）、4.8（R208〜R210）、4.9（R216〜R224）、4.10（R254〜R257） | 本書で参照した箇所 |
| 10章 05 ワンタイムパスワード・監査ログ | 109 | 明記 | C:\test6\healthsupportbank\hld\05_DB設計書.xlsx | シート「ワンタイムパスワード」、シート「監査ログ」 | 本書で参照した箇所 |
| 10章 06 6.1 の各節、グループ1 の各節 | 110 | 明記 | C:\test6\healthsupportbank\hld\06_API設計.xlsx | シート「API設計」【認証欄の凡例】R64〜R70、【トークンの管理】R72〜R92、【冪等キー】R96〜R117、グループ1 R160〜R235 | 本書で参照した箇所 |
| 10章 06 6.2 の各節、A105 | 111 | 明記 | C:\test6\healthsupportbank\hld\06_API設計.xlsx | シート「API定義」【共通の応答形式】R15〜R23、【表記の規則】R31〜R37、【共通のエラーコード】R39〜R45、【本グループのエラーコード】R50〜R69、■A105 R200〜R225 | 本書で参照した箇所 |
| 10章 11 11.1【保存】、別シート「監査ログ対応表」 | 112 | 明記 | C:\test6\healthsupportbank\hld\11_セキュリティ・個人情報保護.xlsx | シート「セキュリティ・個人情報保護」R29〜R46、シート「監査ログ対応表」R8・R63 | 本書で参照した箇所 |
| 10章 12 12.1 No.11 | 113 | 明記 | C:\test6\healthsupportbank\hld\12_バッチ・非同期処理.xlsx | シート「バッチ・非同期処理」R73 | 本書で参照した箇所 |
| 10章 13 13.7【送信の方式】【失敗時】 | 114 | 明記 | C:\test6\healthsupportbank\hld\13_運用・保守.xlsx | シート「運用・保守」R167〜R172 | 本書で参照した箇所 |
| 10章 15 別シート「メッセージ」I003・I019 | 115 | 明記 | C:\test6\healthsupportbank\hld\15_メッセージ一覧.xlsx | シート「メッセージ」R28・R44 | 本書で参照した箇所 |
