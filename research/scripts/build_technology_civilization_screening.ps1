param(
    [string]$CandidatePath = '.\research\data\technology_civilization_candidates.csv',
    [string]$OutputPath = '.\research\data\technology_civilization_screening.csv',
    [string]$StatsPath = '.\research\data\technology_civilization_screening.stats.json'
)

$ErrorActionPreference = 'Stop'

$narrowTerms = @(
    '技术路线','可行性','原型','工程化','基础设施','芯片','软件','硬件','代码','编程','算法','算力','网络','通信',
    '人工智能','AI','机器学习','深度学习','机器人','自动化','无人化','工业化','制造','生产线','工厂','商业化','市场化',
    '专利','产权','知识产权','生产力','失业','劳动力','核能','核电','储能','太阳能','风能','航天','火箭','卫星','太空',
    '生物技术','医疗技术','工业革命','历史经验','知识继承','档案','文献','文明保存','环境','生态','污染','气候','可持续',
    '治理','监管','风险','安全','公共目标','社会目标'
)
$titleQuestionTerms = @($narrowTerms + @('技术','工程','创新','产业','工业','机器','智能','能源','记录','文明') | Sort-Object -Unique)

$candidates = @(Import-Csv -LiteralPath ([IO.Path]::GetFullPath($CandidatePath)))
$rows = [Collections.Generic.List[object]]::new()
foreach ($candidate in $candidates) {
    $titleQuestionHits = @((([string]$candidate.titleHits + '；' + [string]$candidate.questionHits) -split '；') | Where-Object { $_ -in $titleQuestionTerms } | Sort-Object -Unique)
    $bodyNarrowHits = @(([string]$candidate.bodyHits -split '；') | Where-Object { $_ -in $narrowTerms } | Sort-Object -Unique)
    $narrowHits = @($titleQuestionHits + $bodyNarrowHits | Sort-Object -Unique)
    $titleQuestionHit = $titleQuestionHits.Count -gt 0
    if (-not $titleQuestionHit -and $bodyNarrowHits.Count -lt 2) { continue }
    $reason = if ($titleQuestionHit -and $bodyNarrowHits.Count -ge 2) { '标题或问题命中技术主题词；正文含至少两个窄词' } elseif ($titleQuestionHit) { '标题或问题命中技术主题词' } else { '正文含至少两个窄词' }
    $rows.Add([pscustomobject][ordered]@{
        ordinal=$candidate.ordinal; id=$candidate.id; date=$candidate.date; title=$candidate.title; url=$candidate.url; question=$candidate.question
        textLength=$candidate.textLength; relevanceScore=$candidate.relevanceScore; screeningReason=$reason; narrowTermCount=$narrowHits.Count
        narrowTerms=($narrowHits -join '；'); titleQuestionTerms=($titleQuestionHits -join '；'); bodyNarrowTerms=($bodyNarrowHits -join '；')
        titleHits=$candidate.titleHits; questionHits=$candidate.questionHits; categories=$candidate.categories
        thesis=$candidate.thesis; authorActionAndEthicalJudgments=$candidate.authorActionAndEthicalJudgments; faithfulSummary=$candidate.faithfulSummary; sourceReadingFile=$candidate.sourceReadingFile
    })
}
$sorted = @($rows | Sort-Object @{Expression={ [int]$_.relevanceScore };Descending=$true}, @{Expression={ [int]$_.narrowTermCount };Descending=$true}, @{Expression={ [int]$_.textLength };Descending=$true}, @{Expression={ [int]$_.ordinal };Descending=$false})
$sorted | Export-Csv -LiteralPath ([IO.Path]::GetFullPath($OutputPath)) -NoTypeInformation -Encoding utf8BOM
$unique=@($sorted.id|Sort-Object -Unique).Count
$missing=@($sorted|Where-Object{[string]::IsNullOrWhiteSpace($_.id)-or[string]::IsNullOrWhiteSpace($_.title)-or[string]::IsNullOrWhiteSpace($_.url)-or[string]::IsNullOrWhiteSpace($_.thesis)}).Count
$stats=[ordered]@{
    wideCandidates=$candidates.Count; screenedCandidates=$sorted.Count
    titleOrQuestionDirectHits=@($candidates|Where-Object{@((([string]$_.titleHits+'；'+[string]$_.questionHits)-split'；')|Where-Object{$_ -in $titleQuestionTerms}).Count-gt0}).Count
    candidatesWithTwoNarrowTerms=@($candidates|Where-Object{@(([string]$_.bodyHits-split'；')|Where-Object{$_ -in $narrowTerms}).Count-ge2}).Count
    uniqueScreenedIds=$unique; missingCoreFields=$missing
    status=if($unique-eq$sorted.Count-and$missing-eq0-and$sorted.Count-gt0){'PASS'}else{'REVIEW'}
}
$stats|ConvertTo-Json -Depth 5|Set-Content -LiteralPath ([IO.Path]::GetFullPath($StatsPath)) -Encoding utf8
$stats|ConvertTo-Json -Depth 5
