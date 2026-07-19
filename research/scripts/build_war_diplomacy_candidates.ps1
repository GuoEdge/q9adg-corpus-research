param(
    [string]$CorpusPath = '.\sooon-q9adg-articles.jsonl',
    [string]$EvidencePath = '.\research\data\author_view_evidence_clean.jsonl',
    [string]$OutputPath = '.\research\data\war_diplomacy_candidates.csv',
    [string]$StatsPath = '.\research\data\war_diplomacy_candidates.stats.json'
)

$ErrorActionPreference = 'Stop'

$terms = @(
    '战争','战役','战斗','战场','侵略','停战','投降','战败','胜利',
    '军事','军队','军人','士兵','将军','兵役','征兵','军费','国防',
    '武器','导弹','核武','核战争','威慑','军备',
    '外交','盟友','同盟','条约','制裁','联合国','地缘政治',
    '战略','战术','动员','后勤','补给','占领'
)

$categories = [ordered]@{
    '战争冲突与和平' = @('战争','战役','战斗','战场','侵略','停战','投降','战败','胜利','占领')
    '军事组织与军人' = @('军事','军队','军人','士兵','将军','兵役','征兵','军费','国防')
    '武器威慑与核风险' = @('武器','导弹','核武','核战争','威慑','军备')
    '外交同盟与国际秩序' = @('外交','盟友','同盟','条约','制裁','联合国','地缘政治')
    '战略动员与后勤' = @('战略','战术','动员','后勤','补给')
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
$sorted | Export-Csv -LiteralPath ([IO.Path]::GetFullPath($OutputPath)) -NoTypeInformation -Encoding utf8BOM

$categoryCounts = [ordered]@{}
foreach ($name in $categories.Keys) {
    $categoryCounts[$name] = @($sorted | Where-Object { $_.categories -split '；' -contains $name }).Count
}

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

