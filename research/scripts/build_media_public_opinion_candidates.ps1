param(
    [string]$CorpusPath = '.\sooon-q9adg-articles.jsonl',
    [string]$EvidencePath = '.\research\data\author_view_evidence_clean.jsonl',
    [string]$OutputPath = '.\research\data\media_public_opinion_candidates.csv',
    [string]$StatsPath = '.\research\data\media_public_opinion_candidates.stats.json'
)

$ErrorActionPreference = 'Stop'

$terms = @(
    '媒体','新闻媒体','新闻','记者','报道','报导','采访','编辑部','报社','电视台','通讯社','新闻业','新闻学',
    '舆论','舆情','民意','公众意见','网民','评论区','热搜','热点','围观','声量','带节奏',
    '宣传','传播','传媒','叙事','话语','口径','公关','危机公关','洗地','煽动','动员',
    '谣言','传言','假新闻','辟谣','核实','信源','消息源','事实核查','截图','断章取义','信息茧房',
    '自媒体','公众号','博主','网红','主播','直播','短视频','流量','粉丝','算法推荐','推荐算法','社交媒体','微博','知乎','抖音','平台'
)

$categories = [ordered]@{
    '新闻事实与采访报道' = @('媒体','新闻媒体','新闻','记者','报道','报导','采访','编辑部','报社','电视台','通讯社','新闻业','新闻学')
    '舆论民意与群体判断' = @('舆论','舆情','民意','公众意见','网民','评论区','热搜','热点','围观','声量','带节奏')
    '宣传叙事与公共沟通' = @('宣传','传播','传媒','叙事','话语','口径','公关','危机公关','洗地','煽动','动员')
    '谣言信源与事实核验' = @('谣言','传言','假新闻','辟谣','核实','信源','消息源','事实核查','截图','断章取义','信息茧房')
    '自媒体平台与注意力' = @('自媒体','公众号','博主','网红','主播','直播','短视频','流量','粉丝','算法推荐','推荐算法','社交媒体','微博','知乎','抖音','平台')
}

function Get-Hits([string]$text, [string[]]$needles) {
    if ([string]::IsNullOrEmpty($text)) { return @() }
    return @($needles | Where-Object { $text.Contains($_, [StringComparison]::OrdinalIgnoreCase) })
}

$evidenceById = @{}
foreach ($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($EvidencePath))) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $row = $line | ConvertFrom-Json
    $evidenceById[[string]$row.id] = $row
}

$records = [Collections.Generic.List[object]]::new()
$ordinal = 0
foreach ($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($CorpusPath))) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $ordinal++
    $article = $line | ConvertFrom-Json
    $titleHits = @(Get-Hits ([string]$article.title) $terms)
    $questionHits = @(Get-Hits ([string]$article.question) $terms)
    $bodyHits = @(Get-Hits ([string]$article.text) $terms)
    $matched = @($titleHits + $questionHits + $bodyHits | Sort-Object -Unique)
    if ($matched.Count -eq 0) { continue }

    $categoryHits = [Collections.Generic.List[string]]::new()
    foreach ($entry in $categories.GetEnumerator()) {
        if (@($matched | Where-Object { $_ -in $entry.Value }).Count -gt 0) { [void]$categoryHits.Add($entry.Key) }
    }

    $evidence = $evidenceById[[string]$article.id]
    $date = [DateTimeOffset]::FromUnixTimeMilliseconds([int64]$article.publishedAt).ToOffset([TimeSpan]::FromHours(8)).ToString('yyyy-MM-dd')
    $score = 5 * $titleHits.Count + 3 * $questionHits.Count + $bodyHits.Count + [Math]::Min(6, [Math]::Floor(([string]$article.text).Length / 800))
    $records.Add([pscustomobject][ordered]@{
        ordinal = $ordinal
        id = [string]$article.id
        date = $date
        title = [string]$article.title
        url = [string]$article.url
        question = [string]$article.question
        textLength = ([string]$article.text).Length
        relevanceScore = $score
        titleHits = ($titleHits -join '；')
        questionHits = ($questionHits -join '；')
        bodyHits = ($bodyHits -join '；')
        matchedTerms = ($matched -join '；')
        categories = ($categoryHits -join '；')
        thesis = [string]$evidence.thesis
        authorActionAndEthicalJudgments = [string]$evidence.authorActionAndEthicalJudgments
        faithfulSummary = [string]$evidence.faithfulSummary
        sourceReadingFile = [string]$evidence.sourceReadingFile
    })
}

$sorted = @($records | Sort-Object @{ Expression = 'relevanceScore'; Descending = $true }, @{ Expression = 'textLength'; Descending = $true }, ordinal)
$sorted | Export-Csv -LiteralPath ([IO.Path]::GetFullPath($OutputPath)) -NoTypeInformation -Encoding utf8BOM

$categoryCounts = [ordered]@{}
foreach ($name in $categories.Keys) { $categoryCounts[$name] = @($sorted | Where-Object { $_.categories -split '；' -contains $name }).Count }
$missing = @($sorted | Where-Object { [string]::IsNullOrWhiteSpace($_.thesis) }).Count
$unique = @($sorted.id | Sort-Object -Unique).Count
$stats = [ordered]@{
    corpusArticles = $ordinal
    evidenceArticles = $evidenceById.Count
    candidateArticles = $sorted.Count
    termCount = $terms.Count
    categoryCount = $categories.Count
    categoryArticleCounts = $categoryCounts
    missingEvidenceRows = $missing
    uniqueCandidateIds = $unique
    status = if ($ordinal -eq 4050 -and $evidenceById.Count -eq 4050 -and $sorted.Count -gt 0 -and $unique -eq $sorted.Count -and $missing -eq 0) { 'PASS' } else { 'REVIEW' }
}
$stats | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath ([IO.Path]::GetFullPath($StatsPath)) -Encoding utf8
$stats | ConvertTo-Json -Depth 5
if ($stats.status -ne 'PASS') { throw "Media and public opinion candidate validation ended with status $($stats.status)." }
