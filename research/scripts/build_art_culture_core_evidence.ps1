param(
    [string]$CorpusPath = '.\sooon-q9adg-articles.jsonl',
    [string]$ScreeningPath = '.\research\data\art_culture_screening.csv',
    [string]$OutputPath = '.\research\data\art_culture_core_evidence.csv',
    [string]$StatsPath = '.\research\data\art_culture_core_evidence.stats.json'
)

$ErrorActionPreference = 'Stop'

$items = @(
    [ordered]@{ evidenceId='A01'; ordinal=3843; section='审美判断与文化风格'; claim='作者把个人外貌和时尚选择理解为一种有选择地传递身份信息的编码，品味的作用不是让所有人满意，而是帮助价值相近者相互辨认。'; quote='记住，你的外貌应该是一道编过码的半透膜——识得的人，就是值得的人；不值得的人，就识不得。'; evidenceNature='明示品味功能判断'; boundary='文章讨论个人形象与择偶识别，不等同于对一切审美活动的总定义。' }
    [ordered]@{ evidenceId='A02'; ordinal=3963; section='审美判断与文化风格'; claim='作者把美从可有可无的偏好提升为行动者不能逃避的义务，并将其与自由权利并列。'; quote='记住这句话——自由是一种不可抛弃的权利，美是一种不可逃避的义务。'; evidenceNature='明示价值判断'; boundary='全文以反驳对丑的浪漫化为语境，没有给出美的统一形式标准。' }
    [ordered]@{ evidenceId='A03'; ordinal=895; section='审美判断与文化风格'; claim='作者把审美定义为洞察真假、高低和价值的能力，并认为这种能力主要来自亲自参与或直接理解价值创造，而非天生舒适偏好。'; quote='审美能力，指的是洞察价值的能力，除了动物性避害的本能之外，它几乎必然的从创造价值的经验中来。'; evidenceNature='明示审美定义'; boundary='商品、食物、军事和人际例子承担跨域类比功能，具体优劣判断仍需相应技艺。' }
    [ordered]@{ evidenceId='A04'; ordinal=920; section='审美判断与文化风格'; claim='作者认为中国艺术的关键短板不是艺术家或观众数量，而是缺少能在自身美学逻辑中评价作品并指引创作的批评体系。'; quote='艺术批评的缺位，导致中国艺术长期受到西方艺术批评和所谓“大众审美”的双重撕扯。'; evidenceNature='作者艺术生态诊断'; boundary='中国与西方艺术体系的差异及短板排序只记录为作者判断。' }
    [ordered]@{ evidenceId='A05'; ordinal=4011; section='审美判断与文化风格'; claim='作者反对以人物政治评价替代对书法作品的审美判断，认为这种做法会使传统继承进入媚雅和失真。'; quote='因人废行废言，是最令人反胃的“国学”。'; evidenceNature='明示批评原则'; boundary='文章针对特定书法评论风尚，没有系统展开作品与作者生平在何种条件下可以关联。' }
    [ordered]@{ evidenceId='A06'; ordinal=1617; section='审美判断与文化风格'; claim='作者区分文化本体与服饰、餐食、礼仪、舞蹈等文化表现，并以深层生存和认同结构解释朝韩文化产品的风格。'; quote='文化是使得这些东西被生发出来，成为其所成其为的样子的背后的原因，背后的那个更高、更中心的力量。'; evidenceNature='明示文化层次定义'; boundary='朝韩、日本和宗主关系的历史因果均是作者的文化解释，未作外部史实核验。' }

    [ordered]@{ evidenceId='A07'; ordinal=3993; section='艺术解释、批评与价值形成'; claim='作者反对把艺术作品当作作者预先编码、评论者逐项解码的信息系统，认为创作常先于作者对自身表达的概念化理解。'; quote='艺术不是密码情报学。'; evidenceNature='明示反驳命题'; boundary='文章不否认宗教图像等约定符号系统，也不否认作品可以有结构设计。' }
    [ordered]@{ evidenceId='A08'; ordinal=2310; section='艺术解释、批评与价值形成'; claim='作者把俄罗斯艺术成就追溯到东正教身份、牺牲意识和灵性经验，并把艺术解释为信仰的外露。'; quote='美者，牺牲之羊也，艺术行为本身就是一种宗教性极强的行为，甚至不客气的说，它在本质上就是一种信仰的外露。'; evidenceNature='作者宗教艺术解释'; boundary='俄罗斯民族、东正教和艺术成就之间的历史因果均为作者判断。' }
    [ordered]@{ evidenceId='A09'; ordinal=3044; section='艺术解释、批评与价值形成'; claim='作者区分作者意图与作品实际表达，认为二者可能错位，作品意义不能完全由作者事后宣称控制。'; quote='“作者到底表达了什么”和“作者想要表达什么”之间的关系是神秘的，在一些不成熟的艺术家这里甚至是虚无的。'; evidenceNature='明示意图表达区分'; boundary='文章以若干艺术创作现象作推演，没有否定作者意图作为一种解释材料的资格。' }
    [ordered]@{ evidenceId='A10'; ordinal=3148; section='艺术解释、批评与价值形成'; claim='作者认为作品的历史意义由作者、评论者和观看者共同完成，并在历史承认过程中形成。'; quote='实际上作者、评者、观者是同一个作品的三个共同创作者，每一件最后被历史承认的艺术作品，都是这三位一体与历史的声音发生感应的结果。'; evidenceNature='明示共同创作模型'; boundary='历史承认的形成机制不等于任何单次评论或大众偏好都具有同等决定力。' }
    [ordered]@{ evidenceId='A11'; ordinal=1673; section='艺术解释、批评与价值形成'; claim='作者区分神性艺术与商业艺术，认为跨意识形态传播的主要是直接诉诸审美直觉、门槛较低的商业艺术。'; quote='能流行的，一定是商业艺术。也就是直接诉诸人类的审美直觉、无需特殊的精神修养就能直观收到吸引的艺术。'; evidenceNature='作者传播机制判断'; boundary='中日欧艺术源流、宗教结构和商业史的比较均未作外部史实核验。' }
    [ordered]@{ evidenceId='A12'; ordinal=2065; section='艺术解释、批评与价值形成'; claim='作者将 musical 解释为同时包含突破性激情与秩序性安慰的缪斯性，并把它扩展到音乐之外的艺术和实践领域。'; quote='Musical，意思是事物让人强烈的感受到本能冲动、创造性、突破性的灵感狂喜（酒神侧），同时又强烈的感受到秩序感、和谐感和安全感的巨大安慰（太阳神侧）的一种内在特性。'; evidenceNature='作者词源与概念解释'; boundary='希腊神话谱系和词源叙述只按作者文本记录；缪斯性是作者提出的扩展性解释。' }

    [ordered]@{ evidenceId='A13'; ordinal=853; section='书写、视觉艺术与摄影'; claim='作者把书法界定为满足实际书写、辨认和传统字形条件下的艺术，而不是借字形进行任意视觉构图。'; quote='书法实际上并不是“字的艺术”，而是“书写的艺术”。'; evidenceNature='明示书法定义'; boundary='文章承认视觉性的美术字可构成其他艺术，但不把它归入书法。' }
    [ordered]@{ evidenceId='A14'; ordinal=3220; section='书写、视觉艺术与摄影'; claim='作者认为书法作品的本体是可反复书写的字体和书写程序，单幅墨迹只是字体的一次实现。'; quote='字体，才是书法的真正作品本体。'; evidenceNature='明示作品本体判断'; boundary='该定义强调书写可重复性，不等于否认具体墨迹的物质和历史价值。' }
    [ordered]@{ evidenceId='A15'; ordinal=907; section='书写、视觉艺术与摄影'; claim='作者从工整书法的规划、执行和持续专注中识别能力，并把能力视为美的首要含义。'; quote='美的首要含义是“能”。'; evidenceNature='明示美能力命题'; boundary='由书法推断历史人物能力属于作者的个案解释，美与善仍以可持续性进一步区分。' }
    [ordered]@{ evidenceId='A16'; ordinal=2650; section='书写、视觉艺术与摄影'; claim='作者认为支持绘画创作者的关键是尊重和保存其已完成成果，而不是以设备或口头表扬替代持续创作条件。'; quote='最好的鼓励方式不过是“敬惜成果”。'; evidenceNature='明示创作支持建议'; boundary='文章针对儿童绘画和家庭支持，不能直接代替专业艺术教育方案。' }
    [ordered]@{ evidenceId='A17'; ordinal=1522; section='书写、视觉艺术与摄影'; claim='作者把摄影分为高度安排对象的胶片绘画与预判现实事件的荷鲁斯之眼两类，二者依赖不同能力。'; quote='这类摄影，拍摄对象基本完全出自创作者的安排，其实在出手之前就基本画好了草图构思，实际上是利用摄影摄像手段，用道具、布景、灯光代替了画笔颜料而做的一种变相的绘画。'; evidenceNature='作者摄影类型区分'; boundary='商业摄影、新闻摄影和可预料场景之间存在连续区间，不是互斥职业分类。' }
    [ordered]@{ evidenceId='A18'; ordinal=3932; section='书写、视觉艺术与摄影'; claim='作者通过曾侯乙青铜器的工艺、资源和用途，把审美敬畏连接到技术能力、资源节制以及以礼代战的文化理想。'; quote='懂行的人看这件东西，是越看越生敬畏的。凝聚在这件东西身上的智慧、心血和生命，需要多么惊人的机遇去聚合，需要多么大的资源去支持，又需要何等样的勇气去坚持到底？'; evidenceNature='作者文物工艺与文化解释'; boundary='铸造工艺、文字源流和礼制史推断均为作者判断，图片缺失也限制当前文本复核。' }

    [ordered]@{ evidenceId='A19'; ordinal=3488; section='电影、演员与工业协作'; claim='作者认为电影拍摄阶段的最终创作控制属于导演，演员应在合作前充分协商，确认合作后在既定空间内服从整体作品。'; quote='导演和演员的正常的、也是、最“出货”的关系，赤裸一点说，就是木偶师和提线木偶的关系。'; evidenceNature='作者电影分工判断'; boundary='文章强调工业协作中的导演权威，没有同等展开权力滥用和演员保护机制。' }
    [ordered]@{ evidenceId='A20'; ordinal=768; section='电影、演员与工业协作'; claim='作者预测大众电影会因全球市场约束、奇观套路和高成本而式微，低预算、类型鲜明且能精准触达观众的小众电影将扩大。'; quote='小众电影/艺术片预算小、风险小、表达自由、发行容易、观众偏好强，属于有无限生命力的物种。'; evidenceNature='作者电影产业趋势预测'; boundary='影片案例、观众成熟和产业份额属于作者推演，不是外部统计结论。' }
    [ordered]@{ evidenceId='A21'; ordinal=956; section='电影、演员与工业协作'; claim='作者认为跨公司电影工业需要创意团队先完成接近成片的预览和决策，再把边界明确的制作任务交给专业团队。'; quote='不能把“从分镜图到预览动画”阶段的工作视为制作团队的工作，而要视为创意团队的工作。'; evidenceNature='明示工业流程判断'; boundary='中外制作方式和具体项目经验均是作者概括；预览成熟度会随项目类型变化。' }
    [ordered]@{ evidenceId='A22'; ordinal=3602; section='电影、演员与工业协作'; claim='作者从《金刚川》的短周期大团队协作中识别中国电影工业的成熟可能，同时把故事经验与专业制作能力区分开。'; quote='这片子里有希望——看它的时候要意识到，它是2600人的团队，配合三位导演，只用了三个月做出来的。'; evidenceNature='作者个案工业判断'; boundary='影片质量、团队规模和制作过程只按作者文章记录；作者并未把技术合格等同于作品优秀。' }
    [ordered]@{ evidenceId='A23'; ordinal=2302; section='电影、演员与工业协作'; claim='作者以演员在剧本预先写定时仍能享受表演，类比命运或角色的预定不自动取消当事人的快乐体验。'; quote='几乎每一部电影的剧本都是写好的，但这并没有妨碍演员们享受表演的过程。'; evidenceNature='命运问题的类比性辅助证据'; boundary='电影演员只是文章用于讨论预定命运的类比，不能改写成作者的创作自由或表演理论。' }
    [ordered]@{ evidenceId='A24'; ordinal=1771; section='电影、演员与工业协作'; claim='作者借《红毯先生》区分票房、奖项与进入电影史的意义，并把该片写成电影人面向电影行业的作品。'; quote='身为电影人，拍这样的片子就像排骨年糕——不是生意，而是意义。'; evidenceNature='作者具体影片意义判断'; boundary='这是对一部具体作品和创作者处境的评价，不能据此推出全部电影的商业关系。' }

    [ordered]@{ evidenceId='A25'; ordinal=3299; section='创作、疗愈、AI与观众生态'; claim='作者认为艺术疗愈依赖重新组织经验和形成可持续表达，而不等于把未经处理的情绪直接发泄出来。'; quote='艺术当然是可以疗愈的，但是这绝不是“用艺术将自己的情绪表达/发泄出来”可以办得到的。'; evidenceNature='明示疗愈机制判断'; boundary='文章讨论艺术实践的心理作用，只记录作者判断，不作外部临床有效性裁决。' }
    [ordered]@{ evidenceId='A26'; ordinal=1847; section='创作、疗愈、AI与观众生态'; claim='作者区分资本化艺术体制的成名机制与艺术本身，后者被界定为从信仰和爱出发、无需人类见证的诚实表达。'; quote='艺术不是从美术入门的，艺术是从信仰入门。'; evidenceNature='明示艺术资格判断'; boundary='作者明确说明其对艺术体制的描述不等于赞成；金融和策展机制是作者概括。' }
    [ordered]@{ evidenceId='A27'; ordinal=2334; section='创作、疗愈、AI与观众生态'; claim='作者认为AIGC通过降低专业内容生产成本，使资源较少的小企业获得接近头部内容表现的机会。'; quote='AIGC技术带来的最大的改变，其实是通过“内容生产的民主化”，给了本小力薄的小企业以较低预算接近头部企业内容表现的机会。'; evidenceNature='作者技术产业判断'; boundary='成本下降、竞争格局和企业机会均为作者趋势判断。' }
    [ordered]@{ evidenceId='A28'; ordinal=2567; section='创作、疗愈、AI与观众生态'; claim='作者认为AI会替代大量依赖熟练度的普通制作，并迫使创作者把价值转向AI难以生成的经验、问题和人格。'; quote='其实，ai技术在艺术领域内的全面应用对创作者们是一件极大的好事。'; evidenceNature='作者AI艺术判断'; boundary='文章区分熟练制作与作者所谓真正创作，技术能力和职业后果是预测。' }
    [ordered]@{ evidenceId='A29'; ordinal=447; section='创作、疗愈、AI与观众生态'; claim='作者认为长期反复演出与受过训练的观众相互塑造：观众能识别细节，作品因而获得持续打磨的经济和评价动力。'; quote='观众受过深入教育，所以能体会这些剧目的妙处，而这也把这些剧本身养活了，也给了它们不断自我打磨以臻完善的动力。'; evidenceNature='作者观众生态判断'; boundary='中西表演艺术教育和历史积累的比较属于作者解释。' }
    [ordered]@{ evidenceId='A30'; ordinal=338; section='创作、疗愈、AI与观众生态'; claim='作者把教学理解为表演艺术，要求教师把知识转化为情感、画面和可追随的连续体验。'; quote='可以这么说，好的老师实际上是一名“表演艺术家”，是化知识为体验、为记忆的人，而绝非仅仅是“高级读稿机”。'; evidenceNature='明示教学艺术判断'; boundary='文章承认知识明星模式可能产生偶像崇拜问题，但认为教师仍须在该条件下处理风险。' }

    [ordered]@{ evidenceId='A31'; ordinal=965; section='文学阅读、文化、传统与国际秩序'; claim='作者区分人物具有持续人格的文学与为制造情节而任意调度角色的作品，后者应从受众反应而非虚构人物教训中提取价值。'; quote='要从这类作品提取价值，要从“群众对某个情节的反应”入手，而不能从“剧中人A的经验教训”入手。'; evidenceNature='作者文学解释方法'; boundary='四大名著等级和作品人物评价属于作者的文学判断。' }
    [ordered]@{ evidenceId='A32'; ordinal=2608; section='文学阅读、文化、传统与国际秩序'; claim='作者反对用幻想、悲剧和恐怖作品直接推断世界规律，认为虚构更适合用来观察何种心理会被触动。'; quote='任何小说，都没资格为世界定调、为它代言。'; evidenceNature='明示虚构认知边界'; boundary='作者对现实世界总体更温和的判断仍是其文本内事实判断。' }
    [ordered]@{ evidenceId='A33'; ordinal=1709; section='文学阅读、文化、传统与国际秩序'; claim='作者把世界名著视为经历史筛选、跨文化共享的公共知识和沟通资产，并把流行作品视为更细分、衰减更快的文化投资。'; quote='因为后者是历史拣选出来的人类文明财富，基本上世界各国的精英都会共同涉猎。'; evidenceNature='作者阅读价值判断'; boundary='精英共同阅读、信息密度和过时速度是作者概括；文章仍为同代流行作品保留例外。' }
    [ordered]@{ evidenceId='A34'; ordinal=3817; section='文学阅读、文化、传统与国际秩序'; claim='作者把文化本体定义为群体对认识、决策、合作和评价机制的共同预期，而把艺术、服饰和礼仪视为文化产品或符号。'; quote='文化本质上就是一群人对于决策机制的群体共识。'; evidenceNature='明示文化定义'; boundary='中国文化稳定性、地理决定和跨国比较只记录为作者判断。' }
    [ordered]@{ evidenceId='A35'; ordinal=2110; section='文学阅读、文化、传统与国际秩序'; claim='作者把传统解释为父辈主流据以识别继承者、配置资本权力和社会资源的方法论共识，传统也会在代际选择中不断改写。'; quote='所谓的“传统”到底是什么？其实就是既存的社会主流的自我认同，是ta们认同你是“自己人”、认为你有资格或资质传承自己的资本、权力和资源的鉴定标准。'; evidenceNature='明示传统机制定义'; boundary='代际资源优势、阵营循环和行动建议均为作者的社会机制推演。' }
    [ordered]@{ evidenceId='A36'; ordinal=2415; section='文学阅读、文化、传统与国际秩序'; claim='作者认为当前世界艺术评价锁定在国际秩序胜利者的语言和标准上，中国艺术家若取得国际成功通常须先归化该秩序；只有中国成为资本、市场乃至军事中心，外部受众才会因经济理性承担学习中文、典故和中国艺术概念的成本。'; quote='如果你“成功”了，那么几乎不可能是因为你够中国，而只能因为你够“世界”。'; evidenceNature='作者胜利者标准与国际艺术秩序判断'; boundary='艺术标准与政治经济中心的因果、未来秩序变化及具体艺术家评价均为作者的强条件推演。' }
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
    '审美判断与文化风格',
    '艺术解释、批评与价值形成',
    '书写、视觉艺术与摄影',
    '电影、演员与工业协作',
    '创作、疗愈、AI与观众生态',
    '文学阅读、文化、传统与国际秩序'
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
    $screenedIds.Count -eq 404 -and $missingCoreFields -eq 0 -and $allSectionsCovered -and
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
if ($status -ne 'PASS') { throw "Art and culture core evidence validation ended with status $status." }
