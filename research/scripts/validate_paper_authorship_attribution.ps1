param(
    [string]$PaperDir = (Join-Path $PSScriptRoot '..\papers'),
    [string]$OutputPath = (Join-Path $PSScriptRoot '..\data\paper_authorship_attribution_audit.csv')
)

$ErrorActionPreference = 'Stop'
$patterns = [ordered]@{
    researcherStance = '本文(?:主张|建议|认为|赞同|反对|批判)|本研究(?:主张|建议|认为)|我们认为|笔者认为|研究者认为'
    aiStance = 'AI判断|模型判断|外部框架纠正|AI(?:主张|建议|认为|赞同|反对)'
}

$violations = [Collections.Generic.List[object]]::new()
$papers = @(Get-ChildItem -LiteralPath $PaperDir -Filter '*.md' -File | Sort-Object Name)
foreach ($paper in $papers) {
    $lineNumber = 0
    foreach ($line in Get-Content -LiteralPath $paper.FullName) {
        $lineNumber++
        foreach ($patternName in $patterns.Keys) {
            foreach ($match in [regex]::Matches($line, $patterns[$patternName])) {
                [void]$violations.Add([pscustomobject][ordered]@{
                    paper = $paper.Name
                    line = $lineNumber
                    pattern = $patternName
                    match = $match.Value
                    context = $line.Trim()
                })
            }
        }
    }
}

New-Item -ItemType Directory -Path (Split-Path -Parent ([IO.Path]::GetFullPath($OutputPath))) -Force | Out-Null
@($violations) | Export-Csv -LiteralPath $OutputPath -NoTypeInformation -Encoding utf8BOM
$stats = [ordered]@{
    generatedAt = (Get-Date).ToString('o')
    paperCount = $papers.Count
    violationCount = $violations.Count
    status = if ($papers.Count -eq 34 -and $violations.Count -eq 0) { 'PASS' } else { 'REVIEW' }
}
$stats | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath ([IO.Path]::ChangeExtension([IO.Path]::GetFullPath($OutputPath), '.stats.json')) -Encoding utf8
$stats | ConvertTo-Json -Depth 4
