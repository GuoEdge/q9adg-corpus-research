param(
    [string]$CandidatePath = '.\research\data\media_public_opinion_candidates.csv',
    [string]$OutputPath = '.\research\data\media_public_opinion_screening.csv',
    [string]$StatsPath = '.\research\data\media_public_opinion_screening.stats.json'
)

$ErrorActionPreference = 'Stop'

$narrowTerms = @(
    '媒体','新闻媒体','新闻','记者','报道','报导','采访','编辑部','报社','电视台','通讯社','新闻业','新闻学',
    '舆论','舆情','民意','公众意见','网民','评论区','热搜','围观','声量','带节奏',
    '宣传','传媒','口径','公关','危机公关','洗地','煽动',
    '谣言','传言','假新闻','辟谣','核实','信源','消息源','事实核查','断章取义','信息茧房',
    '自媒体','公众号','博主','网红','主播','直播','短视频','流量','粉丝','算法推荐','推荐算法','社交媒体','微博','知乎','抖音'
)

$candidates = @(Import-Csv -LiteralPath ([IO.Path]::GetFullPath($CandidatePath)))
$rows = [Collections.Generic.List[object]]::new()
foreach ($candidate in $candidates) {
    $matched = @([string]$candidate.matchedTerms -split '；' | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    $narrowHits = @($matched | Where-Object { $_ -in $narrowTerms })
    $titleQuestionTerms = @(
        ([string]$candidate.titleHits -split '；') + ([string]$candidate.questionHits -split '；') |
            Where-Object { -not [string]::IsNullOrWhiteSpace($_) -and $_ -in $narrowTerms } |
            Sort-Object -Unique
    )
    $titleQuestionHit = $titleQuestionTerms.Count -gt 0
    if (-not $titleQuestionHit -and $narrowHits.Count -lt 2) { continue }

    $reason = if ($titleQuestionHit -and $narrowHits.Count -ge 2) {
        '标题或问题直接命中窄词；全文含至少两个窄词'
    } elseif ($titleQuestionHit) {
        '标题或问题直接命中窄词'
    } else {
        '全文含至少两个窄词'
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
        directNarrowTerms = ($titleQuestionTerms -join '；')
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
$directCount = @($sorted | Where-Object { -not [string]::IsNullOrWhiteSpace($_.directNarrowTerms) }).Count
$twoNarrowCount = @($sorted | Where-Object { [int]$_.narrowTermCount -ge 2 }).Count
$stats = [ordered]@{
    wideCandidates = $candidates.Count
    screenedCandidates = $sorted.Count
    titleOrQuestionDirectNarrowHits = $directCount
    candidatesWithTwoNarrowTerms = $twoNarrowCount
    uniqueScreenedIds = $unique
    missingCoreFields = $missing
    status = if ($candidates.Count -gt 0 -and $sorted.Count -gt 0 -and $sorted.Count -le $candidates.Count -and $unique -eq $sorted.Count -and $missing -eq 0) { 'PASS' } else { 'REVIEW' }
}
$stats | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath ([IO.Path]::GetFullPath($StatsPath)) -Encoding utf8
$stats | ConvertTo-Json -Depth 5
if ($stats.status -ne 'PASS') { throw "Media and public opinion screening validation ended with status $($stats.status)." }
