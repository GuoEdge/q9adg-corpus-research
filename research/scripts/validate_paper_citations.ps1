param(
    [string]$CorpusPath = (Join-Path $PSScriptRoot '..\..\sooon-q9adg-articles.jsonl'),
    [string]$PaperDir = (Join-Path $PSScriptRoot '..\papers'),
    [string]$LedgerPath = (Join-Path $PSScriptRoot '..\data\paper_citation_ledger.csv'),
    [string]$StatsPath = (Join-Path $PSScriptRoot '..\data\paper_citation_audit.stats.json')
)

$ErrorActionPreference = 'Stop'
$uuidPattern = '(?i)\b[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\b'
$rawRows = [Collections.Generic.List[object]]::new()
$rawById = @{}
foreach ($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($CorpusPath))) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $row = $line | ConvertFrom-Json
    $id = ([string]$row.id).ToLowerInvariant()
    $rawById[$id] = $row
    [void]$rawRows.Add($row)
}

$papers = @(Get-ChildItem -LiteralPath $PaperDir -File -Filter '*.md' | Sort-Object Name)
$records = [Collections.Generic.List[object]]::new()
foreach ($paper in $papers) {
    $text = [IO.File]::ReadAllText($paper.FullName)
    $uuidIds = @(
        [regex]::Matches($text,$uuidPattern) |
            ForEach-Object { $_.Value.ToLowerInvariant() } |
            Sort-Object -Unique
    )
    $seen = [Collections.Generic.HashSet[string]]::new()

    foreach ($id in $uuidIds) {
        $found = $rawById.ContainsKey($id)
        $row = if ($found) { $rawById[$id] } else { $null }
        [void]$records.Add([pscustomobject][ordered]@{
            paper = $paper.Name
            id = $id
            title = if ($found) { [string]$row.title } else { '' }
            url = if ($found) { [string]$row.url } else { '' }
            citedByUuid = $true
            citedByUrl = $found -and (
                $text.Contains([string]$row.url,[StringComparison]::Ordinal) -or
                $text.Contains(([string]$row.url).TrimEnd(')'),[StringComparison]::Ordinal)
            )
            found = $found
        })
        [void]$seen.Add($id)
    }

    foreach ($row in $rawRows) {
        $id = ([string]$row.id).ToLowerInvariant()
        if ($seen.Contains($id)) { continue }
        $url = [string]$row.url
        if ([string]::IsNullOrWhiteSpace($url)) { continue }
        $urlCanonical = $url.TrimEnd(')')
        if (-not $text.Contains($url,[StringComparison]::Ordinal) -and -not $text.Contains($urlCanonical,[StringComparison]::Ordinal)) { continue }
        [void]$records.Add([pscustomobject][ordered]@{
            paper = $paper.Name
            id = $id
            title = [string]$row.title
            url = $url
            citedByUuid = $false
            citedByUrl = $true
            found = $true
        })
        [void]$seen.Add($id)
    }
}

New-Item -ItemType Directory -Path (Split-Path -Parent ([IO.Path]::GetFullPath($LedgerPath))) -Force | Out-Null
$records | Export-Csv -LiteralPath $LedgerPath -NoTypeInformation -Encoding utf8BOM
$missing = @($records | Where-Object { -not $_.found })
$stats = [ordered]@{
    generatedAt = (Get-Date).ToString('o')
    paperCount = $papers.Count
    citationOccurrences = $records.Count
    uniqueCitedIds = @($records.id | Where-Object { $_ } | Sort-Object -Unique).Count
    uuidCitedOccurrences = @($records | Where-Object citedByUuid).Count
    urlOnlyCitationOccurrences = @($records | Where-Object { -not $_.citedByUuid -and $_.citedByUrl }).Count
    missingCitedIds = $missing.Count
    status = if (
        $papers.Count -eq 34 -and
        $missing.Count -eq 0 -and
        @($records | Where-Object { -not $_.citedByUuid -and $_.citedByUrl }).Count -eq 0
    ) { 'PASS' } else { 'REVIEW' }
}
$stats | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $StatsPath -Encoding utf8
$stats | ConvertTo-Json -Depth 4
