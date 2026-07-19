param(
    [string]$CorpusPath = (Join-Path $PSScriptRoot '..\..\sooon-q9adg-articles.jsonl'),
    [string]$OutputDir = (Join-Path $PSScriptRoot '..\data')
)

$ErrorActionPreference = 'Stop'
$OutputDir = [System.IO.Path]::GetFullPath($OutputDir)
New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null

$concepts = [ordered]@{
    ability = '能力'
    choice = '选择'
    cost = '成本'
    responsibility = '责任'
    risk = '风险'
    resource = '资源'
    interest = '利益'
    obligation = '义务'
    right = '权利'
    morality = '道德'
    respect = '尊重'
    ethics = '伦理'
    cooperation = '合作'
    control = '控制'
    status = '地位'
    power = '权力'
    wealth = '财富'
    credit = '信用'
    love = '爱'
    god = '上帝'
    natural_law = '自然法'
    fact = '事实'
    evidence = '证据'
    logic = '逻辑'
    labor = '劳动'
    market = '市场'
    state = '国家'
    law = '法律'
    history = '历史'
    technology = '技术'
    war = '战争'
    gender = '性别'
    trauma = '创伤'
}

function Get-Period([int]$Year) {
    if ($Year -eq 2017) { return '2017_seed' }
    if ($Year -le 2020) { return '2018_2020' }
    if ($Year -le 2023) { return '2021_2023' }
    return '2024_2026'
}

$yearBuckets = @{}
$periodBuckets = @{}
$domainBuckets = @{}

Get-Content -LiteralPath $CorpusPath -Encoding UTF8 | ForEach-Object {
    $item = $_ | ConvertFrom-Json
    $published = [DateTimeOffset]::FromUnixTimeMilliseconds([int64]$item.publishedAt).ToOffset([TimeSpan]::FromHours(8))
    $year = $published.Year
    $period = Get-Period $year
    $combined = '{0}`n{1}`n{2}' -f $item.title, $item.question, $item.text

    if (-not $yearBuckets.ContainsKey($year)) {
        $yearBuckets[$year] = [ordered]@{ articleCount = 0; concepts = [ordered]@{} }
        foreach ($key in $concepts.Keys) { $yearBuckets[$year].concepts[$key] = 0 }
    }
    if (-not $periodBuckets.ContainsKey($period)) {
        $periodBuckets[$period] = [ordered]@{ articleCount = 0; concepts = [ordered]@{} }
        foreach ($key in $concepts.Keys) { $periodBuckets[$period].concepts[$key] = 0 }
    }

    $yearBuckets[$year].articleCount++
    $periodBuckets[$period].articleCount++
    foreach ($key in $concepts.Keys) {
        if ($combined.Contains($concepts[$key], [StringComparison]::OrdinalIgnoreCase)) {
            $yearBuckets[$year].concepts[$key]++
            $periodBuckets[$period].concepts[$key]++
        }
    }

    $domain = try { ([uri]$item.url).Host.ToLowerInvariant() } catch { 'invalid-url' }
    $domainKey = "$year|$domain"
    if (-not $domainBuckets.ContainsKey($domainKey)) { $domainBuckets[$domainKey] = 0 }
    $domainBuckets[$domainKey]++
}

$yearRows = foreach ($year in ($yearBuckets.Keys | Sort-Object)) {
    $bucket = $yearBuckets[$year]
    foreach ($key in $concepts.Keys) {
        [pscustomobject][ordered]@{
            year = $year
            completeYear = ($year -ge 2018 -and $year -le 2025)
            articleCount = $bucket.articleCount
            concept = $key
            literal = $concepts[$key]
            documentCount = $bucket.concepts[$key]
            documentsPer100 = [Math]::Round(100 * $bucket.concepts[$key] / $bucket.articleCount, 2)
        }
    }
}

$periodRows = foreach ($period in @('2017_seed', '2018_2020', '2021_2023', '2024_2026')) {
    if (-not $periodBuckets.ContainsKey($period)) { continue }
    $bucket = $periodBuckets[$period]
    foreach ($key in $concepts.Keys) {
        [pscustomobject][ordered]@{
            period = $period
            articleCount = $bucket.articleCount
            concept = $key
            literal = $concepts[$key]
            documentCount = $bucket.concepts[$key]
            documentsPer100 = [Math]::Round(100 * $bucket.concepts[$key] / $bucket.articleCount, 2)
        }
    }
}

$domainRows = foreach ($domainKey in ($domainBuckets.Keys | Sort-Object)) {
    $parts = $domainKey -split '\|', 2
    [pscustomobject][ordered]@{ year = [int]$parts[0]; domain = $parts[1]; documentCount = $domainBuckets[$domainKey] }
}

$yearRows | Export-Csv -LiteralPath (Join-Path $OutputDir 'year_concept_rates.csv') -NoTypeInformation -Encoding utf8BOM
$periodRows | Export-Csv -LiteralPath (Join-Path $OutputDir 'period_concept_rates.csv') -NoTypeInformation -Encoding utf8BOM
$domainRows | Export-Csv -LiteralPath (Join-Path $OutputDir 'year_source_domains.csv') -NoTypeInformation -Encoding utf8BOM

Write-Output "Wrote $($yearRows.Count) year-concept rows, $($periodRows.Count) period-concept rows, and $($domainRows.Count) year-domain rows."
