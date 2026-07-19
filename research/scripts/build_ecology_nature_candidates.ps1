param(
    [string]$CorpusPath = '.\sooon-q9adg-articles.jsonl',
    [string]$EvidencePath = '.\research\data\author_view_evidence_clean.jsonl',
    [string]$OutputPath = '.\research\data\ecology_nature_candidates.csv',
    [string]$StatsPath = '.\research\data\ecology_nature_candidates.stats.json'
)

$ErrorActionPreference = 'Stop'

$terms = @(
    '自然','自然界','自然环境','自然规律','生态','生态学','生态系统','生态圈','生态环境','生态保护','环境保护','环保','可持续','可持续发展','环境',
    '气候','气候变化','气候异常','全球变暖','温室气体','碳排放','碳中和','减排','升温','热污染','极端天气','灾害','洪水','干旱','台风','地震','防灾','抗灾','容灾',
    '能源','能源安全','能源结构','能源消耗','石油','天然气','煤炭','煤电','核电','核能','核聚变','太阳能','风电','水电','电力','电网','矿产','矿藏','资源','水资源','节水',
    '土地','耕地','农田','土壤','农业','农村','乡村','农民','粮食','粮食安全','种植','养殖','渔业','牧业','农产品','农药','化肥','灌溉','水利',
    '生物','物种','动物','植物','野生动物','保护动物','濒危','灭绝','进化','基因','食物链','森林','草原','湿地','海洋','河流','湖泊','山林',
    '污染','空气污染','水污染','土壤污染','塑料污染','垃圾','垃圾分类','塑料','废物','废水','废气','回收','循环利用','再利用','排放','清洁能源','绿色能源'
)

$categories = [ordered]@{
    '自然观、规律与人的位置' = @('自然','自然界','自然环境','自然规律','生态学','可持续','可持续发展','环境')
    '生态系统、生物多样性与保护' = @('生态','生态系统','生态圈','生态环境','生态保护','环境保护','环保','生物','物种','濒危','灭绝','食物链','森林','草原','湿地','海洋','河流','湖泊','山林')
    '气候、灾害与文明韧性' = @('气候','气候变化','气候异常','全球变暖','温室气体','碳排放','碳中和','减排','升温','热污染','极端天气','灾害','洪水','干旱','台风','地震','防灾','抗灾','容灾')
    '能源、矿产与资源约束' = @('能源','能源安全','能源结构','能源消耗','石油','天然气','煤炭','煤电','核电','核能','核聚变','太阳能','风电','水电','电力','电网','矿产','矿藏','资源','水资源','节水','清洁能源','绿色能源')
    '农业、农村、土地与粮食' = @('土地','耕地','农田','土壤','农业','农村','乡村','农民','粮食','粮食安全','种植','养殖','渔业','牧业','农产品','农药','化肥','灌溉','水利')
    '动物、植物与跨物种关系' = @('动物','植物','野生动物','保护动物','濒危','灭绝','进化','基因','生物','物种','食物链')
    '污染、废物与物质循环' = @('污染','空气污染','水污染','土壤污染','塑料污染','垃圾','垃圾分类','塑料','废物','废水','废气','回收','循环利用','再利用','排放')
    '生态治理、公共责任与文明未来' = @('生态保护','环境保护','环保','可持续','可持续发展','气候变化','碳排放','碳中和','减排','能源安全','粮食安全','防灾','抗灾','容灾','清洁能源','绿色能源')
}

function Get-Hits([string]$Text, [string[]]$Needles) {
    if ([string]::IsNullOrEmpty($Text)) { return @() }
    return @($Needles | Where-Object { $Text.Contains($_, [StringComparison]::OrdinalIgnoreCase) })
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
    $score = 6 * $titleHits.Count + 4 * $questionHits.Count + $bodyHits.Count + [Math]::Min(6, [Math]::Floor(([string]$article.text).Length / 800))
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
if ($stats.status -ne 'PASS') { throw "Ecology/nature candidate validation ended with status $($stats.status)." }
