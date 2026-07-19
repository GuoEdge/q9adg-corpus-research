param(
    [string]$CandidatePath = '.\research\data\intimacy_relationship_candidates.csv',
    [string]$OutputPath = '.\research\data\intimacy_relationship_screening.csv',
    [string]$StatsPath = '.\research\data\intimacy_relationship_screening.stats.json',
    [int]$BodyDistinctTermThreshold = 5
)

$ErrorActionPreference = 'Stop'

$directTerms = @(
    '爱情','恋爱','爱人','恋人','情人','伴侣','情侣','男友','女友','男朋友','女朋友','前任','前夫','前妻','未婚夫','未婚妻',
    '配偶','夫妻','丈夫','妻子','老公','老婆','相亲','表白','暗恋','单恋','网恋','异地恋','早恋','约会','脱单','择偶',
    '结婚','婚姻','婚礼','婚前','婚后','求婚','订婚','领证','彩礼','嫁妆','陪嫁','婚房','门当户对',
    '离婚','分手','复合','挽回','失恋','独身','单身','不婚','再婚','丧偶','鳏寡','剩男','剩女',
    '出轨','婚外情','第三者','小三','亲密关系','性关系','性生活','同居','性伴侣','家暴','冷战','吃醋','查手机'
)

$rows = @(Import-Csv -LiteralPath ([IO.Path]::GetFullPath($CandidatePath)))
$selected = [Collections.Generic.List[object]]::new()
foreach ($row in $rows) {
    $titleQuestion = "{0}`n{1}" -f [string]$row.title, [string]$row.question
    $directHits = @($directTerms | Where-Object { $titleQuestion.Contains($_, [StringComparison]::OrdinalIgnoreCase) })
    $bodyTerms = @(([string]$row.bodyHits -split '；') | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Sort-Object -Unique)
    $reason = if ($directHits.Count -gt 0) {
        '标题或问题直接命中亲密关系窄词'
    } elseif ($bodyTerms.Count -ge $BodyDistinctTermThreshold) {
        "正文至少命中$BodyDistinctTermThreshold个亲密关系词"
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
$directCount = @($sorted | Where-Object screeningReason -eq '标题或问题直接命中亲密关系窄词').Count
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
if ($stats.status -ne 'PASS') { throw "Intimacy screening validation ended with status $($stats.status)." }
