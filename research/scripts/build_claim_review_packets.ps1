param(
    [string]$QueuePath = (Join-Path $PSScriptRoot '..\data\claim_review_queue.csv'),
    [string]$CorpusPath = (Join-Path $PSScriptRoot '..\..\sooon-q9adg-articles.jsonl'),
    [string]$EvidencePath = (Join-Path $PSScriptRoot '..\data\author_view_evidence.jsonl'),
    [string]$OutputDir = (Join-Path $PSScriptRoot '..\review\claim-packets'),
    [int]$PacketSize = 100
)
$ErrorActionPreference='Stop';New-Item -ItemType Directory -Force -Path $OutputDir|Out-Null
$raw=@{};foreach($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($CorpusPath))){if($line){$o=$line|ConvertFrom-Json;$raw[$o.id]=$o}}
$ev=@{};foreach($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($EvidencePath))){if($line){$o=$line|ConvertFrom-Json;$ev[$o.id]=$o}}
$queue=@(Import-Csv -LiteralPath $QueuePath);$packet=0
for($start=0;$start -lt $queue.Count;$start+=$PacketSize){$packet++;$end=[math]::Min($start+$PacketSize,$queue.Count);$path=Join-Path $OutputDir ('claim-review-{0:D2}-{1:D4}-{2:D4}.jsonl' -f $packet,($start+1),$end);$w=[IO.StreamWriter]::new([IO.Path]::GetFullPath($path),$false,[Text.UTF8Encoding]::new($false));try{for($i=$start;$i -lt $end;$i++){$q=$queue[$i];$e=$ev[$q.id];$r=$raw[$q.id];$record=[ordered]@{queueIndex=$i+1;ordinal=[int]$e.ordinal;id=$e.id;title=$e.title;date=$e.date;url=$e.url;rawText=$r.text;thesis=$e.thesis;reasoning=$e.reasoning;conceptsInArticle=$e.conceptsInArticle;actionJudgment=$e.authorActionAndEthicalJudgments;sourceQuotes=$e.sourceQuotes;faithfulSummary=$e.faithfulSummary;reviewSchema=[ordered]@{thesisSupport='PASS|PARTIAL|FAIL';reasoningSupport='PASS|PARTIAL|FAIL';actionSupport='PASS|PARTIAL|FAIL';quoteSupport='PASS|PARTIAL|FAIL|NO_RAW';researcherJudgmentLeak='NONE|PRESENT';reviewNote=''}};$w.WriteLine(($record|ConvertTo-Json -Compress -Depth 8))}}finally{$w.Dispose()}}
[pscustomobject]@{queueCount=$queue.Count;packetCount=$packet;packetSize=$PacketSize;status=if($queue.Count -eq 500 -and $packet -eq 5){'PASS'}else{'REVIEW'}}|ConvertTo-Json
