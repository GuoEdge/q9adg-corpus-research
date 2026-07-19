param(
    [string]$ExistingPath = (Join-Path $PSScriptRoot '..\review\claim-review-results.csv'),
    [Parameter(Mandatory=$true)]
    [string[]]$RefinementPaths,
    [int]$ExpectedTotalCount = 500
)

$ErrorActionPreference = 'Stop'
$allowedSupport = @('PASS','PARTIAL','FAIL')
$allowedQuote = @('EXACT','PARTIAL','NONE')
$allowedLeak = @('NONE','PRESENT')

$existing = @(Import-Csv -LiteralPath $ExistingPath)
if ($existing.Count -ne $ExpectedTotalCount) { throw "Expected $ExpectedTotalCount existing rows; got $($existing.Count)." }
$existingOrdinals = @($existing | ForEach-Object { [int]$_.ordinal })
if (@($existingOrdinals | Sort-Object -Unique).Count -ne $existing.Count) { throw 'Existing result has duplicate ordinals.' }

$replacementMap = @{}
$sourceMap = @{}
foreach ($path in $RefinementPaths) {
    $rows = @(Import-Csv -LiteralPath $path)
    if ($rows.Count -eq 0) { throw "Empty refinement file: $path" }
    foreach ($row in $rows) {
        $ordinal = [int]$row.ordinal
        if ($ordinal -notin $existingOrdinals) { throw "Refinement ordinal $ordinal is absent from the existing result." }
        if ($replacementMap.ContainsKey($ordinal)) { throw "Duplicate refinement ordinal $ordinal across input files." }
        if ($row.thesisSupport -notin $allowedSupport -or
            $row.reasoningSupport -notin $allowedSupport -or
            $row.actionSupport -notin $allowedSupport -or
            $row.quoteSupport -notin $allowedQuote -or
            $row.researcherJudgmentLeak -notin $allowedLeak -or
            [string]::IsNullOrWhiteSpace([string]$row.reviewNote)) {
            throw "Invalid refinement row at ordinal $ordinal."
        }
        $replacementMap[$ordinal] = $row
        $sourceMap[$ordinal] = [IO.Path]::GetFileName($path)
    }
}

$changed = 0
$output = foreach ($row in $existing) {
    $ordinal = [int]$row.ordinal
    if ($replacementMap.ContainsKey($ordinal)) {
        $changed++
        $replacementMap[$ordinal]
    }
    else { $row }
}
$output | Export-Csv -LiteralPath ([IO.Path]::GetFullPath($ExistingPath)) -NoTypeInformation -Encoding UTF8

[ordered]@{
    existingCount = $existing.Count
    refinementFileCount = $RefinementPaths.Count
    replacedCount = $changed
    finalCount = $output.Count
    finalUniqueOrdinalCount = @($output.ordinal | Sort-Object -Unique).Count
    sources = @($sourceMap.Values | Sort-Object -Unique)
    status = if ($changed -eq $replacementMap.Count -and $output.Count -eq $ExpectedTotalCount -and @($output.ordinal | Sort-Object -Unique).Count -eq $ExpectedTotalCount) { 'PASS' } else { 'REVIEW' }
} | ConvertTo-Json -Depth 4
