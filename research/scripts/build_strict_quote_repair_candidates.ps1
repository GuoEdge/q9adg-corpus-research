param(
    [string]$CorpusPath = (Join-Path $PSScriptRoot '..\..\sooon-q9adg-articles.jsonl'),
    [string]$EvidencePath = (Join-Path $PSScriptRoot '..\data\author_view_evidence_clean.jsonl'),
    [string]$CandidatePath = (Join-Path $PSScriptRoot '..\review\strict-quote-auto-candidates.csv'),
    [string]$ReplacementPath = (Join-Path $PSScriptRoot '..\review\strict-quote-auto-replacement-candidates.csv'),
    [string]$UnresolvedPath = (Join-Path $PSScriptRoot '..\review\strict-quote-unresolved.csv'),
    [double]$MinimumRecall = 0.90,
    [double]$MinimumScore = 0.82,
    [double]$MinimumMargin = 0.05,
    [double]$MaximumLengthRatio = 2.5,
    [switch]$ForceReviewAll
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
    for ($i=0; $i -le $normalized.Length-4; $i++) {
        [void]$grams.Add($normalized.Substring($i,4))
    }
    return $grams
}

function Get-MatchMetrics([string]$Needle,[string]$Candidate) {
    $needleGrams = Get-Grams $Needle
    $candidateGrams = Get-Grams $Candidate
    if ($needleGrams.Count -eq 0 -or $candidateGrams.Count -eq 0) {
        return [pscustomobject]@{ recall=0.0; precision=0.0; score=0.0 }
    }
    $hits = 0
    foreach ($gram in $needleGrams) {
        if ($candidateGrams.Contains($gram)) { $hits++ }
    }
    $recall = [double]$hits/[double]$needleGrams.Count
    $precision = [double]$hits/[double]$candidateGrams.Count
    $score = 0.7*$recall + 0.3*$precision
    return [pscustomobject]@{
        recall = [Math]::Round($recall,4)
        precision = [Math]::Round($precision,4)
        score = [Math]::Round($score,4)
    }
}

function Get-RegisteredQuotes([string]$Value) {
    if ([string]::IsNullOrWhiteSpace($Value)) { return @() }
    return @(
        [regex]::Split($Value,"`r?`n|；") |
            ForEach-Object {
                $text = $_.Trim() -replace '^>\s*','' -replace '^[-*•]\s*',''
                if ($text.StartsWith('`',[StringComparison]::Ordinal) -and
                    $text.EndsWith('`',[StringComparison]::Ordinal) -and
                    $text.Length -gt 2) {
                    $text = $text.Substring(1,$text.Length-2).Trim()
                }
                if ($text.StartsWith('“',[StringComparison]::Ordinal) -and
                    $text.EndsWith('”',[StringComparison]::Ordinal) -and
                    $text.Length -gt 2) {
                    $text = $text.Substring(1,$text.Length-2)
                }
                elseif ($text.StartsWith('"',[StringComparison]::Ordinal) -and
                        $text.EndsWith('"',[StringComparison]::Ordinal) -and
                        $text.Length -gt 2) {
                    $text = $text.Substring(1,$text.Length-2)
                }
                $text.Trim()
            } |
            Where-Object { $_.Length -ge 4 }
    )
}

function Get-RawSentences([string]$RawText) {
    $sentences = [Collections.Generic.List[string]]::new()
    foreach ($part in [regex]::Split($RawText,"`r?`n|(?<=[。！？；])")) {
        $text = $part.Trim()
        if ((Normalize $text).Length -ge 4 -and -not $sentences.Contains($text)) {
            [void]$sentences.Add($text)
        }
    }
    return @($sentences)
}

$rawById = @{}
foreach ($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($CorpusPath))) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $row = $line | ConvertFrom-Json
    $rawById[[string]$row.id] = [string]$row.text
}

$candidates = [Collections.Generic.List[object]]::new()
$replacements = [Collections.Generic.List[object]]::new()
$unresolved = [Collections.Generic.List[object]]::new()
$articleCount = 0
$nonExactArticleCount = 0
$resolvedArticleCount = 0
$exactQuoteCount = 0
$nonExactQuoteCount = 0

foreach ($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($EvidencePath))) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $row = $line | ConvertFrom-Json
    $articleCount++
    if (-not $rawById.ContainsKey([string]$row.id)) { throw "Missing corpus id $($row.id)." }
    $raw = [string]$rawById[[string]$row.id]
    $registered = @(Get-RegisteredQuotes ([string]$row.sourceQuotes))
    if ($registered.Count -eq 0) { continue }
    $sentences = @(Get-RawSentences $raw)
    $resolvedQuotes = [Collections.Generic.List[string]]::new()
    $articleHasNonExact = $false
    $articleResolved = $true

    foreach ($quote in $registered) {
        if ($raw.Contains($quote,[StringComparison]::Ordinal)) {
            $exactQuoteCount++
            if (-not $resolvedQuotes.Contains($quote)) { [void]$resolvedQuotes.Add($quote) }
            continue
        }

        $articleHasNonExact = $true
        $nonExactQuoteCount++
        $normalizedQuoteLength = (Normalize $quote).Length
        $ranked = @(
            foreach ($sentence in $sentences) {
                $normalizedSentenceLength = (Normalize $sentence).Length
                if ($normalizedQuoteLength -eq 0) { continue }
                $ratio = [double]$normalizedSentenceLength/[double]$normalizedQuoteLength
                if ($ratio -gt $MaximumLengthRatio -or $ratio -lt (1.0/$MaximumLengthRatio)) { continue }
                $metrics = Get-MatchMetrics $quote $sentence
                [pscustomobject]@{
                    text = $sentence
                    recall = [double]$metrics.recall
                    precision = [double]$metrics.precision
                    score = [double]$metrics.score
                    lengthRatio = [Math]::Round($ratio,4)
                }
            }
        )
        $ranked = @($ranked | Sort-Object @{Expression='score';Descending=$true},@{Expression='recall';Descending=$true},@{Expression='lengthRatio';Ascending=$true})
        $best = @($ranked | Select-Object -First 1)
        $second = @($ranked | Select-Object -Skip 1 -First 1)
        $bestScore = if ($best.Count) { [double]$best[0].score } else { 0.0 }
        $secondScore = if ($second.Count) { [double]$second[0].score } else { 0.0 }
        $margin = [Math]::Round($bestScore-$secondScore,4)
        $isHighConfidence = -not $ForceReviewAll -and
            $best.Count -eq 1 -and
            [double]$best[0].recall -ge $MinimumRecall -and
            $bestScore -ge $MinimumScore -and
            $margin -ge $MinimumMargin -and
            $raw.Contains([string]$best[0].text,[StringComparison]::Ordinal)
        $decision = if ($isHighConfidence) { 'AUTO_ACCEPT' } else { 'REVIEW' }
        $candidate = [pscustomobject]@{
            ordinal = [int]$row.ordinal
            id = [string]$row.id
            title = [string]$row.title
            originalCandidate = $quote
            bestRawSentence = if ($best.Count) { [string]$best[0].text } else { '' }
            recall = if ($best.Count) { [double]$best[0].recall } else { 0.0 }
            precision = if ($best.Count) { [double]$best[0].precision } else { 0.0 }
            score = $bestScore
            margin = $margin
            lengthRatio = if ($best.Count) { [double]$best[0].lengthRatio } else { 0.0 }
            decision = $decision
        }
        [void]$candidates.Add($candidate)
        if ($isHighConfidence) {
            if (-not $resolvedQuotes.Contains([string]$best[0].text)) { [void]$resolvedQuotes.Add([string]$best[0].text) }
        }
        else {
            $articleResolved = $false
            [void]$unresolved.Add($candidate)
        }
    }

    if ($articleHasNonExact) {
        $nonExactArticleCount++
        if ($articleResolved -and $resolvedQuotes.Count -gt 0) {
            $replacementText = $resolvedQuotes -join '；'
            $failed = @($resolvedQuotes | Where-Object { -not $raw.Contains($_,[StringComparison]::Ordinal) })
            if ($failed.Count -ne 0) { throw "Ordinal replacement failure at $($row.ordinal)." }
            [void]$replacements.Add([pscustomobject]@{
                ordinal = [int]$row.ordinal
                field = 'sourceQuotes'
                replacementText = $replacementText
                reason = 'Every registered quote is either already exact or uniquely mapped to a high-confidence contiguous raw sentence; all replacements pass StringComparison.Ordinal.'
            })
            $resolvedArticleCount++
        }
    }
}

$candidates | Export-Csv -LiteralPath ([IO.Path]::GetFullPath($CandidatePath)) -NoTypeInformation -Encoding UTF8
$replacements | Export-Csv -LiteralPath ([IO.Path]::GetFullPath($ReplacementPath)) -NoTypeInformation -Encoding UTF8
$unresolved | Export-Csv -LiteralPath ([IO.Path]::GetFullPath($UnresolvedPath)) -NoTypeInformation -Encoding UTF8

[ordered]@{
    articleCount = $articleCount
    exactQuoteCount = $exactQuoteCount
    nonExactQuoteCount = $nonExactQuoteCount
    nonExactArticleCount = $nonExactArticleCount
    autoResolvedArticleCount = $resolvedArticleCount
    unresolvedArticleCount = @($unresolved.ordinal | Sort-Object -Unique).Count
    unresolvedQuoteCount = $unresolved.Count
    thresholds = [ordered]@{
        minimumRecall = $MinimumRecall
        minimumScore = $MinimumScore
        minimumMargin = $MinimumMargin
        maximumLengthRatio = $MaximumLengthRatio
    }
    forceReviewAll = [bool]$ForceReviewAll
    status = if ($articleCount -eq 4050 -and $replacements.Count -eq $resolvedArticleCount) { 'PASS' } else { 'REVIEW' }
} | ConvertTo-Json -Depth 4
