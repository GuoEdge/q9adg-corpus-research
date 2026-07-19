param(
    [string]$CandidatePath = (Join-Path $PSScriptRoot '..\review\strict-quote-auto-candidates.csv'),
    [string]$CorpusPath = (Join-Path $PSScriptRoot '..\..\sooon-q9adg-articles.jsonl'),
    [string]$OutputPath = (Join-Path $PSScriptRoot '..\review\strict-quote-auto-audit-80.jsonl'),
    [int]$SampleSize = 80
)

$ErrorActionPreference = 'Stop'
if ($SampleSize -lt 1) { throw 'SampleSize must be positive.' }

$raw = @{}
foreach ($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($CorpusPath))) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $row = $line | ConvertFrom-Json
    $raw[[string]$row.id] = [string]$row.text
}

$accepted = @(
    Import-Csv -LiteralPath $CandidatePath |
        Where-Object decision -eq 'AUTO_ACCEPT' |
        ForEach-Object {
            $recall = [double]$_.recall
            $score = [double]$_.score
            $margin = [double]$_.margin
            $ratio = [double]$_.lengthRatio
            [pscustomobject]@{
                row = $_
                risk = [Math]::Round((1-$recall)*100 + [Math]::Max(0,0.9-$score)*20 + [Math]::Max(0,0.1-$margin)*10 + [Math]::Max(0,$ratio-1.5)*2,6)
            }
        } |
        Sort-Object @{Expression='risk';Descending=$true},@{Expression={ [int]$_.row.ordinal };Ascending=$true} |
        Select-Object -First $SampleSize
)
if ($accepted.Count -ne $SampleSize) { throw "Expected $SampleSize accepted candidates, got $($accepted.Count)." }

$writer = [IO.StreamWriter]::new([IO.Path]::GetFullPath($OutputPath),$false,[Text.UTF8Encoding]::new($false))
try {
    foreach ($item in $accepted) {
        $candidate = $item.row
        if (-not $raw.ContainsKey([string]$candidate.id)) { throw "Missing corpus id $($candidate.id)." }
        $best = [string]$candidate.bestRawSentence
        $ordinalExact = ([string]$raw[[string]$candidate.id]).Contains($best,[StringComparison]::Ordinal)
        if (-not $ordinalExact) { throw "Candidate no longer passes Ordinal at $($candidate.ordinal)." }
        $record = [ordered]@{
            ordinal = [int]$candidate.ordinal
            id = [string]$candidate.id
            title = [string]$candidate.title
            rawText = [string]$raw[[string]$candidate.id]
            originalCandidate = [string]$candidate.originalCandidate
            proposedRawSentence = $best
            metrics = [ordered]@{
                recall = [double]$candidate.recall
                precision = [double]$candidate.precision
                score = [double]$candidate.score
                margin = [double]$candidate.margin
                lengthRatio = [double]$candidate.lengthRatio
                risk = [double]$item.risk
                ordinalExact = $ordinalExact
            }
            requiredResult = [ordered]@{
                ordinal = 'int'
                mappingSupport = 'ACCEPT|REJECT'
                reviewNote = 'Does proposedRawSentence faithfully replace the same registered quote as a direct quotation? No external value judgment.'
            }
        }
        $writer.WriteLine(($record | ConvertTo-Json -Compress -Depth 7))
    }
}
finally { $writer.Dispose() }

[ordered]@{
    sampleSize = $accepted.Count
    uniqueOrdinalCount = @($accepted.row.ordinal | Sort-Object -Unique).Count
    recallBelowOne = @($accepted | Where-Object { [double]$_.row.recall -lt 1 }).Count
    minimumRecall = ($accepted.row | Measure-Object recall -Minimum).Minimum
    minimumScore = ($accepted.row | Measure-Object score -Minimum).Minimum
    minimumMargin = ($accepted.row | Measure-Object margin -Minimum).Minimum
    outputPath = [IO.Path]::GetFullPath($OutputPath)
    status = 'PASS'
} | ConvertTo-Json
