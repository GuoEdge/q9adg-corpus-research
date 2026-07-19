param(
    [string]$CorpusPath='.\sooon-q9adg-articles.jsonl',
    [string]$EvidencePath='.\research\data\author_view_evidence_clean.jsonl',
    [string]$ScreeningPath='.\research\data\wealth_economy_screening.csv',
    [string]$OutputPath='.\research\data\wealth_economy_core_evidence.csv',
    [string]$StatsPath='.\research\data\wealth_economy_core_evidence.stats.json'
)
$ErrorActionPreference='Stop'

$sections=[ordered]@{
    '财富定义与资源可及性'=@(3801,3476,68,1344,1492,3990)
    '贫富教育与家族传承'=@(3918,3315,3074,3616,3550,936)
    '劳动、职业与事业'=@(3874,3294,1543,3864,1410,2733)
    '成本、价格与交换'=@(3378,1060,574,1688,925,3683)
    '企业、资本与利润'=@(3175,3863,1919,3463,1281,3677)
    '市场、分配与公共财富'=@(3211,1249,2893,3811,1658,3794)
    '投资、风险与信用'=@(1727,2291,1210,2708,3347,934)
    '慈善、救济与赠与'=@(4007,1399,3952,405,1207,556)
}
$sectionTerms=@{
    '财富定义与资源可及性'=@('财富','资源','金钱','贫穷','贫富','公共')
    '贫富教育与家族传承'=@('贫','富','家族','财富','奢侈','面子')
    '劳动、职业与事业'=@('劳动','职业','事业','工作','收入','失业')
    '成本、价格与交换'=@('成本','价格','钱','感谢','消费','买卖')
    '企业、资本与利润'=@('资本','企业','股东','利润','合伙','盈利')
    '市场、分配与公共财富'=@('市场','分配','工资','就业','消费','全球化')
    '投资、风险与信用'=@('投资','风险','信用','收入','烂尾','资产')
    '慈善、救济与赠与'=@('慈善','捐','公益','善','感谢','出力')
}
$claimTailCuts=@{
    1727='作者的“善良会计学”是价值模型和比喻.*$'
    556='文中的法律、财务和政治行动设想.*$'
}

$corpus=[Collections.Generic.List[object]]::new();foreach($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($CorpusPath))){if(-not[string]::IsNullOrWhiteSpace($line)){$corpus.Add(($line|ConvertFrom-Json))}}
if($corpus.Count-ne4050){throw "Expected 4050 corpus articles, found $($corpus.Count)."}
$evidenceById=@{};foreach($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($EvidencePath))){if([string]::IsNullOrWhiteSpace($line)){continue};$e=$line|ConvertFrom-Json;$evidenceById[[string]$e.id]=$e}
$screened=@{};foreach($row in Import-Csv ([IO.Path]::GetFullPath($ScreeningPath))){$screened[[string]$row.id]=$true}

function Get-ExactQuote([string]$Text,[string]$Registered,[string[]]$Terms){
    foreach($part in ($Registered -split '；')){
        $q=$part.Trim().TrimStart('-',' ','“','"').TrimEnd('”','"','。','；',' ')
        if($q.Length-ge8-and$q.Length-le180-and$Text.Contains($q,[StringComparison]::Ordinal)){return $q}
    }
    $sentences=[regex]::Split($Text,'(?<=[。！？])|\r?\n')|ForEach-Object{$_.Trim()}|Where-Object{$_.Length-ge12}
    foreach($s in $sentences){if(@($Terms|Where-Object{$s.Contains($_,[StringComparison]::OrdinalIgnoreCase)}).Count-gt0){return $(if($s.Length-gt180){$s.Substring(0,180)}else{$s})}}
    $fallback=@($sentences|Select-Object -First 1)[0];if($fallback.Length-gt180){return $fallback.Substring(0,180)};return $fallback
}

$rows=[Collections.Generic.List[object]]::new();$n=0
foreach($entry in $sections.GetEnumerator()){
    foreach($ordinal in $entry.Value){
        $n++;$article=$corpus[[int]$ordinal-1];$e=$evidenceById[[string]$article.id]
        if(-not$screened.ContainsKey([string]$article.id)){throw "Ordinal $ordinal is not in wealth screening."}
        $quote=Get-ExactQuote ([string]$article.text) ([string]$e.sourceQuotes) $sectionTerms[$entry.Key]
        $quoteExact=([string]$article.text).Contains($quote,[StringComparison]::Ordinal);if(-not$quoteExact){throw "Exact quote failed for ordinal $ordinal."}
        $date=[DateTimeOffset]::FromUnixTimeMilliseconds([int64]$article.publishedAt).ToOffset([TimeSpan]::FromHours(8)).ToString('yyyy-MM-dd')
        $claim=[string]$e.thesis;if($claimTailCuts.ContainsKey([int]$ordinal)){$claim=($claim-replace$claimTailCuts[[int]$ordinal],'').Trim()}
        $rows.Add([pscustomobject][ordered]@{evidenceId=('E{0:d2}'-f$n);section=$entry.Key;claim=$claim;evidenceNature='作者在该文中的明示判断及论证';boundary='仅作为该篇文本中的判断、条件和推理使用；跨文关系另行标记为研究重建。';ordinal=[int]$ordinal;id=[string]$article.id;date=$date;title=[string]$article.title;url=[string]$article.url;quote=$quote;quoteExact=$quoteExact;sourceLayer='screened'})
    }
}
$rows|Export-Csv -LiteralPath ([IO.Path]::GetFullPath($OutputPath)) -NoTypeInformation -Encoding utf8BOM
$sectionCounts=[ordered]@{};foreach($name in $sections.Keys){$sectionCounts[$name]=@($rows|Where-Object section -eq $name).Count}
$uniqueIds=@($rows.id|Sort-Object -Unique).Count;$uniqueOrdinals=@($rows.ordinal|Sort-Object -Unique).Count;$missing=@($rows|Where-Object{[string]::IsNullOrWhiteSpace($_.claim)-or[string]::IsNullOrWhiteSpace($_.quote)}).Count;$failures=@($rows|Where-Object quoteExact -ne $true).Count
$status=if($rows.Count-eq48-and$uniqueIds-eq48-and$uniqueOrdinals-eq48-and$missing-eq0-and$failures-eq0-and@($sectionCounts.Values|Where-Object{$_-ne6}).Count-eq0){'PASS'}else{'REVIEW'}
$stats=[ordered]@{corpusArticles=$corpus.Count;screenedCandidates=$screened.Count;evidenceRows=$rows.Count;uniqueArticleIds=$uniqueIds;uniqueOrdinals=$uniqueOrdinals;missingCoreFields=$missing;exactQuoteFailures=$failures;comparison='StringComparison.Ordinal';sectionCounts=$sectionCounts;status=$status}
$stats|ConvertTo-Json -Depth 5|Set-Content -LiteralPath ([IO.Path]::GetFullPath($StatsPath)) -Encoding utf8
$stats|ConvertTo-Json -Depth 5
if($status-ne'PASS'){throw "Wealth core evidence validation ended with status $status."}
