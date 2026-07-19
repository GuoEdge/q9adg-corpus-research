param(
    [string]$CorpusPath = '.\sooon-q9adg-articles.jsonl',
    [string]$EvidencePath = '.\research\data\author_view_evidence_clean.jsonl',
    [string]$OutputPath = '.\research\data\death_memorial_candidates.csv',
    [string]$StatsPath = '.\research\data\death_memorial_candidates.stats.json'
)

$ErrorActionPreference = 'Stop'

$terms = @(
    '死亡','死去','去世','逝世','亡故','亡者','死者','生死','临终','寿终','遗言','遗愿','遗体','尸体',
    '葬礼','丧礼','丧事','治丧','殡葬','殡仪馆','灵堂','安葬','下葬','土葬','火葬','火化','公墓','坟墓','墓地','墓碑','骨灰','棺材','棺椁',
    '哀悼','悼念','追悼','吊唁','悲悼','守丧','服丧','丧亲','哀伤','悲伤','悲痛','节哀',
    '祭祀','祭奠','祭礼','祭扫','扫墓','清明','忌日','牌位','香火','祖先','先人','祖宗',
    '纪念','纪念碑','纪念馆','纪念日','缅怀','铭记','英烈','烈士','牺牲','阵亡','殉难',
    '遗物','遗产','遗嘱','身后事','传承','留名','名垂青史','死后','后事'
)

$categories = [ordered]@{
    '死亡临终与生死经验' = @('死亡','死去','去世','逝世','亡故','亡者','死者','生死','临终','寿终','遗言','遗愿','遗体','尸体')
    '丧葬仪式与遗体处置' = @('葬礼','丧礼','丧事','治丧','殡葬','殡仪馆','灵堂','安葬','下葬','土葬','火葬','火化','公墓','坟墓','墓地','墓碑','骨灰','棺材','棺椁')
    '哀悼悲伤与关系修复' = @('哀悼','悼念','追悼','吊唁','悲悼','守丧','服丧','丧亲','哀伤','悲伤','悲痛','节哀')
    '祖先祭祀与代际共同体' = @('祭祀','祭奠','祭礼','祭扫','扫墓','清明','忌日','牌位','香火','祖先','先人','祖宗')
    '公共纪念与牺牲叙事' = @('纪念','纪念碑','纪念馆','纪念日','缅怀','铭记','英烈','烈士','牺牲','阵亡','殉难')
    '遗愿遗物与身后传承' = @('遗言','遗愿','遗物','遗产','遗嘱','身后事','传承','留名','名垂青史','死后','后事')
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
        if (@($matched | Where-Object { $_ -in $entry.Value }).Count -gt 0) { [void]$categoryHits.Add($entry.Key) }
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
if ($stats.status -ne 'PASS') { throw "Death and memorial candidate validation ended with status $($stats.status)." }
