param(
    [string]$CandidatePath = '.\research\data\education_knowledge_candidates.csv',
    [string]$OutputPath = '.\research\data\education_knowledge_screening.csv',
    [string]$StatsPath = '.\research\data\education_knowledge_screening.stats.json'
)

$ErrorActionPreference = 'Stop'

$educationTerms = @(
    '学习','训练','练习','技能','经验','入门','成长','掌握','教程',
    '教育','学校','老师','教师','学生','课堂','课程','教材','教学','上课','作业','书目','义务教育','职业教育','高等教育',
    '考试','高考','中考','大学','本科','研究生','博士','学历','文凭','学位','分数','成绩','录取','招生','升学','应试','毕业','留学',
    '家庭教育','社会化','天赋','智力','认知发展'
)
$epistemologyTerms = @(
    '事实','证据','知识','认知','科学','理论','假设','验证','核实','研究','实验','观察','确定性','不确定性',
    '错误','犯错','纠错','试错','教训','复盘','改正','修正','反馈','可错','无知','误判',
    '定义','达意','语文','逻辑','论证','批评','反驳','质疑','提问','说服','修辞',
    '记录','笔记','数据','档案','案例','统计','书籍','阅读','写作','记忆'
)
$bodyThreshold = 6

$candidates = @(Import-Csv -LiteralPath ([IO.Path]::GetFullPath($CandidatePath)))
$rows = [Collections.Generic.List[object]]::new()
foreach ($candidate in $candidates) {
    $matched = @([string]$candidate.matchedTerms -split '；' | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    $directTerms = @(
        ([string]$candidate.titleHits -split '；') + ([string]$candidate.questionHits -split '；') |
            Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
            Sort-Object -Unique
    )
    $educationHits = @($matched | Where-Object { $_ -in $educationTerms })
    $epistemologyHits = @($matched | Where-Object { $_ -in $epistemologyTerms })
    $directEducation = @($directTerms | Where-Object { $_ -in $educationTerms })
    $directEpistemology = @($directTerms | Where-Object { $_ -in $epistemologyTerms })

    $educationSelected = $directEducation.Count -gt 0 -or $educationHits.Count -ge $bodyThreshold
    $epistemologySelected = $directEpistemology.Count -gt 0 -or $epistemologyHits.Count -ge $bodyThreshold
    if (-not $educationSelected -and -not $epistemologySelected) { continue }

    $routes = [Collections.Generic.List[string]]::new()
    $reasons = [Collections.Generic.List[string]]::new()
    if ($educationSelected) {
        [void]$routes.Add('教育、学习与能力形成')
        if ($directEducation.Count -gt 0) { [void]$reasons.Add('教育路由标题或问题直接命中') }
        else { [void]$reasons.Add("教育路由全文至少命中${bodyThreshold}个窄词") }
    }
    if ($epistemologySelected) {
        [void]$routes.Add('认识论、知识与论证')
        if ($directEpistemology.Count -gt 0) { [void]$reasons.Add('认识论路由标题或问题直接命中') }
        else { [void]$reasons.Add("认识论路由全文至少命中${bodyThreshold}个窄词") }
    }

    $rows.Add([pscustomobject][ordered]@{
        ordinal = $candidate.ordinal
        id = $candidate.id
        date = $candidate.date
        title = $candidate.title
        url = $candidate.url
        question = $candidate.question
        textLength = $candidate.textLength
        relevanceScore = $candidate.relevanceScore
        topicRoutes = ($routes -join '；')
        screeningReason = ($reasons -join '；')
        educationTermCount = $educationHits.Count
        educationTerms = ($educationHits -join '；')
        epistemologyTermCount = $epistemologyHits.Count
        epistemologyTerms = ($epistemologyHits -join '；')
        directEducationTerms = ($directEducation -join '；')
        directEpistemologyTerms = ($directEpistemology -join '；')
        categories = $candidate.categories
        thesis = $candidate.thesis
        authorActionAndEthicalJudgments = $candidate.authorActionAndEthicalJudgments
        faithfulSummary = $candidate.faithfulSummary
        sourceReadingFile = $candidate.sourceReadingFile
    })
}

$sorted = @($rows | Sort-Object @{ Expression = { [int]$_.relevanceScore }; Descending = $true }, @{ Expression = { [int]$_.textLength }; Descending = $true }, @{ Expression = { [int]$_.ordinal }; Descending = $false })
$sorted | Export-Csv -LiteralPath ([IO.Path]::GetFullPath($OutputPath)) -NoTypeInformation -Encoding utf8BOM

$educationCount = @($sorted | Where-Object { $_.topicRoutes -split '；' -contains '教育、学习与能力形成' }).Count
$epistemologyCount = @($sorted | Where-Object { $_.topicRoutes -split '；' -contains '认识论、知识与论证' }).Count
$overlapCount = @($sorted | Where-Object { ($_.topicRoutes -split '；').Count -eq 2 }).Count
$unique = @($sorted.id | Sort-Object -Unique).Count
$missing = @($sorted | Where-Object {
    [string]::IsNullOrWhiteSpace($_.id) -or [string]::IsNullOrWhiteSpace($_.title) -or
    [string]::IsNullOrWhiteSpace($_.url) -or [string]::IsNullOrWhiteSpace($_.topicRoutes) -or
    [string]::IsNullOrWhiteSpace($_.thesis)
}).Count
$stats = [ordered]@{
    wideCandidates = $candidates.Count
    screenedCandidates = $sorted.Count
    bodyDistinctTermThreshold = $bodyThreshold
    educationRouteCandidates = $educationCount
    epistemologyRouteCandidates = $epistemologyCount
    overlappingRouteCandidates = $overlapCount
    uniqueScreenedIds = $unique
    missingCoreFields = $missing
    status = if (
        $candidates.Count -gt 0 -and $sorted.Count -gt 0 -and $sorted.Count -le $candidates.Count -and
        $educationCount -gt 0 -and $epistemologyCount -gt 0 -and $unique -eq $sorted.Count -and $missing -eq 0
    ) { 'PASS' } else { 'REVIEW' }
}
$stats | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath ([IO.Path]::GetFullPath($StatsPath)) -Encoding utf8
$stats | ConvertTo-Json -Depth 5
if ($stats.status -ne 'PASS') { throw "Education and knowledge screening validation ended with status $($stats.status)." }
