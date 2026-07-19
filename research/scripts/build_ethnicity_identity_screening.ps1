param(
    [string]$CandidatePath = '.\research\data\ethnicity_identity_candidates.csv',
    [string]$OutputPath = '.\research\data\ethnicity_identity_screening.csv',
    [string]$StatsPath = '.\research\data\ethnicity_identity_screening.stats.json',
    [int]$BodyDistinctTermThreshold = 3
)

$ErrorActionPreference = 'Stop'

$directTerms = @(
    '民族','族群','民族国家','国族','主体民族','中华民族','少数民族','民族团结','民族融合','民族认同','民族自决','民族独立','民族解放',
    '汉族','汉人','满族','蒙古族','藏族','回族','维吾尔','壮族','苗族','彝族','土家族','原住民','土著','血统','族裔',
    '种族','种族主义','种族歧视','白人','黑人','黄种人','亚裔','犹太','反犹','穆斯林','白人至上','有色人种','肤色','歧视',
    '国籍','入籍','归化','公民身份','国家认同','爱国','不爱国','爱党','叛国','卖国','出卖国家',
    '移民','难民','侨民','华人','华裔','海外华人','华侨','绿卡','唐人街',
    '身份认同','身份政治','文化认同','文化身份','同化','反同化','母语','方言','语言认同','多元文化','跨文化',
    '殖民','殖民地','殖民主义','帝国主义','宗主国','民族主义','国家主义','国际主义','排外','全球化'
)

$rows = @(Import-Csv -LiteralPath ([IO.Path]::GetFullPath($CandidatePath)))
$selected = [Collections.Generic.List[object]]::new()
foreach ($row in $rows) {
    $titleQuestion = "{0}`n{1}" -f [string]$row.title, [string]$row.question
    $directHits = @($directTerms | Where-Object { $titleQuestion.Contains($_, [StringComparison]::OrdinalIgnoreCase) })
    $bodyTerms = @(([string]$row.bodyHits -split '；') | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Sort-Object -Unique)
    $reason = if ($directHits.Count -gt 0) {
        '标题或问题直接命中民族族群窄词'
    } elseif ($bodyTerms.Count -ge $BodyDistinctTermThreshold) {
        "正文至少命中$BodyDistinctTermThreshold个民族族群词"
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
$directCount = @($sorted | Where-Object screeningReason -eq '标题或问题直接命中民族族群窄词').Count
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
if ($stats.status -ne 'PASS') { throw "Ethnicity/identity screening validation ended with status $($stats.status)." }
