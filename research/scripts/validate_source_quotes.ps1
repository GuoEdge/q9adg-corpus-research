param(
    [string]$CorpusPath = (Join-Path $PSScriptRoot '..\..\sooon-q9adg-articles.jsonl'),
    [string]$EvidencePath = (Join-Path $PSScriptRoot '..\data\author_view_evidence_clean.jsonl'),
    [string]$OutputDir = (Join-Path $PSScriptRoot '..\data')
)

$ErrorActionPreference = 'Stop'

function Get-RegisteredQuotes([string]$Value) {
    if ([string]::IsNullOrWhiteSpace($Value)) { return @() }

    return @(
        [regex]::Split($Value, "`r?`n|；") |
            ForEach-Object {
                $text = $_.Trim() -replace '^>\s*', '' -replace '^[-*•]\s*', ''
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

$raw = @{}
foreach ($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($CorpusPath))) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $row = $line | ConvertFrom-Json
    $raw[[string]$row.id] = [string]$row.text
}

$checked = 0
$exact = 0
$missing = 0
$failures = [Collections.Generic.List[object]]::new()
$all = [Collections.Generic.List[object]]::new()

foreach ($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($EvidencePath))) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $row = $line | ConvertFrom-Json
    if (-not $raw.ContainsKey([string]$row.id)) { throw "Corpus row missing for id $($row.id)." }

    $body = [string]$raw[[string]$row.id]
    foreach ($quote in @(Get-RegisteredQuotes ([string]$row.sourceQuotes))) {
        $checked++
        $isExact = $body.Contains($quote,[StringComparison]::Ordinal)
        $matchType = if ($isExact) { 'exact' } else { 'missing' }
        if ($isExact) {
            $exact++
        }
        else {
            $missing++
            $failures.Add([pscustomobject]@{
                ordinal = [int]$row.ordinal
                id = [string]$row.id
                title = [string]$row.title
                quote = $quote
            })
        }
        $all.Add([pscustomobject]@{
            ordinal = [int]$row.ordinal
            id = [string]$row.id
            title = [string]$row.title
            quote = $quote
            matchType = $matchType
        })
    }
}

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
$failures | Export-Csv -LiteralPath (Join-Path $OutputDir 'source_quote_validation_failures.csv') -NoTypeInformation -Encoding UTF8
$all | Export-Csv -LiteralPath (Join-Path $OutputDir 'source_quote_validation_all.csv') -NoTypeInformation -Encoding UTF8

$stats = [ordered]@{
    evidencePath = [IO.Path]::GetFullPath($EvidencePath)
    comparison = 'StringComparison.Ordinal'
    checkedQuotes = $checked
    exactQuotes = $exact
    partialQuotes = 0
    missingQuotes = $missing
    exactRate = if ($checked) { [math]::Round($exact/$checked,6) } else { 0 }
    locatedRate = if ($checked) { [math]::Round($exact/$checked,6) } else { 0 }
    status = if ($missing -eq 0) { 'PASS' } else { 'REVIEW' }
}
$stats | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $OutputDir 'source_quote_validation.stats.json') -Encoding UTF8
$stats | ConvertTo-Json
