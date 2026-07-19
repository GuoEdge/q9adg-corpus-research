param(
    [string]$CorpusPath = '.\sooon-q9adg-articles.jsonl',
    [string]$EvidencePath = '.\research\data\author_view_evidence_clean.jsonl',
    [string]$OutputPath = '.\research\data\wealth_economy_candidates.csv',
    [string]$StatsPath = '.\research\data\wealth_economy_candidates.stats.json'
)

$ErrorActionPreference = 'Stop'

$terms = @(
    '财富','钱','金钱','货币','现金','财产','资产','私产','公产','公共财富','收入','工资','薪酬','报酬','奖金','利润','收益','回报',
    '贫穷','贫困','穷人','富人','贫富','富裕','富豪','中产','阶层','资本','资本家','企业家','股东','股权','投资','融资','借贷','债务','负债','利息','信用','抵押','担保','风险','保险',
    '市场','价格','定价','成本','机会成本','沉没成本','账目','预算','消费','储蓄','存款','税收','分配','再分配','最低工资','失业','就业',
    '劳动','工作','职业','事业','岗位','雇佣','雇主','雇员','员工','劳动力','生产','产出','效率','技能','手艺','资源','公共品','基础设施','福利',
    '救济','慈善','捐赠','捐款','施舍','善款','资助','援助','扶贫','脱贫','以工代赈','公益','赠与','礼物','感谢',
    '交易','购买','出售','买卖','合同','产权','所有权','生意','商业','创业','产业','供给','需求','竞争','垄断','稀缺','可持续','家业','遗产','继承'
)

$categories = [ordered]@{
    '财富定义与资源可及性' = @('财富','金钱','货币','财产','资产','私产','公产','公共财富','资源','公共品','基础设施','可持续')
    '贫富教育与家族传承' = @('贫穷','贫困','穷人','富人','贫富','富裕','富豪','中产','阶层','家业','遗产','继承')
    '劳动职业与事业' = @('劳动','工作','职业','事业','岗位','雇佣','雇主','雇员','员工','劳动力','生产','产出','效率','技能','手艺','就业','失业')
    '成本价格与交换' = @('价格','定价','成本','机会成本','沉没成本','交易','购买','出售','买卖','合同','产权','所有权','消费','预算')
    '企业资本与利润' = @('资本','资本家','企业家','股东','股权','利润','收益','回报','生意','商业','创业','产业','生产')
    '市场分配与公共财富' = @('市场','供给','需求','竞争','垄断','稀缺','工资','薪酬','报酬','奖金','分配','再分配','最低工资','税收','福利','公共财富')
    '投资风险与信用' = @('投资','融资','借贷','债务','负债','利息','信用','抵押','担保','风险','保险','储蓄','存款')
    '慈善救济与赠与' = @('救济','慈善','捐赠','捐款','施舍','善款','资助','援助','扶贫','脱贫','以工代赈','公益','赠与','礼物','感谢')
}

function Get-Hits([string]$Text,[string[]]$Needles){
    if([string]::IsNullOrEmpty($Text)){return @()}
    return @($Needles|Where-Object{$Text.Contains($_,[StringComparison]::OrdinalIgnoreCase)})
}

$evidenceById=@{}
foreach($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($EvidencePath))){
    if([string]::IsNullOrWhiteSpace($line)){continue};$row=$line|ConvertFrom-Json;$evidenceById[[string]$row.id]=$row
}

$records=[Collections.Generic.List[object]]::new();$ordinal=0
foreach($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($CorpusPath))){
    if([string]::IsNullOrWhiteSpace($line)){continue};$ordinal++;$article=$line|ConvertFrom-Json
    $titleHits=@(Get-Hits ([string]$article.title) $terms);$questionHits=@(Get-Hits ([string]$article.question) $terms);$bodyHits=@(Get-Hits ([string]$article.text) $terms)
    $matched=@($titleHits+$questionHits+$bodyHits|Sort-Object -Unique);if($matched.Count-eq0){continue}
    $categoryHits=[Collections.Generic.List[string]]::new();foreach($entry in $categories.GetEnumerator()){if(@($matched|Where-Object{$_ -in $entry.Value}).Count-gt0){[void]$categoryHits.Add($entry.Key)}}
    $evidence=$evidenceById[[string]$article.id];$date=[DateTimeOffset]::FromUnixTimeMilliseconds([int64]$article.publishedAt).ToOffset([TimeSpan]::FromHours(8)).ToString('yyyy-MM-dd')
    $score=6*$titleHits.Count+4*$questionHits.Count+$bodyHits.Count+[Math]::Min(6,[Math]::Floor(([string]$article.text).Length/800))
    $records.Add([pscustomobject][ordered]@{ordinal=$ordinal;id=[string]$article.id;date=$date;title=[string]$article.title;url=[string]$article.url;question=[string]$article.question;textLength=([string]$article.text).Length;relevanceScore=$score;titleHits=($titleHits-join '；');questionHits=($questionHits-join '；');bodyHits=($bodyHits-join '；');matchedTerms=($matched-join '；');categories=($categoryHits-join '；');thesis=[string]$evidence.thesis;authorActionAndEthicalJudgments=[string]$evidence.authorActionAndEthicalJudgments;faithfulSummary=[string]$evidence.faithfulSummary;sourceReadingFile=[string]$evidence.sourceReadingFile})
}
$sorted=@($records|Sort-Object @{Expression='relevanceScore';Descending=$true},@{Expression='textLength';Descending=$true},ordinal)
$sorted|Export-Csv -LiteralPath ([IO.Path]::GetFullPath($OutputPath)) -NoTypeInformation -Encoding utf8BOM
$categoryCounts=[ordered]@{};foreach($name in $categories.Keys){$categoryCounts[$name]=@($sorted|Where-Object{$_.categories -split '；' -contains $name}).Count}
$missing=@($sorted|Where-Object{[string]::IsNullOrWhiteSpace($_.thesis)}).Count;$unique=@($sorted.id|Sort-Object -Unique).Count
$stats=[ordered]@{corpusArticles=$ordinal;evidenceArticles=$evidenceById.Count;candidateArticles=$sorted.Count;termCount=$terms.Count;categoryCount=$categories.Count;categoryArticleCounts=$categoryCounts;missingEvidenceRows=$missing;uniqueCandidateIds=$unique;status=if($ordinal-eq4050-and$evidenceById.Count-eq4050-and$sorted.Count-gt0-and$unique-eq$sorted.Count-and$missing-eq0){'PASS'}else{'REVIEW'}}
$stats|ConvertTo-Json -Depth 5|Set-Content -LiteralPath ([IO.Path]::GetFullPath($StatsPath)) -Encoding utf8
$stats|ConvertTo-Json -Depth 5
if($stats.status-ne'PASS'){throw "Wealth candidate validation ended with status $($stats.status)."}

