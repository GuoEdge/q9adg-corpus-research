param(
    [string]$CorpusPath = '.\sooon-q9adg-articles.jsonl',
    [string]$EvidencePath = '.\research\data\author_view_evidence_clean.jsonl',
    [string]$OutputPath = '.\research\data\ethnicity_identity_candidates.csv',
    [string]$StatsPath = '.\research\data\ethnicity_identity_candidates.stats.json'
)

$ErrorActionPreference = 'Stop'

$terms = @(
    '民族','族群','民族国家','国族','主体民族','中华民族','少数民族','民族团结','民族融合','民族认同','民族自决','民族独立','民族解放',
    '汉族','汉人','满族','蒙古族','藏族','回族','维吾尔','壮族','苗族','彝族','土家族','原住民','土著','部族','部落','血统','血缘','族裔','祖先','后裔',
    '种族','种族主义','种族歧视','白人','黑人','黄种人','亚裔','犹太','反犹','穆斯林','伊斯兰','白人至上','有色人种','肤色','歧视','偏见',
    '国籍','入籍','归化','公民身份','国家认同','中国人','外国人','爱国','不爱国','爱党','叛国','卖国','出卖国家',
    '移民','难民','侨民','华人','华裔','海外华人','华侨','绿卡','离散','侨居','唐人街',
    '身份认同','身份政治','文化认同','文化身份','同化','反同化','母语','方言','语言认同','文化共同体','多元文化','跨文化',
    '殖民','殖民地','殖民主义','殖民者','被殖民','帝国主义','宗主国','民族主义','国家主义','国际主义','排外','全球化'
)

$categories = [ordered]@{
    '民族概念、共同体与边界' = @('民族','族群','民族国家','国族','主体民族','中华民族','少数民族','民族团结','民族融合','民族认同','民族自决','民族独立','民族解放','文化共同体')
    '血缘、谱系与历史形成' = @('汉族','汉人','满族','蒙古族','藏族','回族','维吾尔','壮族','苗族','彝族','土家族','原住民','土著','部族','部落','血统','血缘','族裔','祖先','后裔')
    '种族观念、差异与歧视' = @('种族','种族主义','种族歧视','白人','黑人','黄种人','亚裔','犹太','反犹','穆斯林','伊斯兰','白人至上','有色人种','肤色','歧视','偏见')
    '国籍、公民与国家归属' = @('国籍','入籍','归化','公民身份','国家认同','中国人','外国人','爱国','不爱国','爱党','叛国','卖国','出卖国家')
    '移民、华人与离散处境' = @('移民','难民','侨民','华人','华裔','海外华人','华侨','绿卡','离散','侨居','唐人街')
    '语言、文化与同化' = @('身份认同','身份政治','文化认同','文化身份','同化','反同化','母语','方言','语言认同','文化共同体','多元文化','跨文化')
    '殖民、帝国与民族解放' = @('殖民','殖民地','殖民主义','殖民者','被殖民','帝国主义','宗主国','民族自决','民族独立','民族解放')
    '民族主义、排外与跨群体秩序' = @('民族主义','国家主义','国际主义','排外','全球化','民族团结','民族融合','多元文化','跨文化')
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
if ($stats.status -ne 'PASS') { throw "Ethnicity/identity candidate validation ended with status $($stats.status)." }
