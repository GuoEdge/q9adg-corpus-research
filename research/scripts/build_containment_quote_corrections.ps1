param(
    [string]$CandidatePath = (Join-Path $PSScriptRoot '..\data\quote_correction_candidates_all.csv'),
    [string]$OutputPath = (Join-Path $PSScriptRoot '..\review\quote-corrections-consolidated.csv')
)
$ErrorActionPreference='Stop'
function Norm([string]$s){if($null-eq$s){return''};return($s-replace'[\s\p{P}\p{S}]','')}
$rows=@(Import-Csv $CandidatePath|ForEach-Object{$inside=(Norm $_.suggestedRawSentence).Contains((Norm $_.unlocatedQuote));[pscustomobject]@{ordinal=$_.ordinal;id=$_.id;title=$_.title;originalUnlocatedQuote=$_.unlocatedQuote;verifiedRawSentence=if($inside){$_.suggestedRawSentence}else{''};similarity=$_.similarity;decision=if($inside){'ACCEPTED_MECHANICAL_CONTAINMENT'}else{'UNRESOLVED'};reviewNote=if($inside){'After punctuation normalization the complete candidate is a contiguous substring of this raw sentence.'}else{'Candidate is combined, paraphrased, or not contained in one raw sentence.'}}})
$rows|Export-Csv ([IO.Path]::GetFullPath($OutputPath)) -NoTypeInformation -Encoding UTF8
[pscustomobject]@{candidateCount=$rows.Count;acceptedCount=@($rows|?{$_.decision-eq'ACCEPTED_MECHANICAL_CONTAINMENT'}).Count;unresolvedCount=@($rows|?{$_.decision-eq'UNRESOLVED'}).Count;status=if($rows.Count-eq152){'PASS'}else{'REVIEW'}}|ConvertTo-Json
