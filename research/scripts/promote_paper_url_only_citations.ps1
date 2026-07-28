param(
    [string]$CorpusPath = (Join-Path $PSScriptRoot '..\..\sooon-q9adg-articles.jsonl'),
    [string]$PaperDir = (Join-Path $PSScriptRoot '..\papers')
)

$ErrorActionPreference = 'Stop'
$urlToId = @{}
foreach ($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($CorpusPath))) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $row = $line | ConvertFrom-Json
    $url = ([string]$row.url).TrimEnd(')')
    if (-not [string]::IsNullOrWhiteSpace($url)) {
        $urlToId[$url] = ([string]$row.id).ToLowerInvariant()
    }
}

$linkPattern = [regex]'(?<link>\[[^\]]+\]\((?<url>https?://[^\s\)]+)\))'
$changedPapers = 0
$promotedCitations = 0
foreach ($paper in Get-ChildItem -LiteralPath $PaperDir -Filter '*.md' -File) {
    $lines = [IO.File]::ReadAllLines($paper.FullName)
    $paperChanged = $false
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $originalLine = $lines[$i]
        $lines[$i] = $linkPattern.Replace($originalLine, {
            param($match)
            $url = $match.Groups['url'].Value.TrimEnd(')')
            if (-not $urlToId.ContainsKey($url)) { return $match.Value }
            $id = $urlToId[$url]
            if ($originalLine.Contains($id,[StringComparison]::OrdinalIgnoreCase)) { return $match.Value }
            $script:promotedCitations++
            return ('{0}（ID `{1}`）' -f $match.Groups['link'].Value,$id)
        })
        if (-not $lines[$i].Equals($originalLine,[StringComparison]::Ordinal)) {
            $paperChanged = $true
        }
    }
    if ($paperChanged) {
        [IO.File]::WriteAllLines($paper.FullName,$lines,[Text.UTF8Encoding]::new($false))
        $changedPapers++
    }
}

[ordered]@{
    paperCount = @(Get-ChildItem -LiteralPath $PaperDir -Filter '*.md' -File).Count
    changedPapers = $changedPapers
    promotedCitations = $promotedCitations
    status = 'PASS'
} | ConvertTo-Json
