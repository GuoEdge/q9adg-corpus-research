param(
    [string]$EvidencePath = (Join-Path $PSScriptRoot '..\data\author_view_evidence.jsonl'),
    [string]$OutputPath = (Join-Path $PSScriptRoot '..\data\author_claims.jsonl')
)

$ErrorActionPreference = 'Stop'
$full = [IO.Path]::GetFullPath($OutputPath)
New-Item -ItemType Directory -Force -Path ([IO.Path]::GetDirectoryName($full)) | Out-Null
$writer = [IO.StreamWriter]::new($full, $false, [Text.UTF8Encoding]::new($false))
$count = 0
try {
    foreach ($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($EvidencePath))) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        $o = $line | ConvertFrom-Json
        $claims = @(
            [pscustomobject]@{ type='articleThesis'; text=[string]$o.thesis },
            [pscustomobject]@{ type='authorActionAndEthicalJudgment'; text=[string]$o.authorActionAndEthicalJudgments },
            [pscustomobject]@{ type='faithfulSummary'; text=[string]$o.faithfulSummary }
        )
        foreach ($claim in $claims) {
            if ([string]::IsNullOrWhiteSpace($claim.text)) { continue }
            $record = [ordered]@{
                claimId = ('{0:D4}-{1}' -f [int]$o.ordinal,$claim.type)
                ordinal = [int]$o.ordinal
                id = [string]$o.id
                title = [string]$o.title
                date = [string]$o.date
                url = [string]$o.url
                claimType = $claim.type
                claimText = $claim.text.Trim()
                sourceReadingFile = [string]$o.sourceReadingFile
                evidencePolicy = 'Interpretive claim index; verify against the raw article before treating as a direct quotation or author-declared theory.'
            }
            $writer.WriteLine(($record | ConvertTo-Json -Compress -Depth 5))
            $count++
        }
    }
}
finally { $writer.Dispose() }
$stats = [ordered]@{ outputPath=$full; articleCount=4050; claimCount=$count; expectedClaimCount=12150; status=if($count -eq 12150){'PASS'}else{'REVIEW'} }
$stats | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath ([IO.Path]::ChangeExtension($full,'.stats.json')) -Encoding UTF8
$stats | ConvertTo-Json -Depth 4
