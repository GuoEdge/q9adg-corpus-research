param(
    [string]$CorpusPath = '.\sooon-q9adg-articles.jsonl',
    [string]$EvidencePath = '.\research\data\author_view_evidence_clean.jsonl',
    [string]$ScreeningPath = '.\research\data\religion_natural_law_screening.csv',
    [string]$OutputPath = '.\research\data\religion_natural_law_core_evidence.csv',
    [string]$StatsPath = '.\research\data\religion_natural_law_core_evidence.stats.json'
)

$ErrorActionPreference = 'Stop'

$sections = [ordered]@{
    '宗教、信仰与经典' = @(3310,3940,1282,3988,3399,3096)
    '上帝、神与神性' = @(2023,3998,2953,3459,3870,3952)
    '神意、天意与世界安排' = @(3229,1636,2302,3801,2628,756)
    '自然法、天道与客观秩序' = @(3442,3088,2492,707,2484,1598)
    '罪、审判、惩罚与救赎' = @(3350,2344,3996,2670,4027,2661)
    '原谅、宽恕与爱的命令' = @(2264,3508,3261,3684,4017,1697)
    '祈祷、修行与行动实践' = @(3403,2417,3865,2841,3964,2405)
    '天命、苦难、死亡与终极意义' = @(4004,3737,4039,2204,2739,1547)
}

$topicTerms = @('宗教','信仰','经文','上帝','神性','神意','天意','自然法','天道','天理','自然规律','罪','有罪','无罪','忏悔','审判','原谅','宽恕','祈祷','祷告','修行','天命','苦难','死亡','无常','地狱','爱')

function Get-RegisteredQuotes([string]$value) {
    if ([string]::IsNullOrWhiteSpace($value)) { return @() }
    return @(
        [regex]::Split($value, "`r?`n|；") | ForEach-Object {
            $text = $_.Trim() -replace '^>\s*', '' -replace '^[-*•]\s*', ''
            if ($text.StartsWith('`',[StringComparison]::Ordinal) -and $text.EndsWith('`',[StringComparison]::Ordinal) -and $text.Length -gt 2) {
                $text = $text.Substring(1,$text.Length-2).Trim()
            }
            if ($text.StartsWith('“',[StringComparison]::Ordinal) -and $text.EndsWith('”',[StringComparison]::Ordinal) -and $text.Length -gt 2) {
                $text = $text.Substring(1,$text.Length-2)
            }
            elseif ($text.StartsWith('"',[StringComparison]::Ordinal) -and $text.EndsWith('"',[StringComparison]::Ordinal) -and $text.Length -gt 2) {
                $text = $text.Substring(1,$text.Length-2)
            }
            $text.Trim()
        } | Where-Object { $_.Length -ge 6 }
    )
}

function Get-ExactQuote([string]$rawText, [string]$registered) {
    foreach ($quote in @(Get-RegisteredQuotes $registered)) {
        if ($quote.Length -le 220 -and $rawText.Contains($quote,[StringComparison]::Ordinal)) { return $quote }
    }
    $sentences = @([regex]::Split($rawText, '\r?\n|(?<=[。！？])') | ForEach-Object { $_.Trim() } | Where-Object { $_.Length -ge 8 })
    $ranked = @($sentences | ForEach-Object {
        $sentence = $_
        $hits = @($topicTerms | Where-Object { $sentence.Contains($_,[StringComparison]::OrdinalIgnoreCase) }).Count
        [pscustomobject]@{ sentence=$sentence; hits=$hits; length=$sentence.Length }
    } | Sort-Object @{Expression='hits';Descending=$true}, @{Expression='length';Descending=$false})
    $selected = [string]($ranked | Where-Object hits -gt 0 | Select-Object -First 1).sentence
    if ([string]::IsNullOrWhiteSpace($selected)) { $selected = [string]($ranked | Select-Object -First 1).sentence }
    if ($selected.Length -gt 220) {
        $term = @($topicTerms | Where-Object { $selected.Contains($_,[StringComparison]::OrdinalIgnoreCase) } | Select-Object -First 1)
        $index = if ($term) { $selected.IndexOf([string]$term,[StringComparison]::OrdinalIgnoreCase) } else { 0 }
        $start = [Math]::Max(0,$index-70)
        $length = [Math]::Min(180,$selected.Length-$start)
        $selected = $selected.Substring($start,$length)
    }
    return $selected
}

$corpus = [Collections.Generic.List[object]]::new()
foreach ($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($CorpusPath))) {
    if (-not [string]::IsNullOrWhiteSpace($line)) { $corpus.Add(($line | ConvertFrom-Json)) }
}
if ($corpus.Count -ne 4050) { throw "Expected 4050 corpus articles, found $($corpus.Count)." }

$evidenceById = @{}
foreach ($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($EvidencePath))) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $evidence = $line | ConvertFrom-Json
    $evidenceById[[string]$evidence.id] = $evidence
}
$screenedIds = @{}
foreach ($row in Import-Csv -LiteralPath ([IO.Path]::GetFullPath($ScreeningPath))) { $screenedIds[[string]$row.id] = $true }

$rows = [Collections.Generic.List[object]]::new()
$sequence = 0
foreach ($entry in $sections.GetEnumerator()) {
    foreach ($ordinal in $entry.Value) {
        $sequence++
        $article = $corpus[[int]$ordinal-1]
        if (-not $screenedIds.ContainsKey([string]$article.id)) { throw "Ordinal $ordinal is not in screened candidates." }
        $evidence = $evidenceById[[string]$article.id]
        $quote = Get-ExactQuote ([string]$article.text) ([string]$evidence.sourceQuotes)
        $quoteExact = ([string]$article.text).Contains($quote,[StringComparison]::Ordinal)
        if (-not $quoteExact) { throw "Exact quote validation failed for ordinal ${ordinal}: $quote" }
        $date = [DateTimeOffset]::FromUnixTimeMilliseconds([int64]$article.publishedAt).ToOffset([TimeSpan]::FromHours(8)).ToString('yyyy-MM-dd')
        $rows.Add([pscustomobject][ordered]@{
            evidenceId = ('R{0:D2}' -f $sequence)
            section = $entry.Key
            claim = [string]$evidence.thesis
            evidenceNature = '作者在单篇文本中的直接命题、定义或应用论证'
            boundary = '本条只呈现作者在该文中的判断；同层及跨层联系属于研究重建。'
            ordinal = [int]$ordinal
            id = [string]$article.id
            date = $date
            title = [string]$article.title
            url = [string]$article.url
            quote = $quote
            quoteExact = $quoteExact
            sourceReadingFile = [string]$evidence.sourceReadingFile
        })
    }
}

$rows | Export-Csv -LiteralPath ([IO.Path]::GetFullPath($OutputPath)) -NoTypeInformation -Encoding utf8BOM
$sectionCounts = [ordered]@{}
foreach ($section in $sections.Keys) { $sectionCounts[$section] = @($rows | Where-Object section -eq $section).Count }
$missing = @($rows | Where-Object { [string]::IsNullOrWhiteSpace($_.claim) -or [string]::IsNullOrWhiteSpace($_.quote) }).Count
$stats = [ordered]@{
    corpusArticles = $corpus.Count
    screenedCandidates = $screenedIds.Count
    evidenceRows = $rows.Count
    uniqueEvidenceIds = @($rows.evidenceId | Sort-Object -Unique).Count
    uniqueArticleIds = @($rows.id | Sort-Object -Unique).Count
    uniqueOrdinals = @($rows.ordinal | Sort-Object -Unique).Count
    missingCoreFields = $missing
    exactQuoteFailures = @($rows | Where-Object { -not $_.quoteExact }).Count
    sectionCounts = $sectionCounts
    status = if ($rows.Count -eq 48 -and @($rows.id | Sort-Object -Unique).Count -eq 48 -and $missing -eq 0 -and @($rows | Where-Object { -not $_.quoteExact }).Count -eq 0 -and @($sections.Keys | Where-Object { $sectionCounts[$_] -ne 6 }).Count -eq 0) { 'PASS' } else { 'REVIEW' }
}
$stats | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath ([IO.Path]::GetFullPath($StatsPath)) -Encoding utf8
$stats | ConvertTo-Json -Depth 5
if ($stats.status -ne 'PASS') { throw "Religion/natural-law core evidence validation ended with status $($stats.status)." }
