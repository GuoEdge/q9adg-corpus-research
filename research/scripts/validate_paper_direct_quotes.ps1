param(
    [string]$CorpusPath = (Join-Path $PSScriptRoot '..\..\sooon-q9adg-articles.jsonl'),
    [string]$PaperPath = (Join-Path $PSScriptRoot '..\papers\03_伦理作为社会技术_权力互惠与社会资本.md'),
    [string]$OutputPath = (Join-Path $PSScriptRoot '..\review\paper-direct-quote-validation.csv'),
    [int]$MinimumLength = 4
)

$ErrorActionPreference = 'Stop'
if ($MinimumLength -lt 1) { throw 'MinimumLength must be positive.' }

$paperText = [IO.File]::ReadAllText([IO.Path]::GetFullPath($PaperPath))
$body = $paperText
$ids = @(
    [regex]::Matches($paperText,'(?i)\b[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\b') |
        ForEach-Object { $_.Value.ToLowerInvariant() } |
        Sort-Object -Unique
)

$raw = [Collections.Generic.List[object]]::new()
foreach ($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($CorpusPath))) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $row = $line | ConvertFrom-Json
    $idIsCited = $ids -contains ([string]$row.id).ToLowerInvariant()
    $urlIsCited = -not [string]::IsNullOrWhiteSpace([string]$row.url) -and
        $paperText.Contains([string]$row.url,[StringComparison]::Ordinal)
    if ($idIsCited -or $urlIsCited) { $raw.Add($row) }
}

$quotePattern = '(?:\u201c(?<quote>[^\u201d\r\n]{' + $MinimumLength + ',})\u201d|\u2018(?<quote>[^\u2019\r\n]{' + $MinimumLength + ',})\u2019)'
$quotes = @(
    [regex]::Matches($body,$quotePattern) |
        ForEach-Object { $_.Groups['quote'].Value } |
        Sort-Object -Unique
)
$results = foreach ($quote in $quotes) {
    $hits = @($raw | Where-Object { ([string]$_.text).Contains($quote,[StringComparison]::Ordinal) })
    [pscustomobject]@{
        quote = $quote
        exactInCitedSource = $hits.Count -gt 0
        matchingIds = ($hits.id -join ';')
        matchingTitles = ($hits.title -join ';')
        comparison = 'StringComparison.Ordinal'
        status = if ($hits.Count -gt 0) { 'PASS' } else { 'REVIEW' }
    }
}

New-Item -ItemType Directory -Force -Path (Split-Path -Parent ([IO.Path]::GetFullPath($OutputPath))) | Out-Null
$results | Export-Csv -LiteralPath $OutputPath -NoTypeInformation -Encoding UTF8
$failures = @($results | Where-Object status -ne 'PASS').Count
[ordered]@{
    paper = [IO.Path]::GetFullPath($PaperPath)
    citedSourceCount = $raw.Count
    uniqueDirectQuoteCount = $results.Count
    exactDirectQuoteCount = @($results | Where-Object exactInCitedSource).Count
    failures = $failures
    comparison = 'StringComparison.Ordinal'
    status = if ($failures -eq 0) { 'PASS' } else { 'REVIEW' }
} | ConvertTo-Json
