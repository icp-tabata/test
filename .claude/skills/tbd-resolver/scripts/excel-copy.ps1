#Requires -PSEdition Desktop
<#
  設計書（Excel）の写しを作成・読み取り・修正するスクリプト。Excel COM で操作する。
  openpyxl 等で保存し直すと描画部品・画像・印刷設定が消えるファイルがある（05 DB設計書で確認）ため、Excel そのもので開いて保存する。

  書き込み（edit / history）は <リポジトリ>\docs\design\(screens|batches)\<ID>\*.xlsx だけを受け付ける。
  原本（基本設計の参照フォルダ）は copy の読み取り元と read の対象にだけなり、書き込まれない。

  edit・history は、修正前後の値を記録ファイル <写しのフォルダ>\edits\<ブック名>.json に残す。
  原本への反映は、この記録をもとに excel-apply.ps1 をユーザーが実行して行う（Claude Code は実行しない）。

  使い方:
    copy    -Source <原本> -Kind screens|batches -Id <画面ID/バッチID>
    read    -Path <xlsx> -Sheet <シート名> -Range <A1:C3>
    edit    -Path <写し> -Tbd <TBD-001> -Sheet <シート名> -Cell <A1> -Value <新しい値> [-RedText <赤字にする部分>]
    history -Path <写し> -Content <【ID TBD-番号】内容>
    list-history -Path <xlsx>
#>
param(
    [Parameter(Mandatory = $true)][ValidateSet('copy', 'read', 'edit', 'history', 'list-history')][string]$Mode,
    [string]$Source,
    [ValidateSet('screens', 'batches')][string]$Kind,
    [string]$Id,
    [string]$Path,
    [string]$Tbd,
    [string]$Sheet,
    [string]$Range,
    [string]$Cell,
    [string]$Value,
    [string]$RedText,
    [string]$Content
)

$ErrorActionPreference = 'Stop'

$HistorySheet = '変更履歴'
$HistoryAuthor = 'Claude'
# 変更履歴シートの列（01〜15 で共通。A=版、E=変更日、L=内容、BB=変更者。見出しは7行目）
$HistoryHeaderRow = 7
# FF0000（RGB）。Excel の Color は BGR の整数で持つため 255 になる
$Red = 255
$xlUp = -4162

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..\..')).Path

function Assert-CopyPath([string]$p) {
    $full = [System.IO.Path]::GetFullPath($p)
    $pattern = '^' + [regex]::Escape($RepoRoot) + '\\docs\\design\\(screens|batches)\\[^\\]+\\[^\\]+\.xlsx$'
    if ($full -notmatch $pattern) {
        throw "書き込み先が写しの置き場所ではありません: $full（docs\design\screens|batches\<ID>\*.xlsx のみ可）"
    }
    if (-not (Test-Path -LiteralPath $full)) {
        throw "写しがありません: $full"
    }
    return $full
}

function Open-Book([string]$p, [bool]$readOnly) {
    $xl = New-Object -ComObject Excel.Application
    try {
        $xl.Visible = $false
        $xl.DisplayAlerts = $false
        # UpdateLinks=0：外部リンクを更新しない（他ファイルを読みに行かせない）
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

# セルの値（Value2）を比較用の文字列にする。excel-apply.ps1 と同じ変換にすること
function ConvertTo-CellString($v) {
    if ($null -eq $v) {
        return ''
    }
    return [Convert]::ToString($v, [Globalization.CultureInfo]::InvariantCulture)
}

function Get-ManifestPath([string]$bookPath) {
    $dir = Join-Path (Split-Path $bookPath -Parent) 'edits'
    return Join-Path $dir ([System.IO.Path]::GetFileNameWithoutExtension($bookPath) + '.json')
}

function Read-Manifest([string]$bookPath) {
    $edits = New-Object System.Collections.ArrayList
    $histories = New-Object System.Collections.ArrayList
    $m = $null
    $mp = Get-ManifestPath $bookPath
    if (Test-Path -LiteralPath $mp) {
        $m = [System.IO.File]::ReadAllText($mp) | ConvertFrom-Json
        foreach ($e in @($m.edits)) {
            if ($e) { [void]$edits.Add($e) }
        }
        foreach ($h in @($m.histories)) {
            if ($h) { [void]$histories.Add($h) }
        }
    }
    $source = $null
    if ($m -and $m.source) {
        $source = $m.source
    }
    return @{ Edits = $edits; Histories = $histories; Source = $source }
}

function Write-Manifest([string]$bookPath, $manifest) {
    $mp = Get-ManifestPath $bookPath
    New-Item -ItemType Directory -Force -Path (Split-Path $mp -Parent) | Out-Null
    $obj = [ordered]@{
        book      = [System.IO.Path]::GetFileName($bookPath)
        source    = $manifest.Source
        edits     = @($manifest.Edits)
        histories = @($manifest.Histories)
    }
    $json = $obj | ConvertTo-Json -Depth 5
    # BOM なしの UTF-8 で書く
    [System.IO.File]::WriteAllText($mp, $json, (New-Object System.Text.UTF8Encoding($false)))
    "記録ファイルに追記: $mp"
}

# 変更履歴の行。版・変更日・内容・変更者のどれかに値がある行を、上から順に返す。
# 最終行は4列それぞれの最終行の最大とする（版が空欄や結合の行があっても、最終行を取り違えない）
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

# 版は N.N の形だけ扱う（1.10 のような2桁は 0.1 を足すと版が戻るため、止めて人に任せる）
function Get-NextVersion([string]$v) {
    if ($v -notmatch '^\d+\.\d$') {
        throw "版の形式が想定外です（N.N のみ対応）: $v"
    }
    $d = [decimal]::Parse($v, [Globalization.CultureInfo]::InvariantCulture) + [decimal]0.1
    return $d.ToString('0.0', [Globalization.CultureInfo]::InvariantCulture)
}

function Get-Sheet($wb, [string]$name) {
    foreach ($s in $wb.Worksheets) {
        if ($s.Name -eq $name) {
            return $s
        }
    }
    throw "シートがありません: $name"
}

switch ($Mode) {
    'copy' {
        if (-not $Source -or -not $Kind -or -not $Id) {
            throw 'copy には -Source・-Kind・-Id が必要です'
        }
        if ($Id -notmatch '^[A-Za-z]+(-[A-Za-z0-9]+)+$') {
            throw "-Id の形式が想定外です（例 U-LG-02、B-06）: $Id"
        }
        $src = (Resolve-Path -LiteralPath $Source).Path
        if ($src -notmatch '\.xlsx$') {
            throw "xlsx ではありません: $src"
        }
        $destDir = Join-Path $RepoRoot "docs\design\$Kind\$Id"
        $dest = Join-Path $destDir ([System.IO.Path]::GetFileName($src))
        if (Test-Path -LiteralPath $dest) {
            throw "写しは既にあります（既存の写しに追記する）: $dest"
        }
        $mp = Get-ManifestPath $dest
        if (Test-Path -LiteralPath $mp) {
            throw "写しは無いが、修正の記録が残っています: $mp（記録の修正前は古い原本の値のため、作り直すと反映できなくなる。記録の扱いをユーザーに確認する）"
        }
        $srcWrite = (Get-Item -LiteralPath $src).LastWriteTimeUtc.ToString('o')
        $before = (Get-FileHash -LiteralPath $src).Hash
        New-Item -ItemType Directory -Force -Path $destDir | Out-Null
        Copy-Item -LiteralPath $src -Destination $dest
        $after = (Get-FileHash -LiteralPath $src).Hash
        "写しを作成: $dest"
        "原本の SHA256: $before（コピー後: $after）"
        # 原本の更新日時とハッシュを記録に残す（excel-apply.ps1 が、写しを取った後に原本が更新されたかの判定に使う）
        $mf = Read-Manifest $dest
        $mf.Source = [pscustomobject]@{ lastWriteUtc = $srcWrite; sha256 = $before }
        Write-Manifest $dest $mf
    }
    'read' {
        $p = (Resolve-Path -LiteralPath $Path).Path
        $xl, $wb = Open-Book $p $true
        try {
            $ws = Get-Sheet $wb $Sheet
            foreach ($c in $ws.Range($Range).Cells) {
                $t = $c.Text
                if (-not [string]::IsNullOrEmpty($t)) {
                    '{0}: {1}' -f $c.Address($false, $false), $t
                }
            }
        }
        finally {
            Close-Book $xl $wb $false
        }
    }
    'edit' {
        $p = Assert-CopyPath $Path
        if (-not $Sheet -or -not $Cell -or -not $PSBoundParameters.ContainsKey('Value')) {
            throw 'edit には -Sheet・-Cell・-Value が必要です'
        }
        if ($Tbd -notmatch '^TBD-\d+$') {
            throw 'edit には -Tbd（例 TBD-001）が必要です'
        }
        if ($RedText) {
            $first = $Value.IndexOf($RedText, [StringComparison]::Ordinal)
            if ($first -lt 0) {
                throw "-RedText が -Value に含まれていません: $RedText"
            }
            if ($Value.LastIndexOf($RedText, [StringComparison]::Ordinal) -ne $first) {
                throw "-RedText が -Value の複数箇所に含まれています（赤字の位置が決まらない）: $RedText"
            }
        }
        $xl, $wb = Open-Book $p $false
        $save = $false
        try {
            $ws = Get-Sheet $wb $Sheet
            $c = $ws.Range($Cell)
            if ($c.Cells.Count -ne 1) {
                throw "-Cell は単一のセルで指定してください: $Cell"
            }
            if ($c.HasFormula) {
                throw "数式のセルは修正できません: [$Sheet]$Cell"
            }
            $addr = $c.Address($false, $false)
            $old = $c.Text
            $oldValue = ConvertTo-CellString $c.Value2
            $c.Value2 = $Value
            if ($c.HasFormula) {
                throw "値が数式として解釈されました（保存しません）: $Value"
            }
            if ($RedText) {
                # 赤字は変更した部分だけにする。Characters の開始位置は 1 始まり
                $c.Characters($Value.IndexOf($RedText, [StringComparison]::Ordinal) + 1, $RedText.Length).Font.Color = $Red
            }
            else {
                $c.Font.Color = $Red
            }
            $newValue = ConvertTo-CellString $c.Value2
            $save = $true
            "修正: [$Sheet]$addr"
            "  修正前: $old"
            "  修正後: $($c.Text)"
        }
        finally {
            Close-Book $xl $wb $save
        }
        # 保存に成功したときだけ記録する。同じセルを同じ TBD で直し直した場合は、修正前を最初の値に保つ
        $mf = Read-Manifest $p
        $prev = $mf.Edits | Where-Object { $_.tbd -eq $Tbd -and $_.sheet -eq $Sheet -and $_.cell -eq $addr } | Select-Object -First 1
        if ($prev) {
            $prev.value = $Value
            $prev.redText = $RedText
            $prev.after = $newValue
        }
        else {
            [void]$mf.Edits.Add([pscustomobject]@{
                    tbd = $Tbd; sheet = $Sheet; cell = $addr
                    before = $oldValue; after = $newValue
                    value = $Value; redText = $RedText
                })
        }
        Write-Manifest $p $mf
    }
    'history' {
        $p = Assert-CopyPath $Path
        if (-not $Content) {
            throw 'history には -Content が必要です'
        }
        if ($Content -notmatch '^【[^ 】]+ (TBD-\d+)】') {
            throw 'history の -Content は【<ID> TBD-番号】で始めてください'
        }
        $histTbd = $Matches[1]
        $mf = Read-Manifest $p
        if ($mf.Histories | Where-Object { $_.tbd -eq $histTbd }) {
            throw "$histTbd の変更履歴は既に追記済みです（二重に追記しない）"
        }
        $xl, $wb = Open-Book $p $false
        $save = $false
        try {
            $ws = Get-Sheet $wb $HistorySheet
            $rows = Get-HistoryRows $ws
            if ($rows.Count -eq 0) {
                throw '変更履歴に既存の行がありません'
            }
            $lastRow = $rows[-1].Row
            $lastVer = ($rows | Where-Object { $_.Version } | Select-Object -Last 1).Version
            $lastAuthor = ($rows | Where-Object { $_.Author } | Select-Object -Last 1).Author
            if (-not $lastVer) {
                throw '変更履歴に版の入った行がありません'
            }
            # 写しでの修正はすべて同じ版にする（最初の修正で1つ上げ、以降は据え置く）
            if ($lastAuthor -eq $HistoryAuthor) {
                $ver = $lastVer
            }
            else {
                $ver = Get-NextVersion $lastVer
            }
            $r = $lastRow + 1
            foreach ($col in 'A', 'E', 'L', 'BB') {
                if ($ws.Range("$col$r").MergeCells) {
                    throw "追記先の行が結合セルです: $col$r"
                }
            }
            $ws.Range("A$r").NumberFormatLocal = '@'
            $ws.Range("A$r").Value2 = $ver
            # [double] を明示しないと COM への代入で型変換エラーになる
            $ws.Range("E$r").Value2 = [double](Get-Date).Date.ToOADate()
            $ws.Range("E$r").NumberFormat = $ws.Range("E$lastRow").NumberFormat
            $ws.Range("L$r").Value2 = $Content
            $ws.Range("BB$r").Value2 = $HistoryAuthor
            $save = $true
            "変更履歴に追記: 行 $r（版 $ver）: $Content"
        }
        finally {
            Close-Book $xl $wb $save
        }
        $mf = Read-Manifest $p
        [void]$mf.Histories.Add([pscustomobject]@{ tbd = $histTbd; content = $Content })
        Write-Manifest $p $mf
    }
    'list-history' {
        $p = (Resolve-Path -LiteralPath $Path).Path
        $xl, $wb = Open-Book $p $true
        try {
            $ws = Get-Sheet $wb $HistorySheet
            foreach ($h in (Get-HistoryRows $ws)) {
                '{0}	{1}	{2}	{3}	{4}' -f $h.Row, $h.Version, $h.Date, $h.Author, $h.Content
            }
        }
        finally {
            Close-Book $xl $wb $false
        }
    }
}
