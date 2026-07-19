param(
    [string]$CandidatePath = '.\research\data\death_memorial_candidates.csv',
    [string]$OutputPath = '.\research\data\death_memorial_screening.csv',
    [string]$StatsPath = '.\research\data\death_memorial_screening.stats.json'
)

$ErrorActionPreference = 'Stop'

$narrowTerms = @(
    '死亡','死去','去世','逝世','亡故','亡者','死者','生死','临终','寿终','遗言','遗愿','遗体','尸体',
    '葬礼','丧礼','丧事','治丧','殡葬','殡仪馆','灵堂','安葬','下葬','土葬','火葬','火化','公墓','坟墓','墓地','墓碑','骨灰','棺材','棺椁',
    '哀悼','悼念','追悼','吊唁','悲悼','守丧','服丧','丧亲','哀伤','悲痛','节哀',
    '祭祀','祭奠','祭礼','祭扫','扫墓','清明','忌日','牌位','香火','祖先','先人','祖宗',
    '纪念碑','纪念馆','纪念日','缅怀','铭记','英烈','烈士','阵亡','殉难',
    '遗物','遗嘱','身后事','留名','名垂青史','死后','后事'
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
if ($stats.status -ne 'PASS') { throw "Death and memorial screening validation ended with status $($stats.status)." }
