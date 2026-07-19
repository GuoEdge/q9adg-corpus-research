param(
    [string]$CorpusPath = '.\sooon-q9adg-articles.jsonl',
    [string]$ScreeningPath = '.\research\data\ecology_nature_screening.csv',
    [string]$OutputPath = '.\research\data\ecology_nature_core_evidence.csv',
    [string]$StatsPath = '.\research\data\ecology_nature_core_evidence.stats.json'
)

$ErrorActionPreference='Stop'
$approvedSupplementOrdinals=@(822,2087)
$items=@(
    [ordered]@{evidenceId='N01';ordinal=2695;section='自然观、规律与人的位置';claim='作者认为语言和数学都是描述关系的符号系统，语言先于完整意义上的人类，故数学具有先在性。';quote='数学本来是人类用来描述事物关系的一种语言';evidenceNature='概念本体论与语言—数学类比';boundary='动物研究只被用于支持方向判断，未形成语言演化证据链。'}
    [ordered]@{evidenceId='N02';ordinal=3493;section='自然观、规律与人的位置';claim='作者认为人类交通、环境改造、繁育和基因工程加速了其他生物的演化，文明人类自身反而可能演化较慢。';quote='人类自己直接参与了新品种的繁育和筛选';evidenceNature='人类活动与演化速度因果模型';boundary='“保护使演化归零”是文章收束性推演，不能扩展成普遍保护理论。'}
    [ordered]@{evidenceId='N03';ordinal=4048;section='自然观、规律与人的位置';claim='作者认为医学借人口密度和社会竞争提高人类面临的选择压力，而非单向阻碍演化。';quote='演化的动力是来自种群密度超标';evidenceNature='人口密度、技术与选择压力推演';boundary='原文把社会末位淘汰和生物演化连用，应保留其文本定义，不能改写成既定生物学结论。'}
    [ordered]@{evidenceId='N04';ordinal=4033;section='自然观、规律与人的位置';claim='作者把智力定义为不改变遗传特征而应付多样环境的能力，并认为全球环境趋同未必有利于动物智力发展。';quote='智力还有另一种更加确切和简单的定义方式：即对多样环境的“应付力”';evidenceNature='智力的作者操作性定义';boundary='指标体系是文章提出的测量方案，不是作者引用的通行定义。'}
    [ordered]@{evidenceId='N05';ordinal=3955;section='自然观、规律与人的位置';claim='作者认为生命靠摄入承载负熵的大分子维持有序，嗅觉厌恶帮助动物回避营养耗尽后的分解物。';quote='我们摄入大分子、排出小分子';evidenceNature='热力学、生理与感官统一解释';boundary='文章以高度概括的分子模型解释营养和气味，未逐类处理例外。'}
    [ordered]@{evidenceId='N06';ordinal=2270;section='自然观、规律与人的位置';claim='作者认为代谢率主要服从物种生存策略，小体型与高速代谢只是经常共同服务于快速繁殖。';quote='实际上新陈代谢只和生存策略有关';evidenceNature='跨物种反例与同果二因辨析';boundary='文章只提供病毒和龟类等反例，未做跨物种系统比较。'}

    [ordered]@{evidenceId='N07';ordinal=4036;section='生态系统、生物多样性与保护';claim='作者把人类与动物的关系分为接触、理解、管理三阶段，并认为管理动物首先要求管理人类自身的开发、排放和捕猎。';quote='我们将这三阶段分别称为接触、理解与管理';evidenceNature='人类—动物关系阶段模型';boundary='“大型动物最终成为广义家畜”是附条件的未来推演。'}
    [ordered]@{evidenceId='N08';ordinal=1387;section='生态系统、生物多样性与保护';claim='作者主张把保护名单倒置为允许利用名单，未获批准利用的动物原则上都受保护。';quote='《保护动物名单》应该改为《允许利用动物名单》';evidenceNature='动物名录制度反转方案';boundary='短文未展开审核标准、既有利用和执法机制。'}
    [ordered]@{evidenceId='N09';ordinal=3125;section='生态系统、生物多样性与保护';claim='作者预测农业将工业化，并要求旧农地转向恢复多层次、有弹性和有容量的生态系统。';quote='其中最至关重要的转变，就是粮食生产工业化';evidenceNature='产业、土地与生态长期情景';boundary='百年转型、能源和太空用途均为作者远期预测。'}
    [ordered]@{evidenceId='N10';ordinal=3942;section='生态系统、生物多样性与保护';claim='作者认为山火治理受火场、水源、机场、森林多样性和林区含水量共同制约，原生多样性本身具有抑火功能。';quote='我们极其需要保护原生树林的多样性';evidenceNature='生态与消防工程系统分析';boundary='消防机队数量、成本和具体因果是文内估算。'}
    [ordered]@{evidenceId='N11';ordinal=3009;section='生态系统、生物多样性与保护';claim='作者认为沙漠并非待消灭的空白荒地，而可能是扬尘、海洋浮游生物、降雨和更大生态循环的关键环节。';quote='沙漠和冰川、深海一样，虽然身为“不毛之地”，但却是生态循环里一个特殊的关键环节，而且恐怕还是不可替代的一环';evidenceNature='反开发直觉与生态系统联系推演';boundary='作者使用“可能”“恐怕”，并未把具体循环做成完整证据链。'}
    [ordered]@{evidenceId='N12';ordinal=2087;section='生态系统、生物多样性与保护';claim='作者认为保护生命和生命多样性的社群会受到社会规律奖励，灭绝和无谓杀生则受到社群筛选惩罚。';quote='社会规律会自然而然的奖励保护生命、保护生命多样性的行为';evidenceNature='古语重释与自然法伦理模型';boundary='这是作者对古语和社群筛选的解释，不是生态学定律。'}

    [ordered]@{evidenceId='N13';ordinal=3180;section='气候、灾害与文明韧性';claim='作者认为灾害可能脱离历史危险带，治理应由单纯防灾转向防灾、抗灾和容灾并重。';quote='不但要加强防灾力、抗灾力，还要增强容灾率';evidenceNature='气候、基础设施与国际秩序系统论';boundary='新冠、土地制度和全球领导权之间的联系均属作者综合判断。'}
    [ordered]@{evidenceId='N14';ordinal=1793;section='气候、灾害与文明韧性';claim='作者认为多年生乔木的大面积折损可作为灾害超出当地常态的观察指标。';quote='当地的树木是一个很好的观察点';evidenceNature='环境指示物推理';boundary='文章用树木作关键观察点，但未说它足以单独完成灾害归因。'}
    [ordered]@{evidenceId='N15';ordinal=2851;section='气候、灾害与文明韧性';claim='作者要求家庭建立便携、耐储、分层且平时不轻易动用的灾备，以渡过初期无序并稳定决策。';quote='都应该有自己的备灾物资储备';evidenceNature='个人灾害韧性操作方案';boundary='适用于一般灾害准备，不是气候灾害专论。'}
    [ordered]@{evidenceId='N16';ordinal=2183;section='气候、灾害与文明韧性';claim='作者认为各文明洪水神话可能分别源于平原农业社会对普通河流泛滥的共同经验，而非一次全球洪水。';quote='原始农业社会对几年一度的母亲河泛滥的正常记忆';evidenceNature='农业、水文与神话历史假说';boundary='年代、传播和水文解释均是文本假说。'}
    [ordered]@{evidenceId='N17';ordinal=3147;section='气候、灾害与文明韧性';claim='作者认为传染病、生态巨变和异常气候会迫使社会适应不可抗拒的自然新常态。';quote='最后只能是人类社会对不可抗拒的自然新常态做出适应';evidenceNature='文明适应与制度演变预测';boundary='东亚和西方制度比较是作者的政治—文化判断。'}
    [ordered]@{evidenceId='N18';ordinal=2274;section='气候、灾害与文明韧性';claim='作者认为中国冲积平原的灌溉、防灾和流域协调需求塑造了大规模国家治理。';quote='整个文明都建立在灌溉、防灾这个围绕水利的主题上';evidenceNature='地理、水利与国家形成模型';boundary='中国和希腊的对照是宏观类型化解释。'}

    [ordered]@{evidenceId='N19';ordinal=3038;section='能源、矿产与资源约束';claim='作者认为煤电退出后核电和绿电会承接海外市场，核电还通过标准、运维和能源安全形成长期秩序绑定。';quote='区别只是以煤电方式去吃，还是核电方式去吃，还是绿电方式去吃';evidenceNature='能源产业和地缘战略分析';boundary='文章主要讨论国家竞争，不是核安全或环境评估。'}
    [ordered]@{evidenceId='N20';ordinal=2388;section='能源、矿产与资源约束';claim='作者把核电站的首要周边风险放在战争和动荡中成为高价值攻击目标。';quote='危险主要在这方面，所以核电站终究还是要远离人口中心';evidenceNature='核电风险重分类';boundary='原文是在比较风险优先级，不等于否认事故和污染存在。'}
    [ordered]@{evidenceId='N21';ordinal=548;section='能源、矿产与资源约束';claim='作者认为乘用车由油转电取决于人口密度和充换电、电网等基础设施，燃油技术仍会留在货运、工程和军用领域。';quote='电动车的里程成本优势和动力优势太大';evidenceNature='条件性能源与产业路径预测';boundary='作者没有主张所有场景同时淘汰内燃机。'}
    [ordered]@{evidenceId='N22';ordinal=1237;section='能源、矿产与资源约束';claim='作者预测换电站最终会成为储能、能源服务、电池回收和无人驾驶的基础设施。';quote='换电站才是下一代电车市场争夺的关键制高点';evidenceNature='换电企业与基础设施情景';boundary='围绕蔚来展开，站点规模和车企合作属于预测。'}
    [ordered]@{evidenceId='N23';ordinal=3284;section='能源、矿产与资源约束';claim='作者认为标准化换电更适合人口稠密地区，并可作为电网边缘蓄水池。';quote='众多换电站的存在也可以作为“边缘蓄水池”为电网的稳定运作提供很大的缓冲';evidenceNature='换电与电网能源技术路线';boundary='氢能用途、特斯拉路线和地区适用性均为作者的强判断。'}
    [ordered]@{evidenceId='N24';ordinal=1825;section='能源、矿产与资源约束';claim='作者认为降雨和河流搬运既富集黄金，也为远端浅海和湿地的石油形成提供物质及生态条件。';quote='这个随机均匀分布很快就遇到了一个天然的富集机制——那就是地表的降雨循环';evidenceNature='资源成因解释';boundary='全文未附地质资料，不能扩展为所有金矿和油田的统一成因。'}

    [ordered]@{evidenceId='N25';ordinal=3944;section='农业、农村、土地与粮食';claim='作者认为商周工具、测绘、土方和灌溉能力不足以长期大面积实行严格方格井田。';quote='技术不行，田就不方；技术够用，田方了，天下已经碎成粉了';evidenceNature='工程约束反证与历史技术分析';boundary='否定的是严格、稳定、大面积井田制，不是否认一切规则田块。'}
    [ordered]@{evidenceId='N26';ordinal=2219;section='农业、农村、土地与粮食';claim='作者认为中国可把发展部门能力转向工业化农业维持生存，但代价是其他产品和发展资源短缺。';quote='一旦遇到了生存危机';evidenceNature='粮食禁运反事实推演';boundary='一两年转型和产量判断是作者预测。'}
    [ordered]@{evidenceId='N27';ordinal=2797;section='农业、农村、土地与粮食';claim='作者认为粮食短缺首先压迫穷国，并经矿产、政权、援助和通胀把成本传导到富裕国家。';quote='当粮食开始短缺，最缺的一定会是最穷的发展中国家';evidenceNature='国际粮价连锁模型';boundary='两条路径是情景推演，不是对所有国家的固定次序。'}
    [ordered]@{evidenceId='N28';ordinal=567;section='农业、农村、土地与粮食';claim='作者认为现代人口规模依赖农药、化肥、抗生素等高密度生产手段，消费者诉求之间可能互相冲突。';quote='在这两项技术之前的世界农业生产根本不足以支撑这么大的人口规模';evidenceNature='生产约束与专业监管论证';boundary='原文主张可信专业监督，不是农业投入品的安全使用规范。'}
    [ordered]@{evidenceId='N29';ordinal=3458;section='农业、农村、土地与粮食';claim='作者猜测美国蔬果价格高主要源于人口分散、运输距离和净菜加工链条。';quote='美国蔬菜产品的运输里程数和中国农产品是不能相提并论的';evidenceNature='中美农产品供应链比较';boundary='作者开篇明确使用“我猜测”并邀请修正。'}
    [ordered]@{evidenceId='N30';ordinal=4041;section='农业、农村、土地与粮食';claim='作者认为小体型动物把更高比例食物能量转成散热，因此不适合肉用养殖。';quote='个体越小的动物越不节能';evidenceNature='简短生物能量解释';boundary='只有两句论证，未计算繁殖率、饲料、设施和加工成本。'}

    [ordered]@{evidenceId='N31';ordinal=740;section='动物、植物与跨物种关系';claim='作者认为虐待动物立法的根本难题是如何区分屠宰、杀生和虐待，并以历史神圣仪式或专业资格解释早期处理方式。';quote='虐待动物要立法，第一个难题就是如何处理畜牧业和屠宰业';evidenceNature='历史伦理与制度解释';boundary='对历史解决方式的解释不能直接改写为作者赞成所有相关制度。'}
    [ordered]@{evidenceId='N32';ordinal=4029;section='动物、植物与跨物种关系';claim='作者认为在胎生、哺乳和依赖母体照料的动物中，雌性抵抗会使强制交配与繁衍目的冲突。';quote='如果雌性不接受或者不配合，雄性很少有能力可以安全的控制雌性';evidenceNature='行为与繁殖成本推理';boundary='作者明确排除缺少可被强迫意志的物种，并承认海豚行为定性有争议。'}
    [ordered]@{evidenceId='N33';ordinal=4030;section='动物、植物与跨物种关系';claim='作者认为群居协作动物并不缺语言，缺少的是使文明能够积累的文字。';quote='动物不缺语言，他们缺的是文字';evidenceNature='语言与文字定义区分';boundary='成立依赖于把语言宽定义为沟通达意。'}
    [ordered]@{evidenceId='N34';ordinal=4043;section='动物、植物与跨物种关系';claim='作者用半数回避距离表示动物对人类的恐惧，并认为人类高效狩猎反而使动物难以通过试错调整这一距离。';quote='我们可以将“惧怕程度”设定为“半数回避距离”';evidenceNature='动物行为指标和史前推演';boundary='作者明确说历史适应证据极难获得。'}
    [ordered]@{evidenceId='N35';ordinal=1602;section='动物、植物与跨物种关系';claim='作者认为食草和食肉动物的视觉系统分别服务于警戒和火控任务，人类更容易把食肉动物的面部动作读作表情。';quote='食草动物的眼睛和食肉动物的眼睛完全是两个设计思路';evidenceNature='功能形态与跨物种感知解释';boundary='文中采用广泛物种概括，没有逐种讨论例外。'}
    [ordered]@{evidenceId='N36';ordinal=3666;section='动物、植物与跨物种关系';claim='作者认为动物依靠嗅觉和栖息习惯筛选水源，而人类远离自然水源聚居反而集中制造水污染风险。';quote='动物也不会乱喝水的';evidenceNature='行为生态与聚居史解释';boundary='文章没有覆盖不同物种、寄生虫和病原体的全部差异。'}

    [ordered]@{evidenceId='N37';ordinal=19;section='污染、废物与物质循环';claim='作者主张截流、利用和再固定北极冻土释放的天然气，避免其直接进入大气。';quote='我们不可能一面在温带热带努力压减碳排放，一边却放任西伯利亚和加拿大冒泡泡';evidenceNature='碳循环与能源利用情景';boundary='冻土成气速率和“化石能源可再生”是作者的强判断。'}
    [ordered]@{evidenceId='N38';ordinal=2043;section='污染、废物与物质循环';claim='作者把甲醛治理分为源头阻断、封闭释放面和抑制累积三层。';quote='必须尽可能封闭';evidenceNature='室内污染工程操作模型';boundary='“不需要通风期”等结论属于作者建议，不能改写成临床或国家标准。'}
    [ordered]@{evidenceId='N39';ordinal=3045;section='污染、废物与物质循环';claim='作者认为取消塑料功能件未必降低总体环境代价，原有防水功能可能由更复杂材料替代。';quote='在需求本身没有消失的前提下';evidenceNature='功能约束与替代负担分析';boundary='文章没有进行定量生命周期计算。'}
    [ordered]@{evidenceId='N40';ordinal=1863;section='污染、废物与物质循环';claim='作者认为无人负责的公共垃圾桶容易超载和形成垃圾堆，集中垃圾站加私域责任可能成本更低。';quote='公共垃圾桶很自然会成为所有过路者投放垃圾的目标';evidenceNature='废物基础设施与责任配置模型';boundary='批评对象是无责任公共空间中的垃圾桶，不是所有场所的垃圾收集设施。'}
    [ordered]@{evidenceId='N41';ordinal=822;section='污染、废物与物质循环';claim='作者建议水银污染清除按边缘到中心收集，并反复检测到无法检出。';quote='反复换袋、吸集、检测，直到最后一次无法检出';evidenceNature='污染收集与检测闭环方案';boundary='这是作者给出的操作办法，原文未引用专业处置标准。'}
    [ordered]@{evidenceId='N42';ordinal=2058;section='污染、废物与物质循环';claim='作者设想以动态污染关税、禁运和处置基金把核污水排放成本施加给排放方。';quote='这一税率将随核污水排放的总量提升而提升';evidenceNature='污染外部性国际治理方案';boundary='作者明称开脑洞，没有把它写成已实施的法律机制。'}

    [ordered]@{evidenceId='N43';ordinal=3268;section='生态治理、公共责任与文明未来';claim='作者认为赤贫供给与富裕者价格不敏感的欲望共同破坏资源稀缺的价格抑制，环保关键是消灭赤贫并改变金钱本位。';quote='在全世界范围内尽可能快的消灭赤贫、摒弃金钱本位的财富观和价值观，才是环境保护的关键问题';evidenceNature='贫富差距与资源耗竭结构模型';boundary='作者明确不把责任归给单一民族，制度路径没有展开。'}
    [ordered]@{evidenceId='N44';ordinal=4034;section='生态治理、公共责任与文明未来';claim='作者认为宣传减少不等于停止提倡节水，无论当前是否短缺，节约都具有可持续和文化安全价值。';quote='无论一种东西现在看起来是不是不缺，你都要节约';evidenceNature='节俭伦理与公共注意力解释';boundary='原文也承认水在当前各种节约对象中未必优先。'}
    [ordered]@{evidenceId='N45';ordinal=1281;section='生态治理、公共责任与文明未来';claim='作者认为非营利组织不应拒绝盈利和专业薪资，而应以使命指标而非利润作为成就本位。';quote='非盈利性根本不表现在“不盈利”或者“避免盈利”上，而是表现在“计算企业成就的指标不是盈利”上';evidenceNature='公共组织治理原则';boundary='环保协会只出现在提问场景，正文给出的是一般非营利组织理论。'}
    [ordered]@{evidenceId='N46';ordinal=4038;section='生态治理、公共责任与文明未来';claim='作者认为聚变若解除能源瓶颈，必须同步建立公众教育、全球管制和技术伦理，否则能源竞争可能造成不可逆生态后果。';quote='必须辅以人类对自身伦理的重大努力';evidenceNature='复杂系统风险与文明治理情景';boundary='作者明确支持聚变，但反对无制度准备的狂热推进。'}
    [ordered]@{evidenceId='N47';ordinal=3900;section='生态治理、公共责任与文明未来';claim='作者认为垃圾分类等行为只有在证据、申诉、独立复核和收益超过治理成本时才适合纳入征信。';quote='必须给予充分合理的证据采集、辩方申诉和独立复核机制';evidenceNature='环境行为激励的程序约束';boundary='正文主论是征信治理，不是垃圾处理技术。'}
    [ordered]@{evidenceId='N48';ordinal=90;section='生态治理、公共责任与文明未来';claim='作者认为受规范的合法狩猎可能以高收费为保护区和反盗猎提供主要资金。';quote='这些收入是维持反盗猎、运营自然保护区的主要收入来源之一';evidenceNature='野生动物保护融资机制解释';boundary='判断严格以合法、指定个体、不损害繁衍和收入用于保护为条件。'}
)

$corpus = [Collections.Generic.List[object]]::new()
foreach ($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($CorpusPath))) {
    if (-not [string]::IsNullOrWhiteSpace($line)) {
        $corpus.Add(($line | ConvertFrom-Json))
    }
}
if ($corpus.Count -ne 4050) {
    throw "Expected 4050 corpus articles, found $($corpus.Count)."
}

$screenedIds = @{}
foreach ($row in Import-Csv -LiteralPath ([IO.Path]::GetFullPath($ScreeningPath))) {
    $screenedIds[[string]$row.id] = $true
}

$rows = [Collections.Generic.List[object]]::new()
foreach ($item in $items) {
    $ordinal = [int]$item.ordinal
    $article = $corpus[$ordinal - 1]
    $isScreened = $screenedIds.ContainsKey([string]$article.id)
    $isSupplement = $approvedSupplementOrdinals -contains $ordinal
    if (-not $isScreened -and -not $isSupplement) {
        throw "[$($item.evidenceId)] Article neither screened nor approved supplement."
    }
    if ($isScreened -and $isSupplement) {
        throw "[$($item.evidenceId)] Supplement unexpectedly screened."
    }
    $quoteOk = ([string]$article.text).Contains([string]$item.quote, [StringComparison]::Ordinal)
    $date = [DateTimeOffset]::FromUnixTimeMilliseconds([int64]$article.publishedAt).ToOffset([TimeSpan]::FromHours(8)).ToString('yyyy-MM-dd')
    $rows.Add([pscustomobject][ordered]@{
        evidenceId    = [string]$item.evidenceId
        section       = [string]$item.section
        claim         = [string]$item.claim
        evidenceNature = [string]$item.evidenceNature
        boundary      = [string]$item.boundary
        ordinal       = $ordinal
        id            = [string]$article.id
        date          = $date
        title         = [string]$article.title
        url           = [string]$article.url
        quote         = [string]$item.quote
        quoteExact    = $quoteOk
        sourceLayer   = if ($isSupplement) { 'approved-supplement' } else { 'screened' }
    })
}
$rows | Export-Csv -LiteralPath ([IO.Path]::GetFullPath($OutputPath)) -NoTypeInformation -Encoding utf8BOM

$requiredSections = @(
    '自然观、规律与人的位置',
    '生态系统、生物多样性与保护',
    '气候、灾害与文明韧性',
    '能源、矿产与资源约束',
    '农业、农村、土地与粮食',
    '动物、植物与跨物种关系',
    '污染、废物与物质循环',
    '生态治理、公共责任与文明未来'
)
$sectionCounts = [ordered]@{}
foreach ($section in $requiredSections) {
    $sectionCounts[$section] = @($rows | Where-Object section -eq $section).Count
}
$missing = @($rows | Where-Object {
    [string]::IsNullOrWhiteSpace($_.claim) -or
    [string]::IsNullOrWhiteSpace($_.evidenceNature) -or
    [string]::IsNullOrWhiteSpace($_.boundary) -or
    [string]::IsNullOrWhiteSpace($_.quote)
}).Count
$stats = [ordered]@{
    corpusArticles          = $corpus.Count
    screenedCandidates      = $screenedIds.Count
    evidenceRows            = $rows.Count
    uniqueEvidenceIds       = @($rows.evidenceId | Sort-Object -Unique).Count
    uniqueArticleIds        = @($rows.id | Sort-Object -Unique).Count
    uniqueOrdinals          = @($rows.ordinal | Sort-Object -Unique).Count
    screenedEvidenceRows    = @($rows | Where-Object sourceLayer -eq 'screened').Count
    directReviewSupplements = @($rows | Where-Object sourceLayer -eq 'approved-supplement').Count
    supplementOrdinals      = $approvedSupplementOrdinals
    missingCoreFields       = $missing
    exactQuoteFailures      = @($rows | Where-Object { -not $_.quoteExact }).Count
    sectionCounts           = $sectionCounts
    status                  = if (
        $rows.Count -eq 48 -and
        @($rows.evidenceId | Sort-Object -Unique).Count -eq 48 -and
        @($rows.id | Sort-Object -Unique).Count -eq 48 -and
        @($rows.ordinal | Sort-Object -Unique).Count -eq 48 -and
        $missing -eq 0 -and
        @($rows | Where-Object { -not $_.quoteExact }).Count -eq 0 -and
        @($requiredSections | Where-Object { $sectionCounts[$_] -ne 6 }).Count -eq 0
    ) { 'PASS' } else { 'REVIEW' }
}
$stats | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath ([IO.Path]::GetFullPath($StatsPath)) -Encoding utf8
$stats | ConvertTo-Json -Depth 5
if ($stats.status -ne 'PASS') {
    throw "Ecology/nature core evidence validation ended with status $($stats.status)."
}
