param(
    [string]$IndexPath = (Join-Path $PSScriptRoot '..\data\corpus_index.csv'),
    [string]$PaperDir = (Join-Path $PSScriptRoot '..\papers'),
    [string]$OutputPath = (Join-Path $PSScriptRoot '..\data\paper_named_source_coverage_audit.csv'),
    [string]$StatsPath = (Join-Path $PSScriptRoot '..\data\paper_named_source_coverage_audit.stats.json')
)

$ErrorActionPreference = 'Stop'
$byTitle = @{}
foreach ($group in Import-Csv -LiteralPath $IndexPath | Group-Object title) {
    $byTitle[$group.Name] = @($group.Group)
}

$audit = [Collections.Generic.List[object]]::new()
$ambiguousCount = 0
$recognizedCount = 0
$papers = @(Get-ChildItem -LiteralPath $PaperDir -Filter '*.md' -File | Sort-Object Name)
foreach ($paper in $papers) {
    $text = [IO.File]::ReadAllText($paper.FullName)
    $titles = @(
        [regex]::Matches($text,'《(?<title>[^》]+)》') |
            ForEach-Object { $_.Groups['title'].Value } |
            Sort-Object -Unique
    )
    foreach ($title in $titles) {
        $matches = @($byTitle[$title])
        if ($matches.Count -gt 1) { $ambiguousCount++; continue }
        if ($matches.Count -ne 1) { continue }
        $recognizedCount++
        $row = $matches[0]
        $url = ([string]$row.url).TrimEnd(')')
        $hasId = $text.Contains([string]$row.id,[StringComparison]::OrdinalIgnoreCase)
        $hasUrl = -not [string]::IsNullOrWhiteSpace($url) -and $text.Contains($url,[StringComparison]::Ordinal)
        [void]$audit.Add([pscustomobject][ordered]@{
            paper = $paper.Name
            title = $title
            id = [string]$row.id
            url = $url
            hasId = $hasId
            hasUrl = $hasUrl
            status = if ($hasId -or $hasUrl) { 'PASS' } else { 'MISSING_SOURCE_ENTRY' }
        })
    }
}

New-Item -ItemType Directory -Force -Path (Split-Path -Parent ([IO.Path]::GetFullPath($OutputPath))) | Out-Null
$audit | Export-Csv -LiteralPath $OutputPath -NoTypeInformation -Encoding utf8BOM
$missing = @($audit | Where-Object status -ne 'PASS')
$stats = [ordered]@{
    paperCount = $papers.Count
    recognizedUniqueTitleCitations = $recognizedCount
    ambiguousTitleMentions = $ambiguousCount
    missingSourceEntries = $missing.Count
    status = if ($papers.Count -eq 34 -and $ambiguousCount -eq 0 -and $missing.Count -eq 0) { 'PASS' } else { 'REVIEW' }
}
$stats | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $StatsPath -Encoding utf8
$stats | ConvertTo-Json -Depth 4
