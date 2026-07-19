[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateRange(1,999)]
    [int]$BatchNumber,

    [Parameter(Mandatory)]
    [ValidateRange(1,100)]
    [int]$ArticleCount,

    [string]$BatchDir = (Join-Path $PSScriptRoot '..\review\strict-quote-residual-batches-100'),
    [string]$ReviewDir = (Join-Path $PSScriptRoot '..\review'),
    [string]$CorpusPath = (Join-Path $PSScriptRoot '..\..\sooon-q9adg-articles.jsonl')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$tag = '{0:D3}-{1:D3}' -f $BatchNumber,$ArticleCount
$prefix = "strict-quote-residual-batch-$tag"
$statsPath = Join-Path $BatchDir "$prefix-decisions.stats.json"
$decisionPath = Join-Path $BatchDir "$prefix-decisions.csv"
$replacementPath = Join-Path $BatchDir "$prefix-exact-replacements.csv"
$outputPath = Join-Path $ReviewDir "$prefix-approved-exact-replacements.csv"

foreach ($path in @($statsPath,$decisionPath,$replacementPath)) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Required batch artifact is missing: $path"
    }
}

$stats = Get-Content -Raw -LiteralPath $statsPath | ConvertFrom-Json
if ([string]$stats.status -ne 'PASS') { throw "Batch stats are not PASS: $statsPath" }
if ([bool]$stats.cleanLayerApplied) { throw 'Batch unexpectedly reports cleanLayerApplied=true.' }
if ([int]$stats.inputArticleCount -ne $ArticleCount) {
    throw "Stats article count $($stats.inputArticleCount) does not match requested $ArticleCount."
}
if ([int]$stats.decisionRowCount -ne [int]$stats.unresolvedCandidateCount) {
    throw 'Decision count does not cover every unresolved candidate.'
}

$allowedDecisions = @('EXACT_REPLACE','NEEDS_REWRITE','DELETE_AS_PARAPHRASE')
$decisions = @(Import-Csv -LiteralPath $decisionPath)
if ($decisions.Count -ne [int]$stats.decisionRowCount) { throw 'Decision CSV count disagrees with stats.' }
foreach ($row in $decisions) {
    if ([string]$row.decision -notin $allowedDecisions) { throw "Unsupported decision: $($row.decision)" }
    if ([string]$row.decision -eq 'EXACT_REPLACE' -and [string]::IsNullOrWhiteSpace([string]$row.replacement)) {
        throw "Empty exact replacement at ordinal $($row.ordinal)."
    }
}

$corpusById = @{}
foreach ($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($CorpusPath))) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $article = $line | ConvertFrom-Json -Depth 100
    $corpusById[[string]$article.id] = [string]$article.text
}

$replacementRows = @(Import-Csv -LiteralPath $replacementPath)
if ($replacementRows.Count -ne $ArticleCount) {
    throw "Replacement row count $($replacementRows.Count) does not match article count $ArticleCount."
}
$uniqueOrdinals = @($replacementRows.ordinal | Sort-Object -Unique)
if ($uniqueOrdinals.Count -ne $ArticleCount) { throw 'Replacement ordinals are not unique.' }

$ordinalFailures = 0
foreach ($row in $replacementRows) {
    if ([string]$row.field -ne 'sourceQuotes') { throw "Unexpected field at ordinal $($row.ordinal): $($row.field)" }
    $id = [string]$row.id
    if (-not $corpusById.ContainsKey($id)) { throw "Unknown corpus id at ordinal $($row.ordinal): $id" }
    $text = [string]$corpusById[$id]
    if ([string]::IsNullOrWhiteSpace([string]$row.replacementText)) { continue }
    foreach ($segment in @(([string]$row.replacementText) -split '；' | ForEach-Object { $_.Trim() } | Where-Object { $_ })) {
        if ($text.IndexOf($segment,[StringComparison]::Ordinal) -lt 0) {
            $ordinalFailures++
            Write-Error "Ordinal failure at $($row.ordinal): $segment"
        }
    }
}
if ($ordinalFailures -ne 0) { throw "Found $ordinalFailures Ordinal failures; refusing promotion." }

$replacementRows | Export-Csv -LiteralPath $outputPath -NoTypeInformation -Encoding utf8BOM
Write-Host "PASS: promoted $ArticleCount articles to $outputPath"
