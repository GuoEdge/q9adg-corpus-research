param(
    [string]$CorpusPath = (Join-Path $PSScriptRoot '..\..\sooon-q9adg-articles.jsonl'),
    [string]$PaperDir = (Join-Path $PSScriptRoot '..\papers'),
    [string]$OutputPath = (Join-Path $PSScriptRoot '..\review\paper-direct-quote-role-audit.csv'),
    [string]$StatsPath = (Join-Path $PSScriptRoot '..\review\paper-direct-quote-role-audit.stats.json'),
    [int]$MinimumLength = 4
)

$ErrorActionPreference = 'Stop'

function Get-LexicalNodeText {
    param([object]$Node)
    $builder = [Text.StringBuilder]::new()
    $stack = [Collections.Generic.Stack[object]]::new()
    $stack.Push($Node)
    while ($stack.Count -gt 0) {
        $current = $stack.Pop()
        $textProperty = $current.psobject.Properties['text']
        if ($null -ne $textProperty -and $null -ne $textProperty.Value) {
            [void]$builder.Append([string]$textProperty.Value)
        }
        $childrenProperty = $current.psobject.Properties['children']
        if ($null -eq $childrenProperty -or $null -eq $childrenProperty.Value) { continue }
        $children = @($childrenProperty.Value)
        for ($i = $children.Count - 1; $i -ge 0; $i--) {
            $stack.Push($children[$i])
        }
    }
    return $builder.ToString()
}

$uuidPattern = '(?i)\b[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\b'
$paperRecords = [Collections.Generic.List[object]]::new()
$allCitedIds = [Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
foreach ($paper in Get-ChildItem -LiteralPath $PaperDir -Filter '*.md' -File | Sort-Object Name) {
    $text = [IO.File]::ReadAllText($paper.FullName)
    $ids = @(
        [regex]::Matches($text,$uuidPattern) |
            ForEach-Object { $_.Value.ToLowerInvariant() } |
            Sort-Object -Unique
    )
    foreach ($id in $ids) { [void]$allCitedIds.Add($id) }
    [void]$paperRecords.Add([pscustomobject]@{ paper = $paper; text = $text; ids = $ids })
}

$corpus = [Collections.Generic.List[object]]::new()
$byId = @{}
foreach ($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($CorpusPath))) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $row = $line | ConvertFrom-Json
    $rowId = ([string]$row.id).ToLowerInvariant()
    if (-not $allCitedIds.Contains($rowId)) { continue }
    $quotedParts = [Collections.Generic.List[string]]::new()
    $authorParts = [Collections.Generic.List[string]]::new()
    if (-not [string]::IsNullOrWhiteSpace([string]$row.lexical)) {
        $lexical = [string]$row.lexical | ConvertFrom-Json
        foreach ($node in @($lexical.root.children)) {
            $nodeText = Get-LexicalNodeText -Node $node
            if ([string]$node.type -eq 'quote') {
                [void]$quotedParts.Add($nodeText)
            }
            else {
                [void]$authorParts.Add($nodeText)
            }
        }
    }
    $record = [pscustomobject]@{
        id = $rowId
        url = ([string]$row.url).TrimEnd(')')
        authorText = $authorParts -join "`n"
        quotedText = $quotedParts -join "`n"
    }
    [void]$corpus.Add($record)
    $byId[$record.id] = $record
}

$quotePattern = '(?:\u201c(?<quote>[^\u201d\r\n]{' + $MinimumLength + ',})\u201d|\u2018(?<quote>[^\u2019\r\n]{' + $MinimumLength + ',})\u2019)'
$audit = [Collections.Generic.List[object]]::new()

foreach ($paperRecord in $paperRecords) {
    $paper = $paperRecord.paper
    $text = $paperRecord.text
    $ids = $paperRecord.ids
    $cited = [Collections.Generic.List[object]]::new()
    foreach ($id in $ids) {
        if ($byId.ContainsKey($id)) { [void]$cited.Add($byId[$id]) }
    }
    $quotes = @(
        [regex]::Matches($text,$quotePattern) |
            ForEach-Object { $_.Groups['quote'].Value } |
            Sort-Object -Unique
    )
    foreach ($quote in $quotes) {
        $authorHits = @($cited | Where-Object { $_.authorText.Contains($quote,[StringComparison]::Ordinal) })
        $quotedHits = @($cited | Where-Object { $_.quotedText.Contains($quote,[StringComparison]::Ordinal) })
        $status = if ($authorHits.Count -gt 0) {
            'PASS'
        }
        elseif ($quotedHits.Count -gt 0) {
            'QUOTED_BLOCK_ONLY'
        }
        else {
            'NOT_FOUND'
        }
        [void]$audit.Add([pscustomobject][ordered]@{
            paper = $paper.Name
            quote = $quote
            authorHitIds = ($authorHits.id -join ';')
            quotedBlockHitIds = ($quotedHits.id -join ';')
            status = $status
        })
    }
}

New-Item -ItemType Directory -Force -Path (Split-Path -Parent ([IO.Path]::GetFullPath($OutputPath))) | Out-Null
$audit | Export-Csv -LiteralPath $OutputPath -NoTypeInformation -Encoding utf8BOM
$quotedOnly = @($audit | Where-Object status -eq 'QUOTED_BLOCK_ONLY')
$notFound = @($audit | Where-Object status -eq 'NOT_FOUND')
$stats = [ordered]@{
    paperCount = $paperRecords.Count
    directQuoteCount = $audit.Count
    authorTextPassCount = @($audit | Where-Object status -eq 'PASS').Count
    quotedBlockOnlyCount = $quotedOnly.Count
    notFoundCount = $notFound.Count
    status = if ($quotedOnly.Count -eq 0 -and $notFound.Count -eq 0) { 'PASS' } else { 'REVIEW' }
}
$stats | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $StatsPath -Encoding utf8
$stats | ConvertTo-Json -Depth 4
