param(
    [string]$CandidatePath = '.\research\data\wealth_economy_candidates.csv',
    [string]$OutputPath = '.\research\data\wealth_economy_screening.csv',
    [string]$StatsPath = '.\research\data\wealth_economy_screening.stats.json',
    [int]$BodyDistinctTermThreshold = 5
)
$ErrorActionPreference='Stop'
$directTerms=@('财富','金钱','货币','财产','资产','收入','工资','薪酬','报酬','利润','贫穷','贫困','穷人','富人','贫富','富裕','资本','资本家','企业家','股东','投资','融资','债务','负债','利息','信用','抵押','市场','价格','定价','成本','消费','储蓄','分配','最低工资','劳动','职业','事业','就业','失业','救济','慈善','捐赠','捐款','善款','扶贫','脱贫','公益','赠与','交易','产权','创业','遗产','继承')
$rows=@(Import-Csv -LiteralPath ([IO.Path]::GetFullPath($CandidatePath)));$selected=[Collections.Generic.List[object]]::new()
foreach($row in $rows){
    $titleQuestion="{0}`n{1}" -f [string]$row.title,[string]$row.question
    $directHits=@($directTerms|Where-Object{$titleQuestion.Contains($_,[StringComparison]::OrdinalIgnoreCase)})
    $bodyTerms=@(([string]$row.bodyHits -split '；')|Where-Object{-not [string]::IsNullOrWhiteSpace($_)}|Sort-Object -Unique)
    $reason=if($directHits.Count-gt0){'标题或问题直接命中财富经济窄词'}elseif($bodyTerms.Count-ge$BodyDistinctTermThreshold){"正文至少命中$BodyDistinctTermThreshold个财富经济词"}else{$null}
    if($null-eq$reason){continue}
    $selected.Add([pscustomobject][ordered]@{ordinal=[int]$row.ordinal;id=[string]$row.id;date=[string]$row.date;title=[string]$row.title;url=[string]$row.url;question=[string]$row.question;textLength=[int]$row.textLength;relevanceScore=[int]$row.relevanceScore;screeningReason=$reason;directTerms=($directHits-join '；');bodyDistinctTermCount=$bodyTerms.Count;bodyTerms=($bodyTerms-join '；');categories=[string]$row.categories;thesis=[string]$row.thesis;authorActionAndEthicalJudgments=[string]$row.authorActionAndEthicalJudgments;faithfulSummary=[string]$row.faithfulSummary;sourceReadingFile=[string]$row.sourceReadingFile})
}
$sorted=@($selected|Sort-Object @{Expression='relevanceScore';Descending=$true},@{Expression='textLength';Descending=$true},ordinal)
$sorted|Export-Csv -LiteralPath ([IO.Path]::GetFullPath($OutputPath)) -NoTypeInformation -Encoding utf8BOM
$unique=@($sorted.id|Sort-Object -Unique).Count;$directCount=@($sorted|Where-Object screeningReason -eq '标题或问题直接命中财富经济窄词').Count;$bodyCount=$sorted.Count-$directCount
$missing=@($sorted|Where-Object{[string]::IsNullOrWhiteSpace($_.id)-or[string]::IsNullOrWhiteSpace($_.title)-or[string]::IsNullOrWhiteSpace($_.thesis)-or[string]::IsNullOrWhiteSpace($_.faithfulSummary)}).Count
$stats=[ordered]@{wideCandidates=$rows.Count;screenedCandidates=$sorted.Count;bodyDistinctTermThreshold=$BodyDistinctTermThreshold;directTitleQuestionCandidates=$directCount;bodyMultiTermCandidates=$bodyCount;uniqueScreenedIds=$unique;missingCoreFields=$missing;status=if($rows.Count-gt0-and$sorted.Count-gt0-and$unique-eq$sorted.Count-and$missing-eq0){'PASS'}else{'REVIEW'}}
$stats|ConvertTo-Json -Depth 4|Set-Content -LiteralPath ([IO.Path]::GetFullPath($StatsPath)) -Encoding utf8
$stats|ConvertTo-Json -Depth 4
if($stats.status-ne'PASS'){throw "Wealth screening validation ended with status $($stats.status)."}
