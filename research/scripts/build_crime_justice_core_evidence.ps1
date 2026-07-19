param(
    [string]$CorpusPath = '.\sooon-q9adg-articles.jsonl',
    [string]$OutputPath = '.\research\data\crime_justice_core_evidence.csv',
    [string]$StatsPath = '.\research\data\crime_justice_core_evidence.stats.json'
)

$ErrorActionPreference = 'Stop'

$items = @(
    [ordered]@{ evidenceId='J01'; ordinal=2344; section='怀疑侦查定罪'; claim='作者区分侦查阶段的合理怀疑、侦查假说与审判阶段的有罪推定：前者投入资源证实或证伪，后者是不经证实或证伪便因嫌疑认定犯罪。'; quote='一般侦查、检察机关的作为所基于的是合理怀疑/侦查假说，不叫“有罪推定”。'; evidenceNature='明示程序定义'; boundary='关于纪委、监委调查可靠性的后续论述另属作者对具体制度的判断。' }
    [ordered]@{ evidenceId='J02'; ordinal=657; section='怀疑侦查定罪'; claim='作者把如实、平静、完整地陈述经过视为被调查者的较优策略，同时指出行为人可能因不知法律而不知道自己的行为已构成罪行。'; quote='这倒不见得一定意味着你会被判无罪——因为很多人是真的法盲，不知道自己的行为其实是罪行——但是对你已经是最好的策略。'; evidenceNature='明示行动建议兼因果判断'; boundary='针对题述报警情境；关于警方直觉及案件办理走向均作为作者推演保留。' }
    [ordered]@{ evidenceId='J03'; ordinal=611; section='怀疑侦查定罪'; claim='作者按控方、辩方、旁观方和裁判方分配不同判断权；缺少侦查和质证能力的旁观者只能在事实假设与个人观点两个限定下表达判断。'; quote='如果你是旁观方，也就是一名路人，你只要记住你可以有自己的正义观，但你缺少侦查手段、缺少质证的权力和机会，因此你要做任何结论，都要用“假设真实情节如下所述的话，那么按照我的看法，xxx属于诬告”这种形式。'; evidenceNature='明示角色与认识边界'; boundary='文中关于诽谤、举证和诉讼风险的具体说法不作外部法律事实使用。' }
    [ordered]@{ evidenceId='J04'; ordinal=770; section='怀疑侦查定罪'; claim='作者把沿时间线分开陈述情节、证据、猜测和观点，视为使控诉可被教师、交警或法官采用的基础叙事能力。'; quote='沿着一根时间轴，首尾相接，情节、证据、猜测、观点，依次铺开。'; evidenceNature='明示取证叙事方法'; boundary='文章由学校和交通纠纷类比司法判断，只记录该类比内部的作者观点。' }

    [ordered]@{ evidenceId='J05'; ordinal=2558; section='证据审判复核'; claim='作者主张司法过程是定罪不可省略的部分；个人即使自认亲见事实，也只能承担取证和举报成本，不能自行定罪。'; quote='司法过程对于定罪是一个绝对不可省略的过程。'; evidenceNature='明示程序原则'; boundary='针对题述小额偷窃处置；刑事罪名和证据效力未在文中作外部核验。' }
    [ordered]@{ evidenceId='J06'; ordinal=796; section='证据审判复核'; claim='作者把辩诉和审判理解为具有巨大不确定性的过程，强调在进入审判前解决纠纷，并认为进入上诉复核后纠正成本很高。'; quote='辩诉、审判是有巨大的不确定性的过程，你最好把问题拦截在这个过程之前就解决掉。'; evidenceNature='作者诉讼风险判断'; boundary='中美审判、二审概率和成本比较均作为文章内部经验判断。' }
    [ordered]@{ evidenceId='J07'; ordinal=2573; section='证据审判复核'; claim='作者不以各方满意定义司法公正，而把司法裁决的目标界定为未来社会的全局全域综合损耗和风险最小。'; quote='它一开始考虑的就只有“全局全域综合损耗/风险最小”。'; evidenceNature='明示司法目的定义'; boundary='文章没有以具体案件材料证明现实司法系统达到了这一标准。' }
    [ordered]@{ evidenceId='J08'; ordinal=1448; section='证据审判复核'; claim='作者认为公民即使掌握确切证据，也应呈现、提交证据并通过请愿、讨论或修法推动改变，而不能自行宣判司法判决不公。'; quote='甚至即使你有什么确切的证据，你也只能呈现、提交这些证据，而不能自行宣判“判决不公”，这个是普通公民没有的权利。'; evidenceNature='明示复核与权柄边界'; boundary='针对国家食品标准下载案件的判决评论，法律权威论只按作者立场记录。' }

    [ordered]@{ evidenceId='J09'; ordinal=1103; section='私人指控与程序权柄'; claim='作者要求私人控诉把事实细节、排除误会的理由和个人怀疑分层呈现，请旁人自行判断，而不是直接交付一项有罪判决。'; quote='正确的做法只能是对别人详细地描述完所有的事实细节——这不仅包括最初的事由，还包括你认为“误会的可能性可以充分排除”的恰当理由——然后按照“我现在怀疑我受到了无礼对待”的立场，把这个作为一种怀疑，而不是一个结论去对旁人讲述，请旁人做出自己的判断，而不是你直接抛出一个审判，让旁人相信你一定足够公正、足够诚实。'; evidenceNature='明示私人控诉规范'; boundary='适用于文中社交关系中的控罪问题，不替代具体侵害事件的调查程序。' }
    [ordered]@{ evidenceId='J10'; ordinal=3925; section='私人指控与程序权柄'; claim='作者把免于未经授权判断视为人的自由，认为判断只有在职责、请求、管辖或本人授权的范围内才获得权柄。'; quote='你需要意识到，人有免于判断的自由，这种自由是不应侵犯的。除非当事人以某种形式放弃了不被论断的权利，愿意将自己置于他人的判断之下，你是没有权利去判断的。只有被请求判断，得到了授权，你的判断才不能被视作一种对ta人自由的侵害。'; evidenceNature='明示权柄理论'; boundary='作者将法官、教师、医生、雇主和网络空间并置类比，具体授权效力只在其理论内部成立。' }
    [ordered]@{ evidenceId='J11'; ordinal=2256; section='私人指控与程序权柄'; claim='作者区分关系上的道歉反思与法律认罪，要求被指控者不自行宣布有罪或无罪，把公共罪责裁定留给法庭。'; quote='因此这个裁定你必须要留给法庭去做。但留给法庭去做决定的意思，是你自己要站一个“我不确定我有没有罪”的立场，而不是一个不等法庭裁定就自行宣布地“我绝对没罪”的立场。'; evidenceNature='明示关系与司法分层'; boundary='针对性骚扰公共指控；作者没有在文中提出客观认定标准。' }
    [ordered]@{ evidenceId='J12'; ordinal=3417; section='私人指控与程序权柄'; claim='作者把报案、起诉的程序权利与案件事实是否正确分开：支持当事人进入规范程序，不要求旁观者先替案件作实体判断。'; quote='如果要问支不支持所谓的报案起诉，我直截了当的告诉你们——我当然支持。出于任何自己觉得合理的原因而走规范程序去报案起诉，无论那个理由事后是否最终被判决所支持，都是所有人不可剥夺的当然权利。这根本不需要“报案人一定是正确的”、或者“报案人确实是正义的”这种前提条件。要我支持你，我也根本不需要非要搞清楚你到底是不是正义的或者正确的。'; evidenceNature='明示程序权利判断'; boundary='文章由平台禁言争议扩展到法院和平台程序，二者不在本文中被视为相同法律制度。' }

    [ordered]@{ evidenceId='J13'; ordinal=3079; section='报警警察律师'; claim='作者建议报案前咨询律师，按刑侦角度准备资料和证据，必要时由律师陪同，以提高报案沟通和立案的实际效果。'; quote='所以，记住，这是一个关键的生活常识——如果打算报案，建议在报案之前咨询律师要怎么准备报案资料和证据，甚至最好能直接请律师陪同去报案。'; evidenceNature='明示报案行动建议'; boundary='源于一则强奸案报案讨论；立案门槛、律师作用和警力成本均为作者经验判断。' }
    [ordered]@{ evidenceId='J14'; ordinal=697; section='报警警察律师'; claim='面对自称警察而身份无法确认的人，作者把拨打110、由到场人员接管身份核验视为最简单的处置办法。'; quote='其实最简单的办法就是不管三七二十一打110报警。'; evidenceNature='明示现场行动建议'; boundary='针对入户身份核验情境；接警和出警规则按文章表述保留。' }
    [ordered]@{ evidenceId='J15'; ordinal=602; section='报警警察律师'; claim='作者用“依法强硬”概括一种行动顺序：先了解法律，再凭法律给予的合法自由采取积极而强硬的边界立场。'; quote='先把法律了解清楚，然后凭借法律给予的合法自由采取积极的强硬立场。'; evidenceNature='明示行动定义'; boundary='文中关于正当防卫、立案和判罚的威慑性修辞不作为具体个案法律意见。' }
    [ordered]@{ evidenceId='J16'; ordinal=3067; section='报警警察律师'; claim='作者认为针对律师的职业暴力会改变法律服务风险和律师站位，因此主张其办案规格与伤害法官、检察官、警察及公务人员同等重要。'; quote='换句话来说，伤害律师案（类似的，还包括伤害记者案）在办案规格上有必要要提升到与伤害法官、检察官、警察和国家公务人员的同等重要程度来处理。'; evidenceNature='明示制度主张'; boundary='针对律师被枪杀事件；法律服务成本和立场异化是作者的制度因果解释。' }

    [ordered]@{ evidenceId='J17'; ordinal=3941; section='刑罚死刑预防'; claim='作者把尚不能废除死刑解释为社会尚不能在压力传递到最无助群体前消解压力，并将持续尝试废死设为道义方向。'; quote='我们之所以还不能废除死刑，是因为我们的社会还没有发达到能在压力传递到最无助的人群之前就消解掉它。是我们还太无能。'; evidenceNature='明示死刑因果判断'; boundary='社会压力、犯罪生成和死刑关系均是作者的伦理历史解释。' }
    [ordered]@{ evidenceId='J18'; ordinal=2686; section='刑罚死刑预防'; claim='作者认为事后刑罚不能替代对绝望生成机制的处理，预防的对象应是绝望本身以及制造、加深绝望的日常关系。'; quote='人类要与人类的绝望本身为敌，而不是去与已经绝望的人为敌。只专注在如何去除已经绝望的人，但却对制造和帮助绝望毫不在意，这样的“解决方案”其实是没有多大意义的。'; evidenceNature='明示预防原则'; boundary='从持刀伤人事件转入日常关系改进，文章未具体展开刑罚配置。' }
    [ordered]@{ evidenceId='J19'; ordinal=1647; section='刑罚死刑预防'; claim='作者按是否掌握公器区分行贿商人与受贿官员的责任，主张受贿方承担显著重于行贿方的刑罚。'; quote='行贿受贿往往是成对案件，如果行贿者判了死刑，那么受贿一方就应该有足够分量和规模的人承担相称的、显著更重的刑罚。'; evidenceNature='明示差异刑罚判断'; boundary='针对越南案件并联系中国吏治史，国家比较和历史因果均为作者判断。' }
    [ordered]@{ evidenceId='J20'; ordinal=940; section='刑罚死刑预防'; claim='作者把认错后的事实承认与赔偿额度分开；双方不能就代价达成一致时，应交由共同接受的仲裁机构或法院裁决。'; quote='如果仍然不能达成一致，那就只有仲裁机构和法院了——这些机构是法定默认的裁决机构，交到这些机构就大家愿赌服输。'; evidenceNature='明示比例与裁决程序'; boundary='讨论一般道歉、赔偿和认罚结构，未对应特定刑事量刑规则。' }

    [ordered]@{ evidenceId='J21'; ordinal=1156; section='悔改重新授信'; claim='作者认为缺乏灵活而持续的低强度惩罚，会使私人主体提高前科和合作筛选门槛，进而妨碍重新接纳、相互授信与小规模合作。'; quote='这导致的后果远远不止“前科分子难以获得社会再接纳”，它还引起了社会公民之间相互授信的门槛高耸入云，从而极大的冻结了社会成员之间的合作潜力，妨碍了社会信用的充分释放和构建，从根上阻碍了中国经济潜力的充分发挥。'; evidenceNature='作者制度因果判断'; boundary='中外轻罪、骚扰和累犯制度比较没有在本文中作外部数据验证。' }
    [ordered]@{ evidenceId='J22'; ordinal=3350; section='悔改重新授信'; claim='作者区分宗教赦免与现实责任：忏悔不取消徒刑、死刑或赔偿，赦免提供的是承担代价后仍不被最终抛弃的希望。'; quote='该十年徒刑的，还是十年徒刑；该绞死的，还是会绞死；该赔偿的，还是得要一分不少的面对追偿。'; evidenceNature='明示赦免与责任区分'; boundary='宗教史、炼狱和忏悔效果只作为作者的信仰与历史解释。' }
    [ordered]@{ evidenceId='J23'; ordinal=342; section='悔改重新授信'; claim='作者把惩罚定义为恢复坦荡、修复尊严、和好并恢复信任的手段，而不是制造恐惧记忆、使人不敢再犯的工具。'; quote='所以惩罚是一种恢复坦荡、修复尊严的手段，是一种和好和恢复信任的礼物，而绝不是制造恐怖记忆、让人“不敢再犯”的工具。'; evidenceNature='明示惩罚目的定义'; boundary='主要用于亲朋关系中的认错与惩罚，不等同于作者对全部国家刑罚的统一定义。' }
    [ordered]@{ evidenceId='J24'; ordinal=3261; section='悔改重新授信'; claim='作者反对父母以“永不原谅”作威慑，要求在严重错误后仍向子女保留被原谅、求助和恢复关系的希望。'; quote='请你务必不要急着绝望，因为只要我还没死，你被原谅的希望就不会断绝。'; evidenceNature='明示关系修复承诺'; boundary='面向父母对子女的关系语言；文末刑责提示没有展开具体年龄和罪责规则。' }

    [ordered]@{ evidenceId='J25'; ordinal=2670; section='亲属保密告解'; claim='作者认为神父举报会使未来有负罪感或犯罪意向的人不再吐露，从而破坏长期挽救渠道；同一后果逻辑被扩展到律师、医生、心理咨询师和配偶。'; quote='如果神父开始搞举报、作证，只会导致第一批“罪犯”不幸踩坑。其结果是将来的人们有罪恶感和负疚感就不会再吐露了。'; evidenceNature='作者保密后果论'; boundary='文章没有区分已经发生的犯罪、正在实施的危险与一般犯罪意向。' }
    [ordered]@{ evidenceId='J26'; ordinal=2252; section='亲属保密告解'; claim='作者认为子女对父母犯罪没有必然举报义务；其行动底线是不得参与、帮助或享受犯罪，并可在经济独立后自行决定是否举报。'; quote='换句话来说，子女对父母实际上没有举报犯罪的义务。'; evidenceNature='明示近亲伦理与程序判断'; boundary='引用中国刑事诉讼法并概括各国立场，具体法域效力未在本文中核验。' }
    [ordered]@{ evidenceId='J27'; ordinal=2958; section='亲属保密告解'; claim='作者把告解保密与机构包庇嫌疑写成教会必须承担的制度选择：保留忏悔神权就承受包庇指控，放弃保密才可能把问题收缩为个人犯罪。'; quote='要么，你就抱着你的忏悔神权，但同时扛住包庇罪，看看最终世人能不能原谅你，要么你就要放弃这一信仰利器，接受重大打击，但可以解除这个弱点。'; evidenceNature='明示制度两难'; boundary='针对天主教性侵危机；个案数量、资料内容与机构责任均只按作者论证记录。' }

    [ordered]@{ evidenceId='J28'; ordinal=3088; section='无知罪责后果'; claim='作者在人类授权关系中把执行者因无知犯错的责任追溯给任命、授权者；面对自然后果时，则认为无知不能阻止死亡或系统崩溃。'; quote='是给你责任、授予你权力的人要为你的无知自负其责。你因为无知犯的错，责任其实在指定你去做这事的人。'; evidenceNature='明示责任归属原则'; boundary='“人”与“天”的二层罪责属于作者自然法框架，不直接替代具体法律责任分配。' }
    [ordered]@{ evidenceId='J29'; ordinal=2645; section='无知罪责后果'; claim='作者把避免无知设为个人义务，并主张签约者以合同文本为准、为自己的理解和由无知造成的损失负责。'; quote='没人有义务因为你的无知而对你给予任何特权和优待，因为自己的无知而遭受的一切损失，都纯然的是你自己的责任，没人对此有赔偿义务。'; evidenceNature='明示无知后果判断'; boundary='合同、专业服务和法院解释权是文章讨论范围，欺诈、胁迫等例外未在文中展开。' }
    [ordered]@{ evidenceId='J30'; ordinal=2370; section='无知罪责后果'; claim='作者认为没有达到理想状态不自动产生罪责，罪的根据在于明知仍有进一步逼近的空间却拒绝善尽可能。'; quote='罪的根据，并非来自“未能符合理想”，而仅仅来自“未尽可能”。'; evidenceNature='明示过失与罪责定义'; boundary='从家属考公问题转入一般理想实践理论，未逐项对应刑法上的故意、过失或责任能力。' }
)

$corpus = [Collections.Generic.List[object]]::new()
foreach ($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($CorpusPath))) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $corpus.Add(($line | ConvertFrom-Json))
}

if ($corpus.Count -ne 4050) {
    throw "Expected 4050 corpus articles, found $($corpus.Count)."
}

$rows = [Collections.Generic.List[object]]::new()
foreach ($item in $items) {
    if ($item.ordinal -lt 1 -or $item.ordinal -gt $corpus.Count) {
        throw "[$($item.evidenceId)] Ordinal $($item.ordinal) is outside the corpus."
    }

    $article = $corpus[$item.ordinal - 1]
    $quoteOk = ([string]$article.text).Contains([string]$item.quote, [StringComparison]::Ordinal)
    if (-not $quoteOk) {
        throw "[$($item.evidenceId)] Exact quote validation failed at ordinal $($item.ordinal): $($item.quote)"
    }

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

$uniqueEvidenceIds = @($rows.evidenceId | Sort-Object -Unique).Count
$uniqueArticleIds = @($rows.id | Sort-Object -Unique).Count
$requiredSections = @('怀疑侦查定罪','证据审判复核','私人指控与程序权柄','报警警察律师','刑罚死刑预防','悔改重新授信','亲属保密告解','无知罪责后果')
$sectionCounts = [ordered]@{}
foreach ($section in $requiredSections) {
    $sectionCounts[$section] = @($rows | Where-Object section -eq $section).Count
}

$missingCoreFields = @($rows | Where-Object {
    [string]::IsNullOrWhiteSpace($_.evidenceId) -or
    [string]::IsNullOrWhiteSpace($_.section) -or
    [string]::IsNullOrWhiteSpace($_.claim) -or
    [string]::IsNullOrWhiteSpace($_.evidenceNature) -or
    [string]::IsNullOrWhiteSpace($_.boundary) -or
    [string]::IsNullOrWhiteSpace($_.id) -or
    [string]::IsNullOrWhiteSpace($_.date) -or
    [string]::IsNullOrWhiteSpace($_.title) -or
    [string]::IsNullOrWhiteSpace($_.url) -or
    [string]::IsNullOrWhiteSpace($_.quote)
}).Count
$allSectionsCovered = @($requiredSections | Where-Object { $sectionCounts[$_] -eq 0 }).Count -eq 0

$outputFull = [IO.Path]::GetFullPath($OutputPath)
$statsFull = [IO.Path]::GetFullPath($StatsPath)
New-Item -ItemType Directory -Force -Path ([IO.Path]::GetDirectoryName($outputFull)) | Out-Null
$rows | Export-Csv -LiteralPath $outputFull -NoTypeInformation -Encoding utf8BOM

$status = if (
    $rows.Count -eq 30 -and
    $uniqueEvidenceIds -eq $rows.Count -and
    $uniqueArticleIds -eq $rows.Count -and
    $missingCoreFields -eq 0 -and
    $allSectionsCovered -and
    -not ($rows.quoteExact -contains $false)
) { 'PASS' } else { 'REVIEW' }

$stats = [ordered]@{
    corpusArticles = $corpus.Count
    evidenceRows = $rows.Count
    uniqueEvidenceIds = $uniqueEvidenceIds
    uniqueArticleIds = $uniqueArticleIds
    questionLayers = $requiredSections.Count
    layerCounts = $sectionCounts
    missingCoreFields = $missingCoreFields
    quoteFailures = @($rows | Where-Object { -not $_.quoteExact }).Count
    status = $status
}
$stats | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $statsFull -Encoding utf8
$stats | ConvertTo-Json -Depth 6

if ($status -ne 'PASS') { exit 1 }
