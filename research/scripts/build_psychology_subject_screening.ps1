param(
    [string]$CandidatePath = '.\research\data\psychology_subject_candidates.csv',
    [string]$OutputPath = '.\research\data\psychology_subject_screening.csv',
    [string]$StatsPath = '.\research\data\psychology_subject_screening.stats.json',
    [int]$BodyDistinctTermThreshold = 4
)

$ErrorActionPreference='Stop'
$directTerms=@(
    '心理','心理健康','心理咨询','心理治疗','治疗师','咨询师','精神病','精神疾病','抑郁','抑郁症','焦虑','焦虑症','PTSD','创伤后应激','诊断',
    '情绪','情绪价值','情绪稳定','痛苦','幸福','悲伤','愤怒','愧疚','羞耻','恐惧','绝望','孤独','自尊','自卑','自信','虚荣','反刍','安全感',
    '创伤','修复','自救','疗愈','自杀','轻生','死亡焦虑','心理防线','情绪劳动','人格','主体'
)
$rows=@(Import-Csv -LiteralPath ([IO.Path]::GetFullPath($CandidatePath)));$selected=[Collections.Generic.List[object]]::new()
foreach($row in $rows){
    $titleQuestion="{0}`n{1}"-f[string]$row.title,[string]$row.question
    $directHits=@($directTerms|Where-Object{$titleQuestion.Contains($_,[StringComparison]::OrdinalIgnoreCase)})
    $bodyTerms=@(([string]$row.bodyHits-split'；')|Where-Object{-not[string]::IsNullOrWhiteSpace($_)}|Sort-Object -Unique)
    $reason=if($directHits.Count-gt0){'标题或问题直接命中心理主体窄词'}elseif($bodyTerms.Count-ge$BodyDistinctTermThreshold){"正文至少命中$($BodyDistinctTermThreshold)个心理主体词"}else{$null}
    if($null-eq$reason){continue}
    $selected.Add([pscustomobject][ordered]@{ordinal=[int]$row.ordinal;id=[string]$row.id;date=[string]$row.date;title=[string]$row.title;url=[string]$row.url;question=[string]$row.question;textLength=[int]$row.textLength;relevanceScore=[int]$row.relevanceScore;screeningReason=$reason;directTerms=($directHits-join'；');bodyDistinctTermCount=$bodyTerms.Count;bodyTerms=($bodyTerms-join'；');categories=[string]$row.categories;thesis=[string]$row.thesis;authorActionAndEthicalJudgments=[string]$row.authorActionAndEthicalJudgments;faithfulSummary=[string]$row.faithfulSummary;sourceReadingFile=[string]$row.sourceReadingFile})
}
$sorted=@($selected|Sort-Object @{Expression='relevanceScore';Descending=$true},@{Expression='textLength';Descending=$true},ordinal)
$sorted|Export-Csv -LiteralPath ([IO.Path]::GetFullPath($OutputPath)) -NoTypeInformation -Encoding utf8BOM
$unique=@($sorted.id|Sort-Object -Unique).Count;$directCount=@($sorted|Where-Object{$_.screeningReason-eq'标题或问题直接命中心理主体窄词'}).Count;$bodyCount=$sorted.Count-$directCount
$missing=@($sorted|Where-Object{[string]::IsNullOrWhiteSpace($_.id)-or[string]::IsNullOrWhiteSpace($_.title)-or[string]::IsNullOrWhiteSpace($_.thesis)-or[string]::IsNullOrWhiteSpace($_.faithfulSummary)}).Count
$stats=[ordered]@{wideCandidates=$rows.Count;screenedCandidates=$sorted.Count;bodyDistinctTermThreshold=$BodyDistinctTermThreshold;directTitleQuestionCandidates=$directCount;bodyMultiTermCandidates=$bodyCount;uniqueScreenedIds=$unique;missingCoreFields=$missing;status=if($rows.Count-gt0-and$sorted.Count-gt0-and$unique-eq$sorted.Count-and$missing-eq0){'PASS'}else{'REVIEW'}}
$stats|ConvertTo-Json -Depth 4|Set-Content -LiteralPath ([IO.Path]::GetFullPath($StatsPath)) -Encoding utf8;$stats|ConvertTo-Json -Depth 4
if($stats.status-ne'PASS'){throw "Psychology/subject screening validation ended with status $($stats.status)."}
