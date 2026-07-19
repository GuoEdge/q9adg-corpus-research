param(
    [string]$AuditPath = (Join-Path $PSScriptRoot '..\data\claim_support_audit_500.csv'),
    [string]$ReviewResultsPath = (Join-Path $PSScriptRoot '..\review\claim-review-results.csv'),
    [string]$CorpusPath = (Join-Path $PSScriptRoot '..\..\sooon-q9adg-articles.jsonl'),
    [string]$EvidencePath = (Join-Path $PSScriptRoot '..\data\author_view_evidence.jsonl'),
    [string]$CleanEvidencePath = (Join-Path $PSScriptRoot '..\data\author_view_evidence_clean.jsonl'),
    [string]$OutputDir = (Join-Path $PSScriptRoot '..\review\claim-review-batches'),
    [string]$BatchSet = 'next',
    [int]$BatchSize = 100,
    [int]$BatchCount = 3
)

$ErrorActionPreference = 'Stop'
if ($BatchSize -lt 1 -or $BatchCount -lt 1) { throw 'BatchSize and BatchCount must be positive.' }

function Read-JsonlMap([string]$Path) {
    $map = @{}
    foreach ($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($Path))) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        $row = $line | ConvertFrom-Json
        if ([string]::IsNullOrWhiteSpace([string]$row.id)) { throw "Missing id in $Path" }
        $map[[string]$row.id] = $row
    }
    return $map
}

$reviewed = @{}
if (Test-Path -LiteralPath $ReviewResultsPath) {
    foreach ($row in Import-Csv -LiteralPath $ReviewResultsPath) {
        $reviewed[[int]$row.ordinal] = $true
    }
}

$candidates = @(
    Import-Csv -LiteralPath $AuditPath |
        Where-Object { -not $reviewed.ContainsKey([int]$_.ordinal) } |
        Sort-Object @{ Expression = { [double]$_.riskScore }; Descending = $true },
                    @{ Expression = { [int]$_.queueIndex }; Descending = $false } |
        Select-Object -First ($BatchSize * $BatchCount)
)
if ($candidates.Count -eq 0) { throw 'No unreviewed claims remain.' }

$raw = Read-JsonlMap $CorpusPath
$original = Read-JsonlMap $EvidencePath
$clean = Read-JsonlMap $CleanEvidencePath
New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

$files = [Collections.Generic.List[object]]::new()
for ($batchIndex = 0; $batchIndex -lt $BatchCount; $batchIndex++) {
    $start = $batchIndex * $BatchSize
    if ($start -ge $candidates.Count) { break }
    $end = [Math]::Min($start + $BatchSize, $candidates.Count)
    $batch = @($candidates[$start..($end - 1)])
    $letter = [char]([int][char]'A' + $batchIndex)
    $path = Join-Path $OutputDir ("claim-review-{0}-{1}.jsonl" -f $BatchSet, $letter)
    $writer = [IO.StreamWriter]::new([IO.Path]::GetFullPath($path), $false, [Text.UTF8Encoding]::new($false))
    try {
        foreach ($candidate in $batch) {
            $id = [string]$candidate.id
            if (-not $raw.ContainsKey($id) -or -not $original.ContainsKey($id) -or -not $clean.ContainsKey($id)) {
                throw "Missing source layer for id $id (ordinal $($candidate.ordinal))."
            }
            $source = $original[$id]
            $record = [ordered]@{
                queueIndex = [int]$candidate.queueIndex
                riskScore = [double]$candidate.riskScore
                ordinal = [int]$source.ordinal
                id = $id
                title = [string]$source.title
                date = [string]$source.date
                url = [string]$source.url
                rawText = [string]$raw[$id].text
                original = [ordered]@{
                    thesis = [string]$source.thesis
                    reasoning = [string]$source.reasoning
                    actionJudgment = [string]$source.authorActionAndEthicalJudgments
                    sourceQuotes = [string]$source.sourceQuotes
                    faithfulSummary = [string]$source.faithfulSummary
                }
                clean = [ordered]@{
                    thesis = [string]$clean[$id].thesis
                    actionJudgment = [string]$clean[$id].authorActionAndEthicalJudgments
                    faithfulSummary = [string]$clean[$id].faithfulSummary
                }
                requiredResult = [ordered]@{
                    queueIndex = 'int'
                    ordinal = 'int'
                    title = 'string'
                    thesisSupport = 'PASS|PARTIAL|FAIL'
                    reasoningSupport = 'PASS|PARTIAL|FAIL'
                    actionSupport = 'PASS|PARTIAL|FAIL'
                    quoteSupport = 'EXACT|PARTIAL|NONE'
                    researcherJudgmentLeak = 'NONE|PRESENT'
                    reviewNote = 'concise evidence-grounded Chinese'
                }
            }
            $writer.WriteLine(($record | ConvertTo-Json -Compress -Depth 8))
        }
    }
    finally { $writer.Dispose() }
    $files.Add([pscustomobject]@{ path = [IO.Path]::GetFullPath($path); rowCount = $batch.Count })
}

[ordered]@{
    reviewedCount = $reviewed.Count
    unreviewedCount = @(Import-Csv -LiteralPath $AuditPath | Where-Object { -not $reviewed.ContainsKey([int]$_.ordinal) }).Count
    generatedCount = ($files | Measure-Object rowCount -Sum).Sum
    files = $files
    status = 'PASS'
} | ConvertTo-Json -Depth 5
