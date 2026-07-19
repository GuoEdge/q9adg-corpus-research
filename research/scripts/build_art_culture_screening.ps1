param(
    [string]$CandidatePath = '.\research\data\art_culture_candidates.csv',
    [string]$OutputPath = '.\research\data\art_culture_screening.csv',
    [string]$StatsPath = '.\research\data\art_culture_screening.stats.json'
)

$ErrorActionPreference = 'Stop'

$narrowTerms = @(
    '艺术','艺术家','美学','审美','美感','品味','丑','风格',
    '文学','文艺','小说','诗歌','诗人','作家','戏剧',
    '绘画','画家','画作','书法','雕塑','摄影',
    '音乐','乐曲','电影','影视','演员','导演','编剧','舞蹈','动画','漫画',
    '创作','创作者','版权','票房','出版','稿费','文物','博物馆','遗产'
)

$candidates = @(Import-Csv -LiteralPath ([IO.Path]::GetFullPath($CandidatePath)))
$rows = [Collections.Generic.List[object]]::new()
foreach ($candidate in $candidates) {
    $matched = @([string]$candidate.matchedTerms -split '；' | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    $narrowHits = @($matched | Where-Object { $_ -in $narrowTerms })
    $titleQuestionHit = -not [string]::IsNullOrWhiteSpace([string]$candidate.titleHits) -or -not [string]::IsNullOrWhiteSpace([string]$candidate.questionHits)
    if (-not $titleQuestionHit -and $narrowHits.Count -lt 2) { continue }

    $reason = if ($titleQuestionHit -and $narrowHits.Count -ge 2) {
        '标题或问题直接命中；正文含至少两个窄词'
    } elseif ($titleQuestionHit) {
        '标题或问题直接命中'
    } else {
        '正文含至少两个窄词'
    }

    $rows.Add([pscustomobject][ordered]@{
        ordinal = $candidate.ordinal
        id = $candidate.id
        date = $candidate.date
        title = $candidate.title
        url = $candidate.url
        question = $candidate.question
        textLength = $candidate.textLength
        relevanceScore = $candidate.relevanceScore
        screeningReason = $reason
        narrowTermCount = $narrowHits.Count
        narrowTerms = ($narrowHits -join '；')
        titleHits = $candidate.titleHits
        questionHits = $candidate.questionHits
        categories = $candidate.categories
        thesis = $candidate.thesis
        authorActionAndEthicalJudgments = $candidate.authorActionAndEthicalJudgments
        faithfulSummary = $candidate.faithfulSummary
        sourceReadingFile = $candidate.sourceReadingFile
    })
}

$sorted = @($rows | Sort-Object @{ Expression = { [int]$_.relevanceScore }; Descending = $true }, @{ Expression = { [int]$_.narrowTermCount }; Descending = $true }, @{ Expression = { [int]$_.textLength }; Descending = $true }, @{ Expression = { [int]$_.ordinal }; Descending = $false })
$sorted | Export-Csv -LiteralPath ([IO.Path]::GetFullPath($OutputPath)) -NoTypeInformation -Encoding utf8BOM

$unique = @($sorted.id | Sort-Object -Unique).Count
$missing = @($sorted | Where-Object { [string]::IsNullOrWhiteSpace($_.id) -or [string]::IsNullOrWhiteSpace($_.title) -or [string]::IsNullOrWhiteSpace($_.url) -or [string]::IsNullOrWhiteSpace($_.thesis) }).Count
$stats = [ordered]@{
    wideCandidates = $candidates.Count
    screenedCandidates = $sorted.Count
    titleOrQuestionDirectHits = @($candidates | Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_.titleHits) -or -not [string]::IsNullOrWhiteSpace([string]$_.questionHits) }).Count
    candidatesWithTwoNarrowTerms = @($candidates | Where-Object {
        $candidateTerms = @([string]$_.matchedTerms -split '；' | Where-Object { $_ -in $narrowTerms })
        $candidateTerms.Count -ge 2
    }).Count
    uniqueScreenedIds = $unique
    missingCoreFields = $missing
    status = if ($candidates.Count -eq 1747 -and $sorted.Count -eq 404 -and $unique -eq $sorted.Count -and $missing -eq 0) { 'PASS' } else { 'REVIEW' }
}
$stats | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath ([IO.Path]::GetFullPath($StatsPath)) -Encoding utf8
$stats | ConvertTo-Json -Depth 5

