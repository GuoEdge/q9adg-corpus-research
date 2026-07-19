param(
    [string]$CorpusPath = (Join-Path $PSScriptRoot '..\..\sooon-q9adg-articles.jsonl'),
    [string]$OutputDir = (Join-Path $PSScriptRoot '..\data')
)

$ErrorActionPreference = 'Stop'
$OutputDir = [System.IO.Path]::GetFullPath($OutputDir)
New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null

$themes = [ordered]@{
    family_kinship = @('父母', '父亲', '母亲', '爸爸', '妈妈', '子女', '孩子', '家庭', '亲戚', '婆婆', '岳父', '岳母', '孝', '婚姻')
    intimacy_gender = @('恋爱', '爱情', '感情', '男朋友', '女朋友', '伴侣', '结婚', '离婚', '相亲', '出轨', '性别', '男性', '女性')
    workplace_org = @('职场', '工作', '同事', '领导', '老板', '公司', '单位', '下属', '升职', '辞职', '绩效', '管理')
    money_property = @('钱', '收入', '工资', '房子', '买房', '财产', '财富', '借钱', '投资', '消费', '成本', '利益')
    ethics_norms = @('道德', '伦理', '责任', '义务', '体面', '尊重', '信用', '规矩', '礼貌', '公平', '正义', '人情')
    power_strategy = @('权力', '权利', '地位', '利益', '资源', '控制', '服从', '博弈', '策略', '手段', '选择', '代价')
    education_growth = @('学习', '教育', '学校', '老师', '学生', '大学', '考试', '知识', '能力', '成长', '读书', '专业')
    psychology_self = @('焦虑', '抑郁', '情绪', '自卑', '内向', '自信', '痛苦', '心理', '人格', '自我', '孤独', '幸福')
    public_society = @('社会', '国家', '政府', '制度', '法律', '阶层', '城市', '农村', '公共', '政治', '政策', '历史')
    communication_conflict = @('沟通', '表达', '说话', '争吵', '冲突', '拒绝', '道歉', '感谢', '关系', '社交', '边界', '合作')
}

$concepts = [ordered]@{
    '伦理' = '伦理'
    '道德' = '道德'
    '责任' = '责任'
    '义务' = '义务'
    '信用' = '信用'
    '体面' = '体面'
    '人情' = '人情'
    '利益' = '利益'
    '资源' = '资源'
    '权力' = '权力'
    '权利' = '权利'
    '地位' = '地位'
    '成本' = '成本'
    '代价' = '代价'
    '风险' = '风险'
    '选择' = '选择'
    '边界' = '边界'
    '尊重' = '尊重'
    '感谢' = '感谢'
    '合作' = '合作'
    '服从' = '服从'
    '控制' = '控制'
    '交换' = '交换'
    '资本' = '资本'
    '博弈' = '博弈'
    '秩序' = '秩序'
    '示范' = '示范'
    '预期' = '预期'
    '能力' = '能力'
    '劳动' = '劳动'
    '财富' = '财富'
}

$rows = [System.Collections.Generic.List[object]]::new()
$themeCounts = [ordered]@{}
$themeExamples = [ordered]@{}
foreach ($theme in $themes.Keys) {
    $themeCounts[$theme] = 0
    $themeExamples[$theme] = [System.Collections.Generic.List[object]]::new()
}
$conceptDocumentCounts = [ordered]@{}
$conceptOccurrenceCounts = [ordered]@{}
foreach ($concept in $concepts.Keys) {
    $conceptDocumentCounts[$concept] = 0
    $conceptOccurrenceCounts[$concept] = 0
}

$seenIds = [System.Collections.Generic.HashSet[string]]::new()
$duplicateIds = [System.Collections.Generic.List[string]]::new()
$invalidLines = [System.Collections.Generic.List[int]]::new()
$lineNumber = 0

Get-Content -LiteralPath $CorpusPath -Encoding UTF8 | ForEach-Object {
    $lineNumber++
    try {
        $item = $_ | ConvertFrom-Json
    }
    catch {
        $invalidLines.Add($lineNumber)
        return
    }

    if (-not $seenIds.Add([string]$item.id)) {
        $duplicateIds.Add([string]$item.id)
    }

    $published = [DateTimeOffset]::FromUnixTimeMilliseconds([int64]$item.publishedAt).ToOffset([TimeSpan]::FromHours(8))
    $text = [string]$item.text
    $combined = '{0}`n{1}`n{2}' -f $item.title, $item.question, $text
    $matchedThemes = [System.Collections.Generic.List[string]]::new()

    foreach ($theme in $themes.Keys) {
        $hit = $false
        foreach ($keyword in $themes[$theme]) {
            if ($combined.Contains($keyword, [StringComparison]::OrdinalIgnoreCase)) {
                $hit = $true
                break
            }
        }
        if ($hit) {
            $themeCounts[$theme]++
            $matchedThemes.Add($theme)
            $examples = $themeExamples[$theme]
            if ($examples.Count -lt 25) {
                $examples.Add([ordered]@{
                    id = $item.id
                    title = $item.title
                    publishedDate = $published.ToString('yyyy-MM-dd')
                    url = $item.url
                    question = $item.question
                    excerpt = if ($text.Length -gt 240) { $text.Substring(0, 240) } else { $text }
                })
            }
        }
    }

    foreach ($concept in $concepts.Keys) {
        $pattern = [regex]::Escape($concepts[$concept])
        $matches = [regex]::Matches($combined, $pattern)
        if ($matches.Count -gt 0) {
            $conceptDocumentCounts[$concept]++
            $conceptOccurrenceCounts[$concept] += $matches.Count
        }
    }

    $rows.Add([pscustomobject][ordered]@{
        id = $item.id
        title = $item.title
        question = $item.question
        url = $item.url
        publishedDate = $published.ToString('yyyy-MM-dd')
        publishedYear = $published.Year
        publishedMonth = $published.ToString('yyyy-MM')
        charCount = $text.Length
        paragraphCount = @($text -split "`n" | Where-Object { $_.Trim().Length -gt 0 }).Count
        themes = ($matchedThemes -join ';')
    })
}

$indexPath = Join-Path $OutputDir 'corpus_index.csv'
$rows | Export-Csv -LiteralPath $indexPath -NoTypeInformation -Encoding utf8BOM

$lengths = @($rows.charCount | Sort-Object)
function Get-Percentile([int[]]$Values, [double]$Percentile) {
    if ($Values.Count -eq 0) { return 0 }
    $index = [Math]::Floor(($Values.Count - 1) * $Percentile)
    return $Values[$index]
}

$yearDistribution = [ordered]@{}
$rows | Group-Object publishedYear | Sort-Object Name | ForEach-Object { $yearDistribution[$_.Name] = $_.Count }
$monthDistribution = [ordered]@{}
$rows | Group-Object publishedMonth | Sort-Object Name | ForEach-Object { $monthDistribution[$_.Name] = $_.Count }

$stats = [ordered]@{
    generatedAt = (Get-Date).ToString('o')
    corpusPath = [System.IO.Path]::GetFullPath($CorpusPath)
    articleCount = $rows.Count
    uniqueIdCount = $seenIds.Count
    duplicateIds = @($duplicateIds)
    invalidLineNumbers = @($invalidLines)
    dateRange = [ordered]@{
        first = ($rows | Sort-Object publishedDate | Select-Object -First 1).publishedDate
        last = ($rows | Sort-Object publishedDate | Select-Object -Last 1).publishedDate
    }
    characterCount = [ordered]@{
        total = ($rows | Measure-Object charCount -Sum).Sum
        mean = [Math]::Round(($rows | Measure-Object charCount -Average).Average, 2)
        median = Get-Percentile $lengths 0.5
        p25 = Get-Percentile $lengths 0.25
        p75 = Get-Percentile $lengths 0.75
        p90 = Get-Percentile $lengths 0.9
        min = $lengths[0]
        max = $lengths[-1]
    }
    yearDistribution = $yearDistribution
    monthDistribution = $monthDistribution
    themeMethod = 'Keyword presence in title, question, or body. Themes overlap and are descriptive retrieval aids, not inferred latent topics.'
    themeCounts = $themeCounts
    conceptMethod = 'Exact literal match in title, question, or body. Document count is preferred for prevalence; occurrence count describes repetition, not importance.'
    conceptDocumentCounts = $conceptDocumentCounts
    conceptOccurrenceCounts = $conceptOccurrenceCounts
}

$stats | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $OutputDir 'corpus_stats.json') -Encoding utf8
$themeExamples | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $OutputDir 'theme_examples.json') -Encoding utf8

Write-Output "Indexed $($rows.Count) articles to $indexPath"
