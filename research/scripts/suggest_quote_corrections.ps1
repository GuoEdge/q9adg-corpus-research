param(
    [string]$AuditPath = (Join-Path $PSScriptRoot '..\data\claim_support_audit_500.csv'),
    [string]$FailurePath = (Join-Path $PSScriptRoot '..\data\source_quote_validation_failures.csv'),
    [string]$CorpusPath = (Join-Path $PSScriptRoot '..\..\sooon-q9adg-articles.jsonl'),
    [string]$OutputPath = (Join-Path $PSScriptRoot '..\data\quote_correction_candidates_500.csv'),
    [switch]$AllFailures
)
$ErrorActionPreference='Stop'
function Norm([string]$s){if($null-eq$s){return''};return($s-replace'[\s\p{P}\p{S}]','')}
function Grams([string]$s){$n=Norm $s;$g=[Collections.Generic.HashSet[string]]::new();for($i=0;$i-lt$n.Length-1;$i++){[void]$g.Add($n.Substring($i,2))};return $g}
function Score([string]$quote,[string]$sentence){$q=Grams $quote;if($q.Count-eq0){return 0};$s=Grams $sentence;$hit=0;foreach($x in $q){if($s.Contains($x)){$hit++}};return [math]::Round(([double]$hit/[double]$q.Count),4)}
$failures=@(Import-Csv $FailurePath);$riskIds=@{};if($AllFailures){foreach($f in $failures){$riskIds[$f.id]=0}}else{foreach($a in Import-Csv $AuditPath){if($a.quoteStatus-eq'MISSING'){$riskIds[$a.id]=[int]$a.queueIndex}}}
$raw=@{};foreach($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($CorpusPath))){if($line){$o=$line|ConvertFrom-Json;$raw[$o.id]=$o}}
$rows=foreach($f in $failures){if(!$riskIds.ContainsKey($f.id)){continue};$o=$raw[$f.id];$sentences=@([regex]::Split([string]$o.text,'\r?\n|(?<=[。！？；])')|?{(Norm $_).Length-ge4});$best='';$bestScore=-1;foreach($s in $sentences){$score=Score $f.quote $s;if($score-gt$bestScore){$bestScore=$score;$best=$s.Trim()}};[pscustomobject]@{queueIndex=$riskIds[$f.id];ordinal=$f.ordinal;id=$f.id;title=$f.title;unlocatedQuote=$f.quote;suggestedRawSentence=$best;similarity=$bestScore;decision='UNREVIEWED';reviewNote=''}}
$rows|Sort-Object queueIndex,@{Expression='similarity';Descending=$true}|Export-Csv ([IO.Path]::GetFullPath($OutputPath)) -NoTypeInformation -Encoding UTF8
$expected=if($AllFailures){@($failures|Select-Object -ExpandProperty id -Unique).Count}else{21};$stats=[ordered]@{riskArticleCount=$riskIds.Count;candidateCount=$rows.Count;highSimilarity=@($rows|?{[double]$_.similarity-ge0.8}).Count;mediumSimilarity=@($rows|?{[double]$_.similarity-ge0.5-and[double]$_.similarity-lt0.8}).Count;lowSimilarity=@($rows|?{[double]$_.similarity-lt0.5}).Count;status=if($riskIds.Count-eq$expected){'PASS'}else{'REVIEW'}};$stats|ConvertTo-Json|Set-Content ([IO.Path]::ChangeExtension([IO.Path]::GetFullPath($OutputPath),'.stats.json')) -Encoding UTF8;$stats|ConvertTo-Json
