param(
    [Parameter(Mandatory=$true)]
    [string[]]$BatchPaths,
    [string]$OutputDir = (Join-Path $PSScriptRoot '..\review\claim-review-batches')
)

$ErrorActionPreference = 'Stop'

function Get-RegisteredQuotes([string]$Value) {
    return @(
        [regex]::Split($Value, "`r?`n|；") |
            ForEach-Object {
                $text = $_.Trim() -replace '^[-*•]\s*',''
                if ($text.StartsWith('“') -and $text.EndsWith('”') -and $text.Length -gt 2) {
                    $text = $text.Substring(1,$text.Length-2)
                }
                $text.Trim()
            } |
            Where-Object { $_.Length -ge 4 }
    )
}

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
$summaries = [Collections.Generic.List[object]]::new()
$allOrdinals = [Collections.Generic.List[int]]::new()
foreach ($batchPath in $BatchPaths) {
    $rows = @(Get-Content -LiteralPath $batchPath | Where-Object { $_ } | ForEach-Object { $_ | ConvertFrom-Json })
    $checks = foreach ($row in $rows) {
        $allOrdinals.Add([int]$row.ordinal)
        $quotes = @(Get-RegisteredQuotes ([string]$row.original.sourceQuotes))
        $exact = @($quotes | Where-Object { ([string]$row.rawText).Contains($_,[StringComparison]::Ordinal) })
        $quoteStatus = if ($quotes.Count -eq 0) { 'NONE' } elseif ($exact.Count -eq $quotes.Count) { 'EXACT' } elseif ($exact.Count -eq 0) { 'NONE' } else { 'PARTIAL' }
        [pscustomobject]@{
            queueIndex = [int]$row.queueIndex
            ordinal = [int]$row.ordinal
            title = [string]$row.title
            riskScore = [double]$row.riskScore
            registeredQuoteCount = $quotes.Count
            exactQuoteCount = $exact.Count
            failedQuoteCount = $quotes.Count-$exact.Count
            computedQuoteSupport = $quoteStatus
            thesisChangedByCleaning = ([string]$row.original.thesis -cne [string]$row.clean.thesis)
            actionChangedByCleaning = ([string]$row.original.actionJudgment -cne [string]$row.clean.actionJudgment)
            summaryChangedByCleaning = ([string]$row.original.faithfulSummary -cne [string]$row.clean.faithfulSummary)
            thesisRemovedChars = ([string]$row.original.thesis).Length-([string]$row.clean.thesis).Length
            actionRemovedChars = ([string]$row.original.actionJudgment).Length-([string]$row.clean.actionJudgment).Length
            summaryRemovedChars = ([string]$row.original.faithfulSummary).Length-([string]$row.clean.faithfulSummary).Length
        }
    }
    $base = [IO.Path]::GetFileNameWithoutExtension($batchPath)
    $outputPath = Join-Path $OutputDir ($base + '-precheck.csv')
    $checks | Export-Csv -LiteralPath ([IO.Path]::GetFullPath($outputPath)) -NoTypeInformation -Encoding UTF8
    $summaries.Add([pscustomobject]@{
        batch = $base
        rows = $checks.Count
        registeredQuotes = ($checks | Measure-Object registeredQuoteCount -Sum).Sum
        failedQuotes = ($checks | Measure-Object failedQuoteCount -Sum).Sum
        articlesWithCleaning = @($checks | Where-Object { $_.thesisChangedByCleaning -or $_.actionChangedByCleaning -or $_.summaryChangedByCleaning }).Count
        outputPath = [IO.Path]::GetFullPath($outputPath)
    })
}

[ordered]@{
    batchCount = $summaries.Count
    rowCount = ($summaries | Measure-Object rows -Sum).Sum
    uniqueOrdinalCount = @($allOrdinals | Sort-Object -Unique).Count
    summaries = $summaries
    status = if (@($summaries | Where-Object rows -lt 1).Count -eq 0 -and @($allOrdinals | Sort-Object -Unique).Count -eq $allOrdinals.Count) { 'PASS' } else { 'REVIEW' }
} | ConvertTo-Json -Depth 5
