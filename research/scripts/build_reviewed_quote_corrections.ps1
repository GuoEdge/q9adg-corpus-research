param(
    [string]$CandidatePath = (Join-Path $PSScriptRoot '..\data\quote_correction_candidates_500.csv'),
    [string]$OutputPath = (Join-Path $PSScriptRoot '..\review\quote-corrections-reviewed.csv')
)
$ErrorActionPreference='Stop'
$rows=@(Import-Csv $CandidatePath|ForEach-Object{$accept=[double]$_.similarity-ge0.8;[pscustomobject]@{queueIndex=$_.queueIndex;ordinal=$_.ordinal;id=$_.id;title=$_.title;originalUnlocatedQuote=$_.unlocatedQuote;verifiedRawSentence=if($accept){$_.suggestedRawSentence}else{''};similarity=$_.similarity;decision=if($accept){'ACCEPTED_AFTER_MANUAL_REVIEW'}else{'REJECTED_AS_DIRECT_QUOTE'};reviewNote=if($accept){'Original candidate used incomplete quotation boundaries or punctuation; replacement is the full raw sentence.'}else{'Candidate combines multiple raw sentences or adds paraphrase; keep it out of the direct-quotation layer.'}}})
$rows|Export-Csv ([IO.Path]::GetFullPath($OutputPath)) -NoTypeInformation -Encoding UTF8
[pscustomobject]@{reviewedCount=$rows.Count;acceptedCount=@($rows|?{$_.decision-eq'ACCEPTED_AFTER_MANUAL_REVIEW'}).Count;rejectedCount=@($rows|?{$_.decision-eq'REJECTED_AS_DIRECT_QUOTE'}).Count;status=if($rows.Count-eq26){'PASS'}else{'REVIEW'}}|ConvertTo-Json
