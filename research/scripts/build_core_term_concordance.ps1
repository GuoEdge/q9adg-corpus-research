param(
    [string]$CorpusPath = (Join-Path $PSScriptRoot '..\..\sooon-q9adg-articles.jsonl'),
    [string]$OutputDir = (Join-Path $PSScriptRoot '..\data')
)

$ErrorActionPreference = 'Stop'

$terms = @(
    '事实', '证据', '定义', '能力', '学习', '教育',
    '选择', '自由', '责任', '义务', '后果', '成本', '风险', '资源', '总账',
    '信用', '信任', '承诺', '爱', '净输出', '不掠夺',
    '劳动', '产出', '财富', '社会资本',
    '权利', '权力', '授权', '服从', '反抗',
    '技术', '自然法', '伦理', '道德'
)

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
$corpusFullPath = [IO.Path]::GetFullPath($CorpusPath)
$rows = [Collections.Generic.List[object]]::new()
$articleCount = 0
$yearArticleCounts = @{}
$groupArticleCounts = @{}

foreach ($line in [IO.File]::ReadLines($corpusFullPath)) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $articleCount++
    $article = $line | ConvertFrom-Json
    $publishedDate = ([DateTimeOffset]::FromUnixTimeMilliseconds([int64]$article.publishedAt).ToOffset([TimeSpan]::FromHours(8))).ToString('yyyy-MM-dd')
    $year = $publishedDate.Substring(0, 4)
    if (-not $yearArticleCounts.ContainsKey($year)) { $yearArticleCounts[$year] = 0 }
    $yearArticleCounts[$year]++
    $period = if ($year -eq '2017') { '2017' } elseif ($year -le '2020') { '2018-2020' } elseif ($year -le '2023') { '2021-2023' } else { '2024-2026' }
    $platform = if ($article.url -match 'zhihu\.com') { 'Zhihu' } elseif ($article.url -match '(ifdian\.net|afdian\.com)') { 'Afdian' } else { 'Other' }
    $groupKey = "$period`t$platform"
    if (-not $groupArticleCounts.ContainsKey($groupKey)) { $groupArticleCounts[$groupKey] = 0 }
    $groupArticleCounts[$groupKey]++
    $paragraphs = @($article.text -split '\r?\n' | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })

    foreach ($term in $terms) {
        $pattern = [regex]::Escape($term)
        $matchedParagraphs = [Collections.Generic.List[string]]::new()
        $occurrenceCount = 0

        for ($i = 0; $i -lt $paragraphs.Count; $i++) {
            $matches = [regex]::Matches($paragraphs[$i], $pattern)
            if ($matches.Count -eq 0) { continue }
            $occurrenceCount += $matches.Count
            [void]$matchedParagraphs.Add(('P{0}: {1}' -f ($i + 1), $paragraphs[$i].Trim()))
        }

        if ($occurrenceCount -eq 0) { continue }
        [void]$rows.Add([pscustomobject]@{
            ordinal = $articleCount
            id = $article.id
            title = $article.title
            date = $publishedDate
            url = $article.url
            period = $period
            platform = $platform
            term = $term
            occurrenceCount = $occurrenceCount
            paragraphCount = $matchedParagraphs.Count
            locatedParagraphs = $matchedParagraphs -join "`n"
        })
    }
}

$concordancePath = Join-Path $OutputDir 'core_term_concordance.csv'
$rows |
    Sort-Object ordinal, term |
    Export-Csv -LiteralPath $concordancePath -NoTypeInformation -Encoding UTF8

$termStats = foreach ($term in $terms) {
    $termRows = @($rows | Where-Object term -eq $term)
    [pscustomobject]@{
        term = $term
        articleCount = $termRows.Count
        articleRate = if ($articleCount) { [math]::Round($termRows.Count / $articleCount, 6) } else { 0 }
        occurrenceCount = [int](($termRows | Measure-Object occurrenceCount -Sum).Sum)
    }
}
$termStatsPath = Join-Path $OutputDir 'core_term_counts.csv'
$termStats | Export-Csv -LiteralPath $termStatsPath -NoTypeInformation -Encoding UTF8

$yearStats = foreach ($year in @($yearArticleCounts.Keys | Sort-Object)) {
    foreach ($term in $terms) {
        $termRows = @($rows | Where-Object { $_.date.StartsWith($year) -and $_.term -eq $term })
        [pscustomobject]@{
            year = $year
            yearArticleCount = $yearArticleCounts[$year]
            term = $term
            articleCount = $termRows.Count
            articleRate = [math]::Round($termRows.Count / $yearArticleCounts[$year], 6)
            occurrenceCount = [int](($termRows | Measure-Object occurrenceCount -Sum).Sum)
        }
    }
}
$yearStatsPath = Join-Path $OutputDir 'core_term_year_counts.csv'
$yearStats | Export-Csv -LiteralPath $yearStatsPath -NoTypeInformation -Encoding UTF8

$groupStats = foreach ($groupKey in @($groupArticleCounts.Keys | Sort-Object)) {
    $parts = $groupKey -split "`t", 2
    $period = $parts[0]
    $platform = $parts[1]
    foreach ($term in $terms) {
        $termRows = @($rows | Where-Object { $_.period -eq $period -and $_.platform -eq $platform -and $_.term -eq $term })
        [pscustomobject]@{
            period = $period
            platform = $platform
            groupArticleCount = $groupArticleCounts[$groupKey]
            term = $term
            articleCount = $termRows.Count
            articleRate = [math]::Round($termRows.Count / $groupArticleCounts[$groupKey], 6)
            occurrenceCount = [int](($termRows | Measure-Object occurrenceCount -Sum).Sum)
        }
    }
}
$groupStatsPath = Join-Path $OutputDir 'core_term_period_platform_counts.csv'
$groupStats | Export-Csv -LiteralPath $groupStatsPath -NoTypeInformation -Encoding UTF8

$summary = [ordered]@{
    corpusPath = $corpusFullPath
    articleCount = $articleCount
    termCount = $terms.Count
    articleTermRowCount = $rows.Count
    zeroHitTerms = @($termStats | Where-Object articleCount -eq 0 | ForEach-Object term)
    concordancePath = [IO.Path]::GetFullPath($concordancePath)
    yearStatsPath = [IO.Path]::GetFullPath($yearStatsPath)
    periodPlatformStatsPath = [IO.Path]::GetFullPath($groupStatsPath)
    periodPlatformGroupCount = $groupArticleCounts.Count
    status = if ($articleCount -eq 4050 -and @($termStats | Where-Object articleCount -eq 0).Count -eq 0) { 'PASS' } else { 'REVIEW' }
}
$summaryPath = Join-Path $OutputDir 'core_term_concordance.stats.json'
$summary | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $summaryPath -Encoding UTF8
$summary | ConvertTo-Json -Depth 4
