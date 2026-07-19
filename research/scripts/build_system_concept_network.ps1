param(
    [string]$EvidencePath = (Join-Path $PSScriptRoot '..\data\author_view_evidence_clean.jsonl'),
    [string]$OutputDir = (Join-Path $PSScriptRoot '..\data')
)

$ErrorActionPreference = 'Stop'
$concepts = [ordered]@{
    '事实与证据' = '事实|证据|核实|材料|依据'
    '定义与达意' = '定义|概念|达意|语义|措辞|表达'
    '能力与学习' = '能力|学习|教育|练习|训练|经验'
    '选择与自由' = '选择|自由|自主|退出|拒绝|不同意'
    '责任与后果' = '责任|后果|承担|赔偿|改进|义务'
    '成本与总账' = '成本|代价|总账|收入|支出|风险|资源'
    '信用与信任' = '信用|信任|可靠|承诺|失约|征信'
    '爱与回应' = '爱|关切|回应|被爱|亲密|陪伴'
    '净输出与不掠夺' = '净输出|净赠与|不掠夺|索取|居功|补偿'
    '边界与许可' = '边界|许可|同意|隐私|打扰|纠缠'
    '照料与家庭' = '照料|家庭|父母|子女|婚姻|生育|亲子'
    '劳动与组织' = '劳动|工作|产出|组织|协作|分功|职场'
    '财富与市场' = '财富|市场|赚钱|商业|交易|资本|消费'
    '法律与秩序' = '法律|国家|秩序|服从|授权|司法|公民'
    '权力与异议' = '权力|控制|支配|反抗|异议|背叛|权柄'
    '技术与工程' = '技术|工程|工具|AI|产业|迭代|路线'
    '文明与历史' = '文明|历史|传统|继承|代际|文化|进化'
    '民族与身份' = '民族|族群|种族|国籍|移民|华人|华裔|殖民|同化|爱国|身份认同'
    '生态与自然' = '生态|环境保护|气候|灾害|能源|动物|植物|污染|粮食|农业|自然循环|生物多样性'
    '人工智能与机器' = '(?i)\bAI\b|人工智能|大模型|机器学习|算力|机器人|自动驾驶|AIGC|AGI|GPT|DeepSeek|脑机接口|意识上传'
    '心理与主体' = '痛苦|焦虑|抑郁|自尊|自信|孤独|情绪|心理'
    '性别与身体' = '性别|女性|男性|身体|性欲|性行为|生理|身体'
    '宗教与自然法' = '上帝|神意|宗教|自然法|天意|神圣'
}

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
$rows = foreach ($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($EvidencePath))) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $o = $line | ConvertFrom-Json
    # Restrict the network to fields that pass the clean author-view filter.
    # questionContext belongs to the questioner; rhetoric and conceptsInArticle
    # are researcher analysis and therefore must not inflate the author network.
    $text = @($o.thesis,$o.reasoning,$o.authorActionAndEthicalJudgments,$o.sourceQuotes,$o.faithfulSummary) -join "`n"
    $hits = [System.Collections.Generic.List[string]]::new()
    foreach ($name in $concepts.Keys) {
        if ([regex]::IsMatch($text, $concepts[$name])) { [void]$hits.Add($name) }
    }
    [pscustomobject]@{ ordinal=[int]$o.ordinal; id=$o.id; title=$o.title; date=$o.date; concepts=@($hits) }
}

$conceptCounts = foreach ($name in $concepts.Keys) {
    $n = @($rows | Where-Object { $_.concepts -contains $name }).Count
    [pscustomobject]@{ concept=$name; articleCount=$n; articleRate=[math]::Round($n / $rows.Count, 6) }
}
$conceptCountByName = @{}
foreach ($row in $conceptCounts) { $conceptCountByName[[string]$row.concept] = [int]$row.articleCount }
$conceptCounts | Export-Csv -LiteralPath (Join-Path $OutputDir 'system_concept_article_counts.csv') -NoTypeInformation -Encoding UTF8
$rows | Select-Object ordinal,id,title,date,@{Name='conceptCount';Expression={$_.concepts.Count}},@{Name='concepts';Expression={$_.concepts -join ';'}} | Export-Csv -LiteralPath (Join-Path $OutputDir 'article_system_concept_map.csv') -NoTypeInformation -Encoding UTF8
$paperRoutes = [ordered]@{
    '事实与证据'='08;09;17'; '定义与达意'='09;17'; '能力与学习'='08;13;18'; '选择与自由'='02;07;16;18';
    '责任与后果'='02;03;10;12;18'; '成本与总账'='03;10;18'; '信用与信任'='03;06;12;18';
    '爱与回应'='04;05;14;16'; '净输出与不掠夺'='03;05;16'; '边界与许可'='05;12;16;18';
    '照料与家庭'='04;05;14;16'; '劳动与组织'='06;10;13;18'; '财富与市场'='03;10;13';
    '法律与秩序'='07;12;18'; '权力与异议'='03;07;12;18'; '技术与工程'='13;17;18;32;33';
    '文明与历史'='11;13;15;31;32;33'; '民族与身份'='12;27;31'; '生态与自然'='13;25;32';
    '人工智能与机器'='13;28;29;33'; '心理与主体'='08;14;17;18'; '性别与身体'='05;14;16'; '宗教与自然法'='07;11'
}
$routeRows = foreach($row in $rows){$papers=[Collections.Generic.HashSet[string]]::new();foreach($concept in $row.concepts){foreach($paper in ($paperRoutes[$concept] -split ';')){[void]$papers.Add($paper)}};[pscustomobject]@{ordinal=$row.ordinal;id=$row.id;title=$row.title;date=$row.date;concepts=$row.concepts -join ';';paperRoutes=@($papers|Sort-Object) -join ';'}}
$routeRows | Export-Csv -LiteralPath (Join-Path $OutputDir 'article_paper_route_map.csv') -NoTypeInformation -Encoding UTF8

$periods = [ordered]@{
    '2017-2020' = { param($d) $d -le '2020-12-31' }
    '2021-2023' = { param($d) $d -ge '2021-01-01' -and $d -le '2023-12-31' }
    '2024-2026' = { param($d) $d -ge '2024-01-01' }
}
$periodRows = foreach ($period in $periods.Keys) {
    $periodArticles = @($rows | Where-Object { & $periods[$period] $_.date })
    foreach ($name in $concepts.Keys) {
        $n = @($periodArticles | Where-Object { $_.concepts -contains $name }).Count
        [pscustomobject]@{ period=$period; articleCount=$periodArticles.Count; concept=$name; conceptArticleCount=$n; conceptArticleRate=if($periodArticles.Count){[math]::Round($n/$periodArticles.Count,6)}else{0} }
    }
}
$periodRows | Export-Csv -LiteralPath (Join-Path $OutputDir 'system_concept_period_rates.csv') -NoTypeInformation -Encoding UTF8

$pairs = @{}
foreach ($row in $rows) {
    $names = @($row.concepts | Sort-Object)
    for ($i=0; $i -lt $names.Count; $i++) {
        for ($j=$i+1; $j -lt $names.Count; $j++) {
            $key = "$($names[$i])`t$($names[$j])"
            if (-not $pairs.ContainsKey($key)) { $pairs[$key] = 0 }
            $pairs[$key]++
        }
    }
}
$pairRows = foreach ($key in $pairs.Keys) {
    $parts = $key -split "`t", 2
    $coCount = [int]$pairs[$key]
    $countA = [int]$conceptCountByName[$parts[0]]
    $countB = [int]$conceptCountByName[$parts[1]]
    $union = $countA + $countB - $coCount
    $observedRate = $coCount / $rows.Count
    $expectedRate = ($countA / $rows.Count) * ($countB / $rows.Count)
    [pscustomobject]@{
        conceptA=$parts[0]
        conceptB=$parts[1]
        conceptAArticleCount=$countA
        conceptBArticleCount=$countB
        coArticleCount=$coCount
        coArticleRate=[math]::Round($observedRate, 6)
        jaccard=if($union){[math]::Round($coCount/$union,6)}else{0}
        lift=if($expectedRate){[math]::Round($observedRate/$expectedRate,6)}else{0}
    }
}
$pairRows | Sort-Object @{Expression='coArticleCount';Descending=$true},conceptA,conceptB | Export-Csv -LiteralPath (Join-Path $OutputDir 'system_concept_cooccurrence.csv') -NoTypeInformation -Encoding UTF8

$summary = [ordered]@{
    evidencePath=[IO.Path]::GetFullPath($EvidencePath)
    inputFields=@('thesis','reasoning','authorActionAndEthicalJudgments','sourceQuotes','faithfulSummary')
    excludedFields=@('questionContext','conceptsInArticle','rhetoric')
    inputFieldPolicy='Only clean author-attributed fields are used; questioner and researcher fields are excluded.'
    articleCount=$rows.Count
    conceptCount=$concepts.Count
    concepts=$conceptCounts
    periodCount=$periods.Count
    pairCount=$pairRows.Count
    status=if ($rows.Count -eq 4050 -and $pairRows.Count -gt 0) { 'PASS' } else { 'REVIEW' }
}
$summary | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath (Join-Path $OutputDir 'system_concept_network.stats.json') -Encoding UTF8
$summary | ConvertTo-Json -Depth 4
