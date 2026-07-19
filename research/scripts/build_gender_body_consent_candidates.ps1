param(
    [string]$CorpusPath = '.\sooon-q9adg-articles.jsonl',
    [string]$EvidencePath = '.\research\data\author_view_evidence_clean.jsonl',
    [string]$OutputPath = '.\research\data\gender_body_consent_candidates.csv',
    [string]$StatsPath = '.\research\data\gender_body_consent_candidates.stats.json'
)

$ErrorActionPreference = 'Stop'

$terms = @(
    '性别','男性','女性','男人','女人','男孩','女孩','男生','女生','男子','女子','性别平等','男女平等','性别歧视','性别角色','性别气质',
    '男权','女权','父权','母权','女性主义','男性主义','大男子主义','阳刚','阴柔','雄性','雌性','雄竞','雌竞','贤妻良母','全职太太','家庭主妇',
    '男主外','女主内','独立女性','娘炮','女汉子','娇妻','女德','男德','贞节','贞操','处女','童贞',
    '身体','身材','外貌','容貌','颜值','漂亮','美貌','化妆','彩妆','素颜','高跟鞋','服装','穿衣','裙子','乳房','胸部','生殖器','阴茎','阴道',
    '子宫','卵巢','睾丸','处女膜','月经','生理期','更年期','整容','医美','减肥','肥胖','身体自主','身体权利','性权利',
    '性欲','性要求','性爱','性行为','性关系','性生活','性取向','同性恋','异性恋','双性恋','无性恋','LGBT','LGBTQ','酷儿','色情','情色','性幻想','性癖',
    '自慰','手淫','勃起','射精','性高潮','性压抑','性吸引','约炮','嫖娼','卖淫','援交','性交易',
    '性同意','同意','许可','拒绝','边界','隐私','纠缠','骚扰','性骚扰','性侵','强奸','猥亵','偷拍','裸照','裸聊','迷奸','家暴','胁迫','强迫','诱奸',
    '性教育','生理教育','避孕','安全套','避孕套','性病','性传播','艾滋','HIV','HPV','梅毒','淋病','性健康','生殖健康','妇科','男科',
    '生育','怀孕','妊娠','孕妇','孕期','备孕','分娩','顺产','剖宫产','剖腹产','流产','堕胎','引产','产后','坐月子','产假','陪产','母乳','哺乳',
    '不孕','绝育','结扎','代孕','试管婴儿','生殖','母职','父职','丁克','婚育','育儿','带娃','家务','家庭劳动','照料劳动','养家','抚养',
    '母亲','父亲','妈妈','爸爸','妻子','丈夫','保护女性','骑士精神','凝视','物化','客体化','尊严','居功','释放信号'
)

$categories = [ordered]@{
    '性别概念、角色与权力' = @('性别','男性','女性','男人','女人','男孩','女孩','男生','女生','男子','女子','性别平等','男女平等','性别歧视','性别角色','性别气质','男权','女权','父权','母权','女性主义','男性主义','大男子主义','阳刚','阴柔','雄性','雌性','雄竞','雌竞','贤妻良母','男主外','女主内','独立女性','娘炮','女汉子','娇妻','女德','男德')
    '身体、外貌与身体自主' = @('身体','身材','外貌','容貌','颜值','漂亮','美貌','化妆','彩妆','素颜','高跟鞋','服装','穿衣','裙子','乳房','胸部','生殖器','阴茎','阴道','子宫','卵巢','睾丸','处女膜','月经','生理期','更年期','整容','医美','减肥','肥胖','身体自主','身体权利')
    '欲望、性行为与性取向' = @('性欲','性要求','性爱','性行为','性关系','性生活','性取向','同性恋','异性恋','双性恋','无性恋','LGBT','LGBTQ','酷儿','色情','情色','性幻想','性癖','处女','童贞','贞操','自慰','手淫','勃起','射精','性高潮','性压抑','性吸引','约炮','嫖娼','卖淫','援交','性交易')
    '同意、边界与性暴力' = @('性同意','同意','许可','拒绝','边界','隐私','纠缠','骚扰','性骚扰','性侵','强奸','猥亵','偷拍','裸照','裸聊','迷奸','家暴','胁迫','强迫','诱奸','性权利')
    '性知识、教育与健康' = @('性教育','生理教育','避孕','安全套','避孕套','性病','性传播','艾滋','HIV','HPV','梅毒','淋病','性健康','生殖健康','妇科','男科','月经','生理期','更年期')
    '生育、妊娠与生殖选择' = @('生育','怀孕','妊娠','孕妇','孕期','备孕','分娩','顺产','剖宫产','剖腹产','流产','堕胎','引产','产后','坐月子','产假','陪产','母乳','哺乳','不孕','绝育','结扎','代孕','试管婴儿','生殖','丁克','婚育')
    '性别化照料与家庭劳动' = @('母职','父职','全职太太','家庭主妇','育儿','带娃','家务','家庭劳动','照料劳动','养家','抚养','母亲','父亲','妈妈','爸爸','妻子','丈夫','陪产')
    '尊严、保护与文化信号' = @('保护女性','骑士精神','凝视','物化','客体化','尊严','居功','释放信号','贤妻良母','女德','男德','贞节','大男子主义','雄竞','雌竞')
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
if ($stats.status -ne 'PASS') { throw "Gender/body/consent candidate validation ended with status $($stats.status)." }
