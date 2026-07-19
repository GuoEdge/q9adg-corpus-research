param(
    [string]$CorpusPath = (Join-Path $PSScriptRoot '..\..\sooon-q9adg-articles.jsonl'),
    [string]$PaperDir = (Join-Path $PSScriptRoot '..\papers'),
    [string]$OutputPath = (Join-Path $PSScriptRoot '..\data\paper_citation_metadata_audit.csv'),
    [switch]$FixDates
)

$ErrorActionPreference = 'Stop'
$uuid = '[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}'
$pattern = '《(?<title>[^》\r\n]+)》(?:(?!《)[^\r\n]){0,800}?（(?<date>\d{4}-\d{2}-\d{2})，(?:ID\s+)?`(?<id>' + $uuid + ')`，\[原文\]\((?<url>[^)\r\n]+)\)）'

$rawById = @{}
foreach ($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($CorpusPath))) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $row = $line | ConvertFrom-Json
    $rawById[([string]$row.id).ToLowerInvariant()] = $row
}

$papers = @(Get-ChildItem -LiteralPath $PaperDir -Filter '*.md' -File | Sort-Object Name)
if ($FixDates) {
    foreach ($paper in $papers) {
        $text = [IO.File]::ReadAllText($paper.FullName)
        $newText = [regex]::Replace($text, $pattern, {
            param($match)
            $id = $match.Groups['id'].Value.ToLowerInvariant()
            if (-not $rawById.ContainsKey($id)) { return $match.Value }
            $raw = $rawById[$id]
            $date = [DateTimeOffset]::FromUnixTimeMilliseconds([int64]$raw.publishedAt).ToOffset([TimeSpan]::FromHours(8)).ToString('yyyy-MM-dd')
            $relativeStart = $match.Groups['date'].Index - $match.Index
            return $match.Value.Substring(0,$relativeStart) + $date + $match.Value.Substring($relativeStart + $match.Groups['date'].Length)
        })
        if ($newText -ne $text) {
            [IO.File]::WriteAllText($paper.FullName,$newText,[Text.UTF8Encoding]::new($false))
        }
    }
}

$rows = [Collections.Generic.List[object]]::new()
foreach ($paper in $papers) {
    $text = [IO.File]::ReadAllText($paper.FullName)
    foreach ($match in [regex]::Matches($text,$pattern)) {
        $id = $match.Groups['id'].Value.ToLowerInvariant()
        $exists = $rawById.ContainsKey($id)
        $raw = if ($exists) { $rawById[$id] } else { $null }
        $actualDate = if ($exists) {
            [DateTimeOffset]::FromUnixTimeMilliseconds([int64]$raw.publishedAt).ToOffset([TimeSpan]::FromHours(8)).ToString('yyyy-MM-dd')
        } else { '' }
        $actualTitle = if ($exists) { [string]$raw.title } else { '' }
        $actualUrl = if ($exists) { [string]$raw.url } else { '' }
        $citedUrlCanonical = $match.Groups['url'].Value.TrimEnd(')')
        $actualUrlCanonical = $actualUrl.TrimEnd(')')
        [void]$rows.Add([pscustomobject][ordered]@{
            paper = $paper.Name
            id = $id
            citedTitle = $match.Groups['title'].Value
            actualTitle = $actualTitle
            citedDate = $match.Groups['date'].Value
            actualDate = $actualDate
            citedUrl = $match.Groups['url'].Value
            actualUrl = $actualUrl
            idExists = $exists
            titleMatches = $exists -and $match.Groups['title'].Value.Equals($actualTitle,[StringComparison]::Ordinal)
            dateMatches = $exists -and $match.Groups['date'].Value.Equals($actualDate,[StringComparison]::Ordinal)
            urlMatches = $exists -and $citedUrlCanonical.Equals($actualUrlCanonical,[StringComparison]::Ordinal)
        })
    }
}

New-Item -ItemType Directory -Path (Split-Path -Parent ([IO.Path]::GetFullPath($OutputPath))) -Force | Out-Null
$rows | Export-Csv -LiteralPath $OutputPath -NoTypeInformation -Encoding utf8BOM
$failures = @($rows | Where-Object { -not $_.idExists -or -not $_.titleMatches -or -not $_.dateMatches -or -not $_.urlMatches })
$stats = [ordered]@{
    generatedAt = (Get-Date).ToString('o')
    paperCount = $papers.Count
    parsedCitationCount = $rows.Count
    missingIdCount = @($rows | Where-Object { -not $_.idExists }).Count
    titleMismatchCount = @($rows | Where-Object { $_.idExists -and -not $_.titleMatches }).Count
    dateMismatchCount = @($rows | Where-Object { $_.idExists -and -not $_.dateMatches }).Count
    urlMismatchCount = @($rows | Where-Object { $_.idExists -and -not $_.urlMatches }).Count
    failureCount = $failures.Count
    fixedDates = [bool]$FixDates
    status = if ($papers.Count -eq 34 -and $failures.Count -eq 0) { 'PASS' } else { 'REVIEW' }
}
$stats | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath ([IO.Path]::ChangeExtension([IO.Path]::GetFullPath($OutputPath), '.stats.json')) -Encoding utf8
$stats | ConvertTo-Json -Depth 4
