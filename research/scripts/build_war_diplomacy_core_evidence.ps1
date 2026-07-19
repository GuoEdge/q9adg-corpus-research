param(
    [string]$CorpusPath = '.\sooon-q9adg-articles.jsonl',
    [string]$ScreeningPath = '.\research\data\war_diplomacy_screening.csv',
    [string]$OutputPath = '.\research\data\war_diplomacy_core_evidence.csv',
    [string]$StatsPath = '.\research\data\war_diplomacy_core_evidence.stats.json'
)

$ErrorActionPreference = 'Stop'

$items = @(
    [ordered]@{ evidenceId='W01'; ordinal=2732; section='战略概念与战争认识'; claim='作者认为战争的发生、胜负、方式和代价会影响政策、产业、城市与个人选择，普通人关心军事应服务于现实判断而非知识炫耀。'; quote='你要留学、你要投资、你要择居、你要择业，如果你不懂军事、不识基本的胜负，你常会犯方向性的错误——筋疲力竭的向上游划水。'; evidenceNature='明示研究必要性'; boundary='军事判断能否改善人生选择是作者的实践主张。' }
    [ordered]@{ evidenceId='W02'; ordinal=977; section='战略概念与战争认识'; claim='作者反对把战术、战役、战略按人数或高低等级排列，并以胜利定义和总体作战思路界定战略。'; quote='战略是取得胜利的总体策略，只要存在清晰的胜利定义，就存在一个对应的战略思考，就会有一个总体作战思路。'; evidenceNature='明示概念定义'; boundary='拳击、围棋等类比用于概念辨析，不等同于真实战争。' }
    [ordered]@{ evidenceId='W03'; ordinal=2883; section='战略概念与战争认识'; claim='作者要求战局判断区分未行动、无意行动与无力行动，并通过客观行动迹象检验意图而非代入自身计划。'; quote='要判断对方的意图，要学会观察更客观的证据。'; evidenceNature='明示战争认识论'; boundary='俄军意图和战况属于作者对2022年具体战争的判断。' }
    [ordered]@{ evidenceId='W04'; ordinal=2446; section='战略概念与战争认识'; claim='作者主张先把战场视频作为情报分析，再作价值判断，以士气、动作和风险承担提取战况信息。'; quote='你要养成一种习惯，首先本能的去做情报分析，而不是价值观判断。'; evidenceNature='明示观察程序'; boundary='视频真伪、士气推断和交战方评价未作外部核验。' }

    [ordered]@{ evidenceId='W05'; ordinal=2856; section='军事组织与国家动员'; claim='作者以营级战术群说明编制评价必须先问任务、假想敌、支援条件和地理约束，不存在适应全部场景的部队。'; quote='因为世界上根本不存在“六边形部队”。'; evidenceNature='明示系统适配判断'; boundary='俄军编制、乌克兰战况和后续地缘预测均为作者推演。' }
    [ordered]@{ evidenceId='W06'; ordinal=4022; section='军事组织与国家动员'; claim='作者把军衔制解释为将私人从属改造成非个人化指挥关系，使部队能够在军官替换和伤亡后重建指挥链。'; quote='因为军衔制意味着他们的部队应该随时可以因为一纸调令接受某个其他军官接管而不发生任何组织心态上的问题。'; evidenceNature='作者军制历史解释'; boundary='古代军制循环和现代军队比较没有作外部史实验证。' }
    [ordered]@{ evidenceId='W07'; ordinal=3687; section='军事组织与国家动员'; claim='作者把学校军训视为义务兵役制和紧急总动员的基层基础设施，重点训练未来可能承担带兵任务的人员。'; quote='他们才是这次军训受到最大训练的人，也才是义务兵役制一旦真正实施动员的关键所在——中国需要大量有基本的训练动员兵经验的基层军官。'; evidenceNature='作者制度功能判断'; boundary='事故率、动员规模和军训必要性只按文章内部主张记录。' }
    [ordered]@{ evidenceId='W08'; ordinal=1157; section='军事组织与国家动员'; claim='作者把太平天国运动解释为中国社会高烈度、大规模和快速学习的战争动员能力展示。'; quote='太平天国运动展现了中国的可怕动员能力和战争潜力。'; evidenceNature='作者历史战略判断'; boundary='列强征服成本和中外军力比较未作外部史实验证。' }

    [ordered]@{ evidenceId='W09'; ordinal=3986; section='武器工程与系统适配'; claim='作者认为舰炮价值来自弹药持续性、再装填和近程自主任务适配，而非替代远程战略导弹。'; quote='舰炮是驱逐舰自主任务之中最廉价的中远程打击武器，在性能可及的前提下，舰炮是第一选择。'; evidenceNature='作者武器功能判断'; boundary='射程、防御和使用成本属于作者的军事技术判断。' }
    [ordered]@{ evidenceId='W10'; ordinal=2524; section='武器工程与系统适配'; claim='作者把反卫星问题拆成发现、追踪、抵近、命中和系统失效，反对把低轨试验直接外推到北斗中高轨道。'; quote='击毁星链卫星和击毁北斗卫星是两个完全不同的技术概念。'; evidenceNature='明示工程分解'; boundary='轨道数据、机动能力和替代系统效力未作外部技术复核。' }
    [ordered]@{ evidenceId='W11'; ordinal=3980; section='武器工程与系统适配'; claim='作者以材料缺陷、热处理和人体挥舞上限解释古代武器形制，要求把所谓神兵放回工程约束。'; quote='问题是人手只能灵活挥舞大概2公斤重的武器。'; evidenceNature='作者工程因果解释'; boundary='材料和人体上限是文章中的概括性判断。' }
    [ordered]@{ evidenceId='W12'; ordinal=3607; section='武器工程与系统适配'; claim='作者认为渡江的关键不是局部过河，而是在同一战役中击溃守军主力并解决跨江补给和持续占领。'; quote='所以，渡江的问题不光是要过掉这条江，而且是要在渡江这一战役里扎扎实实的消灭掉守军的有效兵力。'; evidenceNature='作者战役结构判断'; boundary='历史渡江战例和地理判断未作外部军事史验证。' }

    [ordered]@{ evidenceId='W13'; ordinal=1712; section='威慑、威胁与核力量'; claim='作者区分情绪恐怖主义与长期可信威慑，认为后者依赖意志、忍耐、勇气和仁慈的持续见证。'; quote='倒不是说这是无效的，恐怖主义当然有一定的战术效果，往往令无力者获得一定的安慰，但是恐怖主义和真正的斗争、真正富有斗争艺术的威慑相比，实际上是非常低效和粗放的，有太多不必要的成本和意料外的副作用。'; evidenceNature='明示威慑机制判断'; boundary='文章由关系教育谈威慑，现实暴力正当性未展开。' }
    [ordered]@{ evidenceId='W14'; ordinal=1408; section='威慑、威胁与核力量'; claim='作者把震慑定义为展示反击能力和不确定后果，把威胁定义为指定对象、展示主动进攻意图并要求服从。'; quote='我不是在展现我的反击能力，我是在展现我的进攻能力和进攻意图了。'; evidenceNature='明示语义区分'; boundary='该功能性定义没有覆盖国际法、误判和比例问题。' }
    [ordered]@{ evidenceId='W15'; ordinal=2783; section='威慑、威胁与核力量'; claim='作者把法律保障放在较低顺位，并按价值、信息保护、公开反制和隐藏反制划分四级安全策略。'; quote='维护自己的权益，法律只能担当顺位非常低的保障。'; evidenceNature='明示安全层级'; boundary='报复能力和诉讼策略只记录为作者行动模型。' }
    [ordered]@{ evidenceId='W16'; ordinal=2901; section='威慑、威胁与核力量'; claim='作者从俄乌战争推演所谓核大国特权，认为独立二次打击能力会迫使直接邻国约束民族主义并尊重核大国意志。'; quote='这意味着“核大国的邻国必须服从或至少令其满意的尊重其意志”。'; evidenceNature='作者核秩序预测'; boundary='战争结局、核威慑效力和国际秩序变化均为强前提推演。' }

    [ordered]@{ evidenceId='W17'; ordinal=2900; section='战争目标、胜负与投降'; claim='作者反对把拖延或快速占领单独定义为胜利，要求根据战争的政治和认知目标判断何时结束。'; quote='世界上从来就不存在“让对方一看就觉得你必须速战速决，而你不用坚持到对方自己对这个念头绝望”就能胜利的战争。'; evidenceNature='作者战争目标判断'; boundary='俄罗斯目标、北约信用和乌克兰社会心理均为文章推演。' }
    [ordered]@{ evidenceId='W18'; ordinal=2898; section='战争目标、胜负与投降'; claim='作者把核武器及真实使用意愿视为压低外部援助烈度、争夺政治认知和迫使对手承认物理约束的工具。'; quote='而拿出核武器，并且展示真实的使用意愿，是对抗北约现在已趋疯狂的宣传战的对症之药。'; evidenceNature='作者核威慑与宣传战判断'; boundary='核升级、占领区治理和援助效果未作外部核验。' }
    [ordered]@{ evidenceId='W19'; ordinal=1724; section='战争目标、胜负与投降'; claim='作者认为投降不是无条件正确或错误，而取决于后勤、组织、承诺兑现能力和双方能否执行理性决定。'; quote='实际上投降是一个理性的决策，只不过在中国理性运算的结果往往指向不投降而已。'; evidenceNature='明示条件判断'; boundary='古代侵略后勤和中国历史经验均为作者概括。' }
    [ordered]@{ evidenceId='W20'; ordinal=2899; section='战争目标、胜负与投降'; claim='作者把绝不考虑投降解释为少数大国凭人口、纵深、组织和复兴信心取得的特殊能力，弱国常在不同依附之间选择。'; quote='因为“完全不必考虑投降”是中国（以及很少的一些其它国家）在这个地球上的独有特权。'; evidenceNature='作者大国与弱国比较'; boundary='乌克兰选择和国家能力等级属于文章的地缘判断。' }

    [ordered]@{ evidenceId='W21'; ordinal=3577; section='平民、战争责任与侵略命名'; claim='作者以史前部落资源和生育竞争解释不杀妇孺及贞操观念的形成，最后把现代政策判断交回授权和主体位置。'; quote='在最原始的部落状态，战胜部落是不会虐待战败方的妇女、儿童的。'; evidenceNature='作者演化历史解释'; boundary='史前习俗、性别资源模型和因果链均未作外部历史验证。' }
    [ordered]@{ evidenceId='W22'; ordinal=2776; section='平民、战争责任与侵略命名'; claim='作者把指挥者是否下令、批准或明知不制止针对平民、战俘和危险设施的行为列为战争罪责判断入口。'; quote='是否有下令、或批准、或明知而不禁止虐待战俘。'; evidenceNature='明示战争责任清单'; boundary='针对具体领导人的指控可能性，事实和法律结论未作外部核验。' }
    [ordered]@{ evidenceId='W23'; ordinal=2846; section='平民、战争责任与侵略命名'; claim='作者认为侵略者的历史命名受战后代表权、胜负和叙事延续影响，并非只由越境事实在战争当下决定。'; quote='历史的真相是，越过国境发动战争的国家到底是不是“侵略者”，不是看战争前、战争中被越境方的定性的，而是看战争之后ta们再怎么说。'; evidenceNature='作者历史命名判断'; boundary='该文讨论命名形成，不等于取消具体战争行为判断。' }
    [ordered]@{ evidenceId='W24'; ordinal=4014; section='平民、战争责任与侵略命名'; claim='作者从星际距离和成本推导，若战争以占领和资源攫取为目标，就会倾向保存稀缺生态资产而非无差别摧毁。'; quote='除非星际战争纯粹是为了改变夜空景色，否则以占领和物资攫取为目的的话，想要得到的必定是其他更便宜的手段无法得到的东西、某种这里有别处没有的东西。'; evidenceNature='作者成本目标推演'; boundary='工质推进、虫洞和外星文明均属思想实验。' }

    [ordered]@{ evidenceId='W25'; ordinal=2771; section='同盟、调停与大国边界'; claim='作者把军事同盟解释为以主权妥协换取庇护并形成强制出兵和主从关系，而非单纯平等互助。'; quote='“组成军事同盟”的意义并不在于“军事互助”，而是B有求于A，于是以其他条件换取A的庇护。'; evidenceNature='明示同盟定义'; boundary='明朝朝鲜、中美日和中俄比较均为作者制度解释。' }
    [ordered]@{ evidenceId='W26'; ordinal=1827; section='同盟、调停与大国边界'; claim='作者认为停火需要有能力同时提供和平收益和力量威慑的中间人，使各方接受不完全满意的条件。'; quote='四方其实都想停火，但这四方希望的停火条件各自不同，哪怕这些版本相差甚微，在没有外力介入的前提下，就这么微小的差别都只能用人命、漫长的战火来慢慢磨平。'; evidenceNature='作者调停机制判断'; boundary='缅甸局势、中国作用和后续区域影响均为文章判断。' }
    [ordered]@{ evidenceId='W27'; ordinal=2927; section='同盟、调停与大国边界'; claim='作者把全球情报、研究能力和可说服的行动方案视为大国影响小国的关键，不只依赖明文命令或直接胁迫。'; quote='全球情报和全球研究，是大国影响小国的关键。'; evidenceNature='明示信息权力判断'; boundary='各国情报能力和具体影响链未作外部核验。' }
    [ordered]@{ evidenceId='W28'; ordinal=2352; section='同盟、调停与大国边界'; claim='作者认为强国若越过弱国不可交换的根本红线，会耗尽原可低成本使用的影响力并迫使对方拒绝妥协。'; quote='是要理解国与国的交往存在一些策略的红线，即使你强大也是不能越过的。'; evidenceNature='明示强国克制原则'; boundary='沙伊关系和国家文化禀赋均为作者解释。' }

    [ordered]@{ evidenceId='W29'; ordinal=3664; section='民族主义、制裁、修和与条约'; claim='作者认为狭隘民族主义会被无台阶的刺激和国内狠话裹挟，使决策者主动进入对手设置的军事陷阱。'; quote='对待狭隘民族主义，最致命的策略就是passive aggressive。'; evidenceNature='作者升级机制判断'; boundary='中印美三方意图和策略效果均为文本内推演。' }
    [ordered]@{ evidenceId='W30'; ordinal=2892; section='民族主义、制裁、修和与条约'; claim='作者把对俄制裁和结算迁移解释为扩大纯人民币体系、增加中国战略自主性的机会。'; quote='这是在现有机遇下，最大限度的扩张纯人民币自主结算体系的必然举措之一。'; evidenceNature='作者制裁与结算推演'; boundary='机构意图、资金流和人民币份额预测均未作外部核验。' }
    [ordered]@{ evidenceId='W31'; ordinal=2265; section='民族主义、制裁、修和与条约'; claim='作者把战后道歉拆成持续价值立场、赔偿、防止重犯措施和正式国家声明，认为预防重犯是原谅的核心条件。'; quote='而这三者之中，这个“防止再次发生的措施”，才是这个道歉的核心本质部分，是对方原谅你的逻辑前提。'; evidenceNature='明示修和条件'; boundary='日本战争责任、国家声明和现实政策评价均为作者立场。' }
    [ordered]@{ evidenceId='W32'; ordinal=2934; section='民族主义、制裁、修和与条约'; claim='作者认为条约责任不能保证履行，组织在守约威胁生存时可能违约，保护还取决于执行能力和公众共鸣。'; quote='因为无论多大的违约责任，在大多数主体看来都大不过自身的生存。'; evidenceNature='作者条约执行判断'; boundary='文章描述违约可能性，不把违约本身判为正当。' }
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

$requiredSections = @('战略概念与战争认识','军事组织与国家动员','武器工程与系统适配','威慑、威胁与核力量','战争目标、胜负与投降','平民、战争责任与侵略命名','同盟、调停与大国边界','民族主义、制裁、修和与条约')
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

$outputFull = [IO.Path]::GetFullPath($OutputPath)
$statsFull = [IO.Path]::GetFullPath($StatsPath)
$rows | Export-Csv -LiteralPath $outputFull -NoTypeInformation -Encoding utf8BOM
$status = if ($rows.Count -eq 32 -and $uniqueEvidenceIds -eq 32 -and $uniqueArticleIds -eq 32 -and $screenedIds.Count -eq 261 -and $missingCoreFields -eq 0 -and $allSectionsCovered -and -not ($rows.quoteExact -contains $false)) { 'PASS' } else { 'REVIEW' }
$stats = [ordered]@{
    corpusArticles = $corpus.Count
    screenedCandidates = $screenedIds.Count
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

