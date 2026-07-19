param(
    [string]$BatchDir = (Join-Path $PSScriptRoot '..\review\strict-quote-batches-100'),
    [string]$ReviewDir = (Join-Path $PSScriptRoot '..\review'),
    [string]$ManifestPath = (Join-Path $PSScriptRoot '..\review\strict-quote-batches-100\strict-quote-review-manifest.csv'),
    [string]$OutputPath = (Join-Path $PSScriptRoot '..\data\strict_quote_review_summary.csv')
)

$ErrorActionPreference = 'Stop'
$manifest = @(Import-Csv -LiteralPath $ManifestPath | Sort-Object { [int]$_.batch })
$rows = @(
    foreach ($entry in $manifest) {
        $batch = [int]$entry.batch
        $articleCount = [int]$entry.articleCount
        $candidateCount = [int]$entry.unresolvedQuoteCount
        $tag = '{0:D3}-{1:D3}' -f $batch,$articleCount
        $statsFile = @(Get-ChildItem -LiteralPath $BatchDir -Filter "strict-quote-review-batch-$tag-decisions.stats.json" -File -ErrorAction SilentlyContinue)
        $approvedFile = @(Get-ChildItem -LiteralPath $ReviewDir -Filter "strict-quote-review-batch-$tag-approved-exact-replacements.csv" -File -ErrorAction SilentlyContinue)

        if ($statsFile.Count -eq 1) {
            $stats = Get-Content -LiteralPath $statsFile[0].FullName -Raw | ConvertFrom-Json
            $validationErrorCount = if ($null -eq $stats.validationErrors) { 0 } else { @($stats.validationErrors).Count }
            $failureTotal = 0
            foreach ($property in $stats.psobject.Properties) {
                if ($property.Name -match '(?:Failure|Mismatch|MissingFromAggregate)Count$') {
                    $failureTotal += [int]$property.Value
                }
            }
            $batchStatus = if (
                [string]$stats.status -eq 'PASS' -and
                [int]$stats.inputArticleCount -eq $articleCount -and
                [int]$stats.unresolvedCandidateCount -eq $candidateCount -and
                [int]$stats.decisionRowCount -eq $candidateCount -and
                [int]$stats.exactReplacementArticleCount -eq $articleCount -and
                $failureTotal -eq 0 -and
                $validationErrorCount -eq 0 -and
                $approvedFile.Count -eq 1
            ) { 'PASS' } else { 'REVIEW' }

            [pscustomobject][ordered]@{
                batch = $batch
                articleCount = $articleCount
                candidateCount = $candidateCount
                exactReplaceCount = [int]$stats.exactReplaceCount
                needsRewriteCount = [int]$stats.needsRewriteCount
                deleteAsParaphraseCount = [int]$stats.deleteAsParaphraseCount
                registeredExactFragmentCount = [int]$stats.registeredExactFragmentCount
                failureTotal = $failureTotal
                approvedFile = if ($approvedFile.Count -eq 1) { $approvedFile[0].Name } else { '' }
                status = $batchStatus
            }
        }
        else {
            [pscustomobject][ordered]@{
                batch = $batch
                articleCount = $articleCount
                candidateCount = $candidateCount
                exactReplaceCount = 0
                needsRewriteCount = 0
                deleteAsParaphraseCount = 0
                registeredExactFragmentCount = 0
                failureTotal = -1
                approvedFile = ''
                status = 'MISSING'
            }
        }
    }
)

New-Item -ItemType Directory -Path (Split-Path -Parent ([IO.Path]::GetFullPath($OutputPath))) -Force | Out-Null
$rows | Export-Csv -LiteralPath $OutputPath -NoTypeInformation -Encoding utf8BOM
$stats = [ordered]@{
    generatedAt = (Get-Date).ToString('o')
    batchCount = $rows.Count
    articleCount = ($rows | Measure-Object articleCount -Sum).Sum
    candidateCount = ($rows | Measure-Object candidateCount -Sum).Sum
    exactReplaceCount = ($rows | Measure-Object exactReplaceCount -Sum).Sum
    needsRewriteCount = ($rows | Measure-Object needsRewriteCount -Sum).Sum
    deleteAsParaphraseCount = ($rows | Measure-Object deleteAsParaphraseCount -Sum).Sum
    passBatchCount = @($rows | Where-Object status -eq 'PASS').Count
    incompleteBatches = @($rows | Where-Object status -ne 'PASS' | Select-Object -ExpandProperty batch)
    status = if ($rows.Count -eq 9 -and @($rows | Where-Object status -ne 'PASS').Count -eq 0) { 'PASS' } else { 'REVIEW' }
}
$stats | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath ([IO.Path]::ChangeExtension([IO.Path]::GetFullPath($OutputPath), '.stats.json')) -Encoding utf8
$stats | ConvertTo-Json -Depth 4
