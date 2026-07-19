param(
    [string]$CorpusPath = '.\sooon-q9adg-articles.jsonl',
    [string]$EvidencePath = '.\research\data\author_view_evidence_clean.jsonl',
    [string]$OutputPath = '.\research\data\religion_natural_law_candidates.csv',
    [string]$StatsPath = '.\research\data\religion_natural_law_candidates.stats.json'
)

$ErrorActionPreference = 'Stop'

$layers = [ordered]@{
    '宗教、信仰与经典' = @('宗教','信仰','信徒','教徒','教会','教义','经典','经文','圣经','创世记','福音','原教旨','基督','佛教','道教','儒教','祭祀','献祭')
    '上帝、神与神性' = @('上帝','神性','神圣','神明','诸神','神灵','造物主','位格神','神的','神所','神赐','神授')
    '神意、天意与世界安排' = @('神意','天意','上天','老天','天赐','赐予','安排','注定','预定','命运','定数','无常')
    '自然法、天道与客观秩序' = @('自然法','自然规律','客观规律','物理规律','物理定律','天道','天理','在天','天谴','可持续','正外部性','世界规则')
    '罪、审判、惩罚与救赎' = @('罪人','有罪','无罪','罪恶','犯罪','定罪','赎罪','救赎','忏悔','审判','神罚','惩罚','报应','堕落','邪恶')
    '原谅、宽恕与爱的命令' = @('原谅','宽恕','饶恕','博爱','慈爱','爱人','爱仇敌','无条件的爱','定人的罪','被原谅')
    '祈祷、修行与行动实践' = @('祈祷','祷告','祷词','礼拜','修行','祈求','祝祷','感恩','谦卑','侍奉','奉献','蒙福')
    '天命、苦难、死亡与终极意义' = @('天命','使命','苦难','受苦','灾难','无辜','牺牲','死亡','临终','死后','来世','永生','灵魂','天堂','地狱','终极意义')
}

function Get-Hits([string]$text, [string[]]$terms) {
    if ([string]::IsNullOrWhiteSpace($text)) { return @() }
    return @($terms | Where-Object { $text.Contains($_, [StringComparison]::OrdinalIgnoreCase) })
}

function Get-OccurrenceCount([string]$text, [string[]]$terms) {
    if ([string]::IsNullOrWhiteSpace($text)) { return 0 }
    $count = 0
    foreach ($term in $terms) {
        $start = 0
        while ($start -lt $text.Length) {
            $index = $text.IndexOf($term, $start, [StringComparison]::OrdinalIgnoreCase)
            if ($index -lt 0) { break }
            $count++
            $start = $index + [Math]::Max(1, $term.Length)
        }
    }
    return $count
}

$evidenceById = @{}
foreach ($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($EvidencePath))) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $row = $line | ConvertFrom-Json
    $evidenceById[[string]$row.id] = $row
}

$records = [Collections.Generic.List[object]]::new()
$ordinal = 0
foreach ($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($CorpusPath))) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $ordinal++
    $article = $line | ConvertFrom-Json
    $title = [string]$article.title
    $question = [string]$article.question
    $body = [string]$article.text
    $layerScores = [ordered]@{}
    $layerTerms = [ordered]@{}
    $directLayers = [Collections.Generic.List[string]]::new()
    foreach ($entry in $layers.GetEnumerator()) {
        $titleHits = @(Get-Hits $title $entry.Value)
        $questionHits = @(Get-Hits $question $entry.Value)
        $bodyHits = @(Get-Hits $body $entry.Value)
        $allHits = @($titleHits + $questionHits + $bodyHits | Sort-Object -Unique)
        $occurrences = Get-OccurrenceCount $body $entry.Value
        $score = 8 * $titleHits.Count + 4 * $questionHits.Count + 2 * $bodyHits.Count + [Math]::Min(12, $occurrences)
        $layerScores[$entry.Key] = $score
        $layerTerms[$entry.Key] = ($allHits -join '；')
        if ($titleHits.Count -gt 0 -or $questionHits.Count -gt 0) { [void]$directLayers.Add($entry.Key) }
    }
    $maxScore = @($layerScores.Values | Measure-Object -Maximum).Maximum
    if ($maxScore -le 0) { continue }
    $primaryLayer = @($layerScores.GetEnumerator() | Sort-Object @{Expression='Value';Descending=$true}, @{Expression='Name';Descending=$false} | Select-Object -First 1).Key
    $matchedLayers = @($layerScores.GetEnumerator() | Where-Object Value -gt 0 | ForEach-Object Key)
    $allMatchedTerms = @($layerTerms.Values -split '；' | Where-Object { $_ } | Sort-Object -Unique)
    $evidence = $evidenceById[[string]$article.id]
    $date = [DateTimeOffset]::FromUnixTimeMilliseconds([int64]$article.publishedAt).ToOffset([TimeSpan]::FromHours(8)).ToString('yyyy-MM-dd')
    $records.Add([pscustomobject][ordered]@{
        ordinal = $ordinal
        id = [string]$article.id
        date = $date
        title = $title
        url = [string]$article.url
        question = $question
        textLength = $body.Length
        relevanceScore = [int]$maxScore
        primaryLayer = $primaryLayer
        matchedLayers = ($matchedLayers -join '；')
        directLayers = ($directLayers -join '；')
        matchedTerms = ($allMatchedTerms -join '；')
        layerScoresJson = ($layerScores | ConvertTo-Json -Compress)
        layerTermsJson = ($layerTerms | ConvertTo-Json -Compress)
        thesis = [string]$evidence.thesis
        authorActionAndEthicalJudgments = [string]$evidence.authorActionAndEthicalJudgments
        faithfulSummary = [string]$evidence.faithfulSummary
        sourceQuotes = [string]$evidence.sourceQuotes
        sourceReadingFile = [string]$evidence.sourceReadingFile
    })
}

$sorted = @($records | Sort-Object @{Expression='relevanceScore';Descending=$true}, @{Expression='textLength';Descending=$true}, ordinal)
$sorted | Export-Csv -LiteralPath ([IO.Path]::GetFullPath($OutputPath)) -NoTypeInformation -Encoding utf8BOM
$layerCounts = [ordered]@{}
foreach ($layer in $layers.Keys) { $layerCounts[$layer] = @($sorted | Where-Object { $_.matchedLayers -split '；' -contains $layer }).Count }
$missingEvidence = @($sorted | Where-Object { [string]::IsNullOrWhiteSpace($_.thesis) }).Count
$stats = [ordered]@{
    corpusArticles = $ordinal
    evidenceArticles = $evidenceById.Count
    candidateArticles = $sorted.Count
    uniqueCandidateIds = @($sorted.id | Sort-Object -Unique).Count
    layerCount = $layers.Count
    layerArticleCounts = $layerCounts
    missingEvidenceRows = $missingEvidence
    status = if ($ordinal -eq 4050 -and $evidenceById.Count -eq 4050 -and $sorted.Count -gt 0 -and @($sorted.id | Sort-Object -Unique).Count -eq $sorted.Count -and $missingEvidence -eq 0) { 'PASS' } else { 'REVIEW' }
}
$stats | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath ([IO.Path]::GetFullPath($StatsPath)) -Encoding utf8
$stats | ConvertTo-Json -Depth 5
if ($stats.status -ne 'PASS') { throw "Religion/natural-law candidate validation ended with status $($stats.status)." }
