param(
    [string]$PaperDir = (Join-Path $PSScriptRoot '..\papers'),
    [string]$OutputPath = (Join-Path $PSScriptRoot '..\review\cross-paper-duplicate-paragraphs.csv'),
    [int]$MinimumLength = 100
)

$ErrorActionPreference = 'Stop'
$items = [Collections.Generic.List[object]]::new()
foreach ($file in Get-ChildItem -LiteralPath $PaperDir -File -Filter '*.md') {
    $paragraphs = @(
        [regex]::Split([IO.File]::ReadAllText($file.FullName),'\r?\n\s*\r?\n') |
            ForEach-Object { $_.Trim() } |
            Where-Object { $_.Length -ge $MinimumLength -and $_ -notmatch '^\|' }
    )
    foreach ($paragraph in $paragraphs) {
        $items.Add([pscustomobject]@{ paper=$file.Name; text=$paragraph; chars=$paragraph.Length })
    }
}

$duplicates = @(
    $items | Group-Object text | Where-Object {
        $_.Count -gt 1 -and @($_.Group.paper | Sort-Object -Unique).Count -gt 1
    }
)
$rows = foreach ($group in $duplicates) {
    [pscustomobject]@{
        occurrenceCount = $group.Count
        paperCount = @($group.Group.paper | Sort-Object -Unique).Count
        papers = (@($group.Group.paper | Sort-Object -Unique) -join ';')
        chars = $group.Name.Length
        paragraph = $group.Name
    }
}
New-Item -ItemType Directory -Force -Path (Split-Path -Parent ([IO.Path]::GetFullPath($OutputPath))) | Out-Null
$rows | Export-Csv -LiteralPath $OutputPath -NoTypeInformation -Encoding UTF8
[ordered]@{
    paperCount = (Get-ChildItem -LiteralPath $PaperDir -File -Filter '*.md').Count
    checkedParagraphCount = $items.Count
    minimumLength = $MinimumLength
    crossPaperDuplicateGroups = $duplicates.Count
    status = if ($duplicates.Count -eq 0) { 'PASS' } else { 'REVIEW' }
} | ConvertTo-Json

