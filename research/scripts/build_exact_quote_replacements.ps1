param(
    [string]$ReviewDir = (Join-Path $PSScriptRoot '..\review'),
    [string]$CorpusPath = (Join-Path $PSScriptRoot '..\..\sooon-q9adg-articles.jsonl'),
    [string]$EvidencePath = (Join-Path $PSScriptRoot '..\data\author_view_evidence.jsonl'),
    [string]$OutputPath = (Join-Path $PSScriptRoot '..\review\claim-review-auto-quote-exact-replacements.csv'),
    [string]$UnresolvedPath = (Join-Path $PSScriptRoot '..\review\claim-review-auto-quote-unresolved.csv'),
    [double]$MinimumSimilarity = 0.72
)

$ErrorActionPreference = 'Stop'

function Normalize([string]$Value) {
    if ($null -eq $Value) { return '' }
    return ($Value -replace '[\s\p{P}\p{S}]','').ToLowerInvariant()
}

function Get-Grams([string]$Value) {
    $normalized = Normalize $Value
    $grams = [Collections.Generic.HashSet[string]]::new()
    if ($normalized.Length -lt 4) {
        if ($normalized) { [void]$grams.Add($normalized) }
        return $grams
    }
    for ($i=0; $i -le $normalized.Length-4; $i++) { [void]$grams.Add($normalized.Substring($i,4)) }
    return $grams
}

function Get-Similarity([string]$Needle,[string]$Candidate) {
    $needleGrams = Get-Grams $Needle
    if ($needleGrams.Count -eq 0) { return 0 }
    $candidateGrams = Get-Grams $Candidate
    $hits = 0
    foreach ($gram in $needleGrams) { if ($candidateGrams.Contains($gram)) { $hits++ } }
    return [Math]::Round([double]$hits/[double]$needleGrams.Count,4)
}

function Get-RegisteredQuotes([string]$Value) {
    return @(
        [regex]::Split($Value,"`r?`n|；") |
            ForEach-Object {
                $text = $_.Trim() -replace '^[-*•]\s*',''
                if ($text.StartsWith('“') -and $text.EndsWith('”') -and $text.Length -gt 2) { $text=$text.Substring(1,$text.Length-2) }
                $text.Trim()
            } |
            Where-Object { $_.Length -ge 4 }
    )
}

$requested = @{}
foreach ($file in Get-ChildItem -LiteralPath $ReviewDir -Filter '*-clean-suggestions.csv' -File) {
    foreach ($row in Import-Csv -LiteralPath $file.FullName) {
        if ($row.field -eq 'sourceQuotes' -and $row.action -in @('REPLACE_FIELD','REEXTRACT_QUOTES')) {
            $requested[[int]$row.ordinal] = $true
        }
    }
}

$alreadyResolved = @{}
foreach ($file in Get-ChildItem -LiteralPath $ReviewDir -Filter '*-exact-replacements.csv' -File) {
    foreach ($row in Import-Csv -LiteralPath $file.FullName) {
        if ($row.field -eq 'sourceQuotes') { $alreadyResolved[[int]$row.ordinal] = $true }
    }
}

$rawById = @{}
foreach ($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($CorpusPath))) {
    if ($line) { $row=$line|ConvertFrom-Json; $rawById[[string]$row.id]=[string]$row.text }
}
$evidence = @{}
foreach ($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($EvidencePath))) {
    if ($line) { $row=$line|ConvertFrom-Json; $evidence[[int]$row.ordinal]=$row }
}

$replacements = [Collections.Generic.List[object]]::new()
$unresolved = [Collections.Generic.List[object]]::new()
foreach ($ordinal in @($requested.Keys | Sort-Object)) {
    if ($alreadyResolved.ContainsKey($ordinal)) { continue }
    $row = $evidence[$ordinal]
    if ($null -eq $row) { throw "Missing evidence ordinal $ordinal." }
    $raw = $rawById[[string]$row.id]
    $sentences = @([regex]::Split($raw,"`r?`n|(?<=[。！？；])") | ForEach-Object { $_.Trim() } | Where-Object { (Normalize $_).Length -ge 4 })
    $verified = [Collections.Generic.List[string]]::new()
    $failed = $false
    foreach ($quote in @(Get-RegisteredQuotes ([string]$row.sourceQuotes))) {
        if ($raw.Contains($quote,[StringComparison]::Ordinal)) {
            if (-not $verified.Contains($quote)) { [void]$verified.Add($quote) }
            continue
        }
        $best = ''
        $bestScore = -1.0
        foreach ($sentence in $sentences) {
            $score = Get-Similarity $quote $sentence
            if ($score -gt $bestScore) { $bestScore=$score; $best=$sentence }
        }
        if ($bestScore -lt $MinimumSimilarity -or -not $raw.Contains($best,[StringComparison]::Ordinal)) {
            $failed = $true
            $unresolved.Add([pscustomobject]@{ordinal=$ordinal;id=$row.id;title=$row.title;originalCandidate=$quote;bestRawSentence=$best;similarity=$bestScore})
        }
        elseif (-not $verified.Contains($best)) { [void]$verified.Add($best) }
    }
    if (-not $failed -and $verified.Count -gt 0) {
        $replacementText = $verified -join '；'
        $ordinalFailures = @($verified | Where-Object { -not $raw.Contains($_,[StringComparison]::Ordinal) }).Count
        if ($ordinalFailures -ne 0) { throw "Ordinal validation failed at $ordinal." }
        $replacements.Add([pscustomobject]@{ordinal=$ordinal;field='sourceQuotes';replacementText=$replacementText;reason='All registered quotes were preserved or replaced by the closest contiguous raw sentence; every segment passed Ordinal validation.'})
    }
}

$replacements | Export-Csv -LiteralPath ([IO.Path]::GetFullPath($OutputPath)) -NoTypeInformation -Encoding UTF8
$unresolved | Export-Csv -LiteralPath ([IO.Path]::GetFullPath($UnresolvedPath)) -NoTypeInformation -Encoding UTF8
[ordered]@{
    requestedOrdinals = $requested.Count
    previouslyResolved = @($requested.Keys | Where-Object { $alreadyResolved.ContainsKey($_) }).Count
    generatedReplacementFields = $replacements.Count
    unresolvedQuoteCandidates = $unresolved.Count
    minimumSimilarity = $MinimumSimilarity
    status = if ($unresolved.Count -eq 0) { 'PASS' } else { 'REVIEW' }
} | ConvertTo-Json
