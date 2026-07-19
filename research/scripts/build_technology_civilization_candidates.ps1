param(
    [string]$CorpusPath = '.\sooon-q9adg-articles.jsonl',
    [string]$EvidencePath = '.\research\data\author_view_evidence_clean.jsonl',
    [string]$OutputPath = '.\research\data\technology_civilization_candidates.csv',
    [string]$StatsPath = '.\research\data\technology_civilization_candidates.stats.json'
)

$ErrorActionPreference = 'Stop'

# Wide recall terms. Generic words such as "历史" and "系统" remain here only
# as routing signals; the screening layer requires title/question or narrow hits.
$terms = @(
    '技术','科技','工程','工程化','技术路线','可行性','原型','实验','设计','发明','创新',
    '工具','材料','基础设施','平台','软件','硬件','芯片','代码','编程','算法','模型','数据','网络','互联网','通信',
    '机器','机器化','机器人','自动化','无人化','人工智能','AI','智能','机器学习','深度学习','算力',
    '产业','工业','工业化','制造','生产线','工厂','商业化','市场化','企业','资本','专利','产权','知识产权','生产力',
    '劳动','就业','岗位','失业','劳动力','职业','能源','电力','核能','核电','石油','煤炭','太阳能','风能','储能',
    '交通','航天','火箭','卫星','太空','化学','生物技术','医疗技术',
    '文明','现代化','工业革命','历史经验','记录','档案','文献','知识继承','传承','保存','遗产',
    '环境','生态','污染','气候','可持续','资源','治理','监管','风险','安全','公共目标','社会目标','责任'
)

$categories = [ordered]@{
    '可实现性与工程路线' = @('技术','科技','工程','工程化','技术路线','可行性','原型','实验','设计','发明','创新')
    '工具、材料与基础设施' = @('工具','材料','基础设施','平台','软件','硬件','芯片','代码','编程','数据','网络','互联网','通信','电力')
    '产业组织、所有权与商业化' = @('产业','工业','工业化','制造','生产线','工厂','商业化','市场化','企业','资本','专利','产权','知识产权','生产力')
    '技术、劳动与失业' = @('劳动','就业','岗位','失业','劳动力','职业','生产力','自动化','机器','机器人')
    'AI、机器与智能边界' = @('人工智能','AI','智能','机器学习','深度学习','算法','模型','算力','机器人')
    '历史经验、记录与知识继承' = @('文明','现代化','工业革命','历史经验','记录','档案','文献','知识继承','传承','遗产')
    '文明保存、能源与环境' = @('文明','能源','电力','核能','核电','石油','煤炭','太阳能','风能','储能','环境','生态','污染','气候','可持续','资源','保存')
    '技术治理、风险与公共目标' = @('治理','监管','风险','安全','公共目标','社会目标','责任','技术','人工智能','环境')
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
    status = if ($ordinal -eq 4050 -and $evidenceById.Count -eq 4050 -and $unique -eq $sorted.Count -and $missing -eq 0) { 'PASS' } else { 'REVIEW' }
}
$stats | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath ([IO.Path]::GetFullPath($StatsPath)) -Encoding utf8
$stats | ConvertTo-Json -Depth 5
