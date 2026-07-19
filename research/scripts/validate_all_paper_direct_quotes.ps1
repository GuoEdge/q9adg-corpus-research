param(
    [string]$CorpusPath = (Join-Path $PSScriptRoot '..\..\sooon-q9adg-articles.jsonl'),
    [string]$PaperDir = (Join-Path $PSScriptRoot '..\papers'),
    [string]$SummaryPath = (Join-Path $PSScriptRoot '..\review\all-paper-direct-quote-summary.csv'),
    [string]$FailurePath = (Join-Path $PSScriptRoot '..\review\all-paper-direct-quote-failures.csv'),
    [int]$MinimumLength = 4,
    [switch]$NormalizeNonExact
)

$ErrorActionPreference = 'Stop'
$corpus = [Collections.Generic.List[object]]::new()
foreach ($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($CorpusPath))) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $corpus.Add(($line | ConvertFrom-Json))
}

$summaries = [Collections.Generic.List[object]]::new()
$failures = [Collections.Generic.List[object]]::new()
$pattern = '(?:\u201c(?<quote>[^\u201d\r\n]{' + $MinimumLength + ',})\u201d|\u2018(?<quote>[^\u2019\r\n]{' + $MinimumLength + ',})\u2019)'
$normalizedOccurrenceCount = 0
foreach ($paper in Get-ChildItem -LiteralPath $PaperDir -File -Filter '*.md' | Sort-Object Name) {
    $text = [IO.File]::ReadAllText($paper.FullName)
    $newText = $text
    $ids = @(
        [regex]::Matches($text,'(?i)\b[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\b') |
            ForEach-Object { $_.Value.ToLowerInvariant() } |
            Sort-Object -Unique
    )
    $cited = @(
        $corpus | Where-Object {
            ($ids -contains ([string]$_.id).ToLowerInvariant()) -or
            (-not [string]::IsNullOrWhiteSpace([string]$_.url) -and $text.Contains([string]$_.url,[StringComparison]::Ordinal))
        }
    )
    $quotes = @(
        [regex]::Matches($text,$pattern) |
            ForEach-Object { $_.Groups['quote'].Value } |
            Sort-Object -Unique
    )
    $exactCount = 0
    foreach ($quote in $quotes) {
        $hits = @($cited | Where-Object { ([string]$_.text).Contains($quote,[StringComparison]::Ordinal) })
        if ($hits.Count -gt 0) { $exactCount++; continue }
        if ($NormalizeNonExact) {
            $wrapped = '“' + $quote + '”'
            $occurrences = ([regex]::Matches($newText,[regex]::Escape($wrapped))).Count
            if ($occurrences -gt 0) {
                $newText = $newText.Replace($wrapped,$quote,[StringComparison]::Ordinal)
                $normalizedOccurrenceCount += $occurrences
            }
        }
        $failures.Add([pscustomobject]@{
            paper = $paper.Name
            quote = $quote
            citedSourceCount = $cited.Count
            comparison = 'StringComparison.Ordinal'
            status = 'REVIEW'
        })
    }
    $failureCount = $quotes.Count - $exactCount
    $summaries.Add([pscustomobject]@{
        paper = $paper.Name
        citedSourceCount = $cited.Count
        uniqueDirectQuoteCount = $quotes.Count
        exactDirectQuoteCount = $exactCount
        failureCount = $failureCount
        comparison = 'StringComparison.Ordinal'
        status = if ($failureCount -eq 0) { 'PASS' } else { 'REVIEW' }
    })
    if ($NormalizeNonExact -and $newText -ne $text) {
        [IO.File]::WriteAllText($paper.FullName,$newText,[Text.UTF8Encoding]::new($false))
    }
}

New-Item -ItemType Directory -Force -Path (Split-Path -Parent ([IO.Path]::GetFullPath($SummaryPath))) | Out-Null
$summaries | Export-Csv -LiteralPath $SummaryPath -NoTypeInformation -Encoding UTF8
$failures | Export-Csv -LiteralPath $FailurePath -NoTypeInformation -Encoding UTF8
[ordered]@{
    paperCount = $summaries.Count
    passPaperCount = @($summaries | Where-Object status -eq 'PASS').Count
    reviewPaperCount = @($summaries | Where-Object status -eq 'REVIEW').Count
    uniqueQuoteCount = [int](($summaries | Measure-Object uniqueDirectQuoteCount -Sum).Sum)
    exactQuoteCount = [int](($summaries | Measure-Object exactDirectQuoteCount -Sum).Sum)
    failureCount = $failures.Count
    normalizedOccurrenceCount = $normalizedOccurrenceCount
    comparison = 'StringComparison.Ordinal'
    status = if ($failures.Count -eq 0) { 'PASS' } else { 'REVIEW' }
} | ConvertTo-Json
