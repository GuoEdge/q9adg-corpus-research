param(
    [string]$CorpusPath = '.\sooon-q9adg-articles.jsonl',
    [string]$ScreeningPath = '.\research\data\workplace_organization_screening.csv',
    [string]$OutputPath = '.\research\data\workplace_organization_core_evidence.csv',
    [string]$StatsPath = '.\research\data\workplace_organization_core_evidence.stats.json'
)

$ErrorActionPreference = 'Stop'
$approvedSupplementOrdinals = @(208)

$items = @(
    [ordered]@{ evidenceId='W01'; ordinal=208; section='劳动、事业与职业意义'; claim='作者认为，与其不断寻找省力诀窍，不如建立以工作、学习和劳动过程为乐的能力，并在实践中持续改进方法。'; quote='世界上最珍贵的东西，就是劳动、战斗、学习本身的快感。'; evidenceNature='劳动快感与实践改进'; boundary='文章讨论青年长期行动习惯，不是具体职业选择指南；本篇是经原文复核批准的筛选层补录。' }
    [ordered]@{ evidenceId='W02'; ordinal=60; section='劳动、事业与职业意义'; claim='作者把工作所得继续投入事业写成志业型人生的幸福，并把健康与家庭维持放在事业的基础投入位置。'; quote='把个人的健康、家庭的维持看作工作的基础投入'; evidenceNature='强志业伦理与基础投入'; boundary='这是作者对志业型人生的强规范表述，不能自动推广为所有雇佣岗位的工时规则。' }
    [ordered]@{ evidenceId='W03'; ordinal=1624; section='劳动、事业与职业意义'; claim='作者认为职业倦怠的根本修复来自对客户群体的真实关切，以及服务关系进入正向反馈循环。'; quote='一言以蔽之——击退这种倦怠的根本，是有效的、踏入正循环的爱。'; evidenceNature='客户关切与职业倦怠'; boundary='主要针对以持续服务客户为结构的职业；作者明确认为简单换工作不能解决这种倦怠。' }
    [ordered]@{ evidenceId='W04'; ordinal=1581; section='劳动、事业与职业意义'; claim='作者把准备性琐事看作核心工作的组成条件，把善后性琐事转化为流程、规范和整体设计的改进问题。'; quote='准备工作与关键工作的关系更为紧密，其存在往往是不可减损的，因为会影响到关键工作的执行细节。'; evidenceNature='琐碎劳动与工作整体性'; boundary='文章区分准备工作和可通过设计压缩的善后工作，并未要求接受全部低效杂务。' }
    [ordered]@{ evidenceId='W05'; ordinal=962; section='劳动、事业与职业意义'; claim='作者认为团队看重的是关键时刻仍维持交付和职业信誉，而不是逃避家庭或沉迷工作的无边界加班。'; quote='职业信誉是一个人的社会生命。'; evidenceNature='关键交付与职业信誉'; boundary='文章严格区分三种事业狂场景；履职后仍应处理家庭事务，不能据此推出日夜加班义务。' }
    [ordered]@{ evidenceId='W06'; ordinal=2132; section='劳动、事业与职业意义'; claim='作者认为具体工作和职业可能中断，真正可携带的职业资本是已创造的价值记录和能直接展示能力的作品。'; quote='战绩和能展现能力的作品才是真正的职业硬通货。'; evidenceNature='职业生命与可携带成果'; boundary='针对失业与职业韧性；作者并非说在缺少战绩和作品时年龄、学历等因素完全无关。' }

    [ordered]@{ evidenceId='W07'; ordinal=1031; section='求职、选择与职业发展'; claim='作者认为面谈愉快是面试官的基本职责，落选不能直接等同于实际工作能力被否定，合作姿态是面谈重点。'; quote='你没过面试，其实跟你的实际能力是否真能应付那个工作并没有绝对关联'; evidenceNature='面试筛选与合作姿态'; boundary='这是作者对企业招聘和人才池的解释，不应写成所有公司的确定流程。' }
    [ordered]@{ evidenceId='W08'; ordinal=312; section='求职、选择与职业发展'; claim='作者认为职业适配应看自己是否真正想要该职业成功者的生活，并区分可绕、既成和契约规定的困难。'; quote='所谓“适不适合做这份职业”，有一个很好的判断工具，就是看你是否想要这个职业的成功者的生活状态。'; evidenceNature='职业适配与困难判断'; boundary='成功者参照不应选得遥不可及；文章后半还扩展到一般社会责任。' }
    [ordered]@{ evidenceId='W09'; ordinal=1625; section='求职、选择与职业发展'; claim='作者认为重大专业选择无法保证正确，尽过调查义务后，应选择即使错误也能由未来的自己承受和原谅的方向。'; quote='你所能有的最好的选择，并非所谓的“正确的选择”，而是“我能原谅的选择”——the choice you can live with.'; evidenceNature='职业选择与后悔成本'; boundary='不等于调查研究无用；作者处理的是长期、难逆转选择的责任承担。' }
    [ordered]@{ evidenceId='W10'; ordinal=3874; section='求职、选择与职业发展'; claim='作者主张把职业理解为跨岗位的元角色，把具体岗位视为职业阶段，并投资可跨环境持续使用的元技能。'; quote='你的职业，应该是一个这样级别的表述。这才是你的职业，其他的修饰词只是你的职业的阶段性的附加属性。'; evidenceNature='职业规划与元能力'; boundary='长文建立在作者关于意义、死亡和需求健壮性的整体框架上；设计师只是示例。' }
    [ordered]@{ evidenceId='W11'; ordinal=649; section='求职、选择与职业发展'; claim='作者区分换公司不换专业的专家路线与换岗位不换组织的领袖路线，认为选择取决于组织是否值得长期效忠。'; quote='如果你所在的组织是一个没有愿景、没有清晰的使命、也没有真诚的成员的临时性组织，那就只能拿来走专家路线——果断的换公司不换岗位。'; evidenceNature='专业路线与组织路线'; boundary='只有组织具有生命力、使命和真诚成员时，岗位漂移才被作者解释为领袖资历。' }
    [ordered]@{ evidenceId='W12'; ordinal=938; section='求职、选择与职业发展'; claim='作者认为薪资低于市场公允价时可以认真辞职测试挽留；已达到公允价后，超额薪资要以新增业务、利润和风险控制证明。'; quote='如果你现在的薪水在这条公允价格之下，你希望提升到这个公允价格，你的策略很简单，就是先辞职，而且是老老实实、认认真真的辞职，让老板自己决定要不要留你。'; evidenceNature='加薪、议价与市场价格'; boundary='必须保留低于与不低于公允价两种情形，不能概括成一律辞职争取加薪。' }

    [ordered]@{ evidenceId='W13'; ordinal=17; section='产出、交付与专业能力'; claim='作者要求面对声誉争议时把注意力放回持续产出和对服务对象的实际贡献，而不是无限辩白。'; quote='你和别人最亲近的关系，永远是你的产出，而不是别的。'; evidenceNature='产出优先与职业身份'; boundary='题设是公益人物争议，是产出优先的跨域锚点，不是具体办公程序。' }
    [ordered]@{ evidenceId='W14'; ordinal=625; section='产出、交付与专业能力'; claim='作者把工作归化为取得和移交可验证交付物，认为汇报重点是期限、交付定义和额外资源。'; quote='你可以把“工作”本身直接视为“取得并移交交付物”的过程。'; evidenceNature='交付物定义与工作汇报'; boundary='适用于任务和汇报结构；不能由此否认探索性工作的过程价值。' }
    [ordered]@{ evidenceId='W15'; ordinal=876; section='产出、交付与专业能力'; claim='作者主张把客户反复修改转成逐轮结算、重新报价和可终止的新合同，并把专业名誉设为取得这种合同地位的前提。'; quote='后续无论多少次修改，都按照这个标准模式无限循环。'; evidenceNature='变更管理与合同交付'; boundary='面向设计、开发等供应业务；作者明确说初入行者需先建立作品和名誉。' }
    [ordered]@{ evidenceId='W16'; ordinal=419; section='产出、交付与专业能力'; claim='作者认为能力不足却被授予大项目时，应把领导支持转成正式督导、阶段报告和可追溯责任链。'; quote='你要一个制度性的支持，那就是该领导要正式挂名项目监督/督导，你的定期项目报告要报ta审核签字。'; evidenceNature='大型项目与制度性支持'; boundary='针对上级主动授予的大项目；作者的责任判断是文本内组织设计，不等同于法律责任认定。' }
    [ordered]@{ evidenceId='W17'; ordinal=1281; section='产出、交付与专业能力'; claim='作者认为非营利组织不是不能盈利，而是组织成就的本位指标不以利润衡量，高质量使命仍需要专业人员、薪资和盈余。'; quote='非盈利性根本不表现在“不盈利”或者“避免盈利”上，而是表现在“计算企业成就的指标不是盈利”上。'; evidenceNature='使命指标与专业投入'; boundary='针对非营利组织，不应压缩成一般企业利润无关紧要。' }
    [ordered]@{ evidenceId='W18'; ordinal=1804; section='产出、交付与专业能力'; claim='作者认为开源项目若要持续，必须提供可被他人生意依赖的专业服务，并形成维护者可以获得收入的生态。'; quote='虽是开源，也要以企业家的精神，以对待职业、事业、生意的心态去做。'; evidenceNature='专业开源与事业持续性'; boundary='讨论开源事业的可持续性，不是要求所有公益贡献立即商业化。' }

    [ordered]@{ evidenceId='W19'; ordinal=2; section='协作、分工与功劳分配'; claim='作者要求完成本职之外还要承认同事提供的数据、前后流程和稳定环境，使成果收益能够回到协作网络。'; quote='把自己的工作做好，然后感谢ta的帮助。'; evidenceNature='共同生产与感谢分功'; boundary='针对同事协作与内向者关系，不表示所有参与者贡献相等或取消绩效差异。' }
    [ordered]@{ evidenceId='W20'; ordinal=868; section='协作、分工与功劳分配'; claim='作者主张会议围绕参会者事先提交摘要、本体、意见和最终签字纪要组织，使决策、责任和后续执行可追溯。'; quote='开会不是为了“商量事情”，而是为了“产生会议纪要并签字”。'; evidenceNature='面向纪要的会议协作'; boundary='是作者介绍的一种管理风格，不能写成所有会议唯一合法形式。' }
    [ordered]@{ evidenceId='W21'; ordinal=1231; section='协作、分工与功劳分配'; claim='作者认为负责人以承担首要失败责任换取管理权，应预先设计功劳、责任、补漏预算和贡献记录，而非包揽大部分工作。'; quote='负责人是以搞坏了负首要责任的赌注交换到了管理权，可以凭借管理权来获得最佳结果。'; evidenceNature='项目分功与负责人责任'; boundary='文中的十成项目是作者的示范模型，不是固定会计比例。' }
    [ordered]@{ evidenceId='W22'; ordinal=1656; section='协作、分工与功劳分配'; claim='作者认为跨部门项目要先建立无需外援也能交付最小可用结果的核心团队，再由确定的胜势吸引外围成员合作。'; quote='只有“即使我们都不出力ta们也会赢”，才会让所有人都抢着出力。'; evidenceNature='跨部门协作与核心团队'; boundary='针对可压缩最低目标、可组建少数核心团队的项目；不能推广到所有日常合作。' }
    [ordered]@{ evidenceId='W23'; ordinal=470; section='协作、分工与功劳分配'; claim='作者认为团队成员可以不认同战略或彼此不服，但仍应按专业标准和岗位责任完成合作。'; quote='团队合作，最常规的状态其实是把自己对“战略”的各种认同或不认同抛开，忠实履行自己的职责。'; evidenceNature='分歧中的专业协作'; boundary='前提是成员已接受该岗位和组织；作者没有要求思想认同。' }
    [ordered]@{ evidenceId='W24'; ordinal=494; section='协作、分工与功劳分配'; claim='作者认为工作业绩从直接同事、上司、高层、客户到同行和公众逐层外显，正名通常需要相邻层级的证词。'; quote='如果最近的两级你都取得不了认可，你最好往“自己的功夫和资历还没到位”的方向去思考，而不是往“你们都在针对我”的方向去思考。'; evidenceNature='功劳外显与证词阶梯'; boundary='是作者提出的职业声誉传播经验模型，不是可外部证实的普遍组织规律。' }

    [ordered]@{ evidenceId='W25'; ordinal=2946; section='权柄、管理与责任结构'; claim='作者把管理冲突从私人面子转入正式命令、记录、纪律和人事责任，要求组织为执行链提供制度支持。'; quote='你通过正式途径下发的命令，是公司的命令，对方不服从的是“组织的”管理。'; evidenceNature='正式管理与组织命令'; boundary='依赖有效的正式制度、人事部门和记录渠道；在失能组织中作者转而建议准备离开。' }
    [ordered]@{ evidenceId='W26'; ordinal=3183; section='权柄、管理与责任结构'; claim='作者把报告困难规定为风险预警和团队贡献，同时要求成员及时、按渠道说明，并承担自己未尽责任造成的成本。'; quote='这ABCDEFG里面不该有任何一条是你之前就知道而ta却没听你说过的。'; evidenceNature='困难上报与责任边界'; boundary='上报不是把所有失败转嫁给上司的护身符，组织也有责任教会新人合法困难和报告程序。' }
    [ordered]@{ evidenceId='W27'; ordinal=788; section='权柄、管理与责任结构'; claim='作者认为员工集体要求撤换直属上司时，高层首先应承认信息、监察和用人机制的责任，再调查和修订制度。'; quote='企业里没有决策层无需道歉的过失。'; evidenceNature='高层责任与组织危机'; boundary='是作者对企业危机的处置模型，不确认现实劳动法和公司治理程序。' }
    [ordered]@{ evidenceId='W28'; ordinal=3615; section='权柄、管理与责任结构'; claim='作者严格区分培养、培训和短期帮带，认为真正培养要求覆盖职业周期、可传承事业和双方长期志向。'; quote='你对下属只该谈负责任的指挥、公平的奖惩，是谈不到“培养”的。'; evidenceNature='培养关系与长期责任'; boundary='作者明确把它限定在能承担终身关系的少数组织，反对普通私企滥称培养。' }
    [ordered]@{ evidenceId='W29'; ordinal=3665; section='权柄、管理与责任结构'; claim='作者区分因恐惧而屈服与基于选择而服从，认为有效命令来自成员对组织、目标和授权条件的主动接受。'; quote='服从，是主动的选择。'; evidenceNature='主动服从与授权边界'; boundary='违法、侵犯合法权利或超出契约授权的命令不在服从范围内，成员也保留离开组织的选择。' }
    [ordered]@{ evidenceId='W30'; ordinal=1416; section='权柄、管理与责任结构'; claim='作者把上级拆为客户、服务员和导师三种功能，认为职业阶段变化会改变人对管理和指导的依赖。'; quote='本质上上级领导就是三个角色之和——ta同时是你的客户、服务员和导师。'; evidenceNature='上级功能与职业阶段'; boundary='对后两种角色的依赖随资历降低；不能要求每位上级在所有方面都高于下属。' }

    [ordered]@{ evidenceId='W31'; ordinal=117; section='沟通、关系与组织政治'; claim='作者把圆滑定义为体谅人的软弱、恐惧和私心，在不损害使命的前提下为成员留下适应和喘息空间。'; quote='说到底，无非“体谅”二字。'; evidenceNature='体谅式圆滑与执行分寸'; boundary='圆滑不等于欺骗、巴结或放弃原则，也不是对所有失责无限迁就。' }
    [ordered]@{ evidenceId='W32'; ordinal=2750; section='沟通、关系与组织政治'; claim='作者把社会化定义为与立场未知、多元甚至对立者低成本、可持续、风险可控地建立合作的能力。'; quote='我所谈论的社会化，是超越于具体的意识形态之上的，这是它的首要而且核心的关注。'; evidenceNature='跨立场社会化与合作'; boundary='是跨社会、跨意识形态的一般概念，不是专属职场术语。' }
    [ordered]@{ evidenceId='W33'; ordinal=1419; section='沟通、关系与组织政治'; claim='作者认为把上下级合作贬为讨好、把同事信任贬为人情世故，会由这种态度本身阻断职业发展。'; quote='你把“与上级构建和谐友好的合作关系”蔑称为“讨好领导”，把“与团队成员构建紧密的信任和合作”称为“人情世故”'; evidenceNature='合作关系与老实人自我定性'; boundary='是针对老实人自我定性的短篇反驳，不足以独立承担完整关系理论。' }
    [ordered]@{ evidenceId='W34'; ordinal=1906; section='沟通、关系与组织政治'; claim='作者认为在组织斗争中保持中立，需要足以让双方忌惮的能力、影响力和对隐性拖拽的防范。'; quote='不站队的前提，是“如果触怒你导致你加入敌方会是一个巨大的损失”，同时你又对“隐性拖拽”非常敏锐，以至于对方不敢冒险。'; evidenceNature='组织政治与中立条件'; boundary='针对高冲突、站队压力强的组织政治，不能套用到一切普通同事分歧。' }
    [ordered]@{ evidenceId='W35'; ordinal=1767; section='沟通、关系与组织政治'; claim='作者主张面对公司流言时抓住最近的明确传播者，经正式风纪渠道逐级追查并制造传播成本。'; quote='简单来说就是走正规途径处理就好了，没啥好纠结的。'; evidenceNature='流言追查与正式程序'; boundary='依赖真实存在且可以运转的纪律渠道；不确认具体机构的法律处置权限。' }
    [ordered]@{ evidenceId='W36'; ordinal=1520; section='沟通、关系与组织政治'; claim='作者认为下属不应替领导背锅，而应观察领导能否承担错误、吸收教训和重新出发，再决定是否继续投入。'; quote='是谁的责任就是谁的责任，该怎么样就怎么样。'; evidenceNature='责任归属与领导投资'; boundary='反对的是替人逃避应负责任，不取消正常的共同责任和自愿支持。' }

    [ordered]@{ evidenceId='W37'; ordinal=2377; section='竞争、评价与制度秩序'; claim='作者认为竞争无法靠现有参与者合谋关闭，交通与信息技术扩大竞争者基数，同时也扩大胜利收益。'; quote='竞争是不可能终止的，而且因为信息技术、交通技术的发展，在将来和你竞争的人会越来越多，并且由于生存竞争的烈度只与参与的人数有关，生存竞争的烈度只会越来越大。'; evidenceNature='竞争扩张与内卷解释'; boundary='是作者跨经济、教育和生存领域的宏观理论，论文只能按文本主张记录。' }
    [ordered]@{ evidenceId='W38'; ordinal=1997; section='竞争、评价与制度秩序'; claim='作者认为消除消极工作要建立明确判据、低成本可追溯数据、及时裁判和足以建立信用的典型案例。'; quote='“引入有效竞争”，指的是提高竞争裁判的准确性、降低裁判成本、提高裁判的时效。'; evidenceNature='有效竞争、规则与裁判'; boundary='针对下属普遍消极的组织；作者反对以增加工资资源替代制度修复。' }
    [ordered]@{ evidenceId='W39'; ordinal=1951; section='竞争、评价与制度秩序'; claim='作者认为绩效分配的关键不是个人辛苦，而是员工对上司所服务客户的满意度贡献。'; quote='真正重要的是客户视角。'; evidenceNature='绩效分配与客户贡献'; boundary='原文区分私企经营自由与国企机会公平，不能抹去公私边界。' }
    [ordered]@{ evidenceId='W40'; ordinal=2117; section='竞争、评价与制度秩序'; claim='作者主张劳动者比较外部同类供应商的市场价格，而不是以同事工资作为自己待遇的充分依据。'; quote='你真正的竞争对手其实不是你的同事，所以跟ta们攀比是没有多大意义的。'; evidenceNature='薪酬基准与外部市场'; boundary='是作者将员工理解为驻场供应商的企业模型，不是现行工资制度说明。' }
    [ordered]@{ evidenceId='W41'; ordinal=1268; section='竞争、评价与制度秩序'; claim='作者认为纪律只要可执行、合法、保留退出自由，并能服务组织使命，就应执行，成员也可以选择离开。'; quote='一个纪律除非是逻辑上不可执行的，否则就应该被执行。'; evidenceNature='组织纪律与退出边界'; boundary='题设是学校纪律，承担的是一般组织纪律命题，不是企业劳动法结论。' }
    [ordered]@{ evidenceId='W42'; ordinal=729; section='竞争、评价与制度秩序'; claim='作者主张对被要求签署但合规性存疑的事项，普通执行者应先请求合规、纪律或监管渠道预审。'; quote='你不清楚是否合规，按照企业制度理所当然的应该请合规部门预审。'; evidenceNature='合规预审与签字责任'; boundary='假定组织存在可以使用的预审渠道；原文不是对具体事项是否合法的判断。' }

    [ordered]@{ evidenceId='W43'; ordinal=464; section='离职、失业与未来工作'; claim='作者认为离职后仍应使经手事项有着落，但旧事务只能作为低于现工作、休息和生活的次要优先级。'; quote='凡是我经手的事，都要有始有终，一定不叫它掉在地上。'; evidenceNature='离职交接与职业声誉'; boundary='明确反对离职后随叫随到；帮助可以转成补充交接或付费服务。' }
    [ordered]@{ evidenceId='W44'; ordinal=2772; section='离职、失业与未来工作'; claim='作者主张被裁后先搜集业内信息、持续接触真实招聘市场，再据反馈制定和验证长期发展计划。'; quote='你其实首先要的是招聘人员的反馈，有了这些反馈，你才好针对性的自我发展，而不是完全闭门造车，在家独练神功。'; evidenceNature='裁员过渡与市场反馈'; boundary='作者明确把生活资金不足、必须立即就业排除在从容选择之外。' }
    [ordered]@{ evidenceId='W45'; ordinal=3598; section='离职、失业与未来工作'; claim='作者认为好企业的重要标志，是员工离开后愿意回来，企业也愿意重新录用，使离职成为光荣退役。'; quote='走了的员工不介意再回来，而企业也乐于再录用。'; evidenceNature='职业母港与再录用'; boundary='是作者提出的简短鉴定标准，不是完整离职制度。' }
    [ordered]@{ evidenceId='W46'; ordinal=3293; section='离职、失业与未来工作'; claim='作者认为创业应等待需求、他人难以承担的风险或痛苦、自己的特殊耐受与既有资产同时成为事实。'; quote='少了任何一条，都不要“创业”。'; evidenceNature='创业契机与既成条件'; boundary='作者反对把仍需数年才能成立的条件当成创业计划。' }
    [ordered]@{ evidenceId='W47'; ordinal=50; section='离职、失业与未来工作'; claim='作者认为AI一人公司应从已验证、有护城河的多人业务拆解孵化，不能以技术领先替代产权、客户和经营能力。'; quote='一人公司应该是由多人公司拆解、精简而来，而非作为首次创业的支撑形式。'; evidenceNature='一人公司、AI与业务孵化'; boundary='包含作者对AI成本和商业关系的预测，不是所有一人公司的经验统计。' }
    [ordered]@{ evidenceId='W48'; ordinal=3482; section='离职、失业与未来工作'; claim='作者判断AI会消灭大量现有岗位，并设想以公有算力租金、终身学习研究津贴和新职业结构形成稳态。'; quote='人工智能的应用毋庸置疑的会导致大量人口失去现有的工作岗位。'; evidenceNature='智能失业与未来稳态'; boundary='是作者的未来制度设想，不是现行制度描述或已经证实的预测。' }
)

$corpus = [Collections.Generic.List[object]]::new()
foreach ($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($CorpusPath))) {
    if (-not [string]::IsNullOrWhiteSpace($line)) { $corpus.Add(($line | ConvertFrom-Json)) }
}
if ($corpus.Count -ne 4050) { throw "Expected 4050 corpus articles, found $($corpus.Count)." }

$screenedIds = @{}
foreach ($row in Import-Csv -LiteralPath ([IO.Path]::GetFullPath($ScreeningPath))) { $screenedIds[[string]$row.id] = $true }

$rows = [Collections.Generic.List[object]]::new()
foreach ($item in $items) {
    $ordinal = [int]$item.ordinal
    if ($ordinal -lt 1 -or $ordinal -gt $corpus.Count) { throw "[$($item.evidenceId)] Ordinal $ordinal is outside the corpus." }
    $article = $corpus[$ordinal - 1]
    $isScreened = $screenedIds.ContainsKey([string]$article.id)
    $isApprovedSupplement = $approvedSupplementOrdinals -contains $ordinal
    if (-not $isScreened -and -not $isApprovedSupplement) { throw "[$($item.evidenceId)] Article is neither screened nor an approved supplement." }
    if ($isScreened -and $isApprovedSupplement) { throw "[$($item.evidenceId)] Approved supplement ordinal $ordinal unexpectedly appears in screening." }
    $quoteOk = ([string]$article.text).Contains([string]$item.quote, [StringComparison]::Ordinal)
    if (-not $quoteOk) { throw "[$($item.evidenceId)] Exact quote validation failed: $($item.quote)" }
    $date = [DateTimeOffset]::FromUnixTimeMilliseconds([int64]$article.publishedAt).ToOffset([TimeSpan]::FromHours(8)).ToString('yyyy-MM-dd')
    $rows.Add([pscustomobject][ordered]@{
        evidenceId=$item.evidenceId; section=$item.section; claim=$item.claim; evidenceNature=$item.evidenceNature; boundary=$item.boundary
        ordinal=$ordinal; id=[string]$article.id; date=$date; title=[string]$article.title; url=[string]$article.url
        quote=$item.quote; quoteExact=$quoteOk; sourceLayer=if($isScreened){'screened'}else{'approved-supplement'}
    })
}

$requiredSections = @(
    '劳动、事业与职业意义','求职、选择与职业发展','产出、交付与专业能力','协作、分工与功劳分配',
    '权柄、管理与责任结构','沟通、关系与组织政治','竞争、评价与制度秩序','离职、失业与未来工作'
)
$sectionCounts=[ordered]@{}; foreach($section in $requiredSections){$sectionCounts[$section]=@($rows|Where-Object section -eq $section).Count}
$uniqueEvidenceIds=@($rows.evidenceId|Sort-Object -Unique).Count
$uniqueArticleIds=@($rows.id|Sort-Object -Unique).Count
$uniqueOrdinals=@($rows.ordinal|Sort-Object -Unique).Count
$missingCoreFields=@($rows|Where-Object{[string]::IsNullOrWhiteSpace($_.claim)-or[string]::IsNullOrWhiteSpace($_.evidenceNature)-or[string]::IsNullOrWhiteSpace($_.boundary)-or[string]::IsNullOrWhiteSpace($_.quote)}).Count
$exactQuoteFailures=@($rows|Where-Object quoteExact -eq $false).Count
$allSectionsCovered=@($requiredSections|Where-Object{$sectionCounts[$_] -ne 6}).Count -eq 0
$screenedEvidenceRows=@($rows|Where-Object sourceLayer -eq 'screened').Count
$supplementRows=@($rows|Where-Object sourceLayer -eq 'approved-supplement')
$supplementOrdinals=@($supplementRows.ordinal|Sort-Object)
$supplementSetMatches=@(Compare-Object -ReferenceObject @($approvedSupplementOrdinals|Sort-Object) -DifferenceObject $supplementOrdinals).Count -eq 0

$rows|Export-Csv -LiteralPath ([IO.Path]::GetFullPath($OutputPath)) -NoTypeInformation -Encoding utf8BOM
$status=if(
    $rows.Count-eq48-and$uniqueEvidenceIds-eq48-and$uniqueArticleIds-eq48-and$uniqueOrdinals-eq48-and
    $screenedIds.Count-eq1278-and$screenedEvidenceRows-eq47-and$supplementRows.Count-eq1-and$supplementSetMatches-and
    $missingCoreFields-eq0-and$exactQuoteFailures-eq0-and$allSectionsCovered
){'PASS'}else{'REVIEW'}
$stats=[ordered]@{
    corpusArticles=$corpus.Count; screenedCandidates=$screenedIds.Count; evidenceRows=$rows.Count
    uniqueEvidenceIds=$uniqueEvidenceIds; uniqueArticleIds=$uniqueArticleIds; uniqueOrdinals=$uniqueOrdinals
    screenedEvidenceRows=$screenedEvidenceRows; directReviewSupplements=$supplementRows.Count; supplementOrdinals=$supplementOrdinals
    missingCoreFields=$missingCoreFields; exactQuoteFailures=$exactQuoteFailures; sectionCounts=$sectionCounts; status=$status
}
$stats|ConvertTo-Json -Depth 5|Set-Content -LiteralPath ([IO.Path]::GetFullPath($StatsPath)) -Encoding utf8
$stats|ConvertTo-Json -Depth 5
if($status-ne'PASS'){throw "Workplace core evidence validation ended with status $status."}
