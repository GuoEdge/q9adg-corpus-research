param(
    [string]$CorpusPath = '.\sooon-q9adg-articles.jsonl',
    [string]$EvidencePath = '.\research\data\author_view_evidence_clean.jsonl',
    [string]$OutputPath = '.\research\data\workplace_organization_candidates.csv',
    [string]$StatsPath = '.\research\data\workplace_organization_candidates.stats.json'
)
$ErrorActionPreference='Stop'
$terms=@(
    '工作','职场','职业','事业','劳动','就业','求职','招聘','面试','简历','入职','转正','升职','晋升','加薪','工资','薪酬','绩效','考核','业绩','加班','离职','辞职','跳槽','裁员','失业','创业','自由职业','一人公司',
    '同事','领导','老板','下属','上司','员工','雇员','公司','单位','组织','团队','企业','部门','岗位','职位','职务','办公室','体制内','编制','公务员','事业单位','国企','私企','客户','用户','供应商','合作方',
    '产出','成果','交付','分工','分功','功劳','协作','合作','汇报','会议','流程','职责','责任','授权','管理','管理者','主管','带团队','执行','决策','资源','预算','项目','业务','市场','订单','利润','成本',
    '忠诚','承诺','信用','圆滑','情商','人情','服从','命令','甩锅','背锅','内卷','竞争','公平','分配','奖金','奖励','惩罚','纪律','制度','规则','文化','关系','社交','社会化',
    '专业','技能','经验','培训','导师','师傅','带教','职业生涯','工作意义','职业道德','工德','工匠','服务','贡献','价值','效率','自动化','人工智能','AI','机器人','远程办公'
)
$categories=[ordered]@{
    '劳动、事业与职业意义'=@('工作','职场','职业','事业','劳动','就业','工作意义','职业道德','工德','服务','贡献','价值')
    '求职、选择与职业发展'=@('求职','招聘','面试','简历','入职','转正','升职','晋升','加薪','跳槽','职业生涯','培训','导师','师傅','带教','专业','技能','经验')
    '产出、交付与专业能力'=@('产出','成果','交付','绩效','考核','业绩','效率','项目','业务','市场','订单','利润','成本','客户','用户','工匠')
    '协作、分工与功劳分配'=@('同事','团队','分工','分功','功劳','协作','合作','汇报','会议','流程','合作方','供应商','奖励','奖金','分配')
    '权柄、管理与责任结构'=@('领导','老板','下属','上司','管理','管理者','主管','带团队','职责','责任','授权','服从','命令','执行','决策','资源','预算')
    '沟通、关系与组织政治'=@('办公室','单位','组织','部门','圆滑','情商','人情','信用','忠诚','承诺','甩锅','背锅','关系','社交','社会化','文化')
    '竞争、评价与制度秩序'=@('公司','企业','岗位','职位','职务','工资','薪酬','绩效','考核','内卷','竞争','公平','惩罚','纪律','制度','规则','体制内','编制','公务员','事业单位','国企','私企')
    '离职、失业与未来工作'=@('加班','离职','辞职','裁员','失业','创业','自由职业','一人公司','自动化','人工智能','AI','机器人','远程办公')
}
function Get-Hits([string]$Text,[string[]]$Needles){if([string]::IsNullOrEmpty($Text)){return @()};@($Needles|Where-Object{$Text.Contains($_,[StringComparison]::OrdinalIgnoreCase)})}
$evidenceById=@{};foreach($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($EvidencePath))){if($line){$o=$line|ConvertFrom-Json;$evidenceById[[string]$o.id]=$o}}
$records=[Collections.Generic.List[object]]::new();$ordinal=0
foreach($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($CorpusPath))){
    if([string]::IsNullOrWhiteSpace($line)){continue};$ordinal++;$a=$line|ConvertFrom-Json
    $th=@(Get-Hits ([string]$a.title) $terms);$qh=@(Get-Hits ([string]$a.question) $terms);$bh=@(Get-Hits ([string]$a.text) $terms);$all=@($th+$qh+$bh|sort -Unique);if(!$all.Count){continue}
    $cats=[Collections.Generic.List[string]]::new();foreach($entry in $categories.GetEnumerator()){if(@($all|?{$_ -in $entry.Value}).Count){[void]$cats.Add($entry.Key)}}
    $e=$evidenceById[[string]$a.id];$date=[DateTimeOffset]::FromUnixTimeMilliseconds([int64]$a.publishedAt).ToOffset([TimeSpan]::FromHours(8)).ToString('yyyy-MM-dd');$score=6*$th.Count+4*$qh.Count+$bh.Count+[Math]::Min(6,[Math]::Floor(([string]$a.text).Length/800))
    $records.Add([pscustomobject][ordered]@{ordinal=$ordinal;id=[string]$a.id;date=$date;title=[string]$a.title;url=[string]$a.url;question=[string]$a.question;textLength=([string]$a.text).Length;relevanceScore=$score;titleHits=($th-join'；');questionHits=($qh-join'；');bodyHits=($bh-join'；');matchedTerms=($all-join'；');categories=($cats-join'；');thesis=[string]$e.thesis;authorActionAndEthicalJudgments=[string]$e.authorActionAndEthicalJudgments;faithfulSummary=[string]$e.faithfulSummary;sourceReadingFile=[string]$e.sourceReadingFile})
}
$sorted=@($records|sort @{Expression='relevanceScore';Descending=$true},@{Expression='textLength';Descending=$true},ordinal);$sorted|Export-Csv -LiteralPath ([IO.Path]::GetFullPath($OutputPath)) -NoTypeInformation -Encoding utf8BOM
$cc=[ordered]@{};foreach($n in $categories.Keys){$cc[$n]=@($sorted|?{$_.categories-split'；'-contains$n}).Count};$missing=@($sorted|?{[string]::IsNullOrWhiteSpace($_.thesis)}).Count;$unique=@($sorted.id|sort -Unique).Count
$stats=[ordered]@{corpusArticles=$ordinal;evidenceArticles=$evidenceById.Count;candidateArticles=$sorted.Count;termCount=$terms.Count;categoryCount=$categories.Count;categoryArticleCounts=$cc;missingEvidenceRows=$missing;uniqueCandidateIds=$unique;status=if($ordinal-eq4050-and$evidenceById.Count-eq4050-and$unique-eq$sorted.Count-and$missing-eq0){'PASS'}else{'REVIEW'}}
$stats|ConvertTo-Json -Depth 5|Set-Content -LiteralPath ([IO.Path]::GetFullPath($StatsPath)) -Encoding utf8;$stats|ConvertTo-Json -Depth 5;if($stats.status-ne'PASS'){throw 'Workplace candidate validation failed.'}
