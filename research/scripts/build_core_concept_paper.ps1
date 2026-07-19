param(
    [string]$DictionaryPath = (Join-Path $PSScriptRoot '..\data\core_concept_dictionary.csv'),
    [string]$CorpusPath = (Join-Path $PSScriptRoot '..\..\sooon-q9adg-articles.jsonl'),
    [string]$OutputPath = (Join-Path $PSScriptRoot '..\papers\20_核心概念词典与语义结构.md')
)

$ErrorActionPreference = 'Stop'
$dictionary = @(Import-Csv -LiteralPath $DictionaryPath)
if ($dictionary.Count -ne 30) { throw "Expected 30 concepts, found $($dictionary.Count)." }

$raw = @{}
foreach ($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($CorpusPath))) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $row = $line | ConvertFrom-Json
    $raw[[string]$row.id] = $row
}

$groups = [ordered]@{
    '行动与主体：从选择到承担' = @('责任','自由','选择','成本','总账','能力')
    '关系与边界：从爱到退出' = @('爱','净输出','不掠夺','尊重','边界','宽容','妥协','退出','尊严','焦虑')
    '组织与信用：从授权到共同产出' = @('信用','授权','服从','礼仪','社会资本','合作','劳动')
    '知识、技术与时间：从效能到传承' = @('效能','自然法','伦理','经验','技术路径','记录','纪念')
}
$allTerms = @($groups.Values | ForEach-Object { $_ })
if (@($allTerms | Sort-Object -Unique).Count -ne 30) { throw 'Concept group mapping is incomplete or duplicated.' }

$byTerm = @{}
foreach ($row in $dictionary) {
    if ($byTerm.ContainsKey([string]$row.term)) { throw "Duplicate term $($row.term)." }
    if (-not $raw.ContainsKey([string]$row.representative_id)) { throw "Missing representative ID for $($row.term)." }
    $source = $raw[[string]$row.representative_id]
    if (-not ([string]$source.title).Equals([string]$row.representative_title,[StringComparison]::Ordinal)) { throw "Title mismatch for $($row.term)." }
    if (-not ([string]$source.text).Contains([string]$row.source_quote,[StringComparison]::Ordinal)) { throw "Quote mismatch for $($row.term)." }
    $byTerm[[string]$row.term] = $row
}

$builder = [Text.StringBuilder]::new()
[void]$builder.AppendLine('# 岐伯核心概念词典与语义结构：三十个概念的内部重建')
[void]$builder.AppendLine()
[void]$builder.AppendLine('## 摘要')
[void]$builder.AppendLine()
[void]$builder.AppendLine('本文以4,050篇岐伯公开文本为内部语料，将30个反复出现或具有独特用法的概念组织成四组：行动与主体、关系与边界、组织与信用、知识技术与时间。每个词条分别登记作者在文本中的用法、相邻概念、边界或相反方向、适用领域、条件与例外、代表原文和历时线索。词典不以外部哲学定义替换作者用法，也不把一个代表篇目扩张成全库唯一含义。四组和概念链均为研究重建。')
[void]$builder.AppendLine()
[void]$builder.AppendLine('**关键词：** 核心概念；责任；自由；爱；信用；伦理；自然法；技术路径；记录；岐伯')
[void]$builder.AppendLine()
[void]$builder.AppendLine('## 一、材料、证据与阅读规则')
[void]$builder.AppendLine()
[void]$builder.AppendLine('原始正文和元数据是最高证据。结构化词典只负责定位和比较；宽口径词频不直接证明概念重要性。每个代表短引均使用 `StringComparison.Ordinal` 在对应原始正文中逐字回查。证据类型分为明示命题、明示区分、跨文重复和研究重建；后两类不能写成作者曾自觉提出完整理论。')
[void]$builder.AppendLine()
[void]$builder.AppendLine('词条中的相邻概念表示文本里经常共同进入一条推理链，不等于同义；边界概念表示作者用来限制或区分该概念的方向，不必是形式逻辑上的反义词。条件与例外属于定义本身，不能在摘录时删除。')
[void]$builder.AppendLine()

$sectionNumber = 2
foreach ($group in $groups.GetEnumerator()) {
    [void]$builder.AppendLine("## $sectionNumber、$($group.Key)")
    [void]$builder.AppendLine()
    $index = 1
    foreach ($term in $group.Value) {
        $row = $byTerm[$term]
        $source = $raw[[string]$row.representative_id]
        [void]$builder.AppendLine("### $index. $term")
        [void]$builder.AppendLine()
        [void]$builder.AppendLine("**文本内用法。** $($row.author_usage)")
        [void]$builder.AppendLine()
        [void]$builder.AppendLine("**语义邻接。** $($row.adjacent_concepts)。主要领域：$($row.domains)。")
        [void]$builder.AppendLine()
        [void]$builder.AppendLine("**边界与条件。** 边界或相反方向为：$($row.boundary_or_opposite)。$($row.conditions_exceptions)")
        [void]$builder.AppendLine()
        [void]$builder.AppendLine("**代表证据。** [$($row.representative_title)]($($source.url))，ID `$($row.representative_id)`：")
        [void]$builder.AppendLine()
        [void]$builder.AppendLine("> $($row.source_quote)")
        [void]$builder.AppendLine()
        [void]$builder.AppendLine("**历时与证据性质。** $($row.chronology)；证据类型：$($row.evidence_type)。")
        [void]$builder.AppendLine()
        $index++
    }
    $sectionNumber++
}

[void]$builder.AppendLine('## 六、跨概念链：从局部词义到行动语法')
[void]$builder.AppendLine()
[void]$builder.AppendLine('以下连接均属研究重建。第一条链是**自由—选择—成本—责任—信用**：主体保留决定位置，选择进入现实后产生代价，承担后果形成他人可观察的信用。第二条链是**爱—净输出—尊重—边界—退出**：关切必须给对方带来净增益，同时承认拒绝权；当边界和责任无法重新协商时，退出成为停止继续投入的动作。')
[void]$builder.AppendLine()
[void]$builder.AppendLine('第三条链是**授权—服从—合作—礼仪—社会资本**：权柄先有来源和范围，服从才不等于私人屈从；多方贡献通过礼仪、分功和互惠形成长期合作记录。第四条链是**经验—能力—技术路径—效能—自然法**：记录和经验帮助主体形成能力，技术路径把能力转成可运行方案，现实反馈检验效能。第五条链是**记录—总账—纪念—传承**：行动不只按眼前结果结算，过去的损失、功劳与关系通过记录进入较长账期。')
[void]$builder.AppendLine()
[void]$builder.AppendLine('这些链条不是封闭系统。例如，自由在《一寸欢喜》中带有成年、自有劳动所得和不违法等条件；退出不能抹去既有责任；净输出不要求无限供给；自然法在宗教和世俗文章中的语言不能直接视为完全同义。概念连接只有在保留这些条件时才成立。')
[void]$builder.AppendLine()
[void]$builder.AppendLine('## 七、同词异域与内部差异')
[void]$builder.AppendLine()
[void]$builder.AppendLine('责任在家庭文本中可指抚养和亲属角色义务，在财富文本中可指资源管理，在组织文本中又与授权交换；三者不能只凭同一词名合并。自由在亲子文章中侧重不被阻挠，在服从文章中与理性、信任、契约和退出并存。成本既可能是货币和时间，也可能是关系、风险和机会；总账则取决于作者在具体文章中采用的账期。')
[void]$builder.AppendLine()
[void]$builder.AppendLine('爱、净输出和不掠夺彼此邻接，但原词覆盖范围不同：爱分布最广，净输出有直接定义，不掠夺的原词只见于少量文章。社会资本和信用也不能完全互换：信用侧重对未来行为的预期，社会资本侧重这种预期、声望和关系网络可以调用的资源。自然法有宗教与世俗两种表达，技术路径则主要处理在既定约束下怎样做成。')
[void]$builder.AppendLine()
[void]$builder.AppendLine('## 八、历时线索')
[void]$builder.AppendLine()
[void]$builder.AppendLine('2018—2020年的文本已经使用成本、总账、劳动、财富、可持续性、记录和系统条件。2021—2023年，自然法、净输出、不掠夺、授权、组织和关系分账等表达更集中。2024—2026年，许多概念获得更细的日常行动接口，例如选择与退出、尊重与不居功、伦理轨道、社会资本、能力与规划区分。这个时期划分只描述当前30词代表材料的重心，不证明思想线性进步，也不能排除早期存在相同用法。')
[void]$builder.AppendLine()
[void]$builder.AppendLine('## 九、结论')
[void]$builder.AppendLine()
[void]$builder.AppendLine('三十个概念共同呈现一种反复的文本动作：先确定事实和角色，再识别选择、能力、成本与责任；以爱、尊重和边界约束关系占用；以授权、礼仪、合作和信用组织多轮互动；最终由经验、记录、技术路径和自然后果检验行动。本文只把这种邻接关系重建为概念地图，不将研究者分组写成作者自称的学说。')

$content = $builder.ToString().TrimEnd() + "`r`n"
[IO.File]::WriteAllText([IO.Path]::GetFullPath($OutputPath),$content,[Text.UTF8Encoding]::new($false))
[ordered]@{
    outputPath = [IO.Path]::GetFullPath($OutputPath)
    dictionaryRows = $dictionary.Count
    uniqueTerms = @($dictionary.term | Sort-Object -Unique).Count
    exactQuoteFailures = 0
    characters = $content.Length
    status = 'PASS'
} | ConvertTo-Json

