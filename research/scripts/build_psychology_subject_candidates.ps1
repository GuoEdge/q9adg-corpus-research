param(
    [string]$CorpusPath = '.\sooon-q9adg-articles.jsonl',
    [string]$EvidencePath = '.\research\data\author_view_evidence_clean.jsonl',
    [string]$OutputPath = '.\research\data\psychology_subject_candidates.csv',
    [string]$StatsPath = '.\research\data\psychology_subject_candidates.stats.json'
)

$ErrorActionPreference = 'Stop'
$terms = @(
    '心理','心理健康','心理咨询','心理治疗','治疗师','咨询师','精神','精神病','精神疾病','抑郁','抑郁症','焦虑','焦虑症','PTSD','创伤后应激','诊断',
    '情绪','情绪价值','情绪稳定','感受','痛苦','快乐','幸福','悲伤','哀伤','愤怒','愧疚','内疚','羞耻','后悔','压力','紧张','恐惧','害怕','绝望','孤独',
    '自我','主体','人格','自尊','自卑','自信','虚荣','自我否定','自我怀疑','反刍','安全感','信任','勇气','意志','期待','希望','意义','虚无',
    '创伤','受伤','伤害','修复','自救','恢复','疗愈','调节','稳定','边界','依赖','控制','自由','自主','承诺','习惯','训练','行动','适应','成长','认知','解释',
    '自杀','轻生','求死','死亡焦虑','失眠','失能','崩溃','开朗','心态','心理防线','情绪劳动'
)
$categories = [ordered]@{
    '人格主体、自我与边界' = @('自我','主体','人格','自尊','自卑','自信','虚荣','边界','自由','自主','承诺')
    '情绪、感受与价值解释' = @('情绪','情绪价值','情绪稳定','感受','快乐','幸福','悲伤','哀伤','愤怒','愧疚','内疚','羞耻','后悔','解释')
    '焦虑、恐惧与风险管理' = @('焦虑','焦虑症','紧张','压力','恐惧','害怕','安全感','风险','勇气','死亡焦虑','失眠')
    '抑郁、绝望与意义重建' = @('抑郁','抑郁症','绝望','希望','意义','虚无','自杀','轻生','求死','崩溃','开朗')
    '创伤、羞耻、愤怒与修复' = @('创伤','创伤后应激','PTSD','受伤','伤害','羞耻','愤怒','愧疚','内疚','修复','恢复','疗愈')
    '依赖、控制、自由与关系' = @('依赖','控制','自由','自主','边界','信任','孤独','情绪劳动','情绪价值')
    '咨询、诊断与自我理解' = @('心理','心理健康','心理咨询','心理治疗','治疗师','咨询师','精神','精神病','精神疾病','诊断','认知','自我怀疑')
    '训练、习惯、行动与长期成长' = @('习惯','训练','行动','适应','成长','自救','调节','稳定','意志','承诺','反刍','心态')
}
function Get-Hits([string]$Text,[string[]]$Needles) {
    if ([string]::IsNullOrEmpty($Text)) { return @() }
    return @($Needles | Where-Object { $Text.Contains($_,[StringComparison]::OrdinalIgnoreCase) })
}
$evidenceById=@{}
foreach($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($EvidencePath))){if($line){$o=$line|ConvertFrom-Json;$evidenceById[[string]$o.id]=$o}}
$records=[Collections.Generic.List[object]]::new();$ordinal=0
foreach($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($CorpusPath))){
    if([string]::IsNullOrWhiteSpace($line)){continue};$ordinal++;$article=$line|ConvertFrom-Json
    $titleHits=@(Get-Hits ([string]$article.title) $terms);$questionHits=@(Get-Hits ([string]$article.question) $terms);$bodyHits=@(Get-Hits ([string]$article.text) $terms)
    $matched=@($titleHits+$questionHits+$bodyHits|Sort-Object -Unique);if($matched.Count-eq0){continue}
    $categoryHits=[Collections.Generic.List[string]]::new();foreach($entry in $categories.GetEnumerator()){if(@($matched|Where-Object{$_ -in $entry.Value}).Count-gt0){[void]$categoryHits.Add($entry.Key)}}
    $evidence=$evidenceById[[string]$article.id];$date=[DateTimeOffset]::FromUnixTimeMilliseconds([int64]$article.publishedAt).ToOffset([TimeSpan]::FromHours(8)).ToString('yyyy-MM-dd')
    $score=6*$titleHits.Count+4*$questionHits.Count+$bodyHits.Count+[Math]::Min(6,[Math]::Floor(([string]$article.text).Length/800))
    $records.Add([pscustomobject][ordered]@{ordinal=$ordinal;id=[string]$article.id;date=$date;title=[string]$article.title;url=[string]$article.url;question=[string]$article.question;textLength=([string]$article.text).Length;relevanceScore=$score;titleHits=($titleHits-join'；');questionHits=($questionHits-join'；');bodyHits=($bodyHits-join'；');matchedTerms=($matched-join'；');categories=($categoryHits-join'；');thesis=[string]$evidence.thesis;authorActionAndEthicalJudgments=[string]$evidence.authorActionAndEthicalJudgments;faithfulSummary=[string]$evidence.faithfulSummary;sourceReadingFile=[string]$evidence.sourceReadingFile})
}
$sorted=@($records|Sort-Object @{Expression='relevanceScore';Descending=$true},@{Expression='textLength';Descending=$true},ordinal)
$sorted|Export-Csv -LiteralPath ([IO.Path]::GetFullPath($OutputPath)) -NoTypeInformation -Encoding utf8BOM
$categoryCounts=[ordered]@{};foreach($name in $categories.Keys){$categoryCounts[$name]=@($sorted|Where-Object{$_.categories-split'；'-contains$name}).Count}
$missing=@($sorted|Where-Object{[string]::IsNullOrWhiteSpace($_.thesis)}).Count;$unique=@($sorted.id|Sort-Object -Unique).Count
$stats=[ordered]@{corpusArticles=$ordinal;evidenceArticles=$evidenceById.Count;candidateArticles=$sorted.Count;termCount=$terms.Count;categoryCount=$categories.Count;categoryArticleCounts=$categoryCounts;missingEvidenceRows=$missing;uniqueCandidateIds=$unique;status=if($ordinal-eq4050-and$evidenceById.Count-eq4050-and$sorted.Count-gt0-and$unique-eq$sorted.Count-and$missing-eq0){'PASS'}else{'REVIEW'}}
$stats|ConvertTo-Json -Depth 5|Set-Content -LiteralPath ([IO.Path]::GetFullPath($StatsPath)) -Encoding utf8;$stats|ConvertTo-Json -Depth 5
if($stats.status-ne'PASS'){throw "Psychology/subject candidate validation ended with status $($stats.status)."}
