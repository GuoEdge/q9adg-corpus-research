[CmdletBinding()]
param(
    [string]$ManifestPath = (Join-Path $PSScriptRoot '..\review\strict-quote-residual-batches-100\strict-quote-review-manifest.csv'),
    [string]$BatchDir = (Join-Path $PSScriptRoot '..\review\strict-quote-residual-batches-100'),
    [string]$ReviewDir = (Join-Path $PSScriptRoot '..\review'),
    [string]$OutputCsv = (Join-Path $PSScriptRoot '..\data\strict_quote_residual_batch_summary.csv'),
    [string]$OutputStats = (Join-Path $PSScriptRoot '..\data\strict_quote_residual_batch_summary.stats.json')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-IntProperty([object]$Object,[string[]]$Names) {
    foreach ($name in $Names) {
        $property = $Object.PSObject.Properties[$name]
        if ($null -ne $property) { return [int]$property.Value }
    }
    return 0
}

$manifest = @(Import-Csv -LiteralPath $ManifestPath)
$rows = [Collections.Generic.List[object]]::new()
$errors = [Collections.Generic.List[string]]::new()

foreach ($entry in $manifest) {
    $batch = [int]$entry.batch
    $articleCount = [int]$entry.articleCount
    $candidateCount = [int]$entry.unresolvedQuoteCount
    $tag = '{0:D3}-{1:D3}' -f $batch,$articleCount
    $prefix = "strict-quote-residual-batch-$tag"
    $statsPath = Join-Path $BatchDir "$prefix-decisions.stats.json"
    $decisionPath = Join-Path $BatchDir "$prefix-decisions.csv"
    $approvedPath = Join-Path $ReviewDir "$prefix-approved-exact-replacements.csv"

    $statsPresent = Test-Path -LiteralPath $statsPath -PathType Leaf
    $decisionPresent = Test-Path -LiteralPath $decisionPath -PathType Leaf
    $approvedPresent = Test-Path -LiteralPath $approvedPath -PathType Leaf
    $stats = $null
    $decisionRows = @()
    $approvedRows = @()
    if ($statsPresent) { $stats = Get-Content -Raw -LiteralPath $statsPath | ConvertFrom-Json }
    if ($decisionPresent) { $decisionRows = @(Import-Csv -LiteralPath $decisionPath) }
    if ($approvedPresent) { $approvedRows = @(Import-Csv -LiteralPath $approvedPath) }

    $decisionCount = if ($null -ne $stats) { Get-IntProperty $stats @('decisionRowCount') } else { 0 }
    $exactCount = if ($null -ne $stats) { Get-IntProperty $stats @('exactReplaceCount') } else { 0 }
    $rewriteCount = if ($null -ne $stats) { Get-IntProperty $stats @('needsRewriteCount') } else { 0 }
    $deleteCount = if ($null -ne $stats) { Get-IntProperty $stats @('deleteAsParaphraseCount') } else { 0 }
    $statsPass = $null -ne $stats -and [string]$stats.status -eq 'PASS'
    $countsPass = $statsPass -and
        $decisionCount -eq $candidateCount -and
        $decisionRows.Count -eq $candidateCount -and
        ($exactCount + $rewriteCount + $deleteCount) -eq $candidateCount
    $approvedPass = $approvedPresent -and $approvedRows.Count -eq $articleCount
    $batchStatus = if ($countsPass -and $approvedPass) { 'APPROVED' } elseif ($statsPass) { 'AUDITED_NOT_APPROVED' } else { 'PENDING' }

    if ($statsPresent -and -not $countsPass) { [void]$errors.Add("Batch $batch stats or decision counts do not reconcile.") }
    if ($approvedPresent -and -not $approvedPass) { [void]$errors.Add("Batch $batch approved replacement count is invalid.") }

    [void]$rows.Add([pscustomobject][ordered]@{
        batch = $batch
        articleCount = $articleCount
        candidateCount = $candidateCount
        decisionCount = $decisionCount
        exactReplaceCount = $exactCount
        needsRewriteCount = $rewriteCount
        deleteAsParaphraseCount = $deleteCount
        statsPresent = $statsPresent
        statsPass = $statsPass
        approvedPresent = $approvedPresent
        approvedArticleCount = $approvedRows.Count
        status = $batchStatus
    })
}

$rows | Export-Csv -LiteralPath $OutputCsv -NoTypeInformation -Encoding utf8BOM
$approvedBatchCount = @($rows | Where-Object status -eq 'APPROVED').Count
$summaryStatus = if ($manifest.Count -eq 11 -and $approvedBatchCount -eq 11 -and $errors.Count -eq 0 -and ($rows | Measure-Object candidateCount -Sum).Sum -eq 1534) { 'PASS' } else { 'REVIEW' }
[ordered]@{
    generatedAt = [DateTimeOffset]::Now.ToString('o')
    manifestBatchCount = $manifest.Count
    approvedBatchCount = $approvedBatchCount
    totalArticleAssignments = [int](($rows | Measure-Object articleCount -Sum).Sum)
    totalCandidateCount = [int](($rows | Measure-Object candidateCount -Sum).Sum)
    totalDecisionCount = [int](($rows | Measure-Object decisionCount -Sum).Sum)
    totalExactReplaceCount = [int](($rows | Measure-Object exactReplaceCount -Sum).Sum)
    totalNeedsRewriteCount = [int](($rows | Measure-Object needsRewriteCount -Sum).Sum)
    totalDeleteAsParaphraseCount = [int](($rows | Measure-Object deleteAsParaphraseCount -Sum).Sum)
    errorCount = $errors.Count
    errors = @($errors)
    status = $summaryStatus
} | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $OutputStats -Encoding utf8

Get-Content -Raw -LiteralPath $OutputStats
if ($errors.Count -gt 0) { exit 1 }
