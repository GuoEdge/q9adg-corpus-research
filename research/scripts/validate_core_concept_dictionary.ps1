param(
    [string]$CorpusPath = (Join-Path $PSScriptRoot '..\..\sooon-q9adg-articles.jsonl'),
    [string]$DictionaryPath = (Join-Path $PSScriptRoot '..\data\core_concept_dictionary.csv'),
    [string]$StatsPath = (Join-Path $PSScriptRoot '..\data\core_concept_dictionary.stats.json')
)

$ErrorActionPreference = 'Stop'

$articles = @{}
foreach ($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($CorpusPath))) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $article = $line | ConvertFrom-Json
    $articles[$article.id] = $article
}

$rows = @(Import-Csv -LiteralPath ([IO.Path]::GetFullPath($DictionaryPath)))
$duplicateTerms = @($rows | Group-Object term | Where-Object Count -gt 1 | ForEach-Object Name)
$missingIds = [Collections.Generic.List[string]]::new()
$titleMismatches = [Collections.Generic.List[string]]::new()
$quoteMismatches = [Collections.Generic.List[string]]::new()
$missingFields = [Collections.Generic.List[string]]::new()

$requiredFields = @(
    'term', 'author_usage', 'adjacent_concepts', 'boundary_or_opposite', 'domains',
    'conditions_exceptions', 'representative_id', 'representative_title', 'source_quote',
    'chronology', 'evidence_type'
)

foreach ($row in $rows) {
    foreach ($field in $requiredFields) {
        if ([string]::IsNullOrWhiteSpace([string]$row.$field)) {
            [void]$missingFields.Add("$($row.term):$field")
        }
    }

    if (-not $articles.ContainsKey($row.representative_id)) {
        [void]$missingIds.Add($row.term)
        continue
    }

    $article = $articles[$row.representative_id]
    if ($article.title -ne $row.representative_title) {
        [void]$titleMismatches.Add($row.term)
    }

    $normalizedText = ([string]$article.text -replace '\s+', ' ')
    $normalizedQuote = ([string]$row.source_quote -replace '\s+', ' ')
    if (-not $normalizedText.Contains($normalizedQuote)) {
        [void]$quoteMismatches.Add($row.term)
    }
}

$summary = [ordered]@{
    corpusArticleCount = $articles.Count
    dictionaryRowCount = $rows.Count
    uniqueTermCount = @($rows.term | Sort-Object -Unique).Count
    duplicateTerms = @($duplicateTerms)
    missingFields = @($missingFields)
    missingIds = @($missingIds)
    titleMismatches = @($titleMismatches)
    quoteMismatches = @($quoteMismatches)
    status = if (
        $articles.Count -eq 4050 -and
        $rows.Count -eq 30 -and
        $duplicateTerms.Count -eq 0 -and
        $missingFields.Count -eq 0 -and
        $missingIds.Count -eq 0 -and
        $titleMismatches.Count -eq 0 -and
        $quoteMismatches.Count -eq 0
    ) { 'PASS' } else { 'REVIEW' }
}

$summary | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $StatsPath -Encoding UTF8
$summary | ConvertTo-Json -Depth 5
