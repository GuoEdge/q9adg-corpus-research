param(
    [string]$CorpusPath = '.\sooon-q9adg-articles.jsonl',
    [string]$EvidencePath = '.\research\data\author_view_evidence_clean.jsonl',
    [string]$OutputPath = '.\research\data\intimacy_relationship_candidates.csv',
    [string]$StatsPath = '.\research\data\intimacy_relationship_candidates.stats.json'
)

$ErrorActionPreference = 'Stop'

$terms = @(
    '爱','恋','爱情','恋爱','爱人','恋人','情人','伴侣','情侣','对象','男友','女友','男朋友','女朋友','前任','前夫','前妻',
    '未婚夫','未婚妻','配偶','夫妻','丈夫','妻子','老公','老婆','相爱','被爱','愿人得好','依恋','迷恋','眷恋','好感','喜欢','心动','激情','浪漫',
    '相亲','追求','表白','暗恋','单恋','网恋','异地恋','早恋','约会','脱单','择偶','结婚','婚姻','婚礼','婚前','婚后','求婚','订婚','领证',
    '彩礼','嫁妆','陪嫁','婚房','首付','门当户对','离婚','分手','复合','挽回','失恋','独身','单身','不婚','再婚','丧偶','鳏寡','剩男','剩女',
    '承诺','誓言','忠诚','忠贞','背叛','出轨','婚外情','第三者','小三','信任','信赖','猜疑','亲密关系','亲密','性爱','性关系','性生活',
    '接吻','拥抱','同居','性伴侣','性同意','家暴','冷战','争吵','吵架','和好','道歉','原谅','宽恕','妥协','沟通','冷处理',
    '控制欲','占有欲','嫉妒','吃醋','查手机','隐私','边界','拒绝','同意','自由','奉献','付出','牺牲','照顾','照料','陪伴','回应','净输出',
    '交换','互惠','索取','亏欠','家务','育儿','婚内财产','婚前财产','夫妻共同财产'
)

$categories = [ordered]@{
    '爱欲、依恋与爱的定义' = @('爱','恋','爱情','恋爱','爱人','恋人','相爱','被爱','愿人得好','依恋','迷恋','眷恋','好感','喜欢','心动','激情','浪漫','性爱')
    '相识、择偶与关系形成' = @('伴侣','情侣','对象','男友','女友','男朋友','女朋友','相亲','追求','表白','暗恋','单恋','网恋','异地恋','早恋','约会','脱单','择偶','门当户对')
    '承诺、信任与婚姻联盟' = @('未婚夫','未婚妻','配偶','夫妻','丈夫','妻子','老公','老婆','结婚','婚姻','求婚','订婚','领证','承诺','誓言','忠诚','忠贞','信任','信赖','猜疑')
    '婚礼、金钱与财产安排' = @('婚礼','婚前','婚后','彩礼','嫁妆','陪嫁','婚房','首付','婚内财产','婚前财产','夫妻共同财产','交换','互惠','亏欠')
    '日常照料、劳动与互惠' = @('奉献','付出','牺牲','照顾','照料','陪伴','回应','净输出','索取','家务','育儿','拥抱','接吻','亲密')
    '冲突、沟通与关系修复' = @('家暴','冷战','争吵','吵架','冲突','和好','道歉','原谅','宽恕','妥协','沟通','冷处理','复合','挽回')
    '自由、同意与亲密边界' = @('亲密关系','性关系','性生活','同居','性伴侣','性同意','控制欲','占有欲','嫉妒','吃醋','查手机','隐私','边界','拒绝','同意','自由')
    '分手、离婚与独身路径' = @('前任','前夫','前妻','背叛','出轨','婚外情','第三者','小三','离婚','分手','失恋','独身','单身','不婚','再婚','丧偶','鳏寡','剩男','剩女')
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
if ($stats.status -ne 'PASS') { throw "Intimacy candidate validation ended with status $($stats.status)." }
