param(
    [string]$PaperDir = (Join-Path $PSScriptRoot '..\papers'),
    [string]$OutputPath = (Join-Path $PSScriptRoot '..\data\paper_inventory.csv')
)

$ErrorActionPreference = 'Stop'
$uuidPattern = '(?i)\b[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\b'
$papers = @(Get-ChildItem -LiteralPath $PaperDir -Filter '*.md' -File | Sort-Object Name)
$rows = @(
    foreach ($paper in $papers) {
        $text = [IO.File]::ReadAllText($paper.FullName, [Text.Encoding]::UTF8)
        $uuidCitations = @(
            [regex]::Matches($text, $uuidPattern) |
                ForEach-Object { $_.Value.ToLowerInvariant() } |
                Sort-Object -Unique
        )
        [pscustomobject][ordered]@{
            paper = $paper.Name
            bytes = $paper.Length
            chineseChars = [regex]::Matches($text, '[\p{IsCJKUnifiedIdeographs}]').Count
            nonWhitespaceChars = [regex]::Replace($text, '\s', '').Length
            headings = [regex]::Matches($text, '(?m)^#{1,6}\s+').Count
            uuidCitations = $uuidCitations.Count
        }
    }
)

New-Item -ItemType Directory -Path (Split-Path -Parent ([IO.Path]::GetFullPath($OutputPath))) -Force | Out-Null
$rows | Export-Csv -LiteralPath $OutputPath -NoTypeInformation -Encoding utf8BOM
$stats = [ordered]@{
    generatedAt = (Get-Date).ToString('o')
    paperCount = $rows.Count
    chineseChars = ($rows | Measure-Object chineseChars -Sum).Sum
    nonWhitespaceChars = ($rows | Measure-Object nonWhitespaceChars -Sum).Sum
    headingCount = ($rows | Measure-Object headings -Sum).Sum
    uuidCitationTotal = ($rows | Measure-Object uuidCitations -Sum).Sum
    status = if ($rows.Count -eq 34) { 'PASS' } else { 'REVIEW' }
}
$stats | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath ([IO.Path]::ChangeExtension([IO.Path]::GetFullPath($OutputPath), '.stats.json')) -Encoding utf8
$stats | ConvertTo-Json -Depth 4
