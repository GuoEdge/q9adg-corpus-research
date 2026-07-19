param(
    [string]$UnresolvedPath = (Join-Path $PSScriptRoot '..\review\strict-quote-unresolved.csv'),
    [string]$CorpusPath = (Join-Path $PSScriptRoot '..\..\sooon-q9adg-articles.jsonl'),
    [string]$EvidencePath = (Join-Path $PSScriptRoot '..\data\author_view_evidence_clean.jsonl'),
    [string]$OutputDir = (Join-Path $PSScriptRoot '..\review\strict-quote-batches-100'),
    [int]$BatchSize = 100
)

$ErrorActionPreference = 'Stop'
if ($BatchSize -lt 1) { throw 'BatchSize must be positive.' }

function Read-JsonlMap([string]$Path) {
    $map = @{}
    foreach ($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($Path))) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        $row = $line | ConvertFrom-Json
        $map[[string]$row.id] = $row
    }
    return $map
}

$unresolved = @(Import-Csv -LiteralPath $UnresolvedPath)
if ($unresolved.Count -eq 0) { throw 'No unresolved quote candidates.' }
$groups = @($unresolved | Group-Object ordinal | Sort-Object @{Expression={ [int]$_.Name };Ascending=$true})
$raw = Read-JsonlMap $CorpusPath
$evidence = Read-JsonlMap $EvidencePath
New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

$manifest = [Collections.Generic.List[object]]::new()
for ($start=0; $start -lt $groups.Count; $start += $BatchSize) {
    $batchIndex = [int]($start/$BatchSize)+1
    $end = [Math]::Min($start+$BatchSize,$groups.Count)
    $batchGroups = @($groups[$start..($end-1)])
    $path = Join-Path $OutputDir ('strict-quote-review-{0:D2}.jsonl' -f $batchIndex)
    $writer = [IO.StreamWriter]::new([IO.Path]::GetFullPath($path),$false,[Text.UTF8Encoding]::new($false))
    try {
        foreach ($group in $batchGroups) {
            $first = $group.Group[0]
            $id = [string]$first.id
            if (-not $raw.ContainsKey($id) -or -not $evidence.ContainsKey($id)) { throw "Missing source layer for $id." }
            $row = $evidence[$id]
            $record = [ordered]@{
                ordinal = [int]$row.ordinal
                id = $id
                title = [string]$row.title
                url = [string]$row.url
                rawText = [string]$raw[$id].text
                registeredSourceQuotes = [string]$row.sourceQuotes
                unresolvedCandidates = @(
                    $group.Group | ForEach-Object {
                        [ordered]@{
                            originalCandidate = [string]$_.originalCandidate
                            bestRawSentence = [string]$_.bestRawSentence
                            recall = [double]$_.recall
                            precision = [double]$_.precision
                            score = [double]$_.score
                            margin = [double]$_.margin
                            lengthRatio = [double]$_.lengthRatio
                        }
                    }
                )
                requiredResult = [ordered]@{
                    ordinal = 'int'
                    field = 'sourceQuotes'
                    replacementText = 'one or more verbatim rawText segments separated by ；, or empty when every candidate must be rejected'
                    rejectedCandidates = 'JSON array of registered candidates that cannot be represented as direct quotes'
                    reviewNote = 'concise Chinese explanation; no external value judgment'
                }
            }
            $writer.WriteLine(($record | ConvertTo-Json -Compress -Depth 8))
        }
    }
    finally { $writer.Dispose() }
    [void]$manifest.Add([pscustomobject]@{
        batch = $batchIndex
        path = [IO.Path]::GetFullPath($path)
        articleCount = $batchGroups.Count
        unresolvedQuoteCount = ($batchGroups.Group | Measure-Object).Count
        firstOrdinal = [int]$batchGroups[0].Name
        lastOrdinal = [int]$batchGroups[-1].Name
    })
}

$manifestPath = Join-Path $OutputDir 'strict-quote-review-manifest.csv'
$manifest | Export-Csv -LiteralPath ([IO.Path]::GetFullPath($manifestPath)) -NoTypeInformation -Encoding UTF8
[ordered]@{
    unresolvedArticleCount = $groups.Count
    unresolvedQuoteCount = $unresolved.Count
    batchSize = $BatchSize
    batchCount = $manifest.Count
    fullBatchCount = @($manifest | Where-Object articleCount -eq $BatchSize).Count
    remainderBatchSize = [int]$manifest[-1].articleCount
    uniqueOrdinalCount = @($unresolved.ordinal | Sort-Object -Unique).Count
    status = if ($groups.Count -eq @($unresolved.ordinal | Sort-Object -Unique).Count) { 'PASS' } else { 'REVIEW' }
} | ConvertTo-Json
