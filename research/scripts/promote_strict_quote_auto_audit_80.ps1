param(
    [string]$InputPath = (Join-Path $PSScriptRoot '..\review\strict-quote-auto-audit-80-exact-replacements.csv'),
    [string]$CorpusPath = (Join-Path $PSScriptRoot '..\..\sooon-q9adg-articles.jsonl'),
    [string]$EvidencePath = (Join-Path $PSScriptRoot '..\data\author_view_evidence_clean.jsonl'),
    [string]$OutputPath = (Join-Path $PSScriptRoot '..\review\strict-quote-auto-audit-80-approved-exact-replacements.csv')
)

$ErrorActionPreference = 'Stop'
$rows = @(Import-Csv -LiteralPath $InputPath)
if ($rows.Count -ne 79) { throw "Expected 79 independently audited replacements, found $($rows.Count)." }

$raw = @{}
foreach ($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($CorpusPath))) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $row = $line | ConvertFrom-Json
    $raw[[string]$row.id] = [string]$row.text
}

$evidence = @{}
foreach ($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($EvidencePath))) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $row = $line | ConvertFrom-Json
    $evidence[[int]$row.ordinal] = $row
}

$promoted = foreach ($group in @($rows | Group-Object ordinal,field)) {
    $first = $group.Group[0]
    if ($first.field -ne 'sourceQuotes') { throw "Unsupported field $($first.field)." }
    $ordinal = [int]$first.ordinal
    if (-not $evidence.ContainsKey($ordinal)) { throw "Missing evidence ordinal $ordinal." }
    $current = [string]$evidence[$ordinal].sourceQuotes
    $replacementText = $current
    $decisions = [Collections.Generic.List[string]]::new()
    $reasons = [Collections.Generic.List[string]]::new()
    foreach ($row in $group.Group) {
        if ($row.decision -notin @('ACCEPT','EDIT')) { throw "Unapproved decision $($row.decision)." }
        if (-not $raw.ContainsKey([string]$row.id)) { throw "Missing corpus ID $($row.id)." }
        if ([string]::IsNullOrWhiteSpace([string]$row.replacementQuote)) { throw "Empty replacement at ordinal $ordinal." }
        if (-not $raw[[string]$row.id].Contains([string]$row.replacementQuote,[StringComparison]::Ordinal)) {
            throw "Non-Ordinal replacement at ordinal $ordinal."
        }
        if ($replacementText.Contains([string]$row.originalQuote,[StringComparison]::Ordinal)) {
            $replacementText = $replacementText.Replace([string]$row.originalQuote,[string]$row.replacementQuote,[StringComparison]::Ordinal)
        }
        elseif (-not $replacementText.Contains([string]$row.replacementQuote,[StringComparison]::Ordinal)) {
            throw "Neither original nor audited replacement is present at ordinal $ordinal."
        }
        [void]$decisions.Add([string]$row.decision)
        [void]$reasons.Add([string]$row.reason)
    }
    if ($replacementText -ne $current) {
        [pscustomobject]@{
            ordinal = $ordinal
            id = [string]$first.id
            field = [string]$first.field
            originalText = $current
            replacementText = $replacementText
            auditDecision = ($decisions -join ';')
            auditReason = ($reasons -join '；')
        }
    }
}

$promoted | Export-Csv -LiteralPath $OutputPath -NoTypeInformation -Encoding UTF8
[ordered]@{
    inputRows = $rows.Count
    promotedRows = $promoted.Count
    uniqueKeys = @($rows | Group-Object ordinal,field).Count
    alreadyAppliedKeys = @($rows | Group-Object ordinal,field).Count - $promoted.Count
    comparison = 'StringComparison.Ordinal'
    failures = 0
    status = 'PASS'
} | ConvertTo-Json
