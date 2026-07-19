param(
    [string]$QueuePath = (Join-Path $PSScriptRoot '..\review\quote-corrections-consolidated.csv'),
    [string[]]$DecisionPaths = @(
        (Join-Path $PSScriptRoot '..\review\quote-manual-decisions-a.csv'),
        (Join-Path $PSScriptRoot '..\review\quote-manual-decisions-b.csv')
    ),
    [string]$CorpusPath = (Join-Path $PSScriptRoot '..\..\sooon-q9adg-articles.jsonl'),
    [string]$OutputPath = (Join-Path $PSScriptRoot '..\review\quote-manual-decisions.csv')
)

$ErrorActionPreference = 'Stop'
function Normalize-Quote([string]$Value) {
    if ($null -eq $Value) { return '' }
    return ($Value -replace '[\s\p{P}\p{S}]', '').ToLowerInvariant()
}
$queue = @(Import-Csv -LiteralPath $QueuePath | Where-Object decision -eq 'UNRESOLVED')
$rows = @($DecisionPaths | ForEach-Object { Import-Csv -LiteralPath $_ })
if ($rows.Count -ne $queue.Count) { throw "Decision count $($rows.Count) does not match queue count $($queue.Count)." }

$corpus = @{}
foreach ($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($CorpusPath))) {
    if ($line) { $item = $line | ConvertFrom-Json; $corpus[$item.id] = $item }
}

$byKey = @{}
$accepted = 0
$rejected = 0
$segmentCount = 0
foreach ($row in $rows) {
    $key = "$($row.id)`t$($row.originalUnlocatedQuote)"
    if ($byKey.ContainsKey($key)) { throw "Duplicate manual decision: $key" }
    if ($row.decision -notin @('ACCEPT_MULTI_SEGMENT', 'REJECT_DIRECT_QUOTE')) { throw "Invalid decision for $key" }
    $segments = @($row.verifiedSegmentsJson | ConvertFrom-Json | Where-Object { $null -ne $_ })
    if ($row.decision -eq 'ACCEPT_MULTI_SEGMENT') {
        if ($segments.Count -lt 2) { throw "Accepted decision has fewer than two segments: $key" }
        $raw = [string]$corpus[$row.id].text
        foreach ($segment in $segments) {
            if ($segment.start -lt 0 -or $segment.length -ne ([string]$segment.text).Length) { throw "Invalid location for $key" }
            if ($raw.Substring([int]$segment.start, [int]$segment.length) -cne [string]$segment.text) { throw "Segment does not match raw text: $key" }
        }
        if ((Normalize-Quote (($segments | ForEach-Object text) -join '')) -ne (Normalize-Quote $row.originalUnlocatedQuote)) {
            throw "Accepted segments do not reconstruct the candidate: $key"
        }
        $accepted++
        $segmentCount += $segments.Count
    }
    else {
        if ($segments.Count -ne 0) { throw "Rejected decision contains verified segments: $key" }
        $rejected++
    }
    $byKey[$key] = $row
}

foreach ($item in $queue) {
    $key = "$($item.id)`t$($item.originalUnlocatedQuote)"
    if (-not $byKey.ContainsKey($key)) { throw "Missing manual decision: $key" }
}

$ordered = foreach ($item in $queue) { $byKey["$($item.id)`t$($item.originalUnlocatedQuote)"] }
$ordered | Export-Csv -LiteralPath ([IO.Path]::GetFullPath($OutputPath)) -NoTypeInformation -Encoding UTF8
$stats = [ordered]@{
    queueCount = $queue.Count
    decisionCount = $ordered.Count
    acceptedCandidateCount = $accepted
    acceptedSegmentCount = $segmentCount
    rejectedDirectQuoteCount = $rejected
    status = 'PASS'
}
$stats | ConvertTo-Json | Set-Content -LiteralPath ([IO.Path]::ChangeExtension([IO.Path]::GetFullPath($OutputPath), '.stats.json')) -Encoding UTF8
$stats | ConvertTo-Json
