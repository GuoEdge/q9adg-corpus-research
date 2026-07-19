param(
    [string]$CandidatePath = '.\research\data\religion_natural_law_candidates.csv',
    [string]$OutputPath = '.\research\data\religion_natural_law_screening.csv',
    [string]$StatsPath = '.\research\data\religion_natural_law_screening.stats.json'
)

$ErrorActionPreference = 'Stop'
$candidates = @(Import-Csv -LiteralPath ([IO.Path]::GetFullPath($CandidatePath)))
$rows = [Collections.Generic.List[object]]::new()
foreach ($candidate in $candidates) {
    $score = [int]$candidate.relevanceScore
    $direct = -not [string]::IsNullOrWhiteSpace([string]$candidate.directLayers)
    $terms = @([string]$candidate.matchedTerms -split '；' | Where-Object { $_ })
    if (-not $direct -and $score -lt 7 -and $terms.Count -lt 3) { continue }
    $reason = if ($direct -and $score -ge 7) { '标题或问题直接命中，且专题得分达到7' } elseif ($direct) { '标题或问题直接命中专题词' } else { '正文专题得分或概念密度达到筛选阈值' }
    $rows.Add([pscustomobject][ordered]@{
        ordinal = $candidate.ordinal
        id = $candidate.id
        date = $candidate.date
        title = $candidate.title
        url = $candidate.url
        question = $candidate.question
        textLength = $candidate.textLength
        relevanceScore = $candidate.relevanceScore
        primaryLayer = $candidate.primaryLayer
        matchedLayers = $candidate.matchedLayers
        directLayers = $candidate.directLayers
        matchedTerms = $candidate.matchedTerms
        screeningReason = $reason
        thesis = $candidate.thesis
        authorActionAndEthicalJudgments = $candidate.authorActionAndEthicalJudgments
        faithfulSummary = $candidate.faithfulSummary
        sourceQuotes = $candidate.sourceQuotes
        sourceReadingFile = $candidate.sourceReadingFile
    })
}
$sorted = @($rows | Sort-Object @{Expression={[int]$_.relevanceScore};Descending=$true}, @{Expression={[int]$_.textLength};Descending=$true}, @{Expression={[int]$_.ordinal};Descending=$false})
$sorted | Export-Csv -LiteralPath ([IO.Path]::GetFullPath($OutputPath)) -NoTypeInformation -Encoding utf8BOM
$layerCounts = [ordered]@{}
foreach ($layer in @($sorted.primaryLayer | Sort-Object -Unique)) { $layerCounts[$layer] = @($sorted | Where-Object primaryLayer -eq $layer).Count }
$missing = @($sorted | Where-Object { [string]::IsNullOrWhiteSpace($_.id) -or [string]::IsNullOrWhiteSpace($_.title) -or [string]::IsNullOrWhiteSpace($_.thesis) }).Count
$stats = [ordered]@{
    wideCandidates = $candidates.Count
    screenedCandidates = $sorted.Count
    uniqueScreenedIds = @($sorted.id | Sort-Object -Unique).Count
    directTitleOrQuestionHits = @($sorted | Where-Object { -not [string]::IsNullOrWhiteSpace($_.directLayers) }).Count
    primaryLayerCounts = $layerCounts
    missingCoreFields = $missing
    status = if ($candidates.Count -gt 0 -and $sorted.Count -gt 0 -and $sorted.Count -le $candidates.Count -and @($sorted.id | Sort-Object -Unique).Count -eq $sorted.Count -and $missing -eq 0) { 'PASS' } else { 'REVIEW' }
}
$stats | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath ([IO.Path]::GetFullPath($StatsPath)) -Encoding utf8
$stats | ConvertTo-Json -Depth 5
if ($stats.status -ne 'PASS') { throw "Religion/natural-law screening validation ended with status $($stats.status)." }
