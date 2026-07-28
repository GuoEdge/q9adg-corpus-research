param(
    [string]$IndexPath = (Join-Path $PSScriptRoot '..\data\corpus_index.csv'),
    [string]$PaperDir = (Join-Path $PSScriptRoot '..\papers')
)

$ErrorActionPreference = 'Stop'
$byTitle = @{}
foreach ($group in Import-Csv -LiteralPath $IndexPath | Group-Object title) {
    $byTitle[$group.Name] = @($group.Group)
}

$blockPattern = '(?ms)\r?\n<!-- named-source-coverage:start -->.*?<!-- named-source-coverage:end -->\r?\n?'
$changedPapers = 0
$generatedEntries = 0
foreach ($paper in Get-ChildItem -LiteralPath $PaperDir -Filter '*.md' -File | Sort-Object Name) {
    $original = [IO.File]::ReadAllText($paper.FullName)
    $hadGeneratedBlock = [regex]::IsMatch($original,$blockPattern)
    $baseText = [regex]::Replace($original,$blockPattern,"`r`n")
    $titles = @(
        [regex]::Matches($baseText,'《(?<title>[^》]+)》') |
            ForEach-Object { $_.Groups['title'].Value } |
            Sort-Object -Unique
    )
    $missing = [Collections.Generic.List[object]]::new()
    foreach ($title in $titles) {
        $matches = @($byTitle[$title])
        if ($matches.Count -ne 1) { continue }
        $row = $matches[0]
        $url = ([string]$row.url).TrimEnd(')')
        if ($baseText.Contains([string]$row.id,[StringComparison]::OrdinalIgnoreCase)) { continue }
        if (-not [string]::IsNullOrWhiteSpace($url) -and $baseText.Contains($url,[StringComparison]::Ordinal)) { continue }
        [void]$missing.Add([pscustomobject]@{ title=$title; id=[string]$row.id; url=$url })
    }

    if ($missing.Count -eq 0 -and -not $hadGeneratedBlock) { continue }

    $newText = $baseText.TrimEnd()
    if ($missing.Count -gt 0) {
        $builder = [Text.StringBuilder]::new()
        [void]$builder.AppendLine()
        [void]$builder.AppendLine()
        [void]$builder.AppendLine('<!-- named-source-coverage:start -->')
        [void]$builder.AppendLine('## 补充原文入口（篇名引用）')
        [void]$builder.AppendLine()
        [void]$builder.AppendLine('以下文章在正文中以篇名参与论证，其稳定ID与原链接集中列于此处：')
        [void]$builder.AppendLine()
        foreach ($row in $missing | Sort-Object title) {
            [void]$builder.AppendLine(('- [《{0}》]({1})，ID `{2}`' -f $row.title,$row.url,$row.id))
        }
        [void]$builder.AppendLine('<!-- named-source-coverage:end -->')
        $newText += $builder.ToString()
        $generatedEntries += $missing.Count
    }
    $newText = $newText.TrimEnd() + "`r`n"
    if (-not $newText.Equals($original,[StringComparison]::Ordinal)) {
        [IO.File]::WriteAllText($paper.FullName,$newText,[Text.UTF8Encoding]::new($false))
        $changedPapers++
    }
}

$paperCount = @(Get-ChildItem -LiteralPath $PaperDir -Filter '*.md' -File).Count
[ordered]@{
    paperCount = $paperCount
    changedPapers = $changedPapers
    generatedEntries = $generatedEntries
    status = if ($paperCount -eq 34) { 'PASS' } else { 'REVIEW' }
} | ConvertTo-Json
