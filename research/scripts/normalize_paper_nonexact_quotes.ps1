param(
    [Parameter(Mandatory=$true)][string]$PaperPath,
    [string]$CorpusPath = (Join-Path $PSScriptRoot '..\..\sooon-q9adg-articles.jsonl'),
    [string]$ChangesPath = '',
    [int]$MinimumLength = 4
)

$ErrorActionPreference = 'Stop'
$fullPaperPath = [IO.Path]::GetFullPath($PaperPath)
$paperText = [IO.File]::ReadAllText($fullPaperPath)
$ids = @(
    [regex]::Matches($paperText,'(?i)\b[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\b') |
        ForEach-Object { $_.Value.ToLowerInvariant() } |
        Sort-Object -Unique
)

$raw = [Collections.Generic.List[object]]::new()
foreach ($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($CorpusPath))) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $row = $line | ConvertFrom-Json
    $idIsCited = $ids -contains ([string]$row.id).ToLowerInvariant()
    $urlIsCited = -not [string]::IsNullOrWhiteSpace([string]$row.url) -and
        $paperText.Contains([string]$row.url,[StringComparison]::Ordinal)
    if ($idIsCited -or $urlIsCited) { $raw.Add($row) }
}

$pattern = '(?:\u201c(?<quote>[^\u201d\r\n]{' + $MinimumLength + ',})\u201d|\u2018(?<quote>[^\u2019\r\n]{' + $MinimumLength + ',})\u2019)'
$quotes = @(
    [regex]::Matches($paperText,$pattern) |
        ForEach-Object { $_.Groups['quote'].Value } |
        Sort-Object -Unique
)
$changes = [Collections.Generic.List[object]]::new()
$newText = $paperText
foreach ($quote in $quotes) {
    $exact = @($raw | Where-Object { ([string]$_.text).Contains($quote,[StringComparison]::Ordinal) }).Count -gt 0
    if ($exact) { continue }
    $occurrences = 0
    $wrappedForms = @(
        ('{0}{1}{2}' -f [char]0x201c,$quote,[char]0x201d),
        ('{0}{1}{2}' -f [char]0x2018,$quote,[char]0x2019)
    )
    foreach ($wrapped in $wrappedForms) {
        $wrappedOccurrences = ([regex]::Matches($newText,[regex]::Escape($wrapped))).Count
        if ($wrappedOccurrences -eq 0) { continue }
        $newText = $newText.Replace($wrapped,$quote,[StringComparison]::Ordinal)
        $occurrences += $wrappedOccurrences
    }
    if ($occurrences -eq 0) { continue }
    $changes.Add([pscustomobject]@{
        paper = [IO.Path]::GetFileName($fullPaperPath)
        text = $quote
        occurrenceCount = $occurrences
        action = 'REMOVE_NONEXACT_QUOTE_MARKS'
        reason = 'Not an Ordinal substring of any source cited by ID or URL in this paper.'
    })
}

if ($newText -ne $paperText) {
    [IO.File]::WriteAllText($fullPaperPath,$newText,[Text.UTF8Encoding]::new($false))
}
if ([string]::IsNullOrWhiteSpace($ChangesPath)) {
    $safeName = [IO.Path]::GetFileNameWithoutExtension($fullPaperPath) -replace '[^\p{L}\p{Nd}_-]','_'
    $ChangesPath = Join-Path $PSScriptRoot "..\review\$safeName-nonexact-quote-normalization.csv"
}
New-Item -ItemType Directory -Force -Path (Split-Path -Parent ([IO.Path]::GetFullPath($ChangesPath))) | Out-Null
$changes | Export-Csv -LiteralPath $ChangesPath -NoTypeInformation -Encoding UTF8
[ordered]@{
    paper = $fullPaperPath
    citedSourceCount = $raw.Count
    nonExactQuotedStringsNormalized = $changes.Count
    occurrenceCount = [int](($changes | Measure-Object occurrenceCount -Sum).Sum)
    comparison = 'StringComparison.Ordinal'
    status = 'PASS'
} | ConvertTo-Json
