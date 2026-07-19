param(
    [Parameter(Mandatory=$true)][string]$InputPath,
    [Parameter(Mandatory=$true)][string]$OutputPath,
    [int]$ExpectedArticleCount = 100,
    [string]$CorpusPath = (Join-Path $PSScriptRoot '..\..\sooon-q9adg-articles.jsonl'),
    [string]$EvidencePath = (Join-Path $PSScriptRoot '..\data\author_view_evidence_clean.jsonl')
)

$ErrorActionPreference = 'Stop'

function Get-RegisteredQuotes([string]$Value) {
    if ([string]::IsNullOrWhiteSpace($Value)) { return @() }
    return @(
        [regex]::Split($Value,"`r?`n|；") |
            ForEach-Object {
                $text = $_.Trim() -replace '^>\s*','' -replace '^[-*•]\s*',''
                if ($text.StartsWith('“',[StringComparison]::Ordinal) -and $text.EndsWith('”',[StringComparison]::Ordinal) -and $text.Length -gt 2) {
                    $text = $text.Substring(1,$text.Length-2)
                }
                $text.Trim()
            } |
            Where-Object { $_.Length -ge 4 }
    )
}

$inputRows = @(Import-Csv -LiteralPath $InputPath)
if ($inputRows.Count -ne $ExpectedArticleCount) {
    throw "Expected $ExpectedArticleCount article replacements, found $($inputRows.Count)."
}
$uniqueKeys = @($inputRows | ForEach-Object { '{0}:{1}' -f [int]$_.ordinal,[string]$_.field } | Sort-Object -Unique)
if ($uniqueKeys.Count -ne $inputRows.Count) { throw 'Duplicate ordinal:field keys in batch replacement file.' }

$rawById = @{}
foreach ($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($CorpusPath))) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $row = $line | ConvertFrom-Json
    $rawById[[string]$row.id] = [string]$row.text
}
$evidenceByOrdinal = @{}
foreach ($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($EvidencePath))) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $row = $line | ConvertFrom-Json
    $evidenceByOrdinal[[int]$row.ordinal] = $row
}

$mergedExactFragments = 0
$promoted = foreach ($row in $inputRows) {
    $ordinal = [int]$row.ordinal
    if ($row.field -ne 'sourceQuotes') { throw "Unsupported field $($row.field)." }
    if (-not $evidenceByOrdinal.ContainsKey($ordinal)) { throw "Missing evidence ordinal $ordinal." }
    $evidence = $evidenceByOrdinal[$ordinal]
    $id = [string]$evidence.id
    if (-not $rawById.ContainsKey($id)) { throw "Missing raw ID $id." }
    $body = $rawById[$id]
    $replacementText = [string]$row.replacementText

    foreach ($fragment in @(Get-RegisteredQuotes $replacementText)) {
        if (-not $body.Contains($fragment,[StringComparison]::Ordinal)) {
            throw "Batch replacement contains non-Ordinal fragment at ordinal ${ordinal}: $fragment"
        }
    }

    $current = [string]$evidence.sourceQuotes
    foreach ($fragment in @(Get-RegisteredQuotes $current)) {
        if (-not $body.Contains($fragment,[StringComparison]::Ordinal)) { continue }
        if ($replacementText.Contains($fragment,[StringComparison]::Ordinal)) { continue }
        $replacementText = if ([string]::IsNullOrWhiteSpace($replacementText)) { $fragment } else { $replacementText.TrimEnd('；') + '；' + $fragment }
        $mergedExactFragments++
    }
    foreach ($fragment in @(Get-RegisteredQuotes $replacementText)) {
        if (-not $body.Contains($fragment,[StringComparison]::Ordinal)) {
            throw "Merged replacement contains non-Ordinal fragment at ordinal ${ordinal}: $fragment"
        }
    }
    [pscustomobject]@{
        ordinal = $ordinal
        id = $id
        field = 'sourceQuotes'
        originalText = $current
        replacementText = $replacementText
        reviewReason = [string]$row.reason
    }
}

New-Item -ItemType Directory -Force -Path (Split-Path -Parent ([IO.Path]::GetFullPath($OutputPath))) | Out-Null
$promoted | Export-Csv -LiteralPath $OutputPath -NoTypeInformation -Encoding UTF8
[ordered]@{
    inputArticleCount = $inputRows.Count
    promotedArticleCount = $promoted.Count
    uniqueKeys = $uniqueKeys.Count
    currentExactFragmentsMerged = $mergedExactFragments
    comparison = 'StringComparison.Ordinal'
    failures = 0
    status = 'PASS'
} | ConvertTo-Json
