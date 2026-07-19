param(
    [string]$CandidatePath = '.\research\data\family_kinship_candidates.csv',
    [string]$OutputPath = '.\research\data\family_kinship_screening.csv',
    [string]$StatsPath = '.\research\data\family_kinship_screening.stats.json',
    [int]$BodyDistinctTermThreshold = 5
)

$ErrorActionPreference = 'Stop'

$directTerms = @(
    '家庭','家人','家长','亲属','亲人','亲戚','亲族','族亲','家族','宗族','血缘','代际',
    '父母','父亲','母亲','爸爸','妈妈','双亲','子女','孩子','儿子','女儿','亲子',
    '兄弟','姐妹','手足','祖父','祖母','爷爷','奶奶','外公','外婆','祖辈','后代','子孙',
    '抚养','养育','监护','赡养','养老','孝顺','孝道','家务','家产','遗产','继承','分家',
    '婆媳','公婆','岳父','岳母','援亲','探亲','礼金','奠仪','家风','族谱','家谱','传家'
)

$rows = @(Import-Csv -LiteralPath ([IO.Path]::GetFullPath($CandidatePath)))
$selected = [Collections.Generic.List[object]]::new()
foreach ($row in $rows) {
    $titleQuestion = "{0}`n{1}" -f [string]$row.title, [string]$row.question
    $directHits = @($directTerms | Where-Object { $titleQuestion.Contains($_, [StringComparison]::OrdinalIgnoreCase) })
    $bodyTerms = @(([string]$row.bodyHits -split '；') | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Sort-Object -Unique)
    $reason = if ($directHits.Count -gt 0) {
        '标题或问题直接命中家庭亲属窄词'
    } elseif ($bodyTerms.Count -ge $BodyDistinctTermThreshold) {
        "正文至少命中$BodyDistinctTermThreshold个家庭亲属词"
    } else {
        $null
    }
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
$directCount = @($sorted | Where-Object screeningReason -eq '标题或问题直接命中家庭亲属窄词').Count
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
if ($stats.status -ne 'PASS') { throw "Family and kinship screening validation ended with status $($stats.status)." }
