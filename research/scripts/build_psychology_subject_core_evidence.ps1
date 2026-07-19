param(
    [string]$CorpusPath = '.\sooon-q9adg-articles.jsonl',
    [string]$EvidencePath = '.\research\data\author_view_evidence_clean.jsonl',
    [string]$ScreeningPath = '.\research\data\psychology_subject_screening.csv',
    [string]$QuoteValidationPath = '.\research\data\source_quote_validation_all.csv',
    [string]$OutputPath = '.\research\data\psychology_subject_core_evidence.csv',
    [string]$StatsPath = '.\research\data\psychology_subject_core_evidence.stats.json'
)

$ErrorActionPreference='Stop'
$sections=[ordered]@{
    '人格主体、自我与边界'=@(3385,4020,492,743,1582,3904)
    '情绪、感受与价值解释'=@(26,3165,525,937,1982,2723)
    '焦虑、恐惧与风险管理'=@(1969,4032,4035,3456,230,2570)
    '抑郁、绝望与意义重建'=@(3723,3500,2138,1099,2494,175)
    '创伤、羞耻、愤怒与修复'=@(331,1932,3680,739,3444,369)
    '依赖、控制、自由与关系'=@(7,231,1565,42,1690,2761)
    '咨询、诊断与自我理解'=@(1885,3299,3903,1258,3231,122)
    '训练、习惯、行动与长期成长'=@(912,2911,381,354,181,1084)
}
$manualQuote=@{
    354='其实我们陷入的不是对“没有产出”的焦虑，而是对“没有惊人的产出”的焦虑。'
    369='父母对子女一定要杜绝“如果你做不到xxx，人生就完了”以及“张三这孩子xxx，这辈子算是完蛋了”这类有意无意的“末日谈话”。'
    1582='仅仅“十点没睡”还不算言而无信，要“十点没睡”和“违约处罚未兑现”加起来才算言而无信。'
}
$nature=[ordered]@{
    '人格主体、自我与边界'='作者对主体、自我评价、承诺或边界的明示定义与行动判断'
    '情绪、感受与价值解释'='作者对情绪功能、表达方式和价值解释的文本内模型'
    '焦虑、恐惧与风险管理'='作者对焦虑恐惧的成因、尺度和训练路径的判断'
    '抑郁、绝望与意义重建'='作者对抑郁绝望、希望和意义的解释及建议'
    '创伤、羞耻、愤怒与修复'='作者对受伤经验、自我判决和关系修复的论述'
    '依赖、控制、自由与关系'='作者对依赖、陪伴、控制、自由和关系承载力的判断'
    '咨询、诊断与自我理解'='作者对咨询、诊断、专业关系和自我认识的文本内主张'
    '训练、习惯、行动与长期成长'='作者把主体改变落实为行动、记录、训练和长期积累的方案'
}
$boundary=[ordered]@{
    '人格主体、自我与边界'='只记录作者对主体、人格和边界的定义及推理，不将其扩写成外部心理学定论。'
    '情绪、感受与价值解释'='只重建作者如何解释情绪及其行动含义，不加入研究者对情绪是否健康的裁决。'
    '焦虑、恐惧与风险管理'='焦虑恐惧的成因、功能和训练效果均按作者判断记录。'
    '抑郁、绝望与意义重建'='抑郁、绝望、自杀和意义判断均按原文立场记录，不改写为外部诊断或治疗意见。'
    '创伤、羞耻、愤怒与修复'='文章对受伤、责任和修复的归因仅作为作者主张，不由研究者补充价值裁决。'
    '依赖、控制、自由与关系'='关系责任、依赖和控制边界按作者文本重建，不另加模型侧规范。'
    '咨询、诊断与自我理解'='咨询和诊断相关表述保留作者自己的职业伦理判断，不替作者作医学或心理学裁判。'
    '训练、习惯、行动与长期成长'='行动效果和成长路径均为作者提出的实践方案，研究层只负责定位。'
}

$corpus=[Collections.Generic.List[object]]::new();foreach($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($CorpusPath))){if($line){$corpus.Add(($line|ConvertFrom-Json))}}
if($corpus.Count-ne4050){throw "Expected 4050 corpus articles, found $($corpus.Count)."}
$evidence=@{};foreach($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($EvidencePath))){if($line){$o=$line|ConvertFrom-Json;$evidence[[int]$o.ordinal]=$o}}
$screened=@{};foreach($row in Import-Csv -LiteralPath ([IO.Path]::GetFullPath($ScreeningPath))){$screened[[int]$row.ordinal]=$true}
$exactQuotes=@{};foreach($row in Import-Csv -LiteralPath ([IO.Path]::GetFullPath($QuoteValidationPath))){if($row.matchType-ne'exact'){continue};$ordinal=[int]$row.ordinal;if(!$exactQuotes.ContainsKey($ordinal)){$exactQuotes[$ordinal]=[Collections.Generic.List[string]]::new()};if(!$exactQuotes[$ordinal].Contains([string]$row.quote)){[void]$exactQuotes[$ordinal].Add([string]$row.quote)}}

$rows=[Collections.Generic.List[object]]::new();$index=0
foreach($entry in $sections.GetEnumerator()){
    $section=[string]$entry.Key
    foreach($ordinal in $entry.Value){
        $index++;if(!$screened.ContainsKey([int]$ordinal)){throw "Ordinal $ordinal is not screened."};$article=$corpus[[int]$ordinal-1];$ev=$evidence[[int]$ordinal]
        $quote=if($manualQuote.ContainsKey([int]$ordinal)){[string]$manualQuote[[int]$ordinal]}elseif($exactQuotes.ContainsKey([int]$ordinal)-and$exactQuotes[[int]$ordinal].Count-gt0){[string]$exactQuotes[[int]$ordinal][0]}else{throw "No strict exact quote for ordinal $ordinal."}
        $quoteOk=([string]$article.text).Contains($quote,[StringComparison]::Ordinal);if(!$quoteOk){throw "Quote failed Ordinal at $ordinal."}
        $rows.Add([pscustomobject][ordered]@{evidenceId=('PS{0:D2}'-f$index);section=$section;claim=[string]$ev.thesis;authorActionAndEthicalJudgments=[string]$ev.authorActionAndEthicalJudgments;evidenceNature=[string]$nature[$section];boundary=[string]$boundary[$section];ordinal=[int]$ordinal;id=[string]$article.id;date=[DateTimeOffset]::FromUnixTimeMilliseconds([int64]$article.publishedAt).ToOffset([TimeSpan]::FromHours(8)).ToString('yyyy-MM-dd');title=[string]$article.title;url=[string]$article.url;quote=$quote;quoteExact=$quoteOk;sourceLayer='screened'})
    }
}
$rows|Export-Csv -LiteralPath ([IO.Path]::GetFullPath($OutputPath)) -NoTypeInformation -Encoding utf8BOM
$sectionCounts=[ordered]@{};foreach($s in $sections.Keys){$sectionCounts[$s]=@($rows|Where-Object{$_.section-eq$s}).Count}
$stats=[ordered]@{corpusArticles=$corpus.Count;screenedCandidates=$screened.Count;evidenceRows=$rows.Count;uniqueEvidenceIds=@($rows.evidenceId|Sort-Object -Unique).Count;uniqueArticleIds=@($rows.id|Sort-Object -Unique).Count;uniqueOrdinals=@($rows.ordinal|Sort-Object -Unique).Count;exactQuoteFailures=@($rows|Where-Object{-not$_.quoteExact}).Count;sectionCounts=$sectionCounts;status=if($rows.Count-eq48-and@($rows.id|Sort-Object -Unique).Count-eq48-and@($rows|Where-Object{-not$_.quoteExact}).Count-eq0-and@($sections.Keys|Where-Object{$sectionCounts[$_]-ne6}).Count-eq0){'PASS'}else{'REVIEW'}}
$stats|ConvertTo-Json -Depth 5|Set-Content -LiteralPath ([IO.Path]::GetFullPath($StatsPath)) -Encoding utf8;$stats|ConvertTo-Json -Depth 5
if($stats.status-ne'PASS'){throw "Psychology/subject core evidence validation ended with status $($stats.status)."}
