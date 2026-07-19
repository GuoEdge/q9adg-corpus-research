param(
    [string]$ExistingPath = (Join-Path $PSScriptRoot '..\review\claim-review-results.csv'),
    [string]$BatchPath = (Join-Path $PSScriptRoot '..\review\claim-review-results-next20.csv'),
    [int]$ExpectedPreviousCount = 12,
    [int]$MinimumBatchCount = 20
)

$ErrorActionPreference = 'Stop'
$existing = @(Import-Csv -LiteralPath $ExistingPath)
$batch = @(Import-Csv -LiteralPath $BatchPath)
if ($batch.Count -lt $MinimumBatchCount) { throw "Expected at least $MinimumBatchCount new reviews; found $($batch.Count)." }

$existingOrdinals = @($existing | ForEach-Object { [int]$_.ordinal })
$batchOrdinals = @($batch | ForEach-Object { [int]$_.ordinal })
$alreadyApplied = @($batchOrdinals | Where-Object { $_ -in $existingOrdinals }).Count
if ($alreadyApplied -eq $batch.Count) {
    [pscustomobject]@{ previousCount=$existing.Count; appendedCount=0; totalCount=$existing.Count; alreadyApplied=$true; status='PASS' } | ConvertTo-Json
    exit 0
}
if ($alreadyApplied -ne 0) { throw "Only part of the review batch is already present; refusing a mixed append." }
if ($existing.Count -ne $ExpectedPreviousCount) { throw "Expected $ExpectedPreviousCount existing reviews before this append; found $($existing.Count)." }

$seen = @{}
foreach ($row in $existing) { $seen[[int]$row.ordinal] = $true }
foreach ($row in $batch) {
    if ($seen.ContainsKey([int]$row.ordinal)) { throw "Duplicate reviewed ordinal $($row.ordinal)." }
    if ($row.thesisSupport -notin @('PASS','PARTIAL','FAIL') -or $row.reasoningSupport -notin @('PASS','PARTIAL','FAIL') -or $row.actionSupport -notin @('PASS','PARTIAL','FAIL')) { throw "Invalid support value at ordinal $($row.ordinal)." }
    if ($row.quoteSupport -notin @('EXACT','PARTIAL','NONE') -or $row.researcherJudgmentLeak -notin @('NONE','PRESENT')) { throw "Invalid review classification at ordinal $($row.ordinal)." }
    $seen[[int]$row.ordinal] = $true
}

@($existing + $batch) | Export-Csv -LiteralPath ([IO.Path]::GetFullPath($ExistingPath)) -NoTypeInformation -Encoding UTF8
[pscustomobject]@{
    previousCount = $existing.Count
    appendedCount = $batch.Count
    totalCount = $existing.Count + $batch.Count
    status = 'PASS'
} | ConvertTo-Json
