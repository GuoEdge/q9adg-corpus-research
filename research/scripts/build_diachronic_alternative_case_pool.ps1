param(
    [string]$CorpusPath = (Join-Path $PSScriptRoot '..\..\sooon-q9adg-articles.jsonl'),
    [string]$CleanEvidencePath = (Join-Path $PSScriptRoot '..\data\author_view_evidence_clean.jsonl'),
    [string]$CoreEvidencePath = (Join-Path $PSScriptRoot '..\data\diachronic_core_evidence.csv'),
    [string]$OutputPath = (Join-Path $PSScriptRoot '..\data\diachronic_alternative_case_pool.csv'),
    [string]$StatsPath = (Join-Path $PSScriptRoot '..\data\diachronic_alternative_case_pool.stats.json')
)

$ErrorActionPreference = 'Stop'

function Get-Period([int]$Year) {
    if ($Year -ge 2018 -and $Year -le 2020) { return '2018-2020' }
    if ($Year -ge 2021 -and $Year -le 2023) { return '2021-2023' }
    if ($Year -ge 2024 -and $Year -le 2026) { return '2024-2026' }
    return 'outside'
}

function Get-Platform([string]$Url) {
    $hostName = try { ([uri]$Url).Host.ToLowerInvariant() } catch { '' }
    if ($hostName -like '*zhihu.com') { return 'Zhihu' }
    if ($hostName -like '*afdian.com' -or $hostName -like '*ifdian.net') { return 'Afdian' }
    return 'Other'
}

function Get-NodeText([Parameter(Mandatory)][object]$Node) {
    $builder = [Text.StringBuilder]::new()
    $stack = [Collections.Generic.Stack[object]]::new()
    $stack.Push($Node)
    while ($stack.Count -gt 0) {
        $current = $stack.Pop()
        if ($null -ne $current.PSObject.Properties['text']) {
            [void]$builder.Append([string]$current.text)
        }
        if ($null -eq $current.PSObject.Properties['children']) { continue }
        $children = @($current.children)
        for ($index = $children.Count - 1; $index -ge 0; $index--) { $stack.Push($children[$index]) }
    }
    return $builder.ToString()
}

$definitions = @(
    [pscustomobject]@{ trajectory='D01_事实定义与论辩'; role='ALTERNATIVE'; id='6647e494-2b80-57af-b903-a1b541d9fbf6'; authorClaim='表达者应把达意责任作为基本服务，并通过低利害实践训练表达能力。'; relationToCore='与《学好语文》共享表达失败先归于表达者的中期结构，并进一步给出误解风险自担及从低利害对话逐级练习的路径。'; exclusionReason='与核心《学好语文》共同承担中期表达责任；本文侧重风险自担和低利害训练，为避免同轨迹同阶段重复入格而保留为替代案例。'; quote='每个人都要为自己的表达承担达意责任，这是一种基本服务' },
    [pscustomobject]@{ trajectory='D01_事实定义与论辩'; role='CHALLENGE'; id='09575f9e-4f36-5a4e-84b3-95ee737857e8'; authorClaim='诚实不是保证永不出错，而是为事实担保划定范围并在失败后承担自己声明的责任。'; relationToCore='说明事实论辩还包含担保、误差与赔偿，不只包含表达是否清楚。'; exclusionReason='该文重心是事实担保责任，不直接承担批评程序的早中晚配对。'; quote='“诚实”在实践意义上是一种“事实保险业务”。' },

    [pscustomobject]@{ trajectory='D02_能力学习与主体'; role='ALTERNATIVE'; id='646df58c-b155-5563-8646-c7d5dae28529'; authorClaim='足量且适配水平的实战可以暴露侥幸和知识缺口，再引导主体回到理论学习。'; relationToCore='补充晚期能力形成的实践—复盘路径，不把学习只写成任务拆解。'; exclusionReason='晚期核心格已由《三分一又三分一》承担规划能力，本文作为并列学习机制保留。'; quote='你需要一套覆盖面完整的题，然后在题的引导下去看书。' },
    [pscustomobject]@{ trajectory='D02_能力学习与主体'; role='CHALLENGE'; id='22b8e565-a37b-531a-896d-68604a4264bf'; authorClaim='不知道某项后果不自动构成道德罪责，不能用旁观者掌握的利害关系反向给当事人定罪。'; relationToCore='限制用旁观者知识和优先级给当事人定罪，要求区分不知道、优先级不同与明知故犯。'; exclusionReason='主要承担能力判断的伦理边界，不是能力形成机制本身。'; quote='你只是不知道，不知者不为罪。' },

    [pscustomobject]@{ trajectory='D03_责任后果与授权'; role='ALTERNATIVE'; id='ea9197ca-0a2e-51ee-beeb-ca4773d4a549'; authorClaim='公众声望带来的影响力是关注者借出的公器，使用者应限制私怨并接受共同程序。'; relationToCore='把责任—授权交换扩展到公共影响力的受托和限用。'; exclusionReason='核心矩阵选择《服从》承担中期主体判断；本文专注公共声望，作为尺度扩展保留。'; quote='荣耀附带着权力，任何权力在本质上都是公器。' },
    [pscustomobject]@{ trajectory='D03_责任后果与授权'; role='CHALLENGE'; id='d4d427c5-38df-5cd1-931b-d0ad6a4fd6c0'; authorClaim='个人判断某事错误并不自动产生干预和执法权柄，只能在权限内提醒、举报或请求授权者处理。'; relationToCore='把权柄来源置于个人正误判断之前，限制责任感自行扩张为执法资格。'; exclusionReason='与晚期《赤手空拳》的责任—权柄接口构成限制性对读，不替换其资源交换功能。'; quote='世界上最大的是非，是权柄。' },

    [pscustomobject]@{ trajectory='D04_自由边界与退出'; role='ALTERNATIVE'; id='4323b869-06ea-5335-a116-9418e052e7a4'; authorClaim='若在一个组织中只有自己的利益持续被某人侵占，且所得被其与其他人瓜分，主体可能只是资源而非成员，此时应赶紧退出。'; relationToCore='补充自由边界的组织退出接口，而非只讨论家庭和亲密关系中的拒绝权。'; exclusionReason='篇幅集中于晚期组织处境，不承担三个时期的权利地位配对。'; quote='如果从头到尾只有你一个人的利益被侵犯，而这个人非常聪明，懂得把从你这里掠夺的利益和别人瓜分，那么你的问题就不是如何争取利益，而是要赶紧走人，因为在这种情况下，你根本就不是这个组织的成员，而只是ta们的资源。' },
    [pscustomobject]@{ trajectory='D04_自由边界与退出'; role='CHALLENGE'; id='2a88cc8a-0746-573a-9885-9fed9f447797'; authorClaim='父母给未独立子女发放生活费，应从短周期起步，只在连续账务清结且无违规挪用后逐级延长，失败时可降级。'; relationToCore='把主体的一般决定空间与本文所说、经连续账务执行取得的生活费管理范围分层。'; exclusionReason='它会挑战但不能替换《平权》《爱的底线》《一寸欢喜》所处理的主体决定空间。'; quote='每一级的提升都要以足够多连续周期的完美执行为准。例如一周一发升级到一月一发，必须以连续四周在误差范围内实现账务清结并确保没有发生违规挪用为准。' },

    [pscustomobject]@{ trajectory='D05_爱回应与不掠夺'; role='ALTERNATIVE'; id='8bc2c71a-1303-5254-a513-fdb710fb8876'; authorClaim='爱先产生关切；对方回应使关切生长，继而生成赞赏和认同，而不是先完成挑剔筛选才开始爱。'; relationToCore='为净所得、净输出和不掠夺之外增加爱的发生顺序。'; exclusionReason='处理发生层而非核心矩阵的结果判准，因此作为并列入口保留。'; quote='是爱生赞赏，而不是赞赏生爱。' },
    [pscustomobject]@{ trajectory='D05_爱回应与不掠夺'; role='CHALLENGE'; id='f6fe9e2d-ca06-5a84-82b6-b7fe1d331120'; authorClaim='爱的重点被置于劳动以及人与自然的生产关系；人际关系改善带来的狂喜只是进一步学习、生产和创造的准备。'; relationToCore='表明晚期爱论还包含生产轴，不能只按单一人际付出算法概括。'; exclusionReason='该文改变分析尺度，不适合替换《赛道》在关系不掠夺上的晚期核心功能。'; quote='爱的重点是劳动。' },

    [pscustomobject]@{ trajectory='D06_劳动财富与分配'; role='ALTERNATIVE'; id='f4ee69e7-9b6f-563b-a6b7-3abcef28fe36'; authorClaim='经典奴隶制的稳定依赖足够生产剩余和统治者的武力优势，劳动效率进入历史制度条件。'; relationToCore='把中期劳动从企业角色分账扩展到生产剩余和历史结构。'; exclusionReason='历史尺度与《资本家2》的企业内部尺度并列，不替换后者的角色分账功能。'; quote='一打几？一养几？' },
    [pscustomobject]@{ trajectory='D06_劳动财富与分配'; role='CHALLENGE'; id='2594339e-ab47-562d-bee7-c56fbb2ca325'; authorClaim='劳动教育应把劳动直接连接到成果享受、方案比较和工艺改进，勤奋可被解释为沉迷这种享受。'; relationToCore='说明劳动还具有享受和创造维度，不只承担分配、组织和社交补偿。'; exclusionReason='文章属于晚期教育场景，挑战单一经济尺度但不替换《两个钱包》的关系剩余接口。'; quote='所谓的“勤奋”，本质上就是“沉迷享乐”。' },

    [pscustomobject]@{ trajectory='D07_组织技术与公共能力'; role='ALTERNATIVE'; id='da098d20-c643-5f18-a4ae-2fd637101811'; authorClaim='汉字基准字形是应由公共力量持续提供、让社会低成本使用的文化基础设施。'; relationToCore='补充技术公共能力中的基础资源、长期浸润和公共维护。'; exclusionReason='属于文化基础设施案例，不直接承担组织继承或工程替代路线的核心格。'; quote='汉字因为其特殊性，其基准字形资源是一个不可以交付给单独商家来通过所谓“市场竞争”来自由博弈决定的公共事业。' },
    [pscustomobject]@{ trajectory='D07_组织技术与公共能力'; role='CHALLENGE'; id='6587f538-6d67-5561-99dd-2eaf61719621'; authorClaim='被市场淘汰但曾获成功的整套手艺方案仍应以少量津贴作最低限度保存，作为文明重建的技术种子。'; relationToCore='提醒当期竞争中的落后或淘汰不等于应彻底丢弃，还需另设保存尺度。'; exclusionReason='并不否定《胜半子》的当期替代路线，只增加退出竞争后的保存问题。'; quote='遗产保护只不过是将一度在市场上获得过成功的整套技术方案通过少量津贴做最低限度的保存' },

    [pscustomobject]@{ trajectory='D08_自然法伦理与风险'; role='ALTERNATIVE'; id='550b55cc-125d-5989-b69b-1d76045f01e6'; authorClaim='无知在人际授权关系中可以无罪，但物理和社会后果不会因不知道而停止发生。'; relationToCore='把自然法的普遍约束转成无知、授权与现实后果的分层。'; exclusionReason='与核心《自然法》同属中期，但承担后果示范而非概念定义。'; quote='无知在人是无罪的。' },
    [pscustomobject]@{ trajectory='D08_自然法伦理与风险'; role='CHALLENGE'; id='5ee11a26-89b1-5293-b168-468e96e31c3e'; authorClaim='妥协是在自然法禁令和爱的原则底线内，尽可能兼顾个人理想的折衷行动。'; relationToCore='把自然法从抽象约束定义转入妥协方案中不可伸缩的边界。'; exclusionReason='晚期核心《奠仪几何》承担伦理轨道；本文处理受力和折衷，作为另一行动接口保留。'; quote='换句话来说，我的妥协是在不违背自然法禁令和爱的原则底线上，尽可能兼顾我自己理想的折衷方案。' }
)

$articlesById = @{}
$ordinalsById = @{}
$ordinal = 0
foreach ($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($CorpusPath))) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $ordinal++
    $article = $line | ConvertFrom-Json
    $articlesById[[string]$article.id] = $article
    $ordinalsById[[string]$article.id] = $ordinal
}

$cleanIds = [Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
foreach ($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($CleanEvidencePath))) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $item = $line | ConvertFrom-Json
    [void]$cleanIds.Add([string]$item.id)
}

$coreIds = [Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
foreach ($row in Import-Csv -LiteralPath $CoreEvidencePath) { [void]$coreIds.Add([string]$row.id) }

$errors = [Collections.Generic.List[string]]::new()
$rows = foreach ($definition in $definitions) {
    if (-not $articlesById.ContainsKey($definition.id)) {
        $errors.Add("Missing corpus ID: $($definition.id)")
        continue
    }
    $article = $articlesById[$definition.id]
    $published = [DateTimeOffset]::FromUnixTimeMilliseconds([int64]$article.publishedAt).ToOffset([TimeSpan]::FromHours(8))
    $quoteStart = ([string]$article.text).IndexOf($definition.quote,[StringComparison]::Ordinal)
    if ($quoteStart -lt 0) { $errors.Add("Quote mismatch: $($definition.id) $($article.title)") }
    $lexical = [string]$article.lexical | ConvertFrom-Json
    $authorNodeTypes = [Collections.Generic.List[string]]::new()
    $topLevelQuoteMatchCount = 0
    foreach ($node in @($lexical.root.children)) {
        $nodeText = Get-NodeText $node
        if ($nodeText.IndexOf($definition.quote,[StringComparison]::Ordinal) -lt 0) { continue }
        if ([string]$node.type -eq 'quote') { $topLevelQuoteMatchCount++ }
        else { $authorNodeTypes.Add([string]$node.type) }
    }
    $questionContainsQuote = ([string]$article.question).IndexOf($definition.quote,[StringComparison]::Ordinal) -ge 0
    if ($authorNodeTypes.Count -eq 0) { $errors.Add("Quote missing from author Lexical node: $($definition.id) $($article.title)") }
    if ($topLevelQuoteMatchCount -gt 0) { $errors.Add("Quote also appears in top-level quote node: $($definition.id) $($article.title)") }
    if ($questionContainsQuote) { $errors.Add("Quote also appears in question field: $($definition.id) $($article.title)") }
    if (-not $cleanIds.Contains($definition.id)) { $errors.Add("Missing clean evidence: $($definition.id)") }
    if ($coreIds.Contains($definition.id)) { $errors.Add("Alternative overlaps core ID: $($definition.id)") }
    [pscustomobject][ordered]@{
        candidateId = ('{0}-{1}' -f $definition.trajectory.Substring(0,3),$definition.role.Substring(0,3))
        trajectory = $definition.trajectory
        role = $definition.role
        ordinal = [int]$ordinalsById[$definition.id]
        id = $definition.id
        title = [string]$article.title
        date = $published.ToString('yyyy-MM-dd')
        period = Get-Period $published.Year
        platform = Get-Platform ([string]$article.url)
        url = [string]$article.url
        authorClaim = $definition.authorClaim
        relationToCore = $definition.relationToCore
        exclusionReason = $definition.exclusionReason
        quote = $definition.quote
        quoteStart = $quoteStart
        authorLexicalNodeTypes = ($authorNodeTypes | Sort-Object -Unique) -join '|'
        topLevelQuoteMatchCount = $topLevelQuoteMatchCount
        questionContainsQuote = $questionContainsQuote
        cleanEvidencePresent = $cleanIds.Contains($definition.id)
        coreEvidenceOverlap = $coreIds.Contains($definition.id)
    }
}

$duplicateIds = @($rows | Group-Object id | Where-Object Count -gt 1)
$duplicateCandidateIds = @($rows | Group-Object candidateId | Where-Object Count -gt 1)
$trajectoryCounts = @($rows | Group-Object trajectory | ForEach-Object { [pscustomobject]@{ trajectory=$_.Name; count=$_.Count } })
$roleCounts = @($rows | Group-Object role | ForEach-Object { [pscustomobject]@{ role=$_.Name; count=$_.Count } })
if ($rows.Count -ne 16) { $errors.Add("Expected 16 rows, found $($rows.Count)") }
if ($duplicateIds.Count -gt 0) { $errors.Add("Duplicate candidate IDs: $($duplicateIds.Name -join ', ')") }
if ($duplicateCandidateIds.Count -gt 0) { $errors.Add("Duplicate candidate labels: $($duplicateCandidateIds.Name -join ', ')") }
foreach ($group in @($rows | Group-Object trajectory)) {
    if ($group.Count -ne 2) { $errors.Add("Trajectory count mismatch: $($group.Name)=$($group.Count)") }
    foreach ($role in @('ALTERNATIVE','CHALLENGE')) {
        $roleCount = @($group.Group | Where-Object role -eq $role).Count
        if ($roleCount -ne 1) { $errors.Add("Trajectory role mismatch: $($group.Name) $role=$roleCount") }
    }
}
foreach ($role in @('ALTERNATIVE','CHALLENGE')) {
    $count = @($rows | Where-Object role -eq $role).Count
    if ($count -ne 8) { $errors.Add("Role count mismatch: $role=$count") }
}

New-Item -ItemType Directory -Force -Path (Split-Path -Parent ([IO.Path]::GetFullPath($OutputPath))) | Out-Null
$rows | Sort-Object trajectory,role | Export-Csv -LiteralPath $OutputPath -NoTypeInformation -Encoding utf8BOM
$stats = [ordered]@{
    generatedAt = [DateTimeOffset]::UtcNow.ToString('o')
    scriptVersion = '2.0.0'
    inputCorpusFile = 'sooon-q9adg-articles.jsonl'
    inputCorpusSha256 = (Get-FileHash -LiteralPath ([IO.Path]::GetFullPath($CorpusPath)) -Algorithm SHA256).Hash
    corpusArticleCount = $articlesById.Count
    coreEvidenceCount = $coreIds.Count
    candidateCount = $rows.Count
    uniqueCandidateIdCount = @($rows.id | Sort-Object -Unique).Count
    uniqueCandidateLabelCount = @($rows.candidateId | Sort-Object -Unique).Count
    trajectoryCounts = $trajectoryCounts
    roleCounts = $roleCounts
    quoteFailureCount = @($rows | Where-Object quoteStart -lt 0).Count
    authorLexicalRoleFailureCount = @($rows | Where-Object { [string]::IsNullOrWhiteSpace($_.authorLexicalNodeTypes) }).Count
    topLevelQuoteMatchCount = [int](($rows | Measure-Object topLevelQuoteMatchCount -Sum).Sum)
    questionFieldMatchCount = @($rows | Where-Object questionContainsQuote).Count
    missingCleanEvidenceCount = @($rows | Where-Object { -not $_.cleanEvidencePresent }).Count
    coreEvidenceOverlapCount = @($rows | Where-Object coreEvidenceOverlap).Count
    validationErrors = @($errors)
    status = if ($errors.Count -eq 0) { 'PASS' } else { 'REVIEW' }
}
$stats | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $StatsPath -Encoding utf8
$stats | ConvertTo-Json -Depth 6
if ($errors.Count -gt 0) { throw ($errors -join [Environment]::NewLine) }
