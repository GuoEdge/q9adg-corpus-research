[CmdletBinding()]
param(
    [string]$PaperPath = (Join-Path $PSScriptRoot '..\..\研究总论_内部观点重建.md'),
    [string]$CorpusPath = (Join-Path $PSScriptRoot '..\..\sooon-q9adg-articles.jsonl'),
    [string]$OutputPath = (Join-Path $PSScriptRoot '..\data\root_synthesis_audit.csv')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$text = [IO.File]::ReadAllText([IO.Path]::GetFullPath($PaperPath))
$rawById = @{}
foreach ($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($CorpusPath))) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $row = $line | ConvertFrom-Json -Depth 100
    $rawById[([string]$row.id).ToLowerInvariant()] = $row
}

$failures = [Collections.Generic.List[object]]::new()
$referencePattern = '(?m)^- \[《(?<title>[^》]+)》\]\((?<url>[^)]+)\)（ID `(?<id>[0-9a-fA-F-]{36})`）\s*$'
$referenceMatches = @([regex]::Matches($text,$referencePattern))
$cited = [Collections.Generic.List[object]]::new()
$seenIds = [Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
foreach ($match in $referenceMatches) {
    $id = $match.Groups['id'].Value.ToLowerInvariant()
    if (-not $seenIds.Add($id)) {
        [void]$failures.Add([pscustomobject]@{ type='duplicateReference'; id=$id; detail='' })
        continue
    }
    if (-not $rawById.ContainsKey($id)) {
        [void]$failures.Add([pscustomobject]@{ type='missingId'; id=$id; detail='' })
        continue
    }
    $raw = $rawById[$id]
    if ([string]$raw.title -ne $match.Groups['title'].Value) {
        [void]$failures.Add([pscustomobject]@{ type='titleMismatch'; id=$id; detail=$match.Groups['title'].Value })
    }
    if ([string]$raw.url -ne $match.Groups['url'].Value) {
        [void]$failures.Add([pscustomobject]@{ type='urlMismatch'; id=$id; detail=$match.Groups['url'].Value })
    }
    [void]$cited.Add($raw)
}

$uuidPattern = '(?i)\b[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\b'
$allUuids = @([regex]::Matches($text,$uuidPattern) | ForEach-Object { $_.Value.ToLowerInvariant() } | Sort-Object -Unique)
foreach ($id in $allUuids) {
    if (-not $rawById.ContainsKey($id)) { [void]$failures.Add([pscustomobject]@{ type='unknownUuid'; id=$id; detail='' }) }
    if (-not $seenIds.Contains($id)) { [void]$failures.Add([pscustomobject]@{ type='uuidWithoutStructuredReference'; id=$id; detail='' }) }
}

$quotePattern = '(?:\u201c(?<quote>[^\u201d\r\n]{4,})\u201d|\u2018(?<quote>[^\u2019\r\n]{4,})\u2019)'
$quotes = @([regex]::Matches($text,$quotePattern) | ForEach-Object { $_.Groups['quote'].Value } | Sort-Object -Unique)
$exactQuotes = 0
foreach ($quote in $quotes) {
    $hit = @($cited | Where-Object { ([string]$_.text).IndexOf($quote,[StringComparison]::Ordinal) -ge 0 }).Count -gt 0
    if ($hit) { $exactQuotes++ }
    else { [void]$failures.Add([pscustomobject]@{ type='nonExactDirectQuote'; id=''; detail=$quote }) }
}

$attributionPatterns = [ordered]@{
    researcherStance = '本文(?:主张|建议|认为|赞同|反对|批判)|本研究(?:主张|建议|认为)|我们认为|笔者认为|研究者认为'
    aiStance = 'AI判断|模型判断|外部框架纠正|AI(?:主张|建议|认为|赞同|反对)'
}
foreach ($name in $attributionPatterns.Keys) {
    foreach ($match in [regex]::Matches($text,$attributionPatterns[$name])) {
        [void]$failures.Add([pscustomobject]@{ type=$name; id=''; detail=$match.Value })
    }
}

@($failures) | Export-Csv -LiteralPath $OutputPath -NoTypeInformation -Encoding utf8BOM
$stats = [ordered]@{
    generatedAt = [DateTimeOffset]::Now.ToString('o')
    corpusCount = $rawById.Count
    structuredReferenceCount = $referenceMatches.Count
    uniqueReferencedIdCount = $seenIds.Count
    uuidCount = $allUuids.Count
    directQuoteCount = $quotes.Count
    exactDirectQuoteCount = $exactQuotes
    failureCount = $failures.Count
    status = if ($referenceMatches.Count -gt 0 -and $referenceMatches.Count -eq $seenIds.Count -and $allUuids.Count -eq $seenIds.Count -and $quotes.Count -eq $exactQuotes -and $failures.Count -eq 0) { 'PASS' } else { 'REVIEW' }
}
$statsPath = [IO.Path]::ChangeExtension([IO.Path]::GetFullPath($OutputPath),'.stats.json')
$stats | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $statsPath -Encoding utf8
$stats | ConvertTo-Json -Depth 5
if ($stats.status -ne 'PASS') { exit 1 }
