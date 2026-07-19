param(
    [string]$CorpusPath = '.\sooon-q9adg-articles.jsonl',
    [string]$EvidencePath = '.\research\data\author_view_evidence_clean.jsonl',
    [string]$OutputPath = '.\research\data\medical_care_candidates.csv',
    [string]$StatsPath = '.\research\data\medical_care_candidates.stats.json'
)

$ErrorActionPreference = 'Stop'

$terms = @(
    '医疗','医院','医生','医师','病人','患者','疾病','生病','病痛','治疗','诊断','手术',
    '用药','药物','康复','急救','护理','看病','就医','体检','病房','住院','门诊','精神科',
    '癌症','感染','病毒','疫苗'
)

$categories = [ordered]@{
    '诊疗与专业角色' = @('医疗','医院','医生','医师','治疗','诊断','手术','用药','药物','看病','就医','体检','病房','住院','门诊')
    '疾病经验与主体' = @('病人','患者','疾病','生病','病痛','癌症')
    '护理康复与回归' = @('护理','康复')
    '急救与危机' = @('急救')
    '精神医疗接口' = @('精神科')
    '感染与公共卫生' = @('感染','病毒','疫苗')
}

function Get-Hits([string]$text, [string[]]$needles) {
    if ([string]::IsNullOrEmpty($text)) { return @() }
    return @($needles | Where-Object { $text.Contains($_, [StringComparison]::OrdinalIgnoreCase) })
}

$corpusFull = [IO.Path]::GetFullPath($CorpusPath)
$evidenceFull = [IO.Path]::GetFullPath($EvidencePath)
$outputFull = [IO.Path]::GetFullPath($OutputPath)
$statsFull = [IO.Path]::GetFullPath($StatsPath)

$evidenceById = @{}
foreach ($line in [IO.File]::ReadLines($evidenceFull)) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $row = $line | ConvertFrom-Json
    $evidenceById[[string]$row.id] = $row
}

$records = [Collections.Generic.List[object]]::new()
$ordinal = 0
foreach ($line in [IO.File]::ReadLines($corpusFull)) {
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
        if (@($matched | Where-Object { $_ -in $entry.Value }).Count -gt 0) {
            [void]$categoryHits.Add($entry.Key)
        }
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
$sorted | Export-Csv -LiteralPath $outputFull -NoTypeInformation -Encoding utf8BOM

$categoryCounts = [ordered]@{}
foreach ($name in $categories.Keys) {
    $categoryCounts[$name] = @($sorted | Where-Object { $_.categories -split '；' -contains $name }).Count
}

$stats = [ordered]@{
    corpusArticles = $ordinal
    evidenceArticles = $evidenceById.Count
    candidateArticles = $sorted.Count
    termCount = $terms.Count
    categoryCount = $categories.Count
    categoryArticleCounts = $categoryCounts
    missingEvidenceRows = @($sorted | Where-Object { [string]::IsNullOrWhiteSpace($_.thesis) }).Count
    uniqueCandidateIds = @($sorted.id | Sort-Object -Unique).Count
    status = if ($ordinal -eq 4050 -and $evidenceById.Count -eq 4050 -and @($sorted.id | Sort-Object -Unique).Count -eq $sorted.Count -and @($sorted | Where-Object { [string]::IsNullOrWhiteSpace($_.thesis) }).Count -eq 0) { 'PASS' } else { 'REVIEW' }
}

$stats | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $statsFull -Encoding utf8
$stats | ConvertTo-Json -Depth 5
