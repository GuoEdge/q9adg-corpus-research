param(
    [string]$CorpusPath = (Join-Path $PSScriptRoot '..\..\sooon-q9adg-articles.jsonl'),
    [string]$TermPath = (Join-Path $PSScriptRoot '..\data\core_term_counts.csv'),
    [string]$OutputPath = (Join-Path $PSScriptRoot '..\data\core_term_quote_role_sensitivity.csv'),
    [string]$StatsPath = (Join-Path $PSScriptRoot '..\data\core_term_quote_role_sensitivity.stats.json')
)

$ErrorActionPreference = 'Stop'
$terms = @(Import-Csv -LiteralPath $TermPath | Select-Object -ExpandProperty term)
if ($terms.Count -ne 34) { throw "Expected 34 terms, found $($terms.Count)." }

function Get-LexicalNodeText {
    param([object]$Node)
    $builder = [Text.StringBuilder]::new()
    $stack = [Collections.Generic.Stack[object]]::new()
    $stack.Push($Node)
    while ($stack.Count -gt 0) {
        $current = $stack.Pop()
        $textProperty = $current.psobject.Properties['text']
        if ($null -ne $textProperty -and $null -ne $textProperty.Value) {
            [void]$builder.Append([string]$textProperty.Value)
        }
        $childrenProperty = $current.psobject.Properties['children']
        if ($null -eq $childrenProperty -or $null -eq $childrenProperty.Value) { continue }
        $children = @($childrenProperty.Value)
        for ($i = $children.Count - 1; $i -ge 0; $i--) { $stack.Push($children[$i]) }
    }
    return $builder.ToString()
}

$groupArticleCounts = @{}
$fullArticleCounts = @{}
$authorArticleCounts = @{}
$fullOccurrenceCounts = @{}
$authorOccurrenceCounts = @{}
$articleCount = 0

foreach ($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($CorpusPath))) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $article = $line | ConvertFrom-Json
    $articleCount++
    $date = [DateTimeOffset]::FromUnixTimeMilliseconds([int64]$article.publishedAt).ToOffset([TimeSpan]::FromHours(8))
    $year = $date.Year
    $period = if ($year -eq 2017) { '2017' } elseif ($year -le 2020) { '2018-2020' } elseif ($year -le 2023) { '2021-2023' } else { '2024-2026' }
    $platform = if ([string]$article.url -match 'zhihu\.com') { 'Zhihu' } elseif ([string]$article.url -match '(ifdian\.net|afdian\.com)') { 'Afdian' } else { 'Other' }
    $group = "$period`t$platform"
    if (-not $groupArticleCounts.ContainsKey($group)) { $groupArticleCounts[$group] = 0 }
    $groupArticleCounts[$group]++

    $fullText = [string]$article.text
    $authorBuilder = [Text.StringBuilder]::new()
    if (-not [string]::IsNullOrWhiteSpace([string]$article.lexical)) {
        $lexical = [string]$article.lexical | ConvertFrom-Json
        foreach ($node in @($lexical.root.children)) {
            if ([string]$node.type -eq 'quote') { continue }
            [void]$authorBuilder.AppendLine((Get-LexicalNodeText -Node $node))
        }
    }
    $authorText = $authorBuilder.ToString()

    foreach ($term in $terms) {
        $key = "$group`t$term"
        $pattern = [regex]::Escape($term)
        $fullCount = [regex]::Matches($fullText,$pattern).Count
        $authorCount = [regex]::Matches($authorText,$pattern).Count
        if ($fullCount -gt 0) {
            if (-not $fullArticleCounts.ContainsKey($key)) { $fullArticleCounts[$key] = 0 }
            $fullArticleCounts[$key]++
        }
        if ($authorCount -gt 0) {
            if (-not $authorArticleCounts.ContainsKey($key)) { $authorArticleCounts[$key] = 0 }
            $authorArticleCounts[$key]++
        }
        if (-not $fullOccurrenceCounts.ContainsKey($key)) { $fullOccurrenceCounts[$key] = 0 }
        if (-not $authorOccurrenceCounts.ContainsKey($key)) { $authorOccurrenceCounts[$key] = 0 }
        $fullOccurrenceCounts[$key] += $fullCount
        $authorOccurrenceCounts[$key] += $authorCount
    }
}

$rows = foreach ($group in $groupArticleCounts.Keys | Sort-Object) {
    $parts = $group -split "`t",2
    foreach ($term in $terms) {
        $key = "$group`t$term"
        $fullArticles = if ($fullArticleCounts.ContainsKey($key)) { [int]$fullArticleCounts[$key] } else { 0 }
        $authorArticles = if ($authorArticleCounts.ContainsKey($key)) { [int]$authorArticleCounts[$key] } else { 0 }
        [pscustomobject][ordered]@{
            period = $parts[0]
            platform = $parts[1]
            groupArticleCount = [int]$groupArticleCounts[$group]
            term = $term
            fullTextArticleCount = $fullArticles
            authorTextArticleCount = $authorArticles
            quoteOnlyArticleCount = $fullArticles - $authorArticles
            fullTextRate = [math]::Round($fullArticles / $groupArticleCounts[$group],6)
            authorTextRate = [math]::Round($authorArticles / $groupArticleCounts[$group],6)
            rateDelta = [math]::Round(($fullArticles - $authorArticles) / $groupArticleCounts[$group],6)
            fullTextOccurrenceCount = [int]$fullOccurrenceCounts[$key]
            authorTextOccurrenceCount = [int]$authorOccurrenceCounts[$key]
        }
    }
}

New-Item -ItemType Directory -Force -Path (Split-Path -Parent ([IO.Path]::GetFullPath($OutputPath))) | Out-Null
$rows | Export-Csv -LiteralPath $OutputPath -NoTypeInformation -Encoding utf8BOM
$negativeDeltas = @($rows | Where-Object quoteOnlyArticleCount -lt 0)
$negativeOccurrenceDeltas = @($rows | Where-Object { [int]$_.authorTextOccurrenceCount -gt [int]$_.fullTextOccurrenceCount })
$maximumDeltaRow = $rows | Sort-Object rateDelta -Descending | Select-Object -First 1
$stats = [ordered]@{
    articleCount = $articleCount
    termCount = $terms.Count
    periodPlatformGroupCount = $groupArticleCounts.Count
    outputRowCount = $rows.Count
    quoteOnlyArticleTermCount = [int](($rows | Measure-Object quoteOnlyArticleCount -Sum).Sum)
    maximumRateDelta = [double](($rows | Measure-Object rateDelta -Maximum).Maximum)
    maximumRateDeltaPeriod = [string]$maximumDeltaRow.period
    maximumRateDeltaPlatform = [string]$maximumDeltaRow.platform
    maximumRateDeltaTerm = [string]$maximumDeltaRow.term
    negativeDeltaCount = $negativeDeltas.Count
    authorOccurrenceGreaterThanFullCount = $negativeOccurrenceDeltas.Count
    status = if (
        $articleCount -eq 4050 -and
        $terms.Count -eq 34 -and
        $rows.Count -eq ($groupArticleCounts.Count * $terms.Count) -and
        $negativeDeltas.Count -eq 0 -and
        $negativeOccurrenceDeltas.Count -eq 0
    ) { 'PASS' } else { 'REVIEW' }
}
$stats | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $StatsPath -Encoding utf8
$stats | ConvertTo-Json -Depth 4
