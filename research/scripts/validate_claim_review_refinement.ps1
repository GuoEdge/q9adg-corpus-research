param(
    [Parameter(Mandatory=$true)][string]$BatchPath,
    [Parameter(Mandatory=$true)][string]$ResultPath,
    [Parameter(Mandatory=$true)][string]$SuggestionPath,
    [Parameter(Mandatory=$true)][string[]]$ReplacementPaths
)

$ErrorActionPreference = 'Stop'
$batch = @(Get-Content -LiteralPath $BatchPath | Where-Object { $_ } | ForEach-Object { $_ | ConvertFrom-Json })
$results = @(Import-Csv -LiteralPath $ResultPath)
$suggestions = @(Import-Csv -LiteralPath $SuggestionPath)
$replacements = @($ReplacementPaths | ForEach-Object { Import-Csv -LiteralPath $_ })
$batchByOrdinal = @{}
foreach ($row in $batch) {
    $ordinal = [int]$row.ordinal
    if ($batchByOrdinal.ContainsKey($ordinal)) { throw "Duplicate batch ordinal $ordinal." }
    $batchByOrdinal[$ordinal] = $row
}

$resultFailures = [Collections.Generic.List[string]]::new()
$seenResults = @{}
foreach ($row in $results) {
    $ordinal = [int]$row.ordinal
    if (-not $batchByOrdinal.ContainsKey($ordinal)) { [void]$resultFailures.Add("extra:$ordinal") }
    if ($seenResults.ContainsKey($ordinal)) { [void]$resultFailures.Add("duplicate:$ordinal") }
    $seenResults[$ordinal] = $true
    if ($row.thesisSupport -notin @('PASS','PARTIAL','FAIL') -or
        $row.reasoningSupport -notin @('PASS','PARTIAL','FAIL') -or
        $row.actionSupport -notin @('PASS','PARTIAL','FAIL') -or
        $row.quoteSupport -notin @('EXACT','PARTIAL','NONE') -or
        $row.researcherJudgmentLeak -notin @('NONE','PRESENT') -or
        [string]::IsNullOrWhiteSpace([string]$row.reviewNote)) {
        [void]$resultFailures.Add("schema:$ordinal")
    }
}
foreach ($ordinal in $batchByOrdinal.Keys) {
    if (-not $seenResults.ContainsKey($ordinal)) { [void]$resultFailures.Add("missing:$ordinal") }
}

$fieldMap = @{
    thesis = 'thesis'
    reasoning = 'reasoning'
    authorActionAndEthicalJudgments = 'actionJudgment'
    sourceQuotes = 'sourceQuotes'
    faithfulSummary = 'faithfulSummary'
}
$suggestionFailures = [Collections.Generic.List[string]]::new()
$requiredReplacementKeys = @{}
foreach ($row in $suggestions) {
    $ordinal = [int]$row.ordinal
    if (-not $batchByOrdinal.ContainsKey($ordinal)) { [void]$suggestionFailures.Add("extra:$ordinal"); continue }
    if (-not $fieldMap.ContainsKey([string]$row.field)) { [void]$suggestionFailures.Add("field:$($ordinal):$($row.field)"); continue }
    if ($row.action -notin @('DELETE_TAIL','REPLACE_FIELD','REEXTRACT_QUOTES')) { [void]$suggestionFailures.Add("action:$($ordinal):$($row.action)") }
    $sourceField = $fieldMap[[string]$row.field]
    $value = [string]$batchByOrdinal[$ordinal].original.$sourceField
    $startPhrase = [string]$row.startPhrase
    if ([string]::IsNullOrWhiteSpace($startPhrase)) { [void]$suggestionFailures.Add("empty-start:$($ordinal):$($row.field)") }
    else {
        $first = $value.IndexOf($startPhrase,[StringComparison]::Ordinal)
        $last = $value.LastIndexOf($startPhrase,[StringComparison]::Ordinal)
        if ($first -lt 0) { [void]$suggestionFailures.Add("unlocated:$($ordinal):$($row.field)") }
        elseif ($first -ne $last) { [void]$suggestionFailures.Add("ambiguous:$($ordinal):$($row.field)") }
    }
    if ($row.action -in @('REPLACE_FIELD','REEXTRACT_QUOTES')) {
        $requiredReplacementKeys["$ordinal`:$($row.field)"] = $true
    }
}

$replacementFailures = [Collections.Generic.List[string]]::new()
$replacementKeys = @{}
foreach ($row in $replacements) {
    $ordinal = [int]$row.ordinal
    $key = "$ordinal`:$($row.field)"
    if (-not $batchByOrdinal.ContainsKey($ordinal)) { [void]$replacementFailures.Add("extra:$key"); continue }
    if (-not $fieldMap.ContainsKey([string]$row.field)) { [void]$replacementFailures.Add("field:$key"); continue }
    if ($replacementKeys.ContainsKey($key)) { [void]$replacementFailures.Add("duplicate:$key") }
    $replacementKeys[$key] = $true
    if ([string]::IsNullOrWhiteSpace([string]$row.replacementText)) { [void]$replacementFailures.Add("empty:$key") }
    if ($row.field -eq 'sourceQuotes') {
        $rawText = [string]$batchByOrdinal[$ordinal].rawText
        $quotes = @([string]$row.replacementText -split '；' | ForEach-Object { $_.Trim() } | Where-Object { $_ })
        if ($quotes.Count -eq 0) { [void]$replacementFailures.Add("no-quotes:$key") }
        foreach ($quote in $quotes) {
            if (-not $rawText.Contains($quote,[StringComparison]::Ordinal)) { [void]$replacementFailures.Add("ordinal:$($key):$quote") }
        }
    }
}
foreach ($key in $requiredReplacementKeys.Keys) {
    if (-not $replacementKeys.ContainsKey($key)) { [void]$replacementFailures.Add("missing:$key") }
}

[ordered]@{
    batchRows = $batch.Count
    uniqueBatchOrdinals = $batchByOrdinal.Count
    resultRows = $results.Count
    resultFailures = $resultFailures.Count
    suggestionRows = $suggestions.Count
    suggestionFailures = $suggestionFailures.Count
    requiredReplacementCount = $requiredReplacementKeys.Count
    replacementRows = $replacements.Count
    replacementFailures = $replacementFailures.Count
    failureDetails = @($resultFailures + $suggestionFailures + $replacementFailures)
    status = if ($batch.Count -eq $results.Count -and $resultFailures.Count -eq 0 -and $suggestionFailures.Count -eq 0 -and $replacementFailures.Count -eq 0) { 'PASS' } else { 'REVIEW' }
} | ConvertTo-Json -Depth 5
