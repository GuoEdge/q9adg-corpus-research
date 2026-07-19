param(
    [string]$CorpusPath = '.\sooon-q9adg-articles.jsonl',
    [string]$ScreeningPath = '.\research\data\media_public_opinion_screening.csv',
    [string]$OutputPath = '.\research\data\media_public_opinion_core_evidence.csv',
    [string]$StatsPath = '.\research\data\media_public_opinion_core_evidence.stats.json'
)

$ErrorActionPreference = 'Stop'

$items = @(
    [ordered]@{ evidenceId='M01'; ordinal=3890; section='信源、事实与核验'; claim='作者要求用户主动管理关注列表和推荐环境，把平台视为需要持续筛选信源的信息系统，而不是被动接受热榜。'; quote='知乎死没死，取决于你自己有没有管理好自己的关注列表，不取决于知乎自己的热榜。'; evidenceNature='明示信源管理建议'; boundary='文章给出的是作者个人的信息环境启发式，不保证被选择信源的事实正确性。' }
    [ordered]@{ evidenceId='M02'; ordinal=2853; section='信源、事实与核验'; claim='作者以能否追查到承担责任的来源区分有根和无根消息，并主张来不及核验的无根消息默认无效。'; quote='一个消息能追查到根源，就称为有根消息。'; evidenceNature='明示消息分类规则'; boundary='低成本默认规则会错过部分真实消息，作者以普通人的核验资源有限为前提接受这种错失。' }
    [ordered]@{ evidenceId='M03'; ordinal=757; section='信源、事实与核验'; claim='作者认为新闻生产偏爱反常、刺激和疑似事件，读者不能从报道声量直接推出异常行为的普遍程度。'; quote='看新闻要注意“新闻价值”造成的认知偏差。'; evidenceNature='明示新闻偏差判断'; boundary='文章没有提供具体事件的总体频率统计，只提出阅读时的校正原则。' }
    [ordered]@{ evidenceId='M04'; ordinal=767; section='信源、事实与核验'; claim='作者把未经基本调查便跟风传播对企业或个人的指控视为信息时代的责任问题，并要求在早期公开阻止。'; quote='一拍脑袋，连最基本的核实都不做'; evidenceNature='明示核验责任批评'; boundary='文中涉及企业经营的具体数字没有完成独立核算，不能据此确认被讨论企业的实际状况。' }

    [ordered]@{ evidenceId='M05'; ordinal=3899; section='新闻、采访与报道'; claim='作者不预设记者能够无立场地报道，认为读者应把相互偏执的报道作为控辩材料，自行承担交叉审查责任。'; quote='在媒体报道这个语境里，你的角色是而且始终是一个法官'; evidenceNature='明示新闻阅读角色'; boundary='作者把媒体博弈视为校正来源，但没有系统处理媒体合谋、共同盲点和专业核验程序。' }
    [ordered]@{ evidenceId='M06'; ordinal=1427; section='新闻、采访与报道'; claim='作者认为已有独立表达渠道的公众人物应直接向公众说话，避免把语境、剪辑和发布时间控制权交给未经验证的采访者。'; quote='如果你本来就功成名就，而且生活在现代，你要对公众说话，就一定要自己直接说。'; evidenceNature='明示采访风险建议'; boundary='文章为有长期职业信誉或可被有效制衡的记者保留例外。' }
    [ordered]@{ evidenceId='M07'; ordinal=1125; section='新闻、采访与报道'; claim='作者认为对极端袭击的连篇报道可能把影响力和名声作为行为奖励，因此主张克制、低调和限流式报道。'; quote='新闻媒体连篇累牍的报道小丑，本身就会为小丑增加动能。'; evidenceNature='作者报道后果判断'; boundary='袭击动机、限流效果和安全措施效力均为作者推演，文章也承认风险无法彻底消除。' }
    [ordered]@{ evidenceId='M08'; ordinal=3845; section='新闻、采访与报道'; claim='作者把紧急求助视为公共信息产品，要求准确描述需求、联系人、时效和终止状态，以减少无效转发和沟通成本。'; quote='一定要准确、有效、严谨的描述你所需要的具体帮助，以便最大限度的压缩无效信息的比例，提高有效信息被看到的速度和几率。'; evidenceNature='明示公共信息格式建议'; boundary='规范格式只改善求助被处理的条件，不被作者写成获得帮助的充分保证。' }

    [ordered]@{ evidenceId='M09'; ordinal=2836; section='谣言、纠错与认知责任'; claim='作者反对把异议、谣言和煽动统一装入“带节奏”，认为开放言路需要论文答辩式的怀疑技术。'; quote='一个人要广开言路，就不能随便动用“带节奏”这个口袋罪名'; evidenceNature='明示异议与谣言区分'; boundary='文章承认开放言路会放入谣言，但未给出平台处置每类内容的完整程序。' }
    [ordered]@{ evidenceId='M10'; ordinal=2877; section='谣言、纠错与认知责任'; claim='作者认为显示地址或剥夺发言权不能根除重复谎言，较稳固的防线是训练个人用跨学科常识发现异常并核查。'; quote='你只能尝试做一个就算把谎言重复一千遍也难以欺骗的人。'; evidenceNature='明示认知防线判断'; boundary='文章聚焦个人辨别能力，没有覆盖平台治理、专业事实核查和专家分歧。' }
    [ordered]@{ evidenceId='M11'; ordinal=2882; section='谣言、纠错与认知责任'; claim='作者把认知战解释为有组织攻击者以低成本制造足够小偏移，而无组织防守者以高成本辟谣和争论，因而易攻难守。'; quote='以无源的高成本战术对抗有源的低成本战术，其结果在数学上是确定无疑的。'; evidenceNature='作者认知战成本模型'; boundary='具体战争、宣传主体和成本差异属于作者推演；所谓非认知战方案没有展开。' }
    [ordered]@{ evidenceId='M12'; ordinal=235; section='谣言、纠错与认知责任'; claim='作者把儿童和童谣视为能绕开成人威慑与内容理解的特殊传播媒介，说明信息控制存在结构性绕行通道。'; quote='这就给某些信息打开一道特殊的绕行通道。'; evidenceNature='作者传播机制解释'; boundary='儿童传播、家长默许和政治信息流行的因果均为作者概括。' }

    [ordered]@{ evidenceId='M13'; ordinal=652; section='舆论、公众与多数'; claim='作者认为信息社会使个体同时承受相互冲突的多维意见压力，需要以物理、数学和历史事实以及主动怀疑保持判断。'; quote='有效的怀疑能力是这场十六维飓风里的定风珠。'; evidenceNature='作者信息社会判断'; boundary='信息技术与心理疾病、群体狂热的关系是作者的宏观推演。' }
    [ordered]@{ evidenceId='M14'; ordinal=824; section='舆论、公众与多数'; claim='作者反对把沉默者预设为同意自己但不敢发声，认为多数人常以法律、秩序和日常安全评估争议。'; quote='沉默的大多数不是沉默的站在你那边，而是站在法律那边。'; evidenceNature='作者多数心理判断'; boundary='具体案件中的多数态度没有外部调查，文章提供的是动员失败解释模型。' }
    [ordered]@{ evidenceId='M15'; ordinal=1386; section='舆论、公众与多数'; claim='作者把案件舆论中的激烈反应解释为对司法明察秋毫的过度期待，主张承认司法受证据、资源和人类能力限制。'; quote='司法本来就只有、也只能达到这么个水平，加强不了，提高不到你要的那种“明察秋毫”“不偏不倚”的水平。'; evidenceNature='作者司法舆论祛魅'; boundary='案件事实、法官责任和外部司法标准未在文章中核验。' }
    [ordered]@{ evidenceId='M16'; ordinal=404; section='舆论、公众与多数'; claim='作者认为面对舆论抹黑，长期不占便宜、不滥用权力和不以谣言报复会使对方故事的前提逐渐失效。'; quote='不打破这个原则，本身就是保护自己。'; evidenceNature='作者声誉防御判断'; boundary='文章讨论低质量阴谋叙事自行穿帮的条件，没有声称所有严重诽谤都无需回应。' }

    [ordered]@{ evidenceId='M17'; ordinal=3643; section='宣传、叙事与舆情权力'; claim='作者把中国较少争夺国际话语面子解释为维持西方安全感的战略选择，并认为舆论技巧不能换来真正尊重。'; quote='用舆论战赢来的，不会是真正的尊重，而只会是对你舆论技巧的警惕。'; evidenceNature='作者国际舆论战略判断'; boundary='大国心理、能力和战略选择均为作者解释，文本未核验政策决策过程。' }
    [ordered]@{ evidenceId='M18'; ordinal=2663; section='宣传、叙事与舆情权力'; claim='作者警惕用有意感人的榜样叙事建立人生信念，认为他人成败只能触发反思，不能证明道理本身。'; quote='别人成功或者失败，只能成为你反思你的道理的板机，而不能作为判定你的道理是否成立的决定性因素。'; evidenceNature='明示榜样叙事边界'; boundary='文章质疑具体文案的小说化但未调查当事人事实，重点是限制叙事的证明资格。' }
    [ordered]@{ evidenceId='M19'; ordinal=3797; section='宣传、叙事与舆情权力'; claim='作者认为面对有意塑造的敌对形象，仅列举有利事实不足以改变动员，应从对方文化内部的禁忌和公共理想组织行动。'; quote='世界只关心你要采取什么措施来抬高对方的成本、降低对方的效率、阻止对方的意图。'; evidenceNature='作者国际传播策略'; boundary='宗教史、反犹史和对华敌意因果极度压缩，均只作为作者的战略解释记录。' }
    [ordered]@{ evidenceId='M20'; ordinal=925; section='宣传、叙事与舆情权力'; claim='作者推演低价获客和高估值使经营风险转移后，管理层可能从产品品质转向媒体投资、粉丝共同体和舆情管理。'; quote='这很容易导致管理层的关注点从产品本身的具体品质、对用户的需求满足，转向“舆情管理”。'; evidenceNature='作者资本舆情机制推演'; boundary='具体公司、资本结构和媒体影响没有外部数据支持，不能作为投资判断或事实指控。' }

    [ordered]@{ evidenceId='M21'; ordinal=1586; section='平台算法与注意力'; claim='作者认为短视频算法以连续浅层刺激挤占长期记忆和技能形成，对尚未建立谋生能力的青少年尤其不利。'; quote='因此，短视频带给你的快乐实际上是拿未来的人格尊严交换来的。'; evidenceNature='作者短视频后果判断'; boundary='记忆、能力和成瘾机制属于作者文本内判断，成年人和青少年的条件被明确区分。' }
    [ordered]@{ evidenceId='M22'; ordinal=758; section='平台算法与注意力'; claim='作者以信息倍率衡量有限时间中的生命体验，并要求低信息密度直播的经营者认识观众越界和不稳定的风险。'; quote='有一个很基本的生存策略，你们要注意——尽量倍速摄取信息。'; evidenceNature='明示注意力建议'; boundary='文章没有系统处理陪伴、休闲和低密度交流的其他价值。' }
    [ordered]@{ evidenceId='M23'; ordinal=3618; section='平台算法与注意力'; claim='作者把标题和开头取得的注意力视为读者已支付的鉴定成本，写作者若不提供相称回报就损害基本信任。'; quote='你要确保这东西到后面的确有值得对方最初的关注的回报'; evidenceNature='明示注意力责任'; boundary='文章偏向功能性文字，没有覆盖艺术表达、游戏和非问题解决型写作的全部资格。' }
    [ordered]@{ evidenceId='M24'; ordinal=1537; section='平台算法与注意力'; claim='作者反对把错过某一应用窗口等同于落后时代，认为长期价值可以在后续媒介周期中重新获得传播机会。'; quote='如果你专注的是永恒性，那么任何时代对你都是周期长达12.4小时的潮汐，而且这个赶不上根本无所谓，下一个更香。'; evidenceNature='作者媒介周期判断'; boundary='文章不否认具体平台存在早期红利，只否认其是历史参与的唯一窗口。' }

    [ordered]@{ evidenceId='M25'; ordinal=3417; section='评论区、表达权与公共器具'; claim='作者把声望和关注者借出的影响力视为公器，要求公共动员与个人受伤、傲气和报复冲动分开。'; quote='荣耀附带着权力，任何权力在本质上都是公器。'; evidenceNature='明示影响力权柄判断'; boundary='文章支持通过平台和法院寻求程序裁决，同时要求接受共同规则作出的结果。' }
    [ordered]@{ evidenceId='M26'; ordinal=3849; section='评论区、表达权与公共器具'; claim='作者认为答主有权也有责任管理评论区，可以保留观点分歧而删除尖酸和伤害性的表达方式。'; quote='在我的评论区下，只存在观点的自由，不存在表达方式的自由。'; evidenceNature='明示评论区治理原则'; boundary='文章没有建立删除理由透明、平台公共性和申诉机制的完整边界。' }
    [ordered]@{ evidenceId='M27'; ordinal=3123; section='评论区、表达权与公共器具'; claim='作者区分平台保障的独立发表权与要求其他作者在私人评论区托管自己表达的权利。'; quote='保证你的平等发布权是平台的责任，根本就不是别的作者要在自己评论区对你承担的责任。'; evidenceNature='明示表达位置区分'; boundary='文章聚焦作者评论区裁量，没有讨论平台自身删除、推荐和封禁的责任。' }
    [ordered]@{ evidenceId='M28'; ordinal=3958; section='评论区、表达权与公共器具'; claim='作者认为健康公共环境应容纳阶段性、不同于主流的正名诉求，不把每次异议都当成秩序存亡决战。'; quote='正名本身不急，在正常框架内主张，等待正常程度出结果就是了。'; evidenceNature='作者公开异议程序判断'; boundary='文章对妇女一词的解释和替代名称属于作者判断，没有展开完整历史语义。' }

    [ordered]@{ evidenceId='M29'; ordinal=160; section='自媒体、创作者与公共关系'; claim='作者认为自媒体起点是无掠夺的分享和同乐，创作过程应能长期滋养本人，而不是先制造专业负担再等待回报。'; quote='只要你不掠夺什么，而是真的在分享，你分享的东西再卑微也不是问题。'; evidenceNature='明示自媒体创作原则'; boundary='文章还把善行作为面对未来毁谤的锚，但没有给出增长和盈利保证。' }
    [ordered]@{ evidenceId='M30'; ordinal=2742; section='自媒体、创作者与公共关系'; claim='作者把长期写作的变现理解为培养能够改变关系和世界的读者及后代，而非直接获得平台收入。'; quote='我的所有答案的主要——甚至是唯一的——目的，是要培养一群真正有效的爱人、父母、领袖。'; evidenceNature='作者自述写作目的'; boundary='未来读者贡献和回报是作者信念，不能由文本本身证明已经实现。' }
    [ordered]@{ evidenceId='M31'; ordinal=1052; section='自媒体、创作者与公共关系'; claim='作者认为公共关系不等于讨好所有批评者，有些不可操作风险可以接受，与特定对象保持不和也可能具有关系收益。'; quote='其实公共关系不但要谋求“与特定人群的关系足够好”，还要谋求“与特定人群的关系足够不好”。'; evidenceNature='明示公共关系定义扩展'; boundary='文章没有提供稳定识别恶意批评者的程序，也未实际比较提问中的企业。' }
    [ordered]@{ evidenceId='M32'; ordinal=1524; section='自媒体、创作者与公共关系'; claim='作者愿意推荐具有新鲜感、有效信息、研究或启发价值并显示利他性的内容，把涨粉放在内容价值和传播行动链中。'; quote='如果你的东西有新鲜感，有有效信息，有值得进一步研究的意义或者有某种启发性，并且我觉得你有看上去可见的利ta性，那么我会推荐我的读者关注你。'; evidenceNature='作者个人推荐标准'; boundary='文章提供的是作者个人经验和账号位置，不是平台增长统计规律。' }
)

$corpus = [Collections.Generic.List[object]]::new()
foreach ($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($CorpusPath))) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $corpus.Add(($line | ConvertFrom-Json))
}
if ($corpus.Count -ne 4050) { throw "Expected 4050 corpus articles, found $($corpus.Count)." }

$screenedIds = @{}
foreach ($row in Import-Csv -LiteralPath ([IO.Path]::GetFullPath($ScreeningPath))) {
    $screenedIds[[string]$row.id] = $true
}

$rows = [Collections.Generic.List[object]]::new()
foreach ($item in $items) {
    if ($item.ordinal -lt 1 -or $item.ordinal -gt $corpus.Count) { throw "[$($item.evidenceId)] Invalid ordinal $($item.ordinal)." }
    $article = $corpus[$item.ordinal - 1]
    if (-not $screenedIds.ContainsKey([string]$article.id)) { throw "[$($item.evidenceId)] Article is not in the screened candidate layer." }
    $quoteOk = ([string]$article.text).Contains([string]$item.quote, [StringComparison]::Ordinal)
    if (-not $quoteOk) { throw "[$($item.evidenceId)] Exact quote validation failed: $($item.quote)" }
    $date = [DateTimeOffset]::FromUnixTimeMilliseconds([int64]$article.publishedAt).ToOffset([TimeSpan]::FromHours(8)).ToString('yyyy-MM-dd')
    $rows.Add([pscustomobject][ordered]@{
        evidenceId = $item.evidenceId
        section = $item.section
        claim = $item.claim
        evidenceNature = $item.evidenceNature
        boundary = $item.boundary
        ordinal = $item.ordinal
        id = [string]$article.id
        date = $date
        title = [string]$article.title
        url = [string]$article.url
        quote = $item.quote
        quoteExact = $quoteOk
    })
}

$requiredSections = @(
    '信源、事实与核验','新闻、采访与报道','谣言、纠错与认知责任','舆论、公众与多数',
    '宣传、叙事与舆情权力','平台算法与注意力','评论区、表达权与公共器具','自媒体、创作者与公共关系'
)
$sectionCounts = [ordered]@{}
foreach ($section in $requiredSections) { $sectionCounts[$section] = @($rows | Where-Object section -eq $section).Count }
$uniqueEvidenceIds = @($rows.evidenceId | Sort-Object -Unique).Count
$uniqueArticleIds = @($rows.id | Sort-Object -Unique).Count
$missingCoreFields = @($rows | Where-Object {
    [string]::IsNullOrWhiteSpace($_.evidenceId) -or [string]::IsNullOrWhiteSpace($_.section) -or
    [string]::IsNullOrWhiteSpace($_.claim) -or [string]::IsNullOrWhiteSpace($_.evidenceNature) -or
    [string]::IsNullOrWhiteSpace($_.boundary) -or [string]::IsNullOrWhiteSpace($_.id) -or
    [string]::IsNullOrWhiteSpace($_.date) -or [string]::IsNullOrWhiteSpace($_.title) -or
    [string]::IsNullOrWhiteSpace($_.url) -or [string]::IsNullOrWhiteSpace($_.quote)
}).Count
$allSectionsCovered = @($requiredSections | Where-Object { $sectionCounts[$_] -ne 4 }).Count -eq 0

$rows | Export-Csv -LiteralPath ([IO.Path]::GetFullPath($OutputPath)) -NoTypeInformation -Encoding utf8BOM
$status = if (
    $rows.Count -eq 32 -and $uniqueEvidenceIds -eq 32 -and $uniqueArticleIds -eq 32 -and
    $screenedIds.Count -eq 298 -and $missingCoreFields -eq 0 -and $allSectionsCovered -and
    -not ($rows.quoteExact -contains $false)
) { 'PASS' } else { 'REVIEW' }
$stats = [ordered]@{
    corpusArticles = $corpus.Count
    screenedCandidates = $screenedIds.Count
    evidenceRows = $rows.Count
    uniqueEvidenceIds = $uniqueEvidenceIds
    uniqueArticleIds = $uniqueArticleIds
    missingCoreFields = $missingCoreFields
    exactQuoteFailures = @($rows | Where-Object quoteExact -eq $false).Count
    sectionCounts = $sectionCounts
    status = $status
}
$stats | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath ([IO.Path]::GetFullPath($StatsPath)) -Encoding utf8
$stats | ConvertTo-Json -Depth 5
if ($status -ne 'PASS') { throw "Media and public opinion core evidence validation ended with status $status." }
