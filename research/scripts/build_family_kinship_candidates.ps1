param(
    [string]$CorpusPath = '.\sooon-q9adg-articles.jsonl',
    [string]$EvidencePath = '.\research\data\author_view_evidence_clean.jsonl',
    [string]$OutputPath = '.\research\data\family_kinship_candidates.csv',
    [string]$StatsPath = '.\research\data\family_kinship_candidates.stats.json'
)

$ErrorActionPreference = 'Stop'

$terms = @(
    '家庭','家人','家里','家中','家长','亲属','亲人','亲戚','亲族','族亲','家族','宗族','血缘','骨肉','代际',
    '父母','父亲','母亲','爸爸','妈妈','爹','娘','双亲','单亲','继父','继母','养父','养母',
    '子女','孩子','小孩','儿童','儿子','女儿','独生子女','未成年','成年子女','亲子',
    '兄弟','姐妹','哥哥','弟弟','姐姐','妹妹','兄妹','姐弟','手足',
    '祖父','祖母','爷爷','奶奶','外公','外婆','祖辈','后代','子孙','祖先','祖宗','香火',
    '叔叔','伯伯','姑姑','舅舅','姨妈','姨父','姑父','叔伯','姑舅','婆家','娘家','公婆','岳父','岳母','婆媳','翁婿',
    '抚养','养育','育儿','监护','照护','照料','陪伴','托育','家教','家庭教育','管教','教养',
    '赡养','养老','孝顺','孝道','尽孝','孝敬','养老院','老人','老年人','空巢',
    '家务','做饭','做菜','收纳','家政','带孩子','接送孩子','家庭分工','家务劳动',
    '家产','家庭财产','家庭收入','家庭开支','家庭账户','积蓄','存款','房产','遗产','遗嘱','继承','分家','财产权',
    '援亲','帮扶亲属','探亲','探病','走亲戚','礼金','份子钱','奠仪','葬礼','丧事','奔丧','祭祀','祭祖','族谱','家谱',
    '家风','传家','传承','门第','门当户对','家业','基业','家国','成家','安家','四海为家'
)

$categories = [ordered]@{
    '亲子抚养与基本照护' = @('父母','父亲','母亲','爸爸','妈妈','子女','孩子','小孩','儿童','儿子','女儿','未成年','亲子','抚养','养育','育儿','监护','照护','陪伴','托育')
    '父母权柄与成年退出' = @('家庭教育','家教','管教','教养','监护','未成年','成年子女','财产权','分家','成家','安家')
    '赡养养老与代际支持' = @('赡养','养老','孝顺','孝道','尽孝','孝敬','养老院','老人','老年人','空巢','祖父','祖母','爷爷','奶奶','外公','外婆','祖辈')
    '扩展亲属与人情网络' = @('亲属','亲戚','亲族','族亲','宗族','兄弟','姐妹','哥哥','弟弟','姐姐','妹妹','兄妹','姐弟','手足','叔叔','伯伯','姑姑','舅舅','姨妈','姨父','姑父','叔伯','姑舅','探亲','走亲戚','礼金','份子钱')
    '家庭资源与财产安排' = @('家产','家庭财产','家庭收入','家庭开支','家庭账户','积蓄','存款','房产','遗产','遗嘱','继承','分家','财产权','援亲')
    '危机照料与功能替代' = @('照护','照料','探病','带孩子','接送孩子','葬礼','丧事','奔丧','奠仪','帮扶亲属')
    '家务合作与日常生活' = @('家务','做饭','做菜','收纳','家政','带孩子','接送孩子','家庭分工','家务劳动','婆家','娘家','公婆','岳父','岳母','婆媳','翁婿')
    '家族传承与共同体' = @('家族','血缘','代际','后代','子孙','祖先','祖宗','香火','祭祀','祭祖','族谱','家谱','家风','传家','传承','门第','门当户对','家业','基业','家国')
}

function Get-Hits([string]$Text, [string[]]$Needles) {
    if ([string]::IsNullOrEmpty($Text)) { return @() }
    return @($Needles | Where-Object { $Text.Contains($_, [StringComparison]::OrdinalIgnoreCase) })
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
    $titleHits = @(Get-Hits ([string]$article.title) $terms)
    $questionHits = @(Get-Hits ([string]$article.question) $terms)
    $bodyHits = @(Get-Hits ([string]$article.text) $terms)
    $matched = @($titleHits + $questionHits + $bodyHits | Sort-Object -Unique)
    if ($matched.Count -eq 0) { continue }

    $categoryHits = [Collections.Generic.List[string]]::new()
    foreach ($entry in $categories.GetEnumerator()) {
        if (@($matched | Where-Object { $_ -in $entry.Value }).Count -gt 0) { [void]$categoryHits.Add($entry.Key) }
    }

    $evidence = $evidenceById[[string]$article.id]
    $date = [DateTimeOffset]::FromUnixTimeMilliseconds([int64]$article.publishedAt).ToOffset([TimeSpan]::FromHours(8)).ToString('yyyy-MM-dd')
    $score = 6 * $titleHits.Count + 4 * $questionHits.Count + $bodyHits.Count + [Math]::Min(6, [Math]::Floor(([string]$article.text).Length / 800))
    $records.Add([pscustomobject][ordered]@{
        ordinal = $ordinal
        id = [string]$article.id
        date = $date
        title = [string]$article.title
        url = [string]$article.url
        question = [string]$article.question
        textLength = ([string]$article.text).Length
        relevanceScore = $score
        titleHits = ($titleHits -join '；')
        questionHits = ($questionHits -join '；')
        bodyHits = ($bodyHits -join '；')
        matchedTerms = ($matched -join '；')
        categories = ($categoryHits -join '；')
        thesis = [string]$evidence.thesis
        authorActionAndEthicalJudgments = [string]$evidence.authorActionAndEthicalJudgments
        faithfulSummary = [string]$evidence.faithfulSummary
        sourceReadingFile = [string]$evidence.sourceReadingFile
    })
}

$sorted = @($records | Sort-Object @{ Expression = 'relevanceScore'; Descending = $true }, @{ Expression = 'textLength'; Descending = $true }, ordinal)
$sorted | Export-Csv -LiteralPath ([IO.Path]::GetFullPath($OutputPath)) -NoTypeInformation -Encoding utf8BOM

$categoryCounts = [ordered]@{}
foreach ($name in $categories.Keys) { $categoryCounts[$name] = @($sorted | Where-Object { $_.categories -split '；' -contains $name }).Count }
$missing = @($sorted | Where-Object { [string]::IsNullOrWhiteSpace($_.thesis) }).Count
$unique = @($sorted.id | Sort-Object -Unique).Count
$stats = [ordered]@{
    corpusArticles = $ordinal
    evidenceArticles = $evidenceById.Count
    candidateArticles = $sorted.Count
    termCount = $terms.Count
    categoryCount = $categories.Count
    categoryArticleCounts = $categoryCounts
    missingEvidenceRows = $missing
    uniqueCandidateIds = $unique
    status = if ($ordinal -eq 4050 -and $evidenceById.Count -eq 4050 -and $sorted.Count -gt 0 -and $unique -eq $sorted.Count -and $missing -eq 0) { 'PASS' } else { 'REVIEW' }
}
$stats | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath ([IO.Path]::GetFullPath($StatsPath)) -Encoding utf8
$stats | ConvertTo-Json -Depth 5
if ($stats.status -ne 'PASS') { throw "Family and kinship candidate validation ended with status $($stats.status)." }
