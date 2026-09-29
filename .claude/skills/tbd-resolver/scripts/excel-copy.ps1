<#
  設計書（Excel）の写しを作成・読み取り・修正するスクリプト。Excel COM で操作する。
  openpyxl 等で保存し直すと描画部品・画像・印刷設定が消えるファイルがある（05 DB設計書で確認）ため、Excel そのもので開いて保存する。

  書き込み（edit / history）は <リポジトリ>\docs\design\(screens|batches)\<ID>\*.xlsx だけを受け付ける。
  原本（基本設計の参照フォルダ）は copy の読み取り元と read の対象にだけなり、書き込まれない。

  使い方:
    copy    -Source <原本> -Kind screens|batches -Id <画面ID/バッチID>
    read    -Path <xlsx> -Sheet <シート名> -Range <A1:C3>
    edit    -Path <写し> -Sheet <シート名> -Cell <A1> -Value <新しい値> [-RedText <赤字にする部分>]
    history -Path <写し> -Content <内容>
    list-history -Path <xlsx>
#>
param(
    [Parameter(Mandatory = $true)][ValidateSet('copy', 'read', 'edit', 'history', 'list-history')][string]$Mode,
    [string]$Source,
    [ValidateSet('screens', 'batches')][string]$Kind,
    [string]$Id,
    [string]$Path,
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
    $xl.Visible = $false
    $xl.DisplayAlerts = $false
    # UpdateLinks=0：外部リンクを更新しない（他ファイルを読みに行かせない）
    $wb = $xl.Workbooks.Open($p, 0, $readOnly)
    if (-not $readOnly -and $wb.ReadOnly) {
        $wb.Close($false)
        $xl.Quit()
        throw "読み取り専用でしか開けません（Excel で開いたままの可能性）: $p"
    }
    return @($xl, $wb)
}

function Close-Book($xl, $wb, [bool]$save) {
    if ($null -ne $wb) {
        if ($save) {
            $wb.Save()
        }
        $wb.Close($false)
        [void][Runtime.InteropServices.Marshal]::ReleaseComObject($wb)
    }
    if ($null -ne $xl) {
        $xl.Quit()
        [void][Runtime.InteropServices.Marshal]::ReleaseComObject($xl)
    }
    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()
}

function Get-HistoryRows($ws) {
    $rows = @()
    $r = $HistoryHeaderRow + 1
    while ($true) {
        $ver = $ws.Range("A$r").Text
        if ([string]::IsNullOrWhiteSpace($ver)) {
            break
        }
        $rows += [pscustomobject]@{
            Row     = $r
            Version = $ver
            Date    = $ws.Range("E$r").Text
            Content = $ws.Range("L$r").Text
            Author  = $ws.Range("BB$r").Text
        }
        $r++
    }
    return , $rows
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
        $src = (Resolve-Path -LiteralPath $Source).Path
        if ($src -notmatch '\.xlsx$') {
            throw "xlsx ではありません: $src"
        }
        $destDir = Join-Path $RepoRoot "docs\design\$Kind\$Id"
        $dest = Join-Path $destDir ([System.IO.Path]::GetFileName($src))
        if (Test-Path -LiteralPath $dest) {
            throw "写しは既にあります（既存の写しに追記する）: $dest"
        }
        $before = (Get-FileHash -LiteralPath $src).Hash
        New-Item -ItemType Directory -Force -Path $destDir | Out-Null
        Copy-Item -LiteralPath $src -Destination $dest
        $after = (Get-FileHash -LiteralPath $src).Hash
        "写しを作成: $dest"
        "原本の SHA256: $before（コピー後: $after）"
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
        if (-not $Sheet -or -not $Cell -or $null -eq $Value) {
            throw 'edit には -Sheet・-Cell・-Value が必要です'
        }
        if ($RedText -and $Value.IndexOf($RedText) -lt 0) {
            throw "-RedText が -Value に含まれていません: $RedText"
        }
        $xl, $wb = Open-Book $p $false
        $save = $false
        try {
            $ws = Get-Sheet $wb $Sheet
            $c = $ws.Range($Cell)
            $old = $c.Text
            $c.Value2 = $Value
            if ($RedText) {
                # 赤字は変更した部分だけにする。Characters の開始位置は 1 始まり
                $c.Characters($Value.IndexOf($RedText) + 1, $RedText.Length).Font.Color = $Red
            }
            else {
                $c.Font.Color = $Red
            }
            $save = $true
            "修正: [$Sheet]$Cell"
            "  修正前: $old"
            "  修正後: $($c.Text)"
        }
        finally {
            Close-Book $xl $wb $save
        }
    }
    'history' {
        $p = Assert-CopyPath $Path
        if (-not $Content) {
            throw 'history には -Content が必要です'
        }
        $xl, $wb = Open-Book $p $false
        $save = $false
        try {
            $ws = Get-Sheet $wb $HistorySheet
            $rows = Get-HistoryRows $ws
            if ($rows.Count -eq 0) {
                throw '変更履歴に既存の行がありません'
            }
            $last = $rows[-1]
            # 写しでの修正はすべて同じ版にする（最初の修正で1つ上げ、以降は据え置く）
            if ($last.Author -eq $HistoryAuthor) {
                $ver = $last.Version
            }
            else {
                $ver = '{0:0.0}' -f ([decimal]$last.Version + 0.1)
            }
            $r = $last.Row + 1
            $ws.Range("A$r").NumberFormatLocal = '@'
            $ws.Range("A$r").Value2 = $ver
            # [double] を明示しないと COM への代入で型変換エラーになる
            $ws.Range("E$r").Value2 = [double](Get-Date).Date.ToOADate()
            $ws.Range("E$r").NumberFormat = $ws.Range("E$($last.Row)").NumberFormat
            $ws.Range("L$r").Value2 = $Content
            $ws.Range("BB$r").Value2 = $HistoryAuthor
            $save = $true
            "変更履歴に追記: 行 $r（版 $ver）: $Content"
        }
        finally {
            Close-Book $xl $wb $save
        }
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
