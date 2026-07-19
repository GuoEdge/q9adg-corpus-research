param(
    [string]$CorpusPath = '.\sooon-q9adg-articles.jsonl',
    [string]$ScreeningPath = '.\research\data\family_kinship_screening.csv',
    [string]$OutputPath = '.\research\data\family_kinship_core_evidence.csv',
    [string]$StatsPath = '.\research\data\family_kinship_core_evidence.stats.json'
)

$ErrorActionPreference = 'Stop'

# The lexical screen is a recall aid. Article 105 is an audited supplement
# because its functional-care argument is central despite missing that screen.
$approvedSupplements = @{
    105 = 'Core functional-care text recovered by direct corpus review.'
}

$items = @(
    [ordered]@{ evidenceId='F01'; ordinal=2841; section='亲子抚养与基本照护'; claim='作者把子女诉求区分为乞求、祈求、请求、需求和要求，要求父母先受理和定性，再分别承担基本生存义务、聆听、合作审查或家庭交易规则。'; quote='子女对父母提出的东西，在被定性之前，只能看做诉求。'; evidenceNature='亲子诉求分类与照护程序'; boundary='基本保障与额外自主空间在文中属于不同层次，聆听和礼貌受理不等于必须满足全部诉求。' }
    [ordered]@{ evidenceId='F02'; ordinal=3221; section='亲子抚养与基本照护'; claim='作者认为离婚后的抚养义务可被隐瞒收入、转移财产、拒付和执行拖延削弱，并把低成本逃避抚养写成损伤总体社会信任的问题。'; quote='不愿再承担抚养义务的人在事实上是有大量的手段逃脱离婚后的抚养义务的。'; evidenceNature='抚养义务执行与社会信用判断'; boundary='文章以具体判决和作者的法律观察展开，本文只记录其判断，不认证实际法律效果。' }
    [ordered]@{ evidenceId='F03'; ordinal=3519; section='亲子抚养与基本照护'; claim='作者反对在重组家庭中以“永远不会改变”的保证恢复安全感，主张承认能力有限，并以持续努力帮助子女不再恐惧爱会消失。'; quote='爱是自知不能，尽力而为'; evidenceNature='重组家庭中的承诺边界'; boundary='文章没有否定长期承诺，而是否定把愿望和努力说成绝不会失败的能力保证。' }
    [ordered]@{ evidenceId='F04'; ordinal=3699; section='亲子抚养与基本照护'; claim='作者把社会化抚养限定为家庭抚养明显失败时的补充，并以多样性、制度惯性和政府权力扩张为由反对把它主动推进为一般策略。'; quote='社会化抚养必须绝对遵循谦抑原则'; evidenceNature='家庭与公共抚养的制度边界'; boundary='这是作者对社会化抚养的政治制度判断，不被改写成外部政策事实。' }
    [ordered]@{ evidenceId='F05'; ordinal=3291; section='亲子抚养与基本照护'; claim='作者要求父母对未成年子女的真实过错承担教育责任；若子女无错而遭无权审判，则应离开并撤回利益输出，而不是求取对方认可。'; quote='如果的确是子女有错，那么父母应该道歉——是我们没教好，这怪我们。'; evidenceNature='监护责任与对外保护程序'; boundary='撤回输出针对无授权且无礼的关系场景，不等于否定一切第三方评价或公共规则。' }
    [ordered]@{ evidenceId='F06'; ordinal=3465; section='亲子抚养与基本照护'; claim='作者要求父母逐步让子女认识不平等的现实，同时坚持父母和教师作为受托者不能亲自欺骗、歧视或伤害子女来模拟未来世界。'; quote='你是父母，你的孩子将来可能受别人的骗，难以避免，但这绝不意味着你可以自己去骗ta，以“提前让ta适应被欺骗”。'; evidenceNature='现实教育与受托者不加害边界'; boundary='文章并列现实并不完美与受托者不得主动施害，不把保护写成隐瞒全部现实。' }

    [ordered]@{ evidenceId='F07'; ordinal=157; section='父母权柄与成年退出'; claim='作者把父母规定为帮助子女建立世界关系的临时代言人，要求在安全范围内允许验证、犯错和超越父母。'; quote='你要吸取的教训不是“以后要听父母的”，而是要训练自己调查线索、验证原理的水平和能力'; evidenceNature='父母角色与权柄退出'; boundary='文章仍承认危险情况下的保护和看守，反对的是把保护结果解释为永久服从资格。' }
    [ordered]@{ evidenceId='F08'; ordinal=3277; section='父母权柄与成年退出'; claim='作者区分服从与屈从，把前者写成基于理性、爱或客观限制的主动决定，并要求保留停止服从的自由。'; quote='服从是一种决定。'; evidenceNature='家庭命令的授权基础'; boundary='文章没有取消父母提出命令的可能，而是把命令资格系于谦卑、忏悔、爱和退出权。' }
    [ordered]@{ evidenceId='F09'; ordinal=2844; section='父母权柄与成年退出'; claim='作者主张基本保障之外的额外家庭权限应通过能力、信用和可逆练习逐级取得，把自由同时写成需要训练的技能。'; quote='自由是父母天然拥有的、最大的、最贵重的奖励筹码'; evidenceNature='未成年自主权限的渐进授予'; boundary='“零起点”是作者的强家庭制度方案，基本权利基线在文中另列，不能概括成未成年人没有任何权利。' }
    [ordered]@{ evidenceId='F10'; ordinal=11; section='父母权柄与成年退出'; claim='作者认为父母可以不赞成或不资助成年子女的选择，但不应以阻挠和情绪控制抬高子女本有自由的成本。'; quote='爱的第一要义是要接受人的自由。'; evidenceNature='成年选择、反对与自由边界'; boundary='接受自由不等于父母必须赞成、出资或放弃表达反对。' }
    [ordered]@{ evidenceId='F11'; ordinal=3530; section='父母权柄与成年退出'; claim='作者把子女隐私解释为最高决定权逐步交接的结果，要求这种交接稳定、受控、渐进并可逆。'; quote='稳定的、受控的、渐进的、可逆的在练习中转移这项至关重要的指挥权，是更理想的做法。'; evidenceNature='隐私与决定权交接机制'; boundary='文章没有把所有隐私都设为父母奖励，而是讨论法定成年前责任与决定权如何练习交接。' }
    [ordered]@{ evidenceId='F12'; ordinal=1299; section='父母权柄与成年退出'; claim='作者把成年后的父母子女关系降为“最友善的陌生人”式特殊友情，要求预约、隐私、分居、婚育不干预和财务制度化。'; quote='子女满18岁之后，就要视为独立的人。'; evidenceNature='成年亲子边界与双向礼仪'; boundary='“最友善的陌生人”是作者设置的边界准绳，不表示亲情、赡养或自愿超额付出全部消失。' }

    [ordered]@{ evidenceId='F13'; ordinal=2313; section='赡养养老与代际支持'; claim='作者把孝顺定义为朝向父母并努力维持关系的方向，而不是服从指令、避免全部冲突或保证父母满意的结果。'; quote='孝顺讲的是努力方向，冲不冲突是努力的客观结果。'; evidenceNature='孝的定义与评价尺度'; boundary='文章承认冲突和失败可能存在，所反对的是仅以结果否定子女已经作出的关系努力。' }
    [ordered]@{ evidenceId='F14'; ordinal=3511; section='赡养养老与代际支持'; claim='作者把养老写成需要提前多年筛选、观察、教育和交托的性命相托关系，并主张血缘子女之外也可培养精神和关系上的后继照护者。'; quote='“养老”这件事，本质上就是性命相托。'; evidenceNature='养老关系的长期建构'; boundary='文章不认为法定子女身份自然保证照护能力，也未把普通短期服务合同写成充分替代。' }
    [ordered]@{ evidenceId='F15'; ordinal=751; section='赡养养老与代际支持'; claim='作者认为父母把子女当作全部人生价值、又缺乏财务和责任边界，会使晚年依附于子女；自由主体之间的自愿付出才被其称为爱。'; quote='你的钱就是你的钱，你的时间就是你的时间，你的自由就是你的自由'; evidenceNature='养老依赖与亲子财务边界'; boundary='文章反对无边界依附，不是否定成年子女自愿承担照料与支持。' }
    [ordered]@{ evidenceId='F16'; ordinal=3711; section='赡养养老与代际支持'; claim='作者设想养老机构首先成为研究生存与死亡、训练送别并把临终经验传给后来者的共同体，而不只是消费性安乐设施。'; quote='养老院首先应该是一所关于生存和死亡的学术机构。'; evidenceNature='养老机构目的与临终共同体设想'; boundary='这是作者的理想机构方案，包含资格、发愿和服务要求，不是对现行养老院的经验描述。' }
    [ordered]@{ evidenceId='F17'; ordinal=1367; section='赡养养老与代际支持'; claim='作者反对以孝道要求子女清空跨代积累来延长濒死父母生命，把家族可持续性置于无边界救治之前。'; quote='父母太恋栈生命，乃至于要用所谓“孝道”去逼迫子女“毁家纾难”，干脆就是不道德的'; evidenceNature='临终救治与跨代资源边界'; boundary='文章承认子女可以使用受赠财产救治父母，所限制的是把全部家族资源变成当然义务。' }
    [ordered]@{ evidenceId='F18'; ordinal=2763; section='赡养养老与代际支持'; claim='作者区分法定抚养、未经请求且不索回报的额外恩惠和附带感恩条件的强制交换，并要求子女对额外部分的权利主张保持一致。'; quote='父母的遗产不要惦记，那不是ta们理所当然欠你的。'; evidenceNature='父母恩、义务与遗产边界'; boundary='文章允许子女否认父母有恩，但要求同时放弃把超额给付和遗产当作当然权利。' }

    [ordered]@{ evidenceId='F19'; ordinal=100; section='扩展亲属与人情网络'; claim='作者把投资、借款和援助分开，要求亲友援助设为自身能长期承担的固定额度与期限，而不以彻底解决对方人生为目标。'; quote='再重申一个总原则——投资是投资、借款是借款、援助是援助。'; evidenceNature='亲属援助的名分与限额'; boundary='有限兜底针对扩展亲友，不取代对子女和父母的抚养赡养义务。' }
    [ordered]@{ evidenceId='F20'; ordinal=149; section='扩展亲属与人情网络'; claim='作者认为族亲网络中的早期出席、主动帮助和礼物可以形成声誉支持，使成员以后获得低摩擦缺席的空间。'; quote='确保你不在的时候你的名声不会变坏。'; evidenceNature='族亲声誉与关系退出机制'; boundary='这是先经营再减少出席的一条路径，不表示任何边界都必须以礼物和声誉投资购买。' }
    [ordered]@{ evidenceId='F21'; ordinal=1480; section='扩展亲属与人情网络'; claim='作者认为“长兄如父”只有在年长子女长期获得管理权、资源、训练和最终庇护责任时才成立，反对无权而担责。'; quote='长兄长姊对弟弟妹妹有不可质疑的第一处置权和管理权'; evidenceNature='手足责任与家庭职位结构'; boundary='文章描述传统长子职位的权责配套，不把年龄本身当作对弟妹危机承担全部责任的依据。' }
    [ordered]@{ evidenceId='F22'; ordinal=3657; section='扩展亲属与人情网络'; claim='作者把爱写成自愿接受一定拖累、误解和伤害可能的许可，同时坚持许可额度由爱人自己决定，爱不能成为普遍义务。'; quote='爱，其实就是一种“拖累许可”'; evidenceNature='手足之爱与自愿承担'; boundary='接受一定拖累不等于无限负责；文章尤其反对一面索取爱的名分、一面要求完全保本。' }
    [ordered]@{ evidenceId='F23'; ordinal=1; section='扩展亲属与人情网络'; claim='作者要求子女先承担父丧支出，再以致谢和逐家还礼为由取得礼金明细，使责任、账目和亲属人情进入同一程序。'; quote='为人子者，绝无父丧不自己出钱的道理'; evidenceNature='丧葬责任与人情账目'; boundary='文章的传统责任前提和礼金程序只作为作者主张处理，不被认证为普遍法律规则。' }
    [ordered]@{ evidenceId='F24'; ordinal=1839; section='扩展亲属与人情网络'; claim='作者主张家庭成员超出法定义务的经济支持应有名分、约定和凭证，以明确债务减少隐性期待和日后清算。'; quote='其实兄姐、子女不是不愿意为家庭做贡献，但是这个贡献要有名分，要有约定、要有凭证、要有念想。'; evidenceNature='亲属资助的债务化与可追溯性'; boundary='债务化在文中不是否认恩情，而是使额外贡献的权利义务可被识别。' }

    [ordered]@{ evidenceId='F25'; ordinal=165; section='家庭资源与财产安排'; claim='作者把家庭积蓄和现金流解释为父母保持乐观、宽容并允许子女试错的安全余量，要求教育机会与家庭心理容错一起算总账。'; quote='算账一定要算总账，这一点关节，父母们一定要心里有数。'; evidenceNature='家庭财富的情绪与容错功能'; boundary='文章没有普遍反对进城或教育投入，而是反对以切断主要财富增长和安全余量为代价。' }
    [ordered]@{ evidenceId='F26'; ordinal=72; section='家庭资源与财产安排'; claim='作者提出把子女多年家务、学习和良好习惯转成受监管资产，并在成年时转为清晰的亲子债权和自主消费基础。'; quote='人一成年，就要开始花自己的钱。'; evidenceNature='成年独立的家庭资产交接'; boundary='具体金额、利息和年限是作者的一套家庭方案，不被写成所有家庭必须采用的公式。' }
    [ordered]@{ evidenceId='F27'; ordinal=2476; section='家庭资源与财产安排'; claim='作者反对父母把自己的财产预先宣布为子女所有，认为这种承诺会制造子女干预父母医疗、养老和消费的权利错觉。'; quote='你是在用你子女的人格换你的那点“天伦之乐”。'; evidenceNature='父母财产权与遗产预期'; boundary='文章没有否定父母自愿赠与和立遗嘱，而是否定把未来遗产提前说成子女现有财产。' }
    [ordered]@{ evidenceId='F28'; ordinal=2440; section='家庭资源与财产安排'; claim='作者把家族基金设为规则固定、专款专用、奖励可验证成果的辅助制度，反对以民主灵活之名随时兜底成员失败。'; quote='家族基金仅负责提供生存优势，不负责“保证生存”。'; evidenceNature='跨代基金的规则与功能边界'; boundary='基金不应集中全部家产，成员家庭仍须财务独立，规则“独裁”指用途受控而非一人任意支配。' }
    [ordered]@{ evidenceId='F29'; ordinal=2338; section='家庭资源与财产安排'; claim='作者认为独立家庭和人格边界可以与利益关联并存，利益共同体只表示收益损失相关，不表示“你的就是我的”。'; quote='“两个家庭”跟“利益共同体”根本就不是互相排除的矛盾关系，而是从一开始就是并立的。'; evidenceNature='家庭独立与共同利益定义'; boundary='文章反对用共同利益取消独立人格，不是否认家庭之间存在真实经济关联。' }
    [ordered]@{ evidenceId='F30'; ordinal=2360; section='家庭资源与财产安排'; claim='作者提出通过连续遗嘱、个人受益人和未成年支取限制安排跨代财产，使遗产不自动进入婚姻共同财产。'; quote='父母的遗嘱明确指明受益人是自己的女儿，而非女儿夫妇。'; evidenceNature='遗嘱与跨代财产隔离方案'; boundary='这是作者提出的具体法律安排，本文不确认其在不同法域的效力。' }

    [ordered]@{ evidenceId='F31'; ordinal=105; section='危机照料与功能替代'; claim='作者把探病分解为回应医疗与生活需求、暂时代替家庭工作功能、保障病后社会回归，并限制非专业者给出乐观医疗保证。'; quote='分担对方生病造成的社会性影响。'; evidenceNature='疾病危机中的功能替代程序'; boundary='文章要求亲友做功课并提供具体帮助，但没有赋予非专业者诊断和治疗资格。' }
    [ordered]@{ evidenceId='F32'; ordinal=1565; section='危机照料与功能替代'; claim='作者要求家长先改变自身思考、分别记录亲子史和自传，再共同阅读、协商生活规则与重返社会计划，以系统方式回应子女抑郁。'; quote='你自己作为子女社会环境的最大要素，必须有所改变。'; evidenceNature='家庭心理危机的记录与协商方案'; boundary='文章是作者提出的家庭系统方法，不替代专业诊断，也不被本文认证为临床疗效方案。' }
    [ordered]@{ evidenceId='F33'; ordinal=3541; section='危机照料与功能替代'; claim='作者区分从容选择的亲自照料与因不信任外部协作者而被迫封闭照料，认为动机和家庭情绪环境会进入子女成长。'; quote='动机是一种魔法。'; evidenceNature='照料动机、委托与家庭环境'; boundary='文章没有否定父母亲自照料，而是区分主动选择、受托协作和恐惧驱动的封闭。' }
    [ordered]@{ evidenceId='F34'; ordinal=1891; section='危机照料与功能替代'; claim='作者认为旧式“放养”的低成本依赖熟人社会共同识别和照看儿童，现代核心家庭则被迫承担被抽走的社区监护功能。'; quote='整个社区几千号人都在替父母留神帮手，父母们当然放松得很。'; evidenceNature='社区照看与家庭功能迁移'; boundary='文章不是主张机械恢复旧规则，而是要求理解传统共同照看背后的机制并在新条件下重建。' }
    [ordered]@{ evidenceId='F35'; ordinal=84; section='危机照料与功能替代'; claim='作者主张家庭共同制定走失、失火、晕倒等安全预案并反复演练，把危机准备同时变成亲子爱和共同记忆。'; quote='不要单纯的当作安全事项来做，而要当作彼此相爱的实践来做'; evidenceNature='家庭安全预案与共同演练'; boundary='文章强调预案和演练的关系意义，没有宣称小册子能够消除全部现实风险。' }
    [ordered]@{ evidenceId='F36'; ordinal=407; section='危机照料与功能替代'; claim='作者认为子女对陷入长期心理困境的成年父母应提供稳定而有限的生活支持、寻找专业帮助并先发展自身，而不承担解决全部心结的责任。'; quote='子女对父母的支持，不是要去解决完父母的问题，而是给父母助力，给ta们终极的安慰。'; evidenceNature='成年亲属危机支持与专业分工'; boundary='有限支持针对成年人的长期情绪与康复，不被用来削弱未成年抚养或紧急安全责任。' }

    [ordered]@{ evidenceId='F37'; ordinal=178; section='家务、日常协作与成家边界'; claim='作者把做饭、收纳和常规维修写成创造价值、建立秩序、训练规划执行和形成生活乐趣的家庭教育。'; quote='但做饭做菜、收纳整理和常规维修安装，是应该亲手操作、甚至要精通的。'; evidenceNature='家务能力与现实价值训练'; boundary='文章允许把繁重清洁和高度专业安装外包，不主张所有家务都必须亲自完成。' }
    [ordered]@{ evidenceId='F38'; ordinal=1669; section='家务、日常协作与成家边界'; claim='作者面对姻亲提出的严肃生活要求，主张先缓解敌意、道歉并进行有期限的临时试行，再以实际体验推动折中。'; quote='首要的问题绝不是在这个极端紧张而敏感的、准敌意的状态下进行谈判'; evidenceNature='姻亲冲突的降温与试行程序'; boundary='临时执行在文中是恢复善意和暴露方案缺点的策略，不等于永久接受对方全部要求。' }
    [ordered]@{ evidenceId='F39'; ordinal=3976; section='家务、日常协作与成家边界'; claim='作者把家庭物品的编号、定位和分类视为持续塑造行为的环境接口，并要求先以可见秩序建立共享正反馈。'; quote='人的稳定居住环境是一种塑造人的性格的魔法接口。'; evidenceNature='居住环境、秩序与行为塑形'; boundary='文章同时讨论儿童跨入抽象学习的困难，不能把环境整理写成解决全部教育问题的充分条件。' }
    [ordered]@{ evidenceId='F40'; ordinal=1508; section='家务、日常协作与成家边界'; claim='作者把婚姻写成两个成年人的直接结盟，要求每一方过滤本方父母要求，并独自承担与本方父母交涉的责任。'; quote='配偶之间商量决定，决定了之后对抗各自父母的责任就全在自己身上，而不在配偶身上。'; evidenceNature='夫妻结盟与姻亲边界'; boundary='父母在文中仍被视为贵客，失去的是指挥配偶和越过自己子女施压的资格。' }
    [ordered]@{ evidenceId='F41'; ordinal=632; section='家务、日常协作与成家边界'; claim='作者反对以过度供养、规划和结算投入替代子女主体成长，主张让子女尽早对家庭作出真实贡献并获得相互感激。'; quote='你哪里在托举？'; evidenceNature='家庭贡献、托举与主体形成'; boundary='文章批评的是把单一路径强推到底的供养，不是否定父母提供资源和保护。' }
    [ordered]@{ evidenceId='F42'; ordinal=1107; section='家务、日常协作与成家边界'; claim='作者要求失业家庭成员以家务、生活整理、现场调查和策略更新交付可见成果，同时反对让辱骂因短期有效而积累成家庭暴力债。'; quote='暴力不是在战术上无效，恰恰相反，正是因为它有效，它的危害才如此巨大和深刻。'; evidenceNature='失业期家庭贡献与暴力循环'; boundary='文章同时要求行动者改变和家庭停止暴力，不能只抽取其中一面归责。' }

    [ordered]@{ evidenceId='F43'; ordinal=3933; section='家族传承、记忆与共同体'; claim='作者把门当户对重新定义为两个追求长期基业、具有祖宗自觉的家族相遇，并把家族边界扩展到共同基业中的非血缘伙伴。'; quote='基业所及，即为族人。'; evidenceNature='家族基业与成员边界'; boundary='“永世长存”和祖宗自觉是作者的家族理想，不是对现实世家存续的经验保证。' }
    [ordered]@{ evidenceId='F44'; ordinal=3918; section='家族传承、记忆与共同体'; claim='作者主张家族在衣食住上保持节制，把资源优先投入学习、文明经验、后代伙伴培养和持续慈善，以减少享受水平的跨代负担。'; quote='一代有眼界，正常而言就代代有眼界。'; evidenceNature='家族财富的教育与慈善配置'; boundary='文章中的投资回报和财富风险属于作者判断，本文不替其作外部经济验证。' }
    [ordered]@{ evidenceId='F45'; ordinal=420; section='家族传承、记忆与共同体'; claim='作者把香火传承解释为父母确认责任得到接续、从而允许自己退出极限奉献并接受死亡的文化安全信号。'; quote='第三代的出生，约等于第一代接受死亡的无声前提。'; evidenceNature='生育、代际责任与父母退出解释'; boundary='这是作者对中国家庭文化和催婚催生的内部解释，不能概括所有父母动机。' }
    [ordered]@{ evidenceId='F46'; ordinal=2005; section='家族传承、记忆与共同体'; claim='作者反对把学习压力集中到子女一代，主张第一代父母先亲自学习研究，用三代时间把实践经验沉淀为无需反复说服的家风。'; quote='你在没在学习，比你儿子在没在学习对你们的家族前途更加重要。'; evidenceNature='知识家风的三代积累'; boundary='“三代”是作者的代际模型，不表示任何家庭都必然按固定代数形成文化。' }
    [ordered]@{ evidenceId='F47'; ordinal=929; section='家族传承、记忆与共同体'; claim='作者以人口迁移、灾害和文化边界解释南北宗族差异，把北方写成不断打散重组的糅合机制，把南方写成更强的文化围墙。'; quote='这就意味着北方宗族有一种相当强烈的不断被打散后重新聚合的“糅合”机制'; evidenceNature='宗族结构与历史机制判断'; boundary='文章的南北历史解释仅作为作者主张，不被本文认证为完备的社会史结论。' }
    [ordered]@{ evidenceId='F48'; ordinal=1265; section='家族传承、记忆与共同体'; claim='作者要求家族史采访从最早可知一代沿时间线推进，以影像、地图、照片和人物材料交叉核实，并经受访者审阅后多地保存。'; quote='沿着时间顺序，从采访对象所知道的最早的长辈的事情开始，逐年推进。'; evidenceNature='家族记忆的采集、核实与保存程序'; boundary='文章提供的是家族史记录方法，不保证口述材料未经交叉核实即可成为完整历史事实。' }
)

$corpus = [Collections.Generic.List[object]]::new()
foreach ($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($CorpusPath))) {
    if (-not [string]::IsNullOrWhiteSpace($line)) { $corpus.Add(($line | ConvertFrom-Json)) }
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
    $inScreening = $screenedIds.ContainsKey([string]$article.id)
    $isApprovedSupplement = $approvedSupplements.ContainsKey([int]$item.ordinal)
    if (-not $inScreening -and -not $isApprovedSupplement) { throw "[$($item.evidenceId)] Article is neither screened nor an approved supplement." }
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
        sourceLayer = if ($inScreening) { 'screened' } else { 'direct-review-supplement' }
    })
}

$requiredSections = @(
    '亲子抚养与基本照护', '父母权柄与成年退出', '赡养养老与代际支持', '扩展亲属与人情网络',
    '家庭资源与财产安排', '危机照料与功能替代', '家务、日常协作与成家边界', '家族传承、记忆与共同体'
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
$supplementRows = @($rows | Where-Object sourceLayer -eq 'direct-review-supplement')

$rows | Export-Csv -LiteralPath ([IO.Path]::GetFullPath($OutputPath)) -NoTypeInformation -Encoding utf8BOM
$status = if (
    $rows.Count -eq 48 -and $uniqueEvidenceIds -eq 48 -and $uniqueArticleIds -eq 48 -and
    $screenedIds.Count -eq 692 -and $supplementRows.Count -eq 1 -and
    [int]$supplementRows[0].ordinal -eq 105 -and $missingCoreFields -eq 0 -and $allSectionsCovered -and
    -not ($rows.quoteExact -contains $false)
) { 'PASS' } else { 'REVIEW' }
$stats = [ordered]@{
    corpusArticles = $corpus.Count
    screenedCandidates = $screenedIds.Count
    evidenceRows = $rows.Count
    uniqueEvidenceIds = $uniqueEvidenceIds
    uniqueArticleIds = $uniqueArticleIds
    screenedEvidenceRows = @($rows | Where-Object sourceLayer -eq 'screened').Count
    directReviewSupplements = $supplementRows.Count
    supplementOrdinals = @($supplementRows.ordinal)
    missingCoreFields = $missingCoreFields
    exactQuoteFailures = @($rows | Where-Object quoteExact -eq $false).Count
    sectionCounts = $sectionCounts
    status = $status
}
$stats | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath ([IO.Path]::GetFullPath($StatsPath)) -Encoding utf8
$stats | ConvertTo-Json -Depth 5
if ($status -ne 'PASS') { throw "Family and kinship core evidence validation ended with status $status." }

