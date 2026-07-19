param(
    [string]$CandidatePath = '.\research\data\war_diplomacy_candidates.csv',
    [string]$OutputPath = '.\research\data\war_diplomacy_screening.csv',
    [string]$StatsPath = '.\research\data\war_diplomacy_screening.stats.json'
)

$ErrorActionPreference = 'Stop'

$narrowTerms = @(
    '战争','战役','侵略','停战','投降','战败',
    '军事','军队','军人','士兵','将军','兵役','征兵','军费','国防',
    '武器','导弹','核武','核战争','威慑','军备',
    '外交','盟友','同盟','条约','制裁','联合国','地缘政治',
    '后勤','补给','占领'
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
$missing = @($sorted | Where-Object {
    [string]::IsNullOrWhiteSpace($_.id) -or
    [string]::IsNullOrWhiteSpace($_.title) -or
    [string]::IsNullOrWhiteSpace($_.url) -or
    [string]::IsNullOrWhiteSpace($_.thesis)
}).Count
$stats = [ordered]@{
    wideCandidates = $candidates.Count
    screenedCandidates = $sorted.Count
    titleOrQuestionDirectHits = @($candidates | Where-Object {
        -not [string]::IsNullOrWhiteSpace([string]$_.titleHits) -or -not [string]::IsNullOrWhiteSpace([string]$_.questionHits)
    }).Count
    candidatesWithTwoNarrowTerms = @($candidates | Where-Object {
        $candidateTerms = @([string]$_.matchedTerms -split '；' | Where-Object { $_ -in $narrowTerms })
        $candidateTerms.Count -ge 2
    }).Count
    uniqueScreenedIds = $unique
    missingCoreFields = $missing
    status = if ($candidates.Count -eq 1057 -and $sorted.Count -eq 261 -and $unique -eq $sorted.Count -and $missing -eq 0) { 'PASS' } else { 'REVIEW' }
}

$stats | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath ([IO.Path]::GetFullPath($StatsPath)) -Encoding utf8
$stats | ConvertTo-Json -Depth 5

