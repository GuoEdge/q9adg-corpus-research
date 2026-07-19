param(
    [string]$CorpusPath = (Join-Path $PSScriptRoot '..\..\sooon-q9adg-articles.jsonl'),
    [string]$ReadingDir = (Join-Path $PSScriptRoot '..\close-reading')
)

$ErrorActionPreference = 'Stop'
$corpusByOrdinal = @{}
$corpusById = @{}
$ordinal = 0
foreach ($line in [System.IO.File]::ReadLines([System.IO.Path]::GetFullPath($CorpusPath))) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $item = $line | ConvertFrom-Json
    $ordinal++
    $corpusByOrdinal[$ordinal] = [string]$item.id
    $corpusById[[string]$item.id] = $ordinal
}

$seen = [System.Collections.Generic.List[object]]::new()
$headingPattern = '(?m)^###\s+(\d{1,4})[｜|](.*)$'
$idPattern = '(?m)^(?:-\s+)?(?:\*\*)?ID(?:\*\*)?(?:：|:)(?:\*\*)?\s*(?:`)?([0-9a-fA-F-]{36})(?:`)?'
foreach ($file in Get-ChildItem -LiteralPath $ReadingDir -Filter 'batch-*.md' -File | Sort-Object Name) {
    $content = Get-Content -LiteralPath $file.FullName -Raw -Encoding utf8
    $matches = [regex]::Matches($content, $headingPattern)
    foreach ($match in $matches) {
        $number = [int]$match.Groups[1].Value
        $start = $match.Index
        $next = $matches | Where-Object { $_.Index -gt $start } | Select-Object -First 1
        $end = if ($null -eq $next) { $content.Length } else { $next.Index }
        $section = $content.Substring($start, $end - $start)
        $idMatch = [regex]::Match($section, $idPattern)
        $id = if ($idMatch.Success) { $idMatch.Groups[1].Value.Trim() } else { '' }
        $seen.Add([pscustomobject]@{ ordinal = $number; id = $id; file = $file.Name })
    }
}

$duplicateOrdinals = @($seen | Group-Object ordinal | Where-Object Count -gt 1 | ForEach-Object Name)
$duplicateIds = @($seen | Where-Object { $_.id } | Group-Object id | Where-Object Count -gt 1 | ForEach-Object Name)
$missing = @((1..$corpusByOrdinal.Count) | Where-Object { -not ($seen.ordinal -contains $_) })
$unknownOrdinals = @($seen | Where-Object { -not $corpusByOrdinal.ContainsKey($_.ordinal) } | ForEach-Object ordinal)
$wrongIds = @($seen | Where-Object { $_.id -and $corpusByOrdinal.ContainsKey($_.ordinal) -and $corpusByOrdinal[$_.ordinal] -ne $_.id } | ForEach-Object ordinal)
$missingIds = @($seen | Where-Object { -not $_.id } | ForEach-Object ordinal)

[pscustomobject][ordered]@{
    corpusArticles = $corpusByOrdinal.Count
    readingEntries = $seen.Count
    coveredArticles = @($seen.ordinal | Sort-Object -Unique).Count
    missingEntries = $missing.Count
    duplicateOrdinals = $duplicateOrdinals.Count
    duplicateIds = $duplicateIds.Count
    unknownOrdinals = $unknownOrdinals.Count
    wrongIds = $wrongIds.Count
    missingIds = $missingIds.Count
    status = if ($seen.Count -eq $corpusByOrdinal.Count -and $missing.Count -eq 0 -and $duplicateOrdinals.Count -eq 0 -and $duplicateIds.Count -eq 0 -and $unknownOrdinals.Count -eq 0 -and $wrongIds.Count -eq 0 -and $missingIds.Count -eq 0) { 'PASS' } else { 'INCOMPLETE' }
} | Format-List

if ($missing.Count -gt 0) { "Missing: $($missing -join ', ')" }
if ($wrongIds.Count -gt 0) { "Wrong IDs: $($wrongIds -join ', ')" }
