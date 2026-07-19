param(
    [string]$CandidatePath = '.\research\data\ecology_nature_candidates.csv',
    [string]$OutputPath = '.\research\data\ecology_nature_screening.csv',
    [string]$StatsPath = '.\research\data\ecology_nature_screening.stats.json',
    [int]$BodyDistinctTermThreshold = 5
)

$ErrorActionPreference = 'Stop'

$directTerms = @(
    '自然界','自然环境','自然规律','生态','生态学','生态系统','生态圈','生态环境','生态保护','环境保护','环保','可持续发展',
    '气候','气候变化','气候异常','全球变暖','温室气体','碳排放','碳中和','减排','热污染','极端天气','灾害','洪水','干旱','台风','地震','防灾','抗灾','容灾',
    '能源','能源安全','能源结构','能源消耗','石油','天然气','煤炭','煤电','核电','核能','核聚变','太阳能','风电','水电','电网','矿产','矿藏','水资源','节水','清洁能源','绿色能源',
    '土地','耕地','农田','土壤','农业','农村','乡村','农民','粮食','粮食安全','种植','养殖','渔业','牧业','农产品','农药','化肥','灌溉','水利',
    '生物','物种','动物','植物','野生动物','保护动物','濒危','灭绝','进化','基因','食物链','森林','草原','湿地','海洋','河流','湖泊','山林',
    '污染','空气污染','水污染','土壤污染','塑料污染','垃圾','垃圾分类','塑料','废物','废水','废气','回收','循环利用','再利用','排放'
)

$rows = @(Import-Csv -LiteralPath ([IO.Path]::GetFullPath($CandidatePath)))
$selected = [Collections.Generic.List[object]]::new()
foreach ($row in $rows) {
    $titleQuestion = "{0}`n{1}" -f [string]$row.title, [string]$row.question
    $directHits = @($directTerms | Where-Object { $titleQuestion.Contains($_, [StringComparison]::OrdinalIgnoreCase) })
    $bodyTerms = @(([string]$row.bodyHits -split '；') | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Sort-Object -Unique)
    $reason = if ($directHits.Count -gt 0) {
        '标题或问题直接命中生态自然窄词'
    } elseif ($bodyTerms.Count -ge $BodyDistinctTermThreshold) {
        "正文至少命中$BodyDistinctTermThreshold个生态自然词"
    } else { $null }
    if ($null -eq $reason) { continue }
    $selected.Add([pscustomobject][ordered]@{
        ordinal = [int]$row.ordinal
        id = [string]$row.id
        date = [string]$row.date
        title = [string]$row.title
        url = [string]$row.url
        question = [string]$row.question
        textLength = [int]$row.textLength
        relevanceScore = [int]$row.relevanceScore
        screeningReason = $reason
        directTerms = ($directHits -join '；')
        bodyDistinctTermCount = $bodyTerms.Count
        bodyTerms = ($bodyTerms -join '；')
        categories = [string]$row.categories
        thesis = [string]$row.thesis
        authorActionAndEthicalJudgments = [string]$row.authorActionAndEthicalJudgments
        faithfulSummary = [string]$row.faithfulSummary
        sourceReadingFile = [string]$row.sourceReadingFile
    })
}

$sorted = @($selected | Sort-Object @{ Expression = 'relevanceScore'; Descending = $true }, @{ Expression = 'textLength'; Descending = $true }, ordinal)
$sorted | Export-Csv -LiteralPath ([IO.Path]::GetFullPath($OutputPath)) -NoTypeInformation -Encoding utf8BOM
$unique = @($sorted.id | Sort-Object -Unique).Count
$directCount = @($sorted | Where-Object screeningReason -eq '标题或问题直接命中生态自然窄词').Count
$bodyCount = $sorted.Count - $directCount
$missing = @($sorted | Where-Object {
    [string]::IsNullOrWhiteSpace($_.id) -or [string]::IsNullOrWhiteSpace($_.title) -or
    [string]::IsNullOrWhiteSpace($_.thesis) -or [string]::IsNullOrWhiteSpace($_.faithfulSummary)
}).Count
$stats = [ordered]@{
    wideCandidates = $rows.Count
    screenedCandidates = $sorted.Count
    bodyDistinctTermThreshold = $BodyDistinctTermThreshold
    directTitleQuestionCandidates = $directCount
    bodyMultiTermCandidates = $bodyCount
    uniqueScreenedIds = $unique
    missingCoreFields = $missing
    status = if ($rows.Count -gt 0 -and $sorted.Count -gt 0 -and $unique -eq $sorted.Count -and $missing -eq 0) { 'PASS' } else { 'REVIEW' }
}
$stats | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath ([IO.Path]::GetFullPath($StatsPath)) -Encoding utf8
$stats | ConvertTo-Json -Depth 4
if ($stats.status -ne 'PASS') { throw "Ecology/nature screening validation ended with status $($stats.status)." }
