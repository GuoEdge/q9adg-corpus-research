param(
    [string]$CorpusPath = (Join-Path $PSScriptRoot '..\..\sooon-q9adg-articles.jsonl'),
    [string]$PaperPath = (Join-Path $PSScriptRoot '..\papers\03_伦理作为社会技术_权力互惠与社会资本.md'),
    [string]$OutputPath = (Join-Path $PSScriptRoot '..\review\paper-reference-integrity.csv')
)

$ErrorActionPreference = 'Stop'

$rawById = @{}
foreach ($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($CorpusPath))) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $row = $line | ConvertFrom-Json
    $rawById[[string]$row.id] = $row
}

$paperText = [IO.File]::ReadAllText([IO.Path]::GetFullPath($PaperPath))
$parts = [regex]::Split($paperText, '(?m)^## 内部语料参考文献\s*$')
if ($parts.Count -ne 2) { throw 'Paper must contain exactly one internal-reference heading.' }
$body = $parts[0]
$bibliography = $parts[1]

$referencePattern = '(?m)^\[(?<number>\d+)\]\s+岐伯：《(?<title>[^》]+)》，id：`(?<id>[0-9a-fA-F-]{36})`，URL：(?<url>\S+)\s*$'
$referenceMatches = [regex]::Matches($bibliography,$referencePattern)
if ($referenceMatches.Count -eq 0) { throw 'No structured references found.' }

$citationNumbers = @(
    [regex]::Matches($body,'\[(?<number>\d+)\]') |
        ForEach-Object { [int]$_.Groups['number'].Value }
)
$referenceNumbers = @($referenceMatches | ForEach-Object { [int]$_.Groups['number'].Value })

$results = [Collections.Generic.List[object]]::new()
foreach ($match in $referenceMatches) {
    $number = [int]$match.Groups['number'].Value
    $id = $match.Groups['id'].Value.ToLowerInvariant()
    $title = $match.Groups['title'].Value
    $url = $match.Groups['url'].Value
    $found = $rawById.ContainsKey($id)
    $raw = if ($found) { $rawById[$id] } else { $null }
    $titleExact = $found -and ([string]$raw.title).Equals($title,[StringComparison]::Ordinal)
    $urlExact = $found -and ([string]$raw.url).Equals($url,[StringComparison]::Ordinal)
    $inTextCount = @($citationNumbers | Where-Object { $_ -eq $number }).Count
    $results.Add([pscustomobject]@{
        paper = [IO.Path]::GetFileName($PaperPath)
        referenceNumber = $number
        id = $id
        title = $title
        foundInCorpus = $found
        titleExact = $titleExact
        urlExact = $urlExact
        inTextCitationCount = $inTextCount
        status = if ($found -and $titleExact -and $urlExact -and $inTextCount -gt 0) { 'PASS' } else { 'REVIEW' }
    })
}

$duplicateReferenceNumbers = @($referenceNumbers | Group-Object | Where-Object Count -gt 1).Count
$missingBibliographyNumbers = @($citationNumbers | Sort-Object -Unique | Where-Object { $_ -notin $referenceNumbers }).Count
$uncitedBibliographyEntries = @($results | Where-Object inTextCitationCount -eq 0).Count
$metadataFailures = @($results | Where-Object { -not $_.foundInCorpus -or -not $_.titleExact -or -not $_.urlExact }).Count

$outputDirectory = Split-Path -Parent ([IO.Path]::GetFullPath($OutputPath))
New-Item -ItemType Directory -Force -Path $outputDirectory | Out-Null
$results | Export-Csv -LiteralPath $OutputPath -NoTypeInformation -Encoding UTF8

$stats = [ordered]@{
    paper = [IO.Path]::GetFullPath($PaperPath)
    bibliographyEntries = $referenceMatches.Count
    inTextCitationOccurrences = $citationNumbers.Count
    duplicateReferenceNumbers = $duplicateReferenceNumbers
    missingBibliographyNumbers = $missingBibliographyNumbers
    uncitedBibliographyEntries = $uncitedBibliographyEntries
    metadataFailures = $metadataFailures
    status = if ($duplicateReferenceNumbers -eq 0 -and $missingBibliographyNumbers -eq 0 -and $uncitedBibliographyEntries -eq 0 -and $metadataFailures -eq 0) { 'PASS' } else { 'REVIEW' }
}
$stats | ConvertTo-Json

