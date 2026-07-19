param(
    [string]$BatchPath='.\research\review\claim-review-batches\claim-review-wave3-C.jsonl',
    [string]$PrecheckPath='.\research\review\claim-review-batches\claim-review-wave3-C-precheck.csv',
    [string]$ResultPath='.\research\review\claim-review-results-wave3-C-strict.csv',
    [string]$SuggestionPath='.\research\review\claim-review-wave3-C-strict-clean-suggestions.csv',
    [string]$ReplacementPath='.\research\review\claim-review-wave3-C-strict-exact-replacements.csv'
)
$ErrorActionPreference='Stop'

$leakPattern='研究者|外部|核验|专业评估|律师意见|法律结论|普遍规则|制度化申诉|权力不对等|程序正义|权利救济|儿童安全|个体差异|医疗安全|责任归属|操作资质|事实认定|未覆盖其他|未处理|没有详细处理|没有充分讨论|没有调查材料|没有提供|没有展开|没有讨论|没有明确讨论|没有具体讨论|未作展开|未作诊断|未具体说明|并未说明|不能替代|不能据此|不能当作|不能从文本|不构成|只来自本文|只给出作者|文本内主张|文本内的|强断言|绝对化|带有明显|明显的作者式|主要仍是建立在|属于本文立场|未经验证|未经事实|证据规则|程序边界|现实约束|现实家庭评价|发展阶段|交通安全|亲子协商|情绪照护|教育效果|完整立场'
$forcedKeep=@{
    '1565:thesis'=$true;'3537:thesis'=$true;'1616:thesis'=$true;'1616:reasoning'=$true;'1451:thesis'=$true;'934:reasoning'=$true
    '178:thesis'=$true;'178:reasoning'=$true;'178:authorActionAndEthicalJudgments'=$true;'178:faithfulSummary'=$true
}
$manualReplacement=@{
    '715:faithfulSummary'='本文把持续辱骂的应对方式从言语反击改写为平静撤离和后果管理：先离开、照顾自己、减少家庭运转，再让丈夫承担其未处理母子关系的成本；若对方不承担，便准备继续离开和结束婚姻。作者认为礼貌而明确的行动比脏话更有力量。'
    '707:faithfulSummary'='本文将“天人合一”重建为三步：从宇宙生成过程认识自身，以科学知识辨认规律边界，再依据历史风向行动。作者把成功状态比作顺流航行，认为顺应规律和潮流能减少无效用力并支撑乐观。'
    '1616:faithfulSummary'='作者认为，大学阶段的学习失能往往不是能力下降，而是高中时期依赖家长、排名和高考压力形成的应激性学习模式，在外部刺激消失后失去支撑。文章要求学习者以一个造福整个人类的宏大梦想重新建立长期动力，再用它安排具体学习策略。'
}

function Remove-Leak([string]$Text,[ref]$Changed){
    if([string]::IsNullOrWhiteSpace($Text)){return $Text}
    $parts=[regex]::Split($Text,'(?<=[。！？；])')
    $keep=[Collections.Generic.List[string]]::new()
    foreach($part in $parts){
        $p=$part.Trim();if(-not$p){continue}
        if($p-match$leakPattern){$Changed.Value=$true;continue}
        [void]$keep.Add($p)
    }
    $value=($keep-join'').Trim()
    if(-not$value){$Changed.Value=$true}
    return $value
}

function Get-UniqueStart([string]$Text){
    $line=@($Text-split'\r?\n'|Where-Object{-not[string]::IsNullOrWhiteSpace($_)}|Select-Object -First 1)[0].Trim()
    if($line.Length-gt36){$line=$line.Substring(0,36)}
    $len=$line.Length
    while($len-lt$Text.Length-and$Text.IndexOf($line,[StringComparison]::Ordinal)-ne$Text.LastIndexOf($line,[StringComparison]::Ordinal)){$len=[Math]::Min($Text.Length,$len+8);$line=$Text.Substring(0,$len)}
    return $line
}

function Get-ExactQuotes([string]$Raw,[string]$Registered,[int]$Wanted){
    $out=[Collections.Generic.List[string]]::new()
    $chunks=@($Registered-split'；|\r?\n'|ForEach-Object{$_.Trim()}|Where-Object{$_-and$_-notmatch'^>$'})
    foreach($chunk0 in $chunks){
        $chunk=($chunk0-replace'^\s*>\s*','').Trim().TrimStart('-',' ','“','"').TrimEnd('”','"',' ')
        foreach($candidate in @($chunk,$chunk.TrimEnd('。','！','？','；'))|Sort-Object -Unique){
            if($candidate.Length-ge6-and$Raw.Contains($candidate,[StringComparison]::Ordinal)){if(-not$out.Contains($candidate)){[void]$out.Add($candidate)};break}
        }
        if($out.Count-ge$Wanted){break}
    }
    $sentences=@([regex]::Split($Raw,'(?<=[。！？])|\r?\n')|ForEach-Object{$_.Trim()}|Where-Object{$_.Length-ge8})
    foreach($chunk0 in $chunks){
        if($out.Count-ge$Wanted){break}
        $tokens=@([regex]::Matches($chunk0,'[\p{IsCJKUnifiedIdeographs}A-Za-z0-9]{4,}')|ForEach-Object{$_.Value}|Sort-Object Length -Descending)
        $hit=$null
        foreach($token in $tokens){$hit=$sentences|Where-Object{$_.Contains($token,[StringComparison]::Ordinal)}|Select-Object -First 1;if($hit){break}}
        if($hit){if($hit.Length-gt180){$pos=if($tokens.Count){$hit.IndexOf($tokens[0],[StringComparison]::Ordinal)}else{0};if($pos-lt0){$pos=0};$start=[Math]::Max(0,[Math]::Min($pos,$hit.Length-180));$hit=$hit.Substring($start,[Math]::Min(180,$hit.Length-$start))};if(-not$out.Contains($hit)){[void]$out.Add($hit)}}
    }
    foreach($s in $sentences){if($out.Count-ge$Wanted){break};$q=if($s.Length-gt180){$s.Substring(0,180)}else{$s};if(-not$out.Contains($q)){[void]$out.Add($q)}}
    return @($out|Select-Object -First ([Math]::Max(1,$Wanted)))
}

$batch=@(Get-Content -LiteralPath $BatchPath|Where-Object{$_}|ForEach-Object{$_|ConvertFrom-Json})
$pre=@{};foreach($p in Import-Csv -LiteralPath $PrecheckPath){$pre[[string]$p.ordinal]=$p}
$results=[Collections.Generic.List[object]]::new();$suggestions=[Collections.Generic.List[object]]::new();$replacements=[Collections.Generic.List[object]]::new()
$map=[ordered]@{thesis='thesis';reasoning='reasoning';authorActionAndEthicalJudgments='actionJudgment';faithfulSummary='faithfulSummary'}

foreach($row in $batch){
    $changedFields=[Collections.Generic.List[string]]::new()
    foreach($entry in $map.GetEnumerator()){
        $source=[string]$row.original.($entry.Value);$changed=$false;$cleaned=Remove-Leak $source ([ref]$changed);$key="$($row.ordinal):$($entry.Key)"
        if($forcedKeep.ContainsKey($key)){$changed=$false;$cleaned=$source}
        if($manualReplacement.ContainsKey($key)){$changed=$true;$cleaned=$manualReplacement[$key]}
        if($changed-and-not[string]::IsNullOrWhiteSpace($cleaned)){
            [void]$changedFields.Add($entry.Key)
            $suggestions.Add([pscustomobject][ordered]@{ordinal=[int]$row.ordinal;field=$entry.Key;startPhrase=(Get-UniqueStart $source);action='REPLACE_FIELD';reason='移除研究者追加的外部裁判、未展开事项或规范性修正，仅保留作者主张'})
            $replacements.Add([pscustomobject][ordered]@{ordinal=[int]$row.ordinal;field=$entry.Key;replacementText=$cleaned;reason='按rawText和原结构化论证重建为作者中心字段'})
        }
    }
    $pc=$pre[[string]$row.ordinal];$registered=[int]$pc.registeredQuoteCount;$exact=[int]$pc.exactQuoteCount
    $quoteSupport=if($exact-eq$registered){'EXACT'}else{'PARTIAL'}
    if($quoteSupport-ne'EXACT'){
        $replacementQuotes=@(Get-ExactQuotes ([string]$row.rawText) ([string]$row.original.sourceQuotes) ([Math]::Min(3,[Math]::Max(1,$registered))))
        foreach($q in $replacementQuotes){if(-not([string]$row.rawText).Contains($q,[StringComparison]::Ordinal)){throw "Ordinal quote validation failed for $($row.ordinal): $q"}}
        $suggestions.Add([pscustomobject][ordered]@{ordinal=[int]$row.ordinal;field='sourceQuotes';startPhrase=(Get-UniqueStart ([string]$row.original.sourceQuotes));action='REEXTRACT_QUOTES';reason="$exact/$registered 条登记短引逐字命中，重新抽取原文连续短句"})
        $replacements.Add([pscustomobject][ordered]@{ordinal=[int]$row.ordinal;field='sourceQuotes';replacementText=($replacementQuotes-join'；');reason='所有替换短引均通过StringComparison.Ordinal验证'})
    }
    $thesisSupport=if($changedFields-contains'thesis'){'PARTIAL'}else{'PASS'}
    $reasoningSupport=if($changedFields-contains'reasoning'){'PARTIAL'}else{'PASS'}
    $actionSupport=if($changedFields-contains'authorActionAndEthicalJudgments'){'PARTIAL'}else{'PASS'}
    $leak=if($changedFields.Count-gt0){'PRESENT'}else{'NONE'}
    $noteParts=[Collections.Generic.List[string]]::new();[void]$noteParts.Add("主旨$thesisSupport、推理$reasoningSupport、行动$actionSupport")
    if($leak-eq'PRESENT'){[void]$noteParts.Add('字段含研究者侧外部核验、缺口评论或规范修正，已给出作者中心替换')}else{[void]$noteParts.Add('结构化字段保持作者立场')}
    [void]$noteParts.Add("登记短引逐字命中 $exact/$registered")
    $results.Add([pscustomobject][ordered]@{queueIndex=[int]$row.queueIndex;ordinal=[int]$row.ordinal;title=[string]$row.title;thesisSupport=$thesisSupport;reasoningSupport=$reasoningSupport;actionSupport=$actionSupport;quoteSupport=$quoteSupport;researcherJudgmentLeak=$leak;reviewNote=($noteParts-join'；')})
}
$results|Export-Csv -LiteralPath $ResultPath -NoTypeInformation -Encoding utf8BOM
$suggestions|Export-Csv -LiteralPath $SuggestionPath -NoTypeInformation -Encoding utf8BOM
$replacements|Export-Csv -LiteralPath $ReplacementPath -NoTypeInformation -Encoding utf8BOM
[ordered]@{batchRows=$batch.Count;resultRows=$results.Count;suggestionRows=$suggestions.Count;replacementRows=$replacements.Count;leakRows=@($results|Where-Object researcherJudgmentLeak -eq 'PRESENT').Count;nonExactQuoteRows=@($results|Where-Object quoteSupport -ne 'EXACT').Count;status=if($batch.Count-eq58-and$results.Count-eq58){'PASS'}else{'REVIEW'}}|ConvertTo-Json
