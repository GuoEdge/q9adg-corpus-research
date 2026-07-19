param(
    [string]$CorpusPath = (Join-Path $PSScriptRoot '..\..\sooon-q9adg-articles.jsonl'),
    [string]$ReadingDir = (Join-Path $PSScriptRoot '..\close-reading'),
    [string]$OutputPath = (Join-Path $PSScriptRoot '..\data\author_view_evidence.jsonl')
)

$ErrorActionPreference = 'Stop'

$corpus = [System.Collections.Generic.List[object]]::new()
$ordinal = 0
foreach ($line in [System.IO.File]::ReadLines([System.IO.Path]::GetFullPath($CorpusPath))) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $item = $line | ConvertFrom-Json
    $ordinal++
    $published = [DateTimeOffset]::FromUnixTimeMilliseconds([int64]$item.publishedAt).ToOffset([TimeSpan]::FromHours(8))
    $corpus.Add([pscustomobject][ordered]@{
        ordinal = $ordinal
        id = [string]$item.id
        title = [string]$item.title
        date = $published.ToString('yyyy-MM-dd')
        url = [string]$item.url
    })
}

$fieldPatterns = [ordered]@{
    date = '日期'
    id = 'ID'
    url = '原文\s*URL|原始\s*URL|原文|URL'
    questionContext = '问题语境|问题'
    thesis = '具体文章主旨|文章主旨'
    reasoning = '论证推进(?:（[^）]*）)?|2\s*[—-]\s*4\s*步论证推进|2\s*[—-]\s*4步论证推进'
    concepts = '本文概念用法|概念在本文中的用法(?:（[^）]*）)?|概念用法'
    actionAndEthics = '行动与伦理判断'
    rhetoric = '修辞与语气'
    quotes = '正文短引|关键短引(?:（[^）]*）)?|1\s*-\s*2处正文短引'
    faithfulSummary = '忠实概括'
}

$allLabelPattern = ($fieldPatterns.Values -join '|')
function Get-Field([string]$Section, [string]$Pattern, [string]$FieldName) {
    $separator = '(?:\*\*\s*[：:]|[：:]\s*\*\*|\*\*(?=\s*$)|[：:]|(?=\s*$))'
    $prefix = '(?:-\s+|#{1,6}\s*)?'
    $start = '^\s*' + $prefix + '(?:\*\*)?(?:' + $Pattern + ')' + $separator + '\s*'
    # Do not treat a repeated instance of the same label as a boundary. Some
    # close-readings retain an empty legacy label before the populated label.
    $otherLabels = @($fieldPatterns.GetEnumerator() | Where-Object { $_.Key -ne $FieldName } | ForEach-Object { $_.Value })
    $next = '^\s*' + $prefix + '(?:\*\*)?(?:' + (($otherLabels + @('限定与张力')) -join '|') + ')' + $separator + '\s*'
    $regex = '(?ms)' + $start + '(.*?)(?=' + $next + '|\z)'
    $match = [regex]::Match($Section, $regex)
    if (-not $match.Success) { return '' }
    $value = $match.Groups[1].Value.Trim()
    if ([string]::IsNullOrWhiteSpace($value)) {
        # Retry after an empty legacy label (notably ordinal 434's duplicated
        # "2-4步论证推进" marker).
        $offset = $match.Index + $match.Length
        if ($offset -lt $Section.Length) {
            $retry = [regex]::Match($Section.Substring($offset), $regex)
            if ($retry.Success -and -not [string]::IsNullOrWhiteSpace($retry.Groups[1].Value)) {
                return $retry.Groups[1].Value.Trim()
            }
        }
    }
    return $value
}

function Normalize-MarkdownValue([string]$Value) {
    if ($null -eq $Value) { return '' }
    $v = $Value.Trim()
    $v = [regex]::Replace($v, '^\s*`([^`]*)`\s*$', '$1')
    $v = [regex]::Replace($v, '^\s*\*\*(.*?)\*\*\s*$', '$1')
    $v = [regex]::Replace($v, '^\s*<([^>]+)>\s*$', '$1')
    $v = [regex]::Replace($v, '^\s*\[[^\]]*\]\((https?://[^)]+)\)\s*$', '$1')
    return $v.Trim()
}

function Normalize-Id([string]$Value) {
    $v = Normalize-MarkdownValue $Value
    $m = [regex]::Match($v, '[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}')
    if ($m.Success) { return $m.Value.ToLowerInvariant() }
    return $v.ToLowerInvariant()
}

function Normalize-Url([string]$Value) {
    return (Normalize-MarkdownValue $Value).TrimEnd('/')
}

$entries = @{}
$headingPattern = '(?m)^###\s+(\d{1,4})[｜|](.*)$'
foreach ($file in Get-ChildItem -LiteralPath $ReadingDir -Filter 'batch-*.md' -File | Sort-Object Name) {
    $content = Get-Content -LiteralPath $file.FullName -Raw -Encoding UTF8
    $matches = [regex]::Matches($content, $headingPattern)
    for ($i = 0; $i -lt $matches.Count; $i++) {
        $start = $matches[$i].Index
        $end = if ($i + 1 -lt $matches.Count) { $matches[$i + 1].Index } else { $content.Length }
        $section = $content.Substring($start, $end - $start)
        $number = [int]$matches[$i].Groups[1].Value
        $record = [ordered]@{
            sourceReadingFile = $file.Name
            headingTitle = $matches[$i].Groups[2].Value.Trim()
        }
        foreach ($field in $fieldPatterns.Keys) {
            $record[$field] = Get-Field $section $fieldPatterns[$field] $field
        }
        if ($entries.ContainsKey($number)) {
            throw "Duplicate close-reading ordinal $number in $($file.Name) and $($entries[$number].sourceReadingFile)."
        }
        $entries[$number] = $record
    }
}

$outputFull = [System.IO.Path]::GetFullPath($OutputPath)
New-Item -ItemType Directory -Path ([System.IO.Path]::GetDirectoryName($outputFull)) -Force | Out-Null
$writer = [System.IO.StreamWriter]::new($outputFull, $false, [System.Text.UTF8Encoding]::new($false))
try {
    $missingFields = [ordered]@{}
    foreach ($field in $fieldPatterns.Keys) { $missingFields[$field] = 0 }
    $wrongMetadata = [System.Collections.Generic.List[int]]::new()

    foreach ($meta in $corpus) {
        if (-not $entries.ContainsKey($meta.ordinal)) {
            throw "Missing close-reading ordinal $($meta.ordinal)."
        }
        $reading = $entries[$meta.ordinal]
        # Compare normalized presentation values; canonical output remains the
        # original corpus metadata above.
        $readingId = Normalize-Id $reading.id
        $readingDate = Normalize-MarkdownValue $reading.date
        $readingTitle = Normalize-MarkdownValue $reading.headingTitle
        $readingUrl = Normalize-Url $reading.url
        # Date and URL presentation can differ by timezone, host alias, query
        # spelling, or an omitted line; canonical values are emitted from the
        # raw corpus. Identity validation is limited to ID and title.
        if ($readingId -ne (Normalize-Id $meta.id)) {
            $wrongMetadata.Add($meta.ordinal)
        }
        # A few records omit the URL line; source metadata is authoritative.
        if ([string]::IsNullOrWhiteSpace([string]$reading.url)) { $reading.url = $meta.url }
        foreach ($field in $fieldPatterns.Keys) {
            if ([string]::IsNullOrWhiteSpace([string]$reading[$field])) {
                if ($field -in @('date','id','url')) { $reading[$field] = $meta.$field; continue }
                $missingFields[$field]++
            }
        }

        $output = [ordered]@{
            ordinal = $meta.ordinal
            id = $meta.id
            title = $meta.title
            date = $meta.date
            url = $meta.url
            questionContext = $reading.questionContext
            thesis = $reading.thesis
            reasoning = $reading.reasoning
            conceptsInArticle = $reading.concepts
            authorActionAndEthicalJudgments = $reading.actionAndEthics
            rhetoric = $reading.rhetoric
            sourceQuotes = $reading.quotes
            faithfulSummary = $reading.faithfulSummary
            sourceReadingFile = $reading.sourceReadingFile
            evidencePolicy = 'Author-view evidence only. The raw close-reading limitations/critique field is intentionally excluded.'
        }
        $writer.WriteLine(($output | ConvertTo-Json -Compress -Depth 5))
    }
}
finally {
    $writer.Dispose()
}

$stats = [ordered]@{
    outputPath = $outputFull
    corpusCount = $corpus.Count
    readingCount = $entries.Count
    wrongMetadataOrdinals = @($wrongMetadata)
    missingFieldCounts = $missingFields
    status = if ($entries.Count -eq $corpus.Count -and $wrongMetadata.Count -eq 0 -and (@($missingFields.Values | Where-Object { $_ -gt 0 }).Count -eq 0)) { 'PASS' } else { 'REVIEW' }
}
$stats | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath ([System.IO.Path]::ChangeExtension($outputFull, '.stats.json')) -Encoding UTF8
$stats | ConvertTo-Json -Depth 5
