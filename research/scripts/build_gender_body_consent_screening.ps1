param(
    [string]$CandidatePath = '.\research\data\gender_body_consent_candidates.csv',
    [string]$OutputPath = '.\research\data\gender_body_consent_screening.csv',
    [string]$StatsPath = '.\research\data\gender_body_consent_screening.stats.json',
    [int]$BodyDistinctTermThreshold = 5
)

$ErrorActionPreference = 'Stop'

$directTerms = @(
    '性别','男性','女性','男人','女人','男孩','女孩','男生','女生','男子','女子','性别平等','男女平等','性别歧视','性别角色','男权','女权','父权','女性主义','大男子主义','雄竞','雌竞','贤妻良母','全职太太','家庭主妇','女德','男德',
    '身体自主','身体权利','性权利','高跟鞋','乳房','生殖器','阴茎','阴道','子宫','卵巢','睾丸','处女膜','月经','生理期','更年期','整容','医美',
    '性欲','性要求','性爱','性行为','性关系','性生活','性取向','同性恋','异性恋','双性恋','无性恋','LGBT','LGBTQ','酷儿','色情','情色','性幻想','性癖','自慰','手淫','性高潮','性压抑','约炮','嫖娼','卖淫','援交','性交易',
    '性同意','性骚扰','性侵','强奸','猥亵','偷拍','裸照','裸聊','迷奸','诱奸','家暴',
    '性教育','生理教育','避孕','安全套','避孕套','性病','性传播','艾滋','HIV','HPV','梅毒','淋病','性健康','生殖健康','妇科','男科',
    '生育','怀孕','妊娠','孕妇','孕期','备孕','分娩','顺产','剖宫产','剖腹产','流产','堕胎','引产','产后','坐月子','产假','陪产','母乳','哺乳','不孕','绝育','结扎','代孕','试管婴儿','母职','父职','丁克','婚育',
    '照料劳动','家庭劳动','保护女性','骑士精神','凝视','物化','客体化'
)

$rows = @(Import-Csv -LiteralPath ([IO.Path]::GetFullPath($CandidatePath)))
$selected = [Collections.Generic.List[object]]::new()
foreach ($row in $rows) {
    $titleQuestion = "{0}`n{1}" -f [string]$row.title, [string]$row.question
    $directHits = @($directTerms | Where-Object { $titleQuestion.Contains($_, [StringComparison]::OrdinalIgnoreCase) })
    $bodyTerms = @(([string]$row.bodyHits -split '；') | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Sort-Object -Unique)
    $reason = if ($directHits.Count -gt 0) {
        '标题或问题直接命中性别身体窄词'
    } elseif ($bodyTerms.Count -ge $BodyDistinctTermThreshold) {
        "正文至少命中$BodyDistinctTermThreshold个性别身体词"
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
$directCount = @($sorted | Where-Object screeningReason -eq '标题或问题直接命中性别身体窄词').Count
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
if ($stats.status -ne 'PASS') { throw "Gender/body/consent screening validation ended with status $($stats.status)." }
