#Requires -PSEdition Desktop
<#
  写しの修正を原本（基本設計の参照フォルダの Excel）へ反映するスクリプト。ユーザーが自分のターミナルで実行する。
  Claude Code は実行しない（原本への書き込みは Claude Code に許していないため）。
  CLAUDECODE 環境変数がある場合と、入力が端末でない（パイプ・リダイレクト）場合は止まる。
  .claude/settings.json の deny でも、Claude Code からの実行を拒否している。

  入力は、excel-copy.ps1 の edit・history が残す記録ファイル docs\design\(screens|batches)\<ID>\edits\<ブック名>.json。
  反映した TBD は、同じフォルダの <ブック名>.applied.json に残す（反映済みの TBD は、既定で対象にしない）。

  動き（TBD ごと。TBD 単位で全部書くか、1セルも書かないかのどちらか）:
    0. 最初に、原本の更新日時を、写しを取った時の記録（copy が残す）と比べる。更新されていれば中止する
       （更新日時が違っても、内容が写しを取った時、または前回の反映の直後と同じなら続ける）
    1. 原本を読み取り専用で開き、記録の各セルの現在値を「修正前」「修正後」と比べる（大文字小文字も区別する）
         書ける   … 現在値 = 修正前
         反映済み … 現在値 = 修正後（飛ばす。二重に反映しない）
         変更なし … 修正前 = 修正後（書かない）
         不一致   … どれでもない（他の人が直した・行がずれた等）
         要確認   … 数式のセル、または1つのセルに複数の文字色がある（他の人の赤字を消す恐れ。-AllowMixedFormat で許可）
       不一致・要確認が 1件でもある TBD、変更履歴の記録が無い TBD は、1セルも書かない
       同じセルを複数の TBD が直す場合、後の TBD は前の TBD の反映後の値で判定する
    2. 結果の一覧を出し、「反映する」の入力を求める
    3. 原本を docs\design\_backup\<日時>\ に複製する（一覧を出した時点から原本が変わっていれば止まる）
    4. 書き込み用に開き直して判定をやり直し、変わっていれば保存せずに止まる
    5. 書けるセルだけを書き、赤字（FF0000）にし、変更履歴シートに 1行足す（1回の実行で版を 0.1 上げる）
    6. 保存の前に書いた値を確かめ、保存後にも原本を開き直して確かめる

  使い方:
    excel-apply.ps1 -Manifest <記録ファイル> [-Tbd TBD-001] [-Original <原本>] [-Reapply] [-AllowMixedFormat]
    -Tbd を省くと、反映済みでないすべての TBD を対象にする。
    -Tbd で反映済みの TBD を指定するには -Reapply が要る（人が差し戻した修正を、意図して書き直すとき）。
    -Original を省くと、CLAUDE.local.md の基本設計の参照フォルダ以下から、ブック名で原本を探す（1つに決まらなければ止まる）。
#>
param(
    [Parameter(Mandatory = $true)][string]$Manifest,
    [string]$Tbd,
    [string]$Original,
    [switch]$Reapply,
    [switch]$AllowMixedFormat
)

$ErrorActionPreference = 'Stop'

if ($env:CLAUDECODE) {
    throw '原本への反映はユーザーが自分のターミナルで実行してください（Claude Code からは実行しません）'
}
if ([Console]::IsInputRedirected) {
    throw '入力が端末ではありません。ターミナルで直接実行してください'
}

$HistorySheet = '変更履歴'
$HistoryHeaderRow = 7
$Red = 255
$xlUp = -4162
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..\..')).Path
$Applier = "Claude(適用: $env:USERNAME)"

function ConvertTo-CellString($v) {
    if ($null -eq $v) {
        return ''
    }
    return [Convert]::ToString($v, [Globalization.CultureInfo]::InvariantCulture)
}

function Open-Book([string]$p, [bool]$readOnly) {
    $xl = New-Object -ComObject Excel.Application
    try {
        $xl.Visible = $false
        $xl.DisplayAlerts = $false
        $wb = $xl.Workbooks.Open($p, 0, $readOnly)
        if (-not $readOnly -and $wb.ReadOnly) {
            $wb.Close($false)
            throw "読み取り専用でしか開けません（Excel で開いたままの可能性）: $p"
        }
    }
    catch {
        $xl.Quit()
        throw
    }
    return @($xl, $wb)
}

# 保存に失敗しても、ブックを閉じて Excel を終了する
function Close-Book($xl, $wb, [bool]$save) {
    try {
        if ($null -ne $wb) {
            try {
                if ($save) {
                    $wb.Save()
                }
            }
            finally {
                $wb.Close($false)
                [void][Runtime.InteropServices.Marshal]::ReleaseComObject($wb)
            }
        }
    }
    finally {
        if ($null -ne $xl) {
            $xl.Quit()
            [void][Runtime.InteropServices.Marshal]::ReleaseComObject($xl)
        }
        [GC]::Collect()
        [GC]::WaitForPendingFinalizers()
    }
}

function Get-Sheet($wb, [string]$name) {
    foreach ($s in $wb.Worksheets) {
        if ($s.Name -eq $name) {
            return $s
        }
    }
    return $null
}

function Get-HistoryRows($ws) {
    $last = $HistoryHeaderRow
    foreach ($col in 1, 5, 12, 54) {
        $r = $ws.Cells.Item($ws.Rows.Count, $col).End($xlUp).Row
        if ($r -gt $last) {
            $last = $r
        }
    }
    $rows = @()
    for ($r = $HistoryHeaderRow + 1; $r -le $last; $r++) {
        $o = [pscustomobject]@{
            Row     = $r
            Version = $ws.Range("A$r").Text
            Date    = $ws.Range("E$r").Text
            Content = $ws.Range("L$r").Text
            Author  = $ws.Range("BB$r").Text
        }
        if ($o.Version -or $o.Date -or $o.Content -or $o.Author) {
            $rows += $o
        }
    }
    return , $rows
}

function Get-NextVersion([string]$v) {
    if ($v -notmatch '^\d+\.\d$') {
        throw "版の形式が想定外です（N.N のみ対応）: $v"
    }
    $d = [decimal]::Parse($v, [Globalization.CultureInfo]::InvariantCulture) + [decimal]0.1
    return $d.ToString('0.0', [Globalization.CultureInfo]::InvariantCulture)
}

function Get-OriginalPath([string]$bookName) {
    $local = Join-Path $RepoRoot 'CLAUDE.local.md'
    if (-not (Test-Path -LiteralPath $local)) {
        throw "CLAUDE.local.md がありません: $local"
    }
    $text = [System.IO.File]::ReadAllText($local)
    if ($text -notmatch '基本設計の参照フォルダ[：:]\s*(.+)') {
        throw 'CLAUDE.local.md に「基本設計の参照フォルダ」が書かれていません'
    }
    $root = $Matches[1].Trim()
    if (-not (Test-Path -LiteralPath $root)) {
        throw "基本設計の参照フォルダがありません: $root"
    }
    $found = @(Get-ChildItem -LiteralPath $root -Recurse -File -Filter $bookName)
    if ($found.Count -ne 1) {
        throw "原本を 1つに決められません（$($found.Count) 件）: $bookName（$root 以下）"
    }
    return $found[0].FullName
}

function Show-Text([string]$s) {
    return ($s -replace "`r?`n", '↵')
}

# 【ID TBD-番号】の部分（変更履歴の重複判定に使う）
function Get-HistoryKey([string]$content) {
    if ($content -match '^【[^】]+】') {
        return $Matches[0]
    }
    return $content
}

# 記録の1セルについて、原本の状態を判定する。$pending は、前の TBD が書く予定の値（'シート!セル' → 値）
function Get-ItemState($wb, $e, $pending) {
    $ws = Get-Sheet $wb $e.sheet
    if ($null -eq $ws) {
        return @{ State = '不一致'; Now = "(シート「$($e.sheet)」がありません)"; Note = '' }
    }
    $c = $ws.Range($e.cell)
    $key = "$($e.sheet)!$($e.cell)"
    $note = ''
    if ($pending.ContainsKey($key)) {
        $now = $pending[$key]
        $note = '前の TBD の反映後の値で判定'
    }
    else {
        $now = ConvertTo-CellString $c.Value2
    }
    if ($e.before -ceq $e.after) { $state = '変更なし' }
    elseif ($now -ceq $e.before) { $state = '書ける' }
    elseif ($now -ceq $e.after) { $state = '反映済み' }
    else { $state = '不一致' }
    if ($state -eq '書ける') {
        if ($c.HasFormula) {
            $state = '要確認'
            $note = '数式のセルです。値で上書きすると数式が消えます'
        }
        elseif (-not $AllowMixedFormat -and ($c.Font.Color -is [System.DBNull])) {
            $state = '要確認'
            $note = '1つのセルに複数の文字色があります。他の人の赤字を消す恐れがあります（-AllowMixedFormat で許可）'
        }
    }
    return @{ State = $state; Now = $now; Note = $note }
}

function Read-Json([string]$path) {
    return [System.IO.File]::ReadAllText($path) | ConvertFrom-Json
}

# --- 記録を読む ---
$mp = (Resolve-Path -LiteralPath $Manifest).Path
$m = Read-Json $mp
$edits = @($m.edits)
$histories = @($m.histories)
$ledgerPath = Join-Path (Split-Path $mp -Parent) ([System.IO.Path]::GetFileNameWithoutExtension($mp) + '.applied.json')
$ledger = New-Object System.Collections.ArrayList
if (Test-Path -LiteralPath $ledgerPath) {
    foreach ($a in @((Read-Json $ledgerPath).applied)) {
        if ($a) { [void]$ledger.Add($a) }
    }
}
function Test-Applied([string]$t) {
    return [bool]($ledger | Where-Object { $_.tbd -eq $t })
}

$tbds = @($edits | ForEach-Object { $_.tbd } | Select-Object -Unique)
if ($Tbd) {
    $tbds = @($tbds | Where-Object { $_ -eq $Tbd })
    if ($tbds.Count -eq 0) {
        throw "$Tbd は記録にありません"
    }
    if ((Test-Applied $Tbd) -and -not $Reapply) {
        throw "$Tbd は反映済みの記録があります。書き直す場合は -Reapply を付けてください"
    }
}
else {
    $skipped = @($tbds | Where-Object { Test-Applied $_ })
    foreach ($s in $skipped) {
        "$s は反映済みの記録があるため対象にしません（書き直すなら -Tbd $s -Reapply）"
    }
    $tbds = @($tbds | Where-Object { -not (Test-Applied $_) })
}
if ($tbds.Count -eq 0) {
    '反映する TBD はありません'
    return
}

if ($Original) {
    $original = (Resolve-Path -LiteralPath $Original).Path
}
else {
    $original = Get-OriginalPath $m.book
}
"原本: $original"

# --- 0. タイムスタンプの判定（最初に行う。原本が更新されていれば中止する） ---
''
'■ 原本のタイムスタンプ'
if ($m.source -and $m.source.lastWriteUtc) {
    if ($m.source.lastWriteUtc -is [datetime]) {
        $recorded = $m.source.lastWriteUtc.ToUniversalTime()
    }
    else {
        $recorded = [datetime]::Parse($m.source.lastWriteUtc, [Globalization.CultureInfo]::InvariantCulture, [Globalization.DateTimeStyles]::RoundtripKind).ToUniversalTime()
    }
    $current = (Get-Item -LiteralPath $original).LastWriteTimeUtc
    $fmt = 'yyyy-MM-dd HH:mm:ss'
    '  写しを取った時の更新日時: {0}' -f $recorded.ToLocalTime().ToString($fmt)
    '  原本の現在の更新日時    : {0}' -f $current.ToLocalTime().ToString($fmt)
    # 同期やファイルシステムによる丸めを見込んで、2秒までの差は同じとみなす
    if ([math]::Abs(($current - $recorded).TotalSeconds) -le 2) {
        '  → 一致。原本は写しを取った時から更新されていません'
    }
    else {
        $hashNow = (Get-FileHash -LiteralPath $original).Hash
        $lastApplied = $ledger | Where-Object { $_.originalHashAfter } | Select-Object -Last 1
        if ($m.source.sha256 -and $hashNow -eq $m.source.sha256) {
            '  → 更新日時は違うが、内容（ハッシュ）は写しを取った時と同じです'
        }
        elseif ($lastApplied -and $hashNow -eq $lastApplied.originalHashAfter) {
            '  → 更新日時は違うが、内容（ハッシュ）は前回の反映の直後と同じです（前回の反映による更新）'
        }
        else {
            throw '原本は写しを取った後（または前回の反映の後）に更新されているため、中止しました。何も書いていません。他の人が原本を直した可能性があります。原本の現状を確認し、写しの作り直しは Claude Code に相談してください'
        }
    }
}
else {
    '  → 記録に原本の更新日時がありません（古い形式の記録）。判定できません'
}

# --- 1. 原本と比べる ---
$plan = [ordered]@{}
$xl, $wb = Open-Book $original $true
try {
    $hws = Get-Sheet $wb $HistorySheet
    if ($null -eq $hws) {
        throw "原本に変更履歴シートがありません: $original"
    }
    $origHistory = Get-HistoryRows $hws
    $pending = @{}
    foreach ($t in $tbds) {
        $items = @()
        foreach ($e in @($edits | Where-Object { $_.tbd -eq $t })) {
            $st = Get-ItemState $wb $e $pending
            $items += [pscustomobject]@{ Edit = $e; State = $st.State; Now = $st.Now; Note = $st.Note }
        }
        $hist = $histories | Where-Object { $_.tbd -eq $t } | Select-Object -First 1
        $histDone = $false
        if ($hist) {
            $key = Get-HistoryKey $hist.content
            $histDone = [bool]($origHistory | Where-Object { $_.Content.StartsWith($key, [StringComparison]::Ordinal) })
        }
        $bad = @($items | Where-Object { $_.State -in '不一致', '要確認' })
        $ok = @($items | Where-Object { $_.State -eq '書ける' })
        $plan[$t] = @{ Items = $items; History = $hist; HistoryDone = $histDone; Bad = $bad; Ok = $ok }
        if ($bad.Count -eq 0 -and $ok.Count -gt 0 -and $hist) {
            foreach ($i in $ok) {
                $pending["$($i.Edit.sheet)!$($i.Edit.cell)"] = $i.Edit.after
            }
        }
    }
}
finally {
    Close-Book $xl $wb $false
}
$hashPlan = (Get-FileHash -LiteralPath $original).Hash

# --- 2. 一覧を出す ---
$writable = @()
$alreadyDone = @()
foreach ($t in $tbds) {
    $p = $plan[$t]
    ''
    "■ $t"
    foreach ($i in $p.Items) {
        '  [{0}] {1}!{2}' -f $i.State, $i.Edit.sheet, $i.Edit.cell
        '      原本の現在値: {0}' -f (Show-Text $i.Now)
        '      修正前(記録) : {0}' -f (Show-Text $i.Edit.before)
        '      修正後(記録) : {0}' -f (Show-Text $i.Edit.after)
        if ($i.State -eq '書ける' -and $i.Edit.value -cne $i.Edit.after) {
            '      書く値       : {0}' -f (Show-Text $i.Edit.value)
        }
        if ($i.Note) {
            '      注意         : {0}' -f $i.Note
        }
    }
    if ($p.Bad.Count -gt 0) {
        "  → 不一致・要確認が $($p.Bad.Count) 件あるため、この TBD は反映しません（原本の現状を確認し、必要なら写しを作り直してください）"
    }
    elseif ($p.Ok.Count -eq 0) {
        if ($p.HistoryDone -or -not $p.History) {
            '  → 書くセルはありません（反映済み）'
            $alreadyDone += $t
        }
        else {
            '  → 書くセルはありません（変更履歴だけ未記入。手で確認してください）'
        }
    }
    elseif (-not $p.History) {
        '  → 変更履歴の記録（excel-copy.ps1 -Mode history）が無いため、反映しません'
    }
    else {
        "  → $($p.Ok.Count) セルを反映します"
        $writable += $t
    }
}

function Save-Ledger([string[]]$doneTbds, [string]$backupPath) {
    $hash = (Get-FileHash -LiteralPath $original).Hash
    foreach ($t in $doneTbds) {
        [void]$ledger.Add([pscustomobject]@{
                tbd = $t; at = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss'); by = $env:USERNAME
                backup = $backupPath; originalHashAfter = $hash
            })
    }
    $obj = [ordered]@{ book = $m.book; applied = @($ledger) }
    [System.IO.File]::WriteAllText($ledgerPath, ($obj | ConvertTo-Json -Depth 5), (New-Object System.Text.UTF8Encoding($false)))
    "反映の記録: $ledgerPath"
}

if ($writable.Count -eq 0) {
    ''
    '反映する TBD はありません'
    $newDone = @($alreadyDone | Where-Object { -not (Test-Applied $_) })
    if ($newDone.Count -gt 0) {
        Save-Ledger $newDone ''
    }
    return
}

''
$ans = Read-Host "上記の TBD を原本へ反映します（$($writable -join ', ')）。続けるには「反映する」と入力してください"
if ($ans -ne '反映する') {
    '中止しました'
    return
}

# --- 3. バックアップ ---
$backupDir = Join-Path $RepoRoot ('docs\design\_backup\' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
New-Item -ItemType Directory -Force -Path $backupDir | Out-Null
$backup = Join-Path $backupDir ([System.IO.Path]::GetFileName($original))
Copy-Item -LiteralPath $original -Destination $backup
$hashBackup = (Get-FileHash -LiteralPath $backup).Hash
if ($hashBackup -ne $hashPlan) {
    throw "一覧を出した後に原本が変わったか、バックアップが原本と一致しません。何も書いていません: $backup"
}
"バックアップ: $backup"

# 書いた後の期待値。'シート!セル' → 最後に書く TBD の修正後
$expected = [ordered]@{}
foreach ($t in $writable) {
    foreach ($i in $plan[$t].Ok) {
        $expected["$($i.Edit.sheet)!$($i.Edit.cell)"] = @{ Tbd = $t; Sheet = $i.Edit.sheet; Cell = $i.Edit.cell; After = $i.Edit.after }
    }
}

# --- 4・5. 書き込み用に開き直して判定をやり直し、書く ---
$xl, $wb = Open-Book $original $false
$save = $false
try {
    $hws = Get-Sheet $wb $HistorySheet
    # 判定のやり直し（書く前に、全 TBD を確かめる）
    $pending = @{}
    foreach ($t in $writable) {
        foreach ($i in $plan[$t].Items) {
            $st = Get-ItemState $wb $i.Edit $pending
            if ($st.State -ne $i.State) {
                throw "判定が変わりました（$t [$($i.Edit.sheet)]$($i.Edit.cell): $($i.State) → $($st.State)）。何も保存していません"
            }
        }
        foreach ($i in $plan[$t].Ok) {
            $pending["$($i.Edit.sheet)!$($i.Edit.cell)"] = $i.Edit.after
        }
    }
    $runVer = $null
    foreach ($t in $writable) {
        $p = $plan[$t]
        foreach ($i in $p.Ok) {
            $e = $i.Edit
            $c = (Get-Sheet $wb $e.sheet).Range($e.cell)
            $c.Value2 = $e.value
            if ($e.redText) {
                $c.Characters($e.value.IndexOf($e.redText, [StringComparison]::Ordinal) + 1, $e.redText.Length).Font.Color = $Red
            }
            else {
                $c.Font.Color = $Red
            }
        }
        if (-not $p.HistoryDone) {
            $rows = Get-HistoryRows $hws
            $lastRow = $rows[-1].Row
            if ($null -eq $runVer) {
                $lastVer = ($rows | Where-Object { $_.Version } | Select-Object -Last 1).Version
                if (-not $lastVer) {
                    throw '原本の変更履歴に版の入った行がありません'
                }
                $runVer = Get-NextVersion $lastVer
            }
            $r = $lastRow + 1
            foreach ($col in 'A', 'E', 'L', 'BB') {
                if ($hws.Range("$col$r").MergeCells) {
                    throw "変更履歴の追記先が結合セルです: $col$r"
                }
            }
            $hws.Range("A$r").NumberFormatLocal = '@'
            $hws.Range("A$r").Value2 = $runVer
            $hws.Range("E$r").Value2 = [double](Get-Date).Date.ToOADate()
            $hws.Range("E$r").NumberFormat = $hws.Range("E$lastRow").NumberFormat
            $hws.Range("L$r").Value2 = $p.History.content
            $hws.Range("BB$r").Value2 = $Applier
        }
    }
    # 保存の前に、書いた値を確かめる（同じセルを複数の TBD が書く場合は、最後に書く TBD の修正後と比べる）
    foreach ($k in $expected.Keys) {
        $x = $expected[$k]
        $now = ConvertTo-CellString (Get-Sheet $wb $x.Sheet).Range($x.Cell).Value2
        if ($now -cne $x.After) {
            throw "書いた値が記録の修正後と一致しません（$($x.Tbd) [$($x.Sheet)]$($x.Cell): 期待=$(Show-Text $x.After) 実際=$(Show-Text $now)）。何も保存していません"
        }
    }
    $save = $true
}
finally {
    Close-Book $xl $wb $save
}

# --- 6. 保存後にも読み直して確かめる ---
$failed = 0
$xl, $wb = Open-Book $original $true
try {
    foreach ($k in $expected.Keys) {
        $x = $expected[$k]
        $now = ConvertTo-CellString (Get-Sheet $wb $x.Sheet).Range($x.Cell).Value2
        if ($now -ceq $x.After) {
            "確認OK: $($x.Tbd) [$($x.Sheet)]$($x.Cell)"
        }
        else {
            "確認NG: $($x.Tbd) [$($x.Sheet)]$($x.Cell) 期待=$(Show-Text $x.After) 実際=$(Show-Text $now)"
            $failed++
        }
    }
}
finally {
    Close-Book $xl $wb $false
}
if ($failed -gt 0) {
    throw "保存後の値が記録と一致しないセルが $failed 件あります。バックアップ: $backup"
}
Save-Ledger (@($writable) + @($alreadyDone | Where-Object { -not (Test-Applied $_) })) $backup
"反映しました（バックアップ: $backup）"
