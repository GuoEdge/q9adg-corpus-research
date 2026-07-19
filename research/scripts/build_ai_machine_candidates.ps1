param(
    [string]$CorpusPath = '.\sooon-q9adg-articles.jsonl',
    [string]$EvidencePath = '.\research\data\author_view_evidence_clean.jsonl',
    [string]$OutputPath = '.\research\data\ai_machine_candidates.csv',
    [string]$StatsPath = '.\research\data\ai_machine_candidates.stats.json'
)

$ErrorActionPreference = 'Stop'

$terms = @(
    '人工智能','AI','大模型','语言模型','大型语言模型','ChatGPT','AutoGPT','OpenAI','DeepSeek','Claude','Gemini','Sora','GPT','机器学习','深度学习','神经网络','算法','模型训练','训练数据','提示词','prompt',
    '算力','芯片算力','算力资源','算力生态','开源AI','可信AI','AI服务','AI应用','AI工具','AI公司','AI企业','AI产业','AI时代',
    '机器人','人形机器人','具身智能','智能体','机器智能','机器意识','人工意识','编舞器','自动化','全自动','无人化',
    'AGI','强人工智能','超级人工智能','图灵测试','费米悖论','自我迭代','自我意识','AI权利','机器权利','AI伦理','AI治理','AI风险','AI失控',
    'AIGC','生成式AI','AI绘画','AI视频','AI生成','AI创作','AI换脸','深度伪造','AI版权','AI侵权',
    'AI失业','智能失业','AI替代','机器替代','职业替代','AI教育','AI教学','AI论文','AI考试','工业软件'
)

$categories = [ordered]@{
    '智能、意识与人类边界' = @('人工智能','机器智能','机器意识','人工意识','智能体','AGI','强人工智能','超级人工智能','图灵测试','自我意识','AI权利','机器权利','费米悖论','意识','智能','主体','人类')
    '模型、知识、提问与可信性' = @('大模型','语言模型','大型语言模型','ChatGPT','AutoGPT','OpenAI','DeepSeek','Claude','Gemini','Sora','GPT','机器学习','深度学习','神经网络','算法','模型训练','训练数据','提示词','prompt','可信AI','AI服务','AI工具','自我迭代','知识','信任','提问','回答','语料','文献')
    '算力、数据、架构与产业生态' = @('算力','芯片算力','算力资源','算力生态','开源AI','AI应用','AI公司','AI企业','AI产业','AI时代','工业软件','数据','架构','产业','公司','企业','芯片','开源','应用')
    '具身、机器人与自动化' = @('机器人','人形机器人','具身智能','智能体','编舞器','自动化','全自动','无人化','机器替代','硬件','身体','动作','控制')
    '劳动、职业与教育重组' = @('AI失业','智能失业','AI替代','机器替代','职业替代','AI教育','AI教学','AI论文','AI考试','AI时代','工业软件','工作','职业','就业','失业','教育','学习','考试','论文')
    '创作、审美、版权与身份' = @('AIGC','生成式AI','AI绘画','AI视频','AI生成','AI创作','AI换脸','深度伪造','AI版权','AI侵权','创作','艺术','绘画','视频','版权','侵权','审美','作者','作品')
    '责任、隐私、风险与治理' = @('AI伦理','AI治理','AI风险','AI失控','AI换脸','深度伪造','AI版权','AI侵权','可信AI','训练数据','责任','隐私','伦理','治理','风险','失控','监管','管理','版权','侵权','法律')
    '强智能、文明与未来秩序' = @('AGI','强人工智能','超级人工智能','费米悖论','AI失控','自我迭代','自我意识','AI权利','机器权利','智能失业','算力生态','文明','未来','人类','社会','国家','秩序')
}

function Get-Hits([string]$Text, [string[]]$Needles) {
    if ([string]::IsNullOrEmpty($Text)) { return @() }
    return @($Needles | Where-Object {
        if ($_ -in @('AI','GPT','AGI','AIGC')) { return [regex]::IsMatch($Text, "(?i)(?<![A-Za-z])$([regex]::Escape($_))(?![A-Za-z])") }
        return $Text.Contains($_, [StringComparison]::OrdinalIgnoreCase)
    })
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
    $categoryText = "{0}`n{1}`n{2}" -f [string]$article.title, [string]$article.question, [string]$article.text
    foreach ($entry in $categories.GetEnumerator()) {
        if (@(Get-Hits $categoryText $entry.Value).Count -gt 0) { [void]$categoryHits.Add($entry.Key) }
    }
    $evidence = $evidenceById[[string]$article.id]
    $date = [DateTimeOffset]::FromUnixTimeMilliseconds([int64]$article.publishedAt).ToOffset([TimeSpan]::FromHours(8)).ToString('yyyy-MM-dd')
    $score = 6 * $titleHits.Count + 4 * $questionHits.Count + $bodyHits.Count + [Math]::Min(6, [Math]::Floor(([string]$article.text).Length / 800))
    $records.Add([pscustomobject][ordered]@{
        ordinal=$ordinal; id=[string]$article.id; date=$date; title=[string]$article.title; url=[string]$article.url
        question=[string]$article.question; textLength=([string]$article.text).Length; relevanceScore=$score
        titleHits=($titleHits -join '；'); questionHits=($questionHits -join '；'); bodyHits=($bodyHits -join '；')
        matchedTerms=($matched -join '；'); categories=($categoryHits -join '；'); thesis=[string]$evidence.thesis
        authorActionAndEthicalJudgments=[string]$evidence.authorActionAndEthicalJudgments
        faithfulSummary=[string]$evidence.faithfulSummary; sourceReadingFile=[string]$evidence.sourceReadingFile
    })
}

$sorted=@($records|Sort-Object @{Expression='relevanceScore';Descending=$true},@{Expression='textLength';Descending=$true},ordinal)
$sorted|Export-Csv -LiteralPath ([IO.Path]::GetFullPath($OutputPath)) -NoTypeInformation -Encoding utf8BOM
$categoryCounts=[ordered]@{};foreach($name in $categories.Keys){$categoryCounts[$name]=@($sorted|Where-Object{$_.categories -split '；' -contains $name}).Count}
$missing=@($sorted|Where-Object{[string]::IsNullOrWhiteSpace($_.thesis)}).Count;$unique=@($sorted.id|Sort-Object -Unique).Count
$stats=[ordered]@{corpusArticles=$ordinal;evidenceArticles=$evidenceById.Count;candidateArticles=$sorted.Count;termCount=$terms.Count;categoryCount=$categories.Count;categoryArticleCounts=$categoryCounts;missingEvidenceRows=$missing;uniqueCandidateIds=$unique;status=if($ordinal-eq4050-and$evidenceById.Count-eq4050-and$sorted.Count-gt0-and$unique-eq$sorted.Count-and$missing-eq0){'PASS'}else{'REVIEW'}}
$stats|ConvertTo-Json -Depth 5|Set-Content -LiteralPath ([IO.Path]::GetFullPath($StatsPath)) -Encoding utf8
$stats|ConvertTo-Json -Depth 5
if($stats.status-ne'PASS'){throw "AI/machine candidate validation ended with status $($stats.status)."}
