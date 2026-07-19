param(
    [string]$CorpusPath = (Join-Path $PSScriptRoot '..\..\sooon-q9adg-articles.jsonl'),
    [string]$CleanEvidencePath = (Join-Path $PSScriptRoot '..\data\author_view_evidence_clean.jsonl'),
    [string]$OutputDir = (Join-Path $PSScriptRoot '..\data')
)

$ErrorActionPreference = 'Stop'
$OutputDir = [System.IO.Path]::GetFullPath($OutputDir)
New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null

function Get-Period([int]$Year) {
    if ($Year -ge 2018 -and $Year -le 2020) { return '2018-2020' }
    if ($Year -ge 2021 -and $Year -le 2023) { return '2021-2023' }
    if ($Year -ge 2024 -and $Year -le 2026) { return '2024-2026' }
    return 'outside'
}

function Get-Platform([string]$Url) {
    $sourceHost = try { ([uri]$Url).Host.ToLowerInvariant() } catch { '' }
    if ($sourceHost -like '*zhihu.com') { return 'Zhihu' }
    if ($sourceHost -like '*afdian.com' -or $sourceHost -like '*ifdian.net') { return 'Afdian' }
    return 'Other'
}

$definitions = @(
    [pscustomobject]@{ trajectory='D01_事实定义与论辩'; period='2018-2020'; id='11ad7ad3-87eb-5681-93e2-de3e21cbd8a2'; authorClaim='批评只能提供逻辑、疑问和论证，不能越线成为讽刺、定罪或构陷。'; evidenceNature='明示边界＋操作规范'; conditions='允许尖锐反对；限制的是人格攻击、入罪和构陷。'; quote='批评有一条细细的、意识几乎难以觉察、人常常不愿接受的红线——批评只能给逻辑、给疑问、给论证，不可以讽刺，不可以定罪，更不可以用作构陷的工具。' },
    [pscustomobject]@{ trajectory='D01_事实定义与论辩'; period='2021-2023'; id='8a7bdf9f-2cce-5d55-9210-618cfb05adcb'; authorClaim='表达者应承担把问题说清楚的技术责任，不能把沟通失败一概归给听者。'; evidenceNature='能力定义＋责任归属'; conditions='是否继续投入改进仍取决于具体沟通是否值得成本。'; quote='你必须先建立起这个基本原则。只有建立起这个原则，你才会去关心问题出在哪里，而不是永远把沟通无效的责任全都放在对方理解能力不够上。' },
    [pscustomobject]@{ trajectory='D01_事实定义与论辩'; period='2024-2026'; id='daa2da9d-9204-588a-88a3-a5d9006bf4d4'; authorClaim='批评造成的屈辱和沮丧只能是中间环节，批评者还要给出值得尝试的回弹路径。'; evidenceNature='过程模型＋行动接口'; conditions='给的是可尝试方法，不是保证立刻解决；无方法时只能请求体谅。'; quote='批评的应有结果不是屈辱、沮丧，屈辱和沮丧应该只是批评的中间环节，而不能是结束状态。' },

    [pscustomobject]@{ trajectory='D02_能力学习与主体'; period='2018-2020'; id='bbe903b2-99ab-5425-a566-e7dfd1ae6c2d'; authorClaim='自信是对自身能力具有信度的认识，而不是排名、自豪或被崇拜感。'; evidenceNature='明示定义＋结果校准'; conditions='一次成功不保证持续可靠，预期须由反复结果校准。'; quote='自信，是对自己拥有有信度的认知的人所处的心理状态。' },
    [pscustomobject]@{ trajectory='D02_能力学习与主体'; period='2021-2023'; id='ecfc1be7-86b5-57d6-806d-7a8fcc374949'; authorClaim='私产的作用之一是帮助主体接入公共服务和共同知识，脱贫还依赖学习与调用公共财富的能力。'; evidenceNature='财富重定义＋能力路径'; conditions='文中关于雇佣和公共服务价值的数量判断是作者的文本内事实判断。'; quote='你自己的私有财产，真正起到的作用是作为撬动公共财富的撬棒，挖掘公共财富矿藏的铁锹。' },
    [pscustomobject]@{ trajectory='D02_能力学习与主体'; period='2024-2026'; id='15e6750c-c146-58ea-b925-3a495204a3ef'; authorClaim='整体失败可能主要来自任务规模估计和工序规划不足，而非每个具体工序都做不到。'; evidenceNature='任务拆解＋能力诊断'; conditions='针对文中习得性无助场景；不排除具体工序本身也可能超出能力。'; quote='你不是完成任务的能力不足，而是规划的能力不足。' },

    [pscustomobject]@{ trajectory='D03_责任后果与授权'; period='2018-2020'; id='2133f3d8-4ccb-5c0f-9c09-1539ab21c794'; authorClaim='财富并非完全由个人劳动制造，获得更多财富同时意味着更大的管理责任。'; evidenceNature='归因扩展＋托付命题'; conditions='劳动仍是贡献和申请，不因财富被称为赐予而取消。'; quote='换句话来说，财富即责任。' },
    [pscustomobject]@{ trajectory='D03_责任后果与授权'; period='2021-2023'; id='8859afe4-31fa-5b72-a79a-675c16950c82'; authorClaim='服从是主体保留是非判断后作出的决定，不能与放弃判断的屈从混同。'; evidenceNature='概念对立＋授权判断'; conditions='命令权被限定于具体关系；实力本身不证明正误。'; quote='服从是一种决定。' },
    [pscustomobject]@{ trajectory='D03_责任后果与授权'; period='2024-2026'; id='ca0b2dd4-e67a-5243-a150-98c3b33953c1'; authorClaim='责任与信任、权柄、地位、资源和报酬相互对应，承担责任也是取得行动权限。'; evidenceNature='重新描述＋资源对应'; conditions='无相应授权的强加任务不自动成为福利，责任范围仍须定义。'; quote='负责任是福利，不是吃亏。' },

    [pscustomobject]@{ trajectory='D04_自由边界与退出'; period='2018-2020'; id='94815489-f471-5075-ac07-f496082d34db'; authorClaim='私权领域的平权不是结果对等，而是各方可以依自身条件主张、竞争和退出。'; evidenceNature='领域区分＋权利模型'; conditions='文章同时区分公共权利地位与私人交换，不把两者混为一层。'; quote='问题不在于女性要求这权利，而在于有人不想给。' },
    [pscustomobject]@{ trajectory='D04_自由边界与退出'; period='2021-2023'; id='eaa1d952-119f-5ebd-88ec-3093430f7530'; authorClaim='爱带有预先存在的行动底线，主体可以祈求回应，却不能把祈求升级为要求。'; evidenceNature='底线命题＋权限划界'; conditions='保留表达愿望；取消的是对他人回应的强制要求。'; quote='你可以祈求（pray），但你不能要求。一丝一毫都不行。' },
    [pscustomobject]@{ trajectory='D04_自由边界与退出'; period='2024-2026'; id='8db8f172-3520-5077-a078-2c9578ebaf39'; authorClaim='爱首先承认对方自由；反对、不资助和阻止是不同动作。'; evidenceNature='关系拆分＋行动边界'; conditions='自由不要求父母必须出资，也不取消成年行动者承担后果。'; quote='爱的第一要义是要接受人的自由。' },

    [pscustomobject]@{ trajectory='D05_爱回应与不掠夺'; period='2018-2020'; id='557cd798-03d7-57fd-a7a4-14f743e1ba13'; authorClaim='爱要按付出、有效性和被爱者实际净所得计算，失败不能转成向对方追债。'; evidenceNature='公式化总账＋责任回收'; conditions='公式是作者的关系模型；不表示所有情感价值都可精确计量。'; quote='被爱者的净所得N = 爱者的付出P*爱者的有效性系数E - 被爱者的无效性U' },
    [pscustomobject]@{ trajectory='D05_爱回应与不掠夺'; period='2021-2023'; id='bc0b8aa6-c51e-5c02-8b44-64f7c256154f'; authorClaim='爱是否成立不由行动者自我宣布，也不只由接受者感受裁决，而要看客观净输出。'; evidenceNature='判准压缩＋经济心理双账'; conditions='净输出可以很小；做得不出色与完全不是爱被作者区分。'; quote='你所行的是不是爱，标准既不在你手里，也不在对方手里，而在客观算法手里。' },
    [pscustomobject]@{ trajectory='D05_爱回应与不掠夺'; period='2024-2026'; id='9a72db20-919b-5a27-839d-2a80125dc09b'; authorClaim='亲密关系若存在竞争，竞争方向应是减少争夺、索债与掠夺。'; evidenceNature='竞争反转＋关系判准'; conditions='不争不等于不投入；双方仍可交换并相互净赠与。'; quote='爱如果是竞争，那么它争的就是不争。' },

    [pscustomobject]@{ trajectory='D06_劳动财富与分配'; period='2018-2020'; id='1a0c33e3-e996-5f61-a55e-751991bbdfa0'; authorClaim='劳动需求下降会使分配问题从怎样生产转向谁有资格获得技术和全球化成果。'; evidenceNature='历史趋势判断＋分配方案'; conditions='劳动趋势和税收效果属于作者的外部事实判断，本文只记录其论证位置。'; quote='可以说数学上看，唯一有效的补救方法就是对富人征大额的遗产税和所得税，重新分配给穷人。' },
    [pscustomobject]@{ trajectory='D06_劳动财富与分配'; period='2021-2023'; id='ad556f54-6be5-5da3-ae98-0591d1ff359a'; authorClaim='资本家以配置和出借资本分享利润，企业家则直接承担把事情做成的生产决策。'; evidenceNature='角色定义＋功能分账'; conditions='同一人可以兼具角色；该区分不自动证明现实权力已经平衡。'; quote='资本家，是指以出借资本来分享利润的人。' },
    [pscustomobject]@{ trajectory='D06_劳动财富与分配'; period='2024-2026'; id='05d3be97-1b30-5c13-8330-1c5bb3992838'; authorClaim='劳动合作产生的超额收益可以覆盖部分社交损耗，退出劳动也会失去这部分补偿资源。'; evidenceNature='公式模型＋反事实比较'; conditions='只有劳动剩余大于社交损耗时纯利为正，并非所有合作都成立。'; quote='劳动获利 - 劳动过程中社交损耗 = 劳动纯利。' },

    [pscustomobject]@{ trajectory='D07_组织技术与公共能力'; period='2018-2020'; id='5a32a445-202b-593a-a880-21c3716cd9cc'; authorClaim='技术基础设施变化在改变成本结构后会触发组织、制造和协作方式的联动变化。'; evidenceNature='系统推演＋成本阈值'; conditions='具体5G产业预测是作者当时的未来判断，不作为已验证结果。'; quote='当改变的成本低于不改变的成本，改变就会到来' },
    [pscustomobject]@{ trajectory='D07_组织技术与公共能力'; period='2021-2023'; id='8dedae32-f1a6-56bb-a836-49d58f2d86d4'; authorClaim='组织能力是成员推动组织有效完成共同目标并留下可继承能力，而非私人获领袖认可。'; evidenceNature='明示定义＋继承性检验'; conditions='组织外部反馈和随个人离开即消失的技能不能单独算作组织能力。'; quote='你是服务于组织，还是服务于组织的领袖个人，这个问题你一定要分清。' },
    [pscustomobject]@{ trajectory='D07_组织技术与公共能力'; period='2024-2026'; id='afd418f9-36d1-5652-8f90-188680e6cfbf'; authorClaim='当前做不出最小单元并不必然终止竞争，可以选择较易实现、能积累工艺并继续迭代的替代路线。'; evidenceNature='约束接受＋路径比较'; conditions='结论只是有机会赢半子，不是已经证明全面领先。'; quote='因为我们目前做不出小单元格，所以我们决定用大单元格叠两层的办法解决问题。' },

    [pscustomobject]@{ trajectory='D08_自然法伦理与风险'; period='2018-2020'; id='0d2e3bdf-c978-59ad-b127-abde090ff2c0'; authorClaim='善行是无现世对价的义务，不能用行善向神或他人索取必然回报。'; evidenceNature='宗教解释＋反交易命题'; conditions='无对价不取消文本后段关于文明合作成本的另一条世俗论证。'; quote='你行善，是一种义务，没有任何对价的义务。' },
    [pscustomobject]@{ trajectory='D08_自然法伦理与风险'; period='2021-2023'; id='4e7ea5d1-018f-5e57-839c-f91e3065007d'; authorClaim='自然法是不同智慧主体在语言、风俗和契约不相通时仍会承认的约束交集。'; evidenceNature='思想实验＋明示定义'; conditions='文章为保持问题意义采用狭义自然法，广义还包含自然规律。'; quote='这个交集里装着的，就是自然法。' },
    [pscustomobject]@{ trajectory='D08_自然法伦理与风险'; period='2024-2026'; id='9af3f757-ffb6-5c9e-b461-afdf9ccea949'; authorClaim='伦理可以借责任、礼数和声誉后果为行动设置强硬轨道。'; evidenceNature='行动示范＋机制命题'; conditions='轨道成立依赖提问者先履行费用责任，并接受最后可能亏本。'; quote='伦理其实是一件武器，学会巧妙的运用，你可以为人的行为设立强硬的轨道，随时可以限制住事态向你不希望的方向发展。' }
)

$articlesById = @{}
$articleOrdinals = @{}
$allArticles = [System.Collections.Generic.List[object]]::new()
$ordinal = 0
Get-Content -LiteralPath $CorpusPath -Encoding UTF8 | ForEach-Object {
    $ordinal++
    $item = $_ | ConvertFrom-Json
    $articlesById[$item.id] = $item
    $articleOrdinals[$item.id] = $ordinal
    $allArticles.Add($item)
}

$cleanById = @{}
Get-Content -LiteralPath $CleanEvidencePath -Encoding UTF8 | ForEach-Object {
    $item = $_ | ConvertFrom-Json
    $cleanById[$item.id] = $item
}

$errors = [System.Collections.Generic.List[string]]::new()
$rows = foreach ($definition in $definitions) {
    if (-not $articlesById.ContainsKey($definition.id)) {
        $errors.Add("Missing raw article: $($definition.id)")
        continue
    }
    if (-not $cleanById.ContainsKey($definition.id)) {
        $errors.Add("Missing clean evidence: $($definition.id)")
    }
    $article = $articlesById[$definition.id]
    $published = [DateTimeOffset]::FromUnixTimeMilliseconds([int64]$article.publishedAt).ToOffset([TimeSpan]::FromHours(8))
    $actualPeriod = Get-Period $published.Year
    if ($actualPeriod -ne $definition.period) {
        $errors.Add("Period mismatch: $($definition.id) expected $($definition.period) actual $actualPeriod")
    }
    $quoteStart = ([string]$article.text).IndexOf($definition.quote, [StringComparison]::Ordinal)
    if ($quoteStart -lt 0) {
        $errors.Add("Quote mismatch: $($definition.id) $($article.title)")
    }
    $paragraphIndex = if ($quoteStart -ge 0) {
        1 + ([regex]::Matches(([string]$article.text).Substring(0, $quoteStart), "`n")).Count
    } else { -1 }
    [pscustomobject][ordered]@{
        evidenceId = ('{0}-{1}' -f $definition.trajectory.Substring(0,3), $definition.period)
        trajectory = $definition.trajectory
        period = $definition.period
        ordinal = $articleOrdinals[$definition.id]
        id = $definition.id
        title = $article.title
        date = $published.ToString('yyyy-MM-dd')
        platform = Get-Platform $article.url
        url = $article.url
        authorClaim = $definition.authorClaim
        evidenceNature = $definition.evidenceNature
        conditions = $definition.conditions
        quote = $definition.quote
        quoteStart = $quoteStart
        paragraphIndex = $paragraphIndex
        cleanEvidencePresent = $cleanById.ContainsKey($definition.id)
    }
}

$trackedTerms = [ordered]@{
    fact = '事实'
    ability = '能力'
    responsibility = '责任'
    freedom = '自由'
    love = '爱'
    labor = '劳动'
    naturalLaw = '自然法'
    ethics = '伦理'
}
$buckets = @{}
foreach ($article in $allArticles) {
    $published = [DateTimeOffset]::FromUnixTimeMilliseconds([int64]$article.publishedAt).ToOffset([TimeSpan]::FromHours(8))
    $period = Get-Period $published.Year
    if ($period -eq 'outside') { continue }
    $platform = Get-Platform $article.url
    $key = "$period|$platform"
    if (-not $buckets.ContainsKey($key)) {
        $buckets[$key] = [ordered]@{ articleCount = 0; terms = [ordered]@{} }
        foreach ($termKey in $trackedTerms.Keys) { $buckets[$key].terms[$termKey] = 0 }
    }
    $buckets[$key].articleCount++
    foreach ($termKey in $trackedTerms.Keys) {
        if (([string]$article.text).Contains($trackedTerms[$termKey], [StringComparison]::Ordinal)) {
            $buckets[$key].terms[$termKey]++
        }
    }
}

$platformRows = foreach ($key in ($buckets.Keys | Sort-Object)) {
    $parts = $key -split '\|', 2
    $bucket = $buckets[$key]
    foreach ($termKey in $trackedTerms.Keys) {
        [pscustomobject][ordered]@{
            period = $parts[0]
            platform = $parts[1]
            articleCount = $bucket.articleCount
            term = $termKey
            literal = $trackedTerms[$termKey]
            documentCount = $bucket.terms[$termKey]
            documentRate = [Math]::Round($bucket.terms[$termKey] / $bucket.articleCount, 6)
        }
    }
}

$duplicateIds = @($rows | Group-Object id | Where-Object Count -gt 1 | ForEach-Object Name)
$trajectoryCounts = @($rows | Group-Object trajectory | ForEach-Object { [pscustomobject]@{ trajectory=$_.Name; count=$_.Count } })
$periodCounts = @($rows | Group-Object period | ForEach-Object { [pscustomobject]@{ period=$_.Name; count=$_.Count } })
if ($rows.Count -ne 24) { $errors.Add("Expected 24 evidence rows, got $($rows.Count)") }
if ($duplicateIds.Count -gt 0) { $errors.Add("Duplicate evidence IDs: $($duplicateIds -join ', ')") }
foreach ($group in $trajectoryCounts) { if ($group.count -ne 3) { $errors.Add("Trajectory count mismatch: $($group.trajectory)=$($group.count)") } }
foreach ($group in $periodCounts) { if ($group.count -ne 8) { $errors.Add("Period count mismatch: $($group.period)=$($group.count)") } }

$evidencePath = Join-Path $OutputDir 'diachronic_core_evidence.csv'
$platformPath = Join-Path $OutputDir 'diachronic_period_platform_stats.csv'
$statsPath = Join-Path $OutputDir 'diachronic_core_evidence.stats.json'
$rows | Sort-Object trajectory, period | Export-Csv -LiteralPath $evidencePath -NoTypeInformation -Encoding utf8BOM
$platformRows | Export-Csv -LiteralPath $platformPath -NoTypeInformation -Encoding utf8BOM
[pscustomobject][ordered]@{
    generatedAt = [DateTimeOffset]::Now.ToString('o')
    corpusArticleCount = $allArticles.Count
    cleanEvidenceCount = $cleanById.Count
    evidenceRowCount = $rows.Count
    uniqueEvidenceIdCount = @($rows.id | Sort-Object -Unique).Count
    quoteOrdinalFailureCount = @($rows | Where-Object quoteStart -lt 0).Count
    missingCleanEvidenceCount = @($rows | Where-Object { -not $_.cleanEvidencePresent }).Count
    periodCounts = $periodCounts
    trajectoryCounts = $trajectoryCounts
    duplicateIds = $duplicateIds
    validationErrors = @($errors)
    status = if ($errors.Count -eq 0) { 'PASS' } else { 'FAIL' }
} | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $statsPath -Encoding utf8BOM

if ($errors.Count -gt 0) { throw ($errors -join [Environment]::NewLine) }
Write-Output "PASS: $($rows.Count) evidence rows; 0 quote failures; 0 duplicate IDs."
