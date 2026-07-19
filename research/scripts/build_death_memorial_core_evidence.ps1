param(
    [string]$CorpusPath = '.\sooon-q9adg-articles.jsonl',
    [string]$ScreeningPath = '.\research\data\death_memorial_screening.csv',
    [string]$OutputPath = '.\research\data\death_memorial_core_evidence.csv',
    [string]$StatsPath = '.\research\data\death_memorial_core_evidence.stats.json'
)

$ErrorActionPreference = 'Stop'

$items = @(
    [ordered]@{ evidenceId='D01'; ordinal=3737; section='死亡认识、必死信念与自由'; claim='作者区分“人会死”和“人必然会死”，并把普遍死亡理解为兼具个人宽慰、社会幸存和牺牲动员功能的文明信念。'; quote='“人终有一死”是人类最大的宽慰。'; evidenceNature='作者的死亡认识论与社会功能解释'; boundary='普遍死亡的证据限度、古代长生观和文明竞争史均只记录为作者判断。' }
    [ordered]@{ evidenceId='D02'; ordinal=3678; section='死亡认识、必死信念与自由'; claim='作者认为记忆容量、调用能力、运算速度、身体载体和人格连续性共同限制真正永生，单纯延长生理活动不能保全同一主体。'; quote='实际上是你的思维机制本身最终决定了你无法在真实意义上永生，不是新陈代谢，也不是所谓的端粒限制。'; evidenceNature='作者的思想实验与技术判断'; boundary='记忆、意识上传和脑机改造的技术可行性均是作者推演，不作外部科技裁决。' }
    [ordered]@{ evidenceId='D03'; ordinal=4039; section='死亡认识、必死信念与自由'; claim='作者按资源效率排列死亡相关投入，主张优先延缓死亡、改善存活质量和降低死亡恐惧，而不是把全部资源投入攻克死亡。'; quote='我们当然只有把重心放在更有效率的“让人暂时不死”和“让暂时死不了的人活得好一些”上。'; evidenceNature='明示资源优先级判断'; boundary='族群危机和牺牲意识形态的必要性属于作者的历史尺度推演。' }
    [ordered]@{ evidenceId='D04'; ordinal=4032; section='死亡认识、必死信念与自由'; claim='作者把死亡恐惧解释为文化塑造和未来预期的共同结果，并把一定程度的恐惧视为防止低估风险的生命保险。'; quote='死亡恐惧所造成的负担，客观上就像你为生命买的一份保险。'; evidenceNature='作者的心理功能判断'; boundary='文章给出等待适应和深入认识死亡两条路径，不是临床诊断或治疗方案。' }
    [ordered]@{ evidenceId='D05'; ordinal=1486; section='死亡认识、必死信念与自由'; claim='作者把明知某项行动会提高死亡概率而仍自愿接受风险的死亡称为自觉死亡，并将其解释为自由价值的实现。'; quote='自觉的死亡是自由的实现。'; evidenceNature='明示自由与死亡命题'; boundary='文章以风险知情和自愿接受为条件，不把一切意外死亡或被迫死亡都写成自由实现。' }
    [ordered]@{ evidenceId='D06'; ordinal=2400; section='死亡认识、必死信念与自由'; claim='作者认为事故后的教训会永久缩小行动空间，因此安全收益必须与禁区范围、执行成本和生命能力损失一起计算。'; quote='教训导致的选择余地的损失范围和执行教训的具体成本构成教训的成本，该成本越低越好。'; evidenceNature='明示风险与教训算法'; boundary='文章允许为超越性价值承担致命后果，但反对把一般教训总结成取消全部行动能力的禁令。' }

    [ordered]@{ evidenceId='D07'; ordinal=1547; section='临终准备、遗嘱与抚慰'; claim='作者把临终关怀扩展到盛壮之年，要求提前安排葬礼、遗产、忏悔、原谅和重要关系，使死亡准备反过来重排当前生活。'; quote='活着的每一刻都是临终，“临终关怀”就是向死而生罢了。'; evidenceNature='明示临终准备主张'; boundary='作者以传统葬礼准备说明从容面对死亡，不等同于专业安宁疗护的完整定义。' }
    [ordered]@{ evidenceId='D08'; ordinal=1485; section='临终准备、遗嘱与抚慰'; claim='作者要求临终抚慰者不越权保证康复，而应具体处理病人的生活、遗属、事业、义务和精神遗产焦虑，并防止无爱者借绝望攫取信仰。'; quote='绝不能容无爱的人对将死之人谈信仰，危险至极。'; evidenceNature='明示抚慰程序与守护边界'; boundary='超脱生死被作者设为需要长期经验、信任和机缘的高门槛行动，不是普通陪伴者的默认权限。' }
    [ordered]@{ evidenceId='D09'; ordinal=2785; section='临终准备、遗嘱与抚慰'; claim='作者把持续写作、修改和公证遗嘱视为把模糊死亡恐惧转化为可反复决定的具体练习。'; quote='试试开始写遗嘱。'; evidenceNature='明示行动建议'; boundary='短文只给出个人练习方向，没有展开遗嘱内容、效力和法律程序。' }
    [ordered]@{ evidenceId='D10'; ordinal=2350; section='临终准备、遗嘱与抚慰'; claim='作者以亲人先到前方等待和熟悉环境的共同体想象，提供一种不把离世写成绝对失联的临终告别话语。'; quote='在前面等我们几年，没事多溜达，替我们熟悉一下环境。'; evidenceNature='作者的修辞性临终抚慰'; boundary='这是针对弥留告别的简短表达，不是作者对死后世界的事实断言。' }
    [ordered]@{ evidenceId='D11'; ordinal=1367; section='临终准备、遗嘱与抚慰'; claim='作者反对以孝道要求子女毁尽家产延长父母生命，主张父母提前划定医疗资金和代际财产边界，并为后代与社会保留遗产。'; quote='作为父母，要对两代人的财产有充分的边界意识——父母的财产就是父母的财产，子女的就是子女的。'; evidenceNature='作者的临终资源与家族责任判断'; boundary='具体支出红线、遗产比例和家族可持续性均由作者按其伦理模型提出，不替代法律或医疗决定。' }
    [ordered]@{ evidenceId='D12'; ordinal=3711; section='临终准备、遗嘱与抚慰'; claim='作者把养老院重构为生死教育、修和送别和代际传承的机构，认为临终经验应进入社会学习，而不能只被消费型护理封闭起来。'; quote='养老院首先应该是一所关于生存和死亡的学术机构。'; evidenceNature='作者的养老机构理想模型'; boundary='文章明确把正式加入设为长期、自愿、逐层取得资格的少数道路，不称为所有老人的统一方案。' }

    [ordered]@{ evidenceId='D13'; ordinal=64; section='丧葬、遗体与墓地技术'; claim='作者从地层塌陷、气味、动物、水分和排水解释棺椁、木炭、膏泥与墓址选择，把丧葬礼制还原为遗体处置工程。'; quote='其实埋葬尸体防止气味外泄的要害在于棺材。'; evidenceNature='作者的墓葬工程解释'; boundary='具体材料性能、墓制等级和古代技术史只按作者文本记录。' }
    [ordered]@{ evidenceId='D14'; ordinal=1925; section='丧葬、遗体与墓地技术'; claim='作者把墓葬解释为早期文明的长期实物证据，又把稳定墓地写成定居共同体的卫生设施、地理锚、历史见证和伦理锚。'; quote='坟墓是第一种能长时间存在的历史实物证据，这一点非常非常的关键，甚至可以说型塑了整个中国的文明史。'; evidenceNature='作者的文明起源与共同体解释'; boundary='墓葬年代、风水功能和文明因果链属于作者推测，未作考古与历史外部核验。' }
    [ordered]@{ evidenceId='D15'; ordinal=1; section='丧葬、遗体与墓地技术'; claim='作者要求子女先承担父丧费用，再以致谢和回礼责任索取奠仪明细，使葬礼成本、亲属劳动和人情账户进入明确程序。'; quote='为人子者，绝无父丧不自己出钱的道理，还望大伯成全。'; evidenceNature='作者的丧葬责任与程序建议'; boundary='直系责任、人情往还和伦理施压的正当性均是作者判断，不作为普遍法律义务。' }
    [ordered]@{ evidenceId='D16'; ordinal=651; section='丧葬、遗体与墓地技术'; claim='作者设想把自己的骨灰制成盲道水泥砌块，使遗体不固定于私人墓地，而在死后继续成为公共通行条件。'; quote='找一个需要修盲道的地方铺下去。'; evidenceNature='作者的身后处置设想'; boundary='短文表达个人设想，没有讨论实施许可、材料标准和公共工程程序。' }
    [ordered]@{ evidenceId='D17'; ordinal=2008; section='丧葬、遗体与墓地技术'; claim='作者认为烈士陵园因建造时靠近旧城、城市持续扩张和纪念地难以拆迁，逐渐从边缘进入城市中心并成为稳定政治地标。'; quote='烈士陵园绝大部分都在市中心。'; evidenceNature='作者的城市空间与纪念解释'; boundary='城市位置、年代和规划规律是作者概括，没有逐城统计核验。' }
    [ordered]@{ evidenceId='D18'; ordinal=2069; section='丧葬、遗体与墓地技术'; claim='作者认为空间站死亡应优先完整保存并返运遗体，因为礼仪、伦理和太空医学研究价值同时要求留存；只有绝对无法返运时才接受太空葬。'; quote='当然是用完善的保护手段保存起来，等待货运飞船转运回地面。'; evidenceNature='作者的航天遗体处置判断'; boundary='文章讨论罕见未来场景，航天选拔、捐赠条款和技术程序均是作者推演。' }

    [ordered]@{ evidenceId='D19'; ordinal=5; section='哀悼、悼亡与继续生活'; claim='作者认为持续祭祀和纪念让生者相信奉献会被后代承接，由此支撑生育、家族经营、长期劳动和个人意义。'; quote='纪念是最基本的爱，我们不该吝啬。'; evidenceNature='明示纪念价值判断'; boundary='祭祀与生育意愿、职业稳定和心理成本之间的因果只记录为作者解释。' }
    [ordered]@{ evidenceId='D20'; ordinal=842; section='哀悼、悼亡与继续生活'; claim='作者反对歌颂殉情、殉节和集体殉亡，认为这种赞美以牺牲仍可生活的人来强化社会法则，爱应帮助留下者免于失去后的恐惧。'; quote='我死了，你殉情，那就是我输了。'; evidenceNature='明示反殉判断'; boundary='文章以极端思想实验揭示社会利益，没有否定哀悼本身。' }
    [ordered]@{ evidenceId='D21'; ordinal=1903; section='哀悼、悼亡与继续生活'; claim='作者把悔恨和幸存者负疚的首要出口设为降低同类损害的复现概率，反对以自我折磨再次消费受害和过错。'; quote='尽量让将来的人不必再遭受同样的损害。'; evidenceNature='明示悔恨转化公式'; boundary='文章称其为统一公式，是作者的强命题；具体事件仍需分别判断可行的预防行动。' }
    [ordered]@{ evidenceId='D22'; ordinal=2194; section='哀悼、悼亡与继续生活'; claim='作者把庆祝他人死亡理解为公开暴露自己的死刑阈值，并认为这种低阈值表达会迅速损害周围人的安全感和关系信用。'; quote='你诅咒一个人或者庆祝一个人的死亡的行为，标定了你心目中的死刑标准。'; evidenceNature='作者的死亡言论与关系后果判断'; boundary='文章针对因日常冒犯而庆祝死亡的表达，不讨论全部战争、刑罚或公共纪念语境。' }
    [ordered]@{ evidenceId='D23'; ordinal=2842; section='哀悼、悼亡与继续生活'; claim='作者把死亡时间与面对死亡的姿态分开，并以是否忏悔和是否自弃生命区分善终与恶终，使幸存者不必把死亡本身理解为失败。'; quote='人不必执着于自己什么时候死，而要在意自己将以什么样的姿态面对死亡。'; evidenceNature='作者的善终与哀悼重构'; boundary='意外、病故、蒙冤、自戕和忏悔的分类是作者的生命伦理判断，不作外部宗教或医学裁决。' }
    [ordered]@{ evidenceId='D24'; ordinal=2204; section='哀悼、悼亡与继续生活'; claim='作者把真正祭奠写成生者因他人苦难而重新检查生活、和解、原谅和行动，使无辜受苦不只留下短暂安慰。'; quote='才是对伤者悲痛的真正祭奠。'; evidenceNature='作者的无常警醒与纪念实践'; boundary='文章把苦难称为警醒他人的祭献，是作者的意义解释，不表示受苦本身应被追求。' }

    [ordered]@{ evidenceId='D25'; ordinal=2129; section='祭祀、祖先与公共共同体'; claim='作者把古代献祭解释为聚集人口、供给食宿、统一食品标准、宣读神谕和完成议事选举的低技术公共制度。'; quote='实际上“献祭”是在古代推动公共事务、维持政治运作的关键要素。'; evidenceNature='作者的祭祀制度解释'; boundary='希腊、罗马与中国祭礼史及行政发展均为作者的宏观历史判断。' }
    [ordered]@{ evidenceId='D26'; ordinal=3435; section='祭祀、祖先与公共共同体'; claim='作者把祭祀、历法和年号连接为统一社会时间、安排生产服务并由统治者为时间计划承担责任的制度。'; quote='“祀”是一种“全地图时间魔法”，是官方发布全体臣民的首要政策共识——同一时间表——的方法。'; evidenceNature='作者的祭祀与时间治理解释'; boundary='历书宜忌、年号和宗教纪年的起源与功能均为作者推演。' }
    [ordered]@{ evidenceId='D27'; ordinal=420; section='祭祀、祖先与公共共同体'; claim='作者把中国人的死亡接受放入香火传承结构：父母先为子女承担生存压力，待子女婚育和第三代出生后才更容易放松延寿执着。'; quote='第三代的出生，约等于第一代接受死亡的无声前提。'; evidenceNature='作者的代际生命结构判断'; boundary='“典型中国人”的文化模型是作者概括，不能外推为每个家庭的实际心理。' }
    [ordered]@{ evidenceId='D28'; ordinal=2920; section='祭祀、祖先与公共共同体'; claim='作者认为公共苦难的纪念不能止于确认敌人邪恶，而应持续追问灾难为何未被阻止、哪些准备被忽略以及怎样防止重演。'; quote='让你从以后永远一看到它就心痛如绞，咬住牙关不能不继续再寻找，才是它的意义所在。'; evidenceNature='作者的苦难纪念与行动判断'; boundary='文章要求持续寻找而不宣布终局答案，具体历史原因仍须分别研究。' }
    [ordered]@{ evidenceId='D29'; ordinal=1890; section='祭祀、祖先与公共共同体'; claim='作者把攀附祖先理解为家族选择身份、技艺投资和政治方向的战略叙事，并主张外部纠错可能被对方视为敌对行动。'; quote='历史叙事首先是政治机制的结果，而不是史学规范的结果。'; evidenceNature='作者的祖先叙事与政治机制解释'; boundary='文章没有否认史学规范本身，而是说明家族政治叙事的目标并不以学术核验为先。' }
    [ordered]@{ evidenceId='D30'; ordinal=3933; section='祭祀、祖先与公共共同体'; claim='作者把祖宗自觉定义为不再只谋求个人一代速成，而为后代积累可继承的基业、经验、教育和跨血缘合作网络。'; quote='财富并不是最难获得的家族资源，传承和韧性才是。'; evidenceNature='作者的家族延续与祖宗角色判断'; boundary='永世家族、名门概率和现代家族机制均为作者的理想模型和历史概括。' }

    [ordered]@{ evidenceId='D31'; ordinal=2319; section='遗愿、遗物与历史存在'; claim='作者拒绝把留下数字遗产与被网络遗忘设成互斥选项，暗示身后可见性可以按内容、对象或时间作差异化安排。'; quote='就是认为“留下数字遗产”和“被网络遗忘”不可兼得。'; evidenceNature='明示二分法反驳'; boundary='短文没有给出数字遗产分类、平台处置或隐私实施方案，不能补写为完整制度主张。' }
    [ordered]@{ evidenceId='D32'; ordinal=3789; section='遗愿、遗物与历史存在'; claim='作者把生命价值的实践尺度写成对其他生命产生可被感知的改变，并以被记忆、继承和继续影响的时间积分定义历史存在。'; quote='你将存在到无人再意识得到你存在过的那一刻为止。'; evidenceNature='明示历史存在定义'; boundary='这是作者提供给缺少超世俗信仰者的过渡性价值观，不被写成唯一终极信仰。' }
    [ordered]@{ evidenceId='D33'; ordinal=27; section='遗愿、遗物与历史存在'; claim='作者把濒危手工技艺类比为种子库中的原始种，主张以最低资源保存完整工序，使技术遗产在未来条件恢复时能够重新生长。'; quote='伟业不死，只是逢冬而眠。'; evidenceNature='作者的技术遗产保存命题'; boundary='文明崩溃、手工重建和遗产永生的功能属于作者推演，不代表所有旧技术都须维持现实生产。' }
    [ordered]@{ evidenceId='D34'; ordinal=3968; section='遗愿、遗物与历史存在'; claim='作者把超越死亡与绝望的道路写成向不特定他人留下可继承的精神收益，使生命意义不再依赖个人满足能否持续。'; quote='人的意义是由他或有意或无意的遗产定义的，而非由他自身的满足定义。'; evidenceNature='明示精神遗产与生命价值判断'; boundary='文章称其为战胜绝望的唯一途径，是作者的强命题；具体精神遗产仍可有多种形式。' }
    [ordered]@{ evidenceId='D35'; ordinal=2360; section='遗愿、遗物与历史存在'; claim='作者以连续遗嘱、个人受益人、遗嘱信托和公益捐赠设计跨代财产，使遗产不因婚姻共有或继承人意外而偏离安排。'; quote='父母的遗嘱明确指明受益人是自己的女儿，而非女儿夫妇。'; evidenceNature='作者的具体遗嘱方案'; boundary='方案针对独生女家庭的特定情境，未核验不同法域中的遗嘱与信托效力。' }
    [ordered]@{ evidenceId='D36'; ordinal=3801; section='遗愿、遗物与历史存在'; claim='作者把财富视为受托管理的责任，并要求临终者不能为延寿耗尽全部财富，至少要通过继承或公益安排给后人和世人留下遗产。'; quote='也就是必有遗产留给世人。'; evidenceNature='作者的财富托付与临终遗产判断'; boundary='上帝托付、节俭生命和遗产比例属于作者的宗教财富观，不替代医疗、继承和财产法律。' }
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
    '死亡认识、必死信念与自由',
    '临终准备、遗嘱与抚慰',
    '丧葬、遗体与墓地技术',
    '哀悼、悼亡与继续生活',
    '祭祀、祖先与公共共同体',
    '遗愿、遗物与历史存在'
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
$allSectionsCovered = @($requiredSections | Where-Object { $sectionCounts[$_] -ne 6 }).Count -eq 0

$outputFull = [IO.Path]::GetFullPath($OutputPath)
$statsFull = [IO.Path]::GetFullPath($StatsPath)
$rows | Export-Csv -LiteralPath $outputFull -NoTypeInformation -Encoding utf8BOM
$status = if (
    $rows.Count -eq 36 -and $uniqueEvidenceIds -eq 36 -and $uniqueArticleIds -eq 36 -and
    $screenedIds.Count -eq 159 -and $missingCoreFields -eq 0 -and $allSectionsCovered -and
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
$stats | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $statsFull -Encoding utf8
$stats | ConvertTo-Json -Depth 5
if ($status -ne 'PASS') { throw "Death and memorial core evidence validation ended with status $status." }
