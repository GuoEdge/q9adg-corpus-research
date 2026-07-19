param(
    [string]$CandidatePath = '.\research\data\ai_machine_candidates.csv',
    [string]$OutputPath = '.\research\data\ai_machine_screening.csv',
    [string]$StatsPath = '.\research\data\ai_machine_screening.stats.json',
    [int]$BodyDistinctTermThreshold = 2
)

$ErrorActionPreference='Stop'
$directTerms=@(
    '人工智能','AI','大模型','语言模型','大型语言模型','ChatGPT','AutoGPT','OpenAI','DeepSeek','Claude','Gemini','Sora','GPT','机器学习','深度学习','神经网络','算力','开源AI','可信AI',
    '机器人','人形机器人','具身智能','智能体','机器智能','机器意识','人工意识','编舞器','自动化','全自动','无人化',
    'AGI','强人工智能','超级人工智能','图灵测试','AI权利','机器权利','AI伦理','AI治理','AI风险','AI失控',
    'AIGC','生成式AI','AI绘画','AI视频','AI生成','AI创作','AI换脸','深度伪造','AI版权','AI侵权',
    'AI失业','智能失业','AI替代','机器替代','AI教育','AI教学','AI论文','AI考试'
)
$rows=@(Import-Csv -LiteralPath ([IO.Path]::GetFullPath($CandidatePath)));$selected=[Collections.Generic.List[object]]::new()
foreach($row in $rows){
    $titleQuestion="{0}`n{1}"-f[string]$row.title,[string]$row.question
    $directHits=@($directTerms|Where-Object{
        if ($_ -in @('AI','GPT','AGI','AIGC')) { return [regex]::IsMatch($titleQuestion, "(?i)(?<![A-Za-z])$([regex]::Escape($_))(?![A-Za-z])") }
        return $titleQuestion.Contains($_, [StringComparison]::OrdinalIgnoreCase)
    })
    $bodyTerms=@(([string]$row.bodyHits -split '；')|Where-Object{-not[string]::IsNullOrWhiteSpace($_)}|Sort-Object -Unique)
    $reason=if($directHits.Count-gt0){'标题或问题直接命中人工智能窄词'}elseif($bodyTerms.Count-ge$BodyDistinctTermThreshold){"正文至少命中$BodyDistinctTermThreshold个人工智能词"}else{$null}
    if($null-eq$reason){continue}
    $selected.Add([pscustomobject][ordered]@{ordinal=[int]$row.ordinal;id=[string]$row.id;date=[string]$row.date;title=[string]$row.title;url=[string]$row.url;question=[string]$row.question;textLength=[int]$row.textLength;relevanceScore=[int]$row.relevanceScore;screeningReason=$reason;directTerms=($directHits-join'；');bodyDistinctTermCount=$bodyTerms.Count;bodyTerms=($bodyTerms-join'；');categories=[string]$row.categories;thesis=[string]$row.thesis;authorActionAndEthicalJudgments=[string]$row.authorActionAndEthicalJudgments;faithfulSummary=[string]$row.faithfulSummary;sourceReadingFile=[string]$row.sourceReadingFile})
}
$sorted=@($selected|Sort-Object @{Expression='relevanceScore';Descending=$true},@{Expression='textLength';Descending=$true},ordinal)
$sorted|Export-Csv -LiteralPath ([IO.Path]::GetFullPath($OutputPath)) -NoTypeInformation -Encoding utf8BOM
$unique=@($sorted.id|Sort-Object -Unique).Count;$directCount=@($sorted|Where-Object screeningReason -eq '标题或问题直接命中人工智能窄词').Count;$bodyCount=$sorted.Count-$directCount
$missing=@($sorted|Where-Object{[string]::IsNullOrWhiteSpace($_.id)-or[string]::IsNullOrWhiteSpace($_.title)-or[string]::IsNullOrWhiteSpace($_.thesis)-or[string]::IsNullOrWhiteSpace($_.faithfulSummary)}).Count
$stats=[ordered]@{wideCandidates=$rows.Count;screenedCandidates=$sorted.Count;bodyDistinctTermThreshold=$BodyDistinctTermThreshold;directTitleQuestionCandidates=$directCount;bodyMultiTermCandidates=$bodyCount;uniqueScreenedIds=$unique;missingCoreFields=$missing;status=if($rows.Count-gt0-and$sorted.Count-gt0-and$unique-eq$sorted.Count-and$missing-eq0){'PASS'}else{'REVIEW'}}
$stats|ConvertTo-Json -Depth 4|Set-Content -LiteralPath ([IO.Path]::GetFullPath($StatsPath)) -Encoding utf8
$stats|ConvertTo-Json -Depth 4
if($stats.status-ne'PASS'){throw "AI/machine screening validation ended with status $($stats.status)."}
