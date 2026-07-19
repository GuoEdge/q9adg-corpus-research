param(
    [string]$CorpusPath = '.\sooon-q9adg-articles.jsonl',
    [string]$ScreeningPath = '.\research\data\ethnicity_identity_screening.csv',
    [string]$OutputPath = '.\research\data\ethnicity_identity_core_evidence.csv',
    [string]$StatsPath = '.\research\data\ethnicity_identity_core_evidence.stats.json'
)

$ErrorActionPreference = 'Stop'

$items = @(
    [ordered]@{ evidenceId='E01'; ordinal=3201; section='民族概念、共同体与边界'; claim='作者把中华民族定义为文化认同而非血统身份，并把民族分类解释为殖民分化工具。'; quote='“中华民族”根本就不是一个血统身份，而是一个文化认同身份。'; evidenceNature='民族概念与文化认同'; boundary='只代表本文的民族概念和殖民解释，不是作者对全部生物、法律身份问题的完整分类。' }
    [ordered]@{ evidenceId='E02'; ordinal=3170; section='民族概念、共同体与边界'; claim='作者把民族主义压缩为平等和自主诉求，把种族主义压缩为优越、孤立和不需要他者。'; quote='民族主义的口号是“我们不比任何人差”，'; evidenceNature='民族主义与种族主义的明示区分'; boundary='这是作者用于伦理自检的压缩定义，不是对两者全部历史形态的穷尽说明。' }
    [ordered]@{ evidenceId='E03'; ordinal=2266; section='民族概念、共同体与边界'; claim='作者认为民族团结不是对称交换，而是强者向弱者开放；通婚、接纳混血后代及其权利是关键证明。'; quote='团结并不是一种相互对称的等价交换，而是强者基于优越的实力和高度的自信，对弱者的开放、宽容和接纳。'; evidenceNature='强弱结构、通婚与民族团结'; boundary='文本集中讨论强弱关系和通婚开放，未给出民族团结的全部制度安排。' }
    [ordered]@{ evidenceId='E04'; ordinal=1744; section='民族概念、共同体与边界'; claim='作者把国际主义界定为某种跨国理想高于本国利益，并另将国际人道主义从阵营式国际主义中分出。'; quote='一个自我声明的国际主义者对于民族国家而言就是一个公开的不忠者。'; evidenceNature='民族国家与跨国身份边界'; boundary='文中的不忠判断以该国是否为这种国际主义中心为条件，并明确不包括作者所称国际人道主义。' }
    [ordered]@{ evidenceId='E05'; ordinal=3833; section='民族概念、共同体与边界'; claim='作者认为民族只有主动增进他者繁荣、对敌人也保留援助和人道主义，才配称伟大。'; quote='让自己繁荣不叫伟大，让别人能繁荣才称为伟大。'; evidenceNature='民族伟大与对外责任'; boundary='文章提出的是民族使命标准，没有展开有限资源下的政策排序。' }
    [ordered]@{ evidenceId='E06'; ordinal=3600; section='民族概念、共同体与边界'; claim='作者主张中国使权谋服从大义，不称霸而以仁义和温柔承担天下责任。'; quote='中国永远不称霸，但中国必终为王。'; evidenceNature='中国共同体的文明使命'; boundary='“必终为王”是本文的文明使命判断和历史预期，不应改写成已经实现的事实。' }

    [ordered]@{ evidenceId='E07'; ordinal=3689; section='血缘、谱系与历史形成'; claim='作者反对用普通民族单位概括华夏和犹太，认为二者是长期面向整个世界形成的文明实体，其特性来自历史角色而非先天勤劳智慧。'; quote='这是两个文明级别的实体，你无法用“民族”来概括它们。'; evidenceNature='民族单位与文明实体'; boundary='文章使用高度整体化的文明角色对比，没有展开内部地区、阶层和反例。' }
    [ordered]@{ evidenceId='E08'; ordinal=1185; section='血缘、谱系与历史形成'; claim='作者把尚武解释为社会围绕力量、纪律、国防和军事动员进行自我改造，而不是个人肌肉崇拜。'; quote='尚武是指重视力量胜于一切，围绕实力追求来毫不留情的建设和改造自身'; evidenceNature='民族性格与长期动员结构'; boundary='对汉族制度、礼仪和历史的解释是本文的文明总括，不是逐时代的制度史。' }
    [ordered]@{ evidenceId='E09'; ordinal=1925; section='血缘、谱系与历史形成'; claim='作者把墓葬解释为由卫生和安全技术发展成的仪式、遗产及伦理锚，先祖墓地使群落与土地长期相连。'; quote='真正安土重迁的，并不是活人，而是已经入土为安的先祖们。'; evidenceNature='祖先、墓地与共同体记忆'; boundary='文章讲的是墓葬形成共同体记忆的文本内机制，不等于所有传统规则都由墓葬产生。' }
    [ordered]@{ evidenceId='E10'; ordinal=1890; section='血缘、谱系与历史形成'; claim='作者认为家族认祖常服务于精神财富、战略定位和政治利益，未必首先服从DNA或史学证据。'; quote='历史叙事首先是政治机制的结果，而不是史学规范的结果。'; evidenceNature='谱系叙事的政治功能'; boundary='文章讨论身份叙事如何运作及公开驳斥的冲突成本，不是否认一切谱系研究。' }
    [ordered]@{ evidenceId='E11'; ordinal=3577; section='血缘、谱系与历史形成'; claim='作者以生育、归化和部落延续解释早期群体边界，并把贞操观解释为降低掠夺收益的战略承诺。'; quote='育龄妇女成了一种事关部落未来生死的战略资源，于是同时是一种会招来攻击的重大诱因。'; evidenceNature='部落延续、生育与归化'; boundary='作者随后转向追问现代政策授权，没有把史前机制直接确立为现代规范。' }
    [ordered]@{ evidenceId='E12'; ordinal=1102; section='血缘、谱系与历史形成'; claim='作者把提问者对白人气质和成就的羡慕归因于双方所处历史位置不同，而非白人种族的天然优越。'; quote='真正导致你羡慕的，并不是“种族”要素，而是历史的盛衰涨落。'; evidenceNature='种族印象与历史盛衰'; boundary='文章使用反事实历史比较反驳种族归因，没有建立完整的群体差异理论。' }

    [ordered]@{ evidenceId='E13'; ordinal=3559; section='种族差异与歧视'; claim='作者把平等定义为给每个人凭自身作为建立关系的公平机会，把先以群体标签替代个人表现界定为歧视。'; quote='平等的本质，是一次公平的机会。'; evidenceNature='歧视定义与关系机会'; boundary='作者承认个人选择关系的自由，并主要论述这种选择的社会代价，未形成公共规制方案。' }
    [ordered]@{ evidenceId='E14'; ordinal=3777; section='种族差异与歧视'; claim='作者认为美国抗议中的真正分界是种族主义者与反种族主义者，而不是黑人和白人。'; quote='这并不是黑人和白人的种族间的矛盾，而是种族主义者（无论其有色无色）和反种族主义者（无论其有色无色）之间的矛盾。'; evidenceNature='跨肤色政治分界'; boundary='文章借跨肤色抗议判断美国道德力量尚存，没有展开警察制度改革。' }
    [ordered]@{ evidenceId='E15'; ordinal=1279; section='种族差异与歧视'; claim='作者区分部落主义、种族主义和国家主义，认为前两者分别按共居协作或基因血缘划亲疏，并把群体亲疏置于是非之上。'; quote='部落主义的宗旨是“就算ta是个混蛋，那也是我们的混蛋”'; evidenceNature='部落、种族与国家主义区分'; boundary='这是作者的规定性概念区分，不应替换成外部学科定义。' }
    [ordered]@{ evidenceId='E16'; ordinal=3121; section='种族差异与歧视'; claim='作者认为跨市场产品差异可以来自成本和经营选择；个人可以抵制，但不能仅凭诉求未被满足就完成道德定罪。'; quote='提诉求那就提诉求，这没什么，但不要以“不满足这种诉求就是对方有道德问题”的方式来提。'; evidenceNature='差别待遇与商业歧视边界'; boundary='本文处理具体商业规格争议，不概括所有民族差别待遇。' }
    [ordered]@{ evidenceId='E17'; ordinal=2248; section='种族差异与歧视'; claim='作者认为未经独立核查便给黑人群体施加集体原罪，是定罪门槛过低的行为。'; quote='这种讨厌不用说是很不健康的，因为ta给人定罪的门槛太低了。'; evidenceNature='风闻、群体概括与定罪门槛'; boundary='文章批评的是听说、风闻和群体概括，没有讨论每一种安全判断。' }
    [ordered]@{ evidenceId='E18'; ordinal=2478; section='种族差异与歧视'; claim='作者认为美国思想与战略体系对中国人的集体敌意，使其自由平等话语在中国观众眼中失去可信度。'; quote='美国自己用对中国人的集体种族歧视证明了自己的意识形态的根本性虚伪。'; evidenceNature='反华敌意与意识形态可信度'; boundary='这是作者对美国对华文化关系的政治判断，不是对每个美国人或文化产品的逐一个体判断。' }

    [ordered]@{ evidenceId='E19'; ordinal=3222; section='国籍、公民与国家归属'; claim='作者把中国描述为向奉行其礼仪、理想和道路者开放的“天下”，认为外国国籍不能单独取消一个人爱中国的可能。'; quote='任何向往和奉行中国的礼仪、理想和道路的人，都是中国人。'; evidenceNature='国籍形式与共同体归属'; boundary='文章没有处理多重国籍下具体法律义务冲突。' }
    [ordered]@{ evidenceId='E20'; ordinal=2973; section='国籍、公民与国家归属'; claim='作者认为爱不是奴隶式逢迎，真正的爱能够批评并通过批评加深关系。'; quote='真正的爱是可以批评的，而且越批评感情越深。'; evidenceNature='爱国、批评与服从'; boundary='作者讨论的是爱的行动规则，没有给出国家批评的制度程序。' }
    [ordered]@{ evidenceId='E21'; ordinal=2972; section='国籍、公民与国家归属'; claim='作者区分爱国情感与公民义务，认为爱国与否不改变人必须履行的份内义务，也不给国家索取额外义务的理由。'; quote='爱与不爱，你要承担的义务是相同的。'; evidenceNature='爱国情感与义务边界'; boundary='文章只处理义务与情感的逻辑关系，没有列出具体法定义务。' }
    [ordered]@{ evidenceId='E22'; ordinal=2159; section='国籍、公民与国家归属'; claim='作者认为真正爱国者中应有人能识别、保护并为同类担保；若无人愿意担保，当事人应反省表达和立场。'; quote='爱是认识爱的，爱会保护爱'; evidenceNature='爱国身份的共同体识别'; boundary='文本把共同体承认置于很高位置，没有提供误判纠正的独立程序。' }
    [ordered]@{ evidenceId='E23'; ordinal=2162; section='国籍、公民与国家归属'; claim='作者区分法律定性、政治忠诚和个人归属后果，认为是否叛国应问法官，以不忠惩罚国家更可能先毁掉自己的社会位置。'; quote='不要自认为你可以用不爱国、不忠于自己的祖国来“惩罚”你的国家。'; evidenceNature='叛国定性与个人归属后果'; boundary='文章没有自行判定入籍必然叛国，也没有解释各法域的叛国构成。' }
    [ordered]@{ evidenceId='E24'; ordinal=2907; section='国籍、公民与国家归属'; claim='作者认为每个人所爱的国家对象都带有自我构建成分，但这不能成为逃避学习爱的理由。'; quote='对爱国主义的种种挑剔、质疑，说到底，是想找到足够的理由回避一种爱的责任和义务。'; evidenceNature='爱国作为可学习的责任'; boundary='文章讨论爱的责任及可持续方法，不解决所有国家行为是否值得支持的问题。' }

    [ordered]@{ evidenceId='E25'; ordinal=3768; section='移民、华人与离散处境'; claim='作者认为当祖籍国强大且被所在国视为敌手时，华人公开团结可能降低其忠诚可信度和现实生存空间。'; quote='与其说是华人本性不团结，不如说在大部分国家，华人是不能团结的。'; evidenceNature='海外华人的团结条件'; boundary='该判断以华裔尚不足以改变所在国政治版图为条件，不是所有国家、时代的普遍结论。' }
    [ordered]@{ evidenceId='E26'; ordinal=3187; section='移民、华人与离散处境'; claim='作者认为真正的全球化经营依赖长期侨居、理解当地制度和建立当地关系，而不是短期出差旅游。'; quote='全球化的大头是一个侨居海外的中国人，或者侨居中国的外国人，因为看到某个跨国资源整合的商机而做的创业工作。'; evidenceNature='侨居经验与跨国经营能力'; boundary='文章讨论跨国创业和经营能力，不是对一切移民生活的总论。' }
    [ordered]@{ evidenceId='E27'; ordinal=501; section='移民、华人与离散处境'; claim='作者认为中国历史更倾向于恢复邻国秩序或安置内附部族，而不是大规模把难民吸收进中心社会。'; quote='我们的思路一向不是“接收难民”，而是“传播王化”，就是派出部队和官员，解决掉当地的问题——一般是帮助正统王室平息叛乱或者册封已经获得正统地位且称臣的当地辛苦势力——恢复当地的秩序，让这些人民可以在自己的原地安居乐业。'; evidenceNature='难民安置与秩序恢复模式'; boundary='这是作者的宏观历史解释，并把西方接收能力与殖民、资本盈余相连，未逐国逐时期展开。' }
    [ordered]@{ evidenceId='E28'; ordinal=3128; section='移民、华人与离散处境'; claim='作者认为1990至2015年前后的“人才流失”更多是国内岗位和产业承载不足造成的过量溢出，而不是短缺状态下被动失血。'; quote='过去二十年，中国的“严重人才流失”本来就是半个伪问题——本来就是过量溢出，根本不存在“短缺还流出”这么回事。'; evidenceNature='人才迁移与产业承载'; boundary='命题受作者设定的工业化阶段和时间范围限制，不应外推为所有人才外流。' }
    [ordered]@{ evidenceId='E29'; ordinal=764; section='移民、华人与离散处境'; claim='作者认为中国人尤其精英带着代表家族和共同体面子的身份意识，倾向于要求对等礼貌，因而可能在海外被读成不够温柔。'; quote='一来中国人——尤其是中国精英——在心理上俯视一切异族。'; evidenceNature='异地交往中的共同体身份心理'; boundary='这是文章对中日礼仪动力的群体概括，不是每个中国人的行为定律。' }
    [ordered]@{ evidenceId='E30'; ordinal=2011; section='移民、华人与离散处境'; claim='作者认为大量缺乏身份、教育和上升渠道的移民处于美国分散底层，警察暴力被制度容留并参与维持这种无组织状态。'; quote='美国的警察暴力其实是一种被有意识容留的制度特性。'; evidenceNature='移民底层、阶层与警务'; boundary='这是作者对美国移民、阶层和警务关系的结构解释，没有逐项建立制度因果链。' }

    [ordered]@{ evidenceId='E31'; ordinal=3818; section='语言、文化与同化'; claim='作者认为中国的抗同化不是拒绝外来成分，而是以巨大规模充分吸收后仍保持总体连续性。'; quote='每一次，我们几乎都是全部拥抱，完全吸纳对方。'; evidenceNature='文明吸收与反同化'; boundary='文章把这种能力归因于文明体量和历史记忆，未展开吸收过程中不同群体的差异。' }
    [ordered]@{ evidenceId='E32'; ordinal=2310; section='语言、文化与同化'; claim='作者把俄罗斯人的根本自我认同解释为东方正教和拜占庭罗马的继承者，而不是斯拉夫或苏维埃标签。'; quote='俄罗斯人最根本的自我认同，是“基督正教会的东方正统继承人”'; evidenceNature='宗教历史与文化认同'; boundary='这是作者对俄罗斯文化和艺术的整体解释，不是俄罗斯内部身份分布调查。' }
    [ordered]@{ evidenceId='E33'; ordinal=1775; section='语言、文化与同化'; claim='作者认为《繁花》的沪语不是装饰性方言，而是人物依据场合和剧情切换语言的叙事机制。'; quote='这不是“用上海方言”，而是“让剧中人用与场合、剧情相对应的语言”。'; evidenceNature='语言、场合与身份关系'; boundary='文章针对一部作品的语言真实性，不直接推导普遍语言政策。' }
    [ordered]@{ evidenceId='E34'; ordinal=3626; section='语言、文化与同化'; claim='作者认为不同语言对概念的切分不可完全互译，学习异源语言能暴露母语造成的思想默认轨道。'; quote='语言是思想的载体，在最深处甚至是无法翻译的'; evidenceNature='母语边界与多语训练'; boundary='文章强调严肃思考者的多语训练，没有说明所有概念都不可翻译。' }
    [ordered]@{ evidenceId='E35'; ordinal=3997; section='语言、文化与同化'; claim='作者认为即使同说汉语，个体对正义、爱和信等概念的意义也可能不同，语言是最难翻越的隔离墙。'; quote='语言才是人类最难以翻越的隔离墙。'; evidenceNature='语言差异与跨群体理解'; boundary='无偏差理解能够减少战争是本文的思想推演，不是对战争原因的唯一解释。' }
    [ordered]@{ evidenceId='E36'; ordinal=3817; section='语言、文化与同化'; claim='作者把文化定义为群体长期共同生活形成的底层决策共识，而不只是服饰、食物等外显符号。'; quote='文化本质上就是一群人对于决策机制的群体共识。'; evidenceNature='文化本体与群体决策'; boundary='文章规定的是文化在行动中的深层机制，没有否认外在符号可以承载文化信息。' }

    [ordered]@{ evidenceId='E37'; ordinal=3126; section='殖民、帝国与民族解放'; claim='作者把殖民地描述为道路和首府服务资源外运、教育语言服从宗主国，并缺少表决权和司法终审权。'; quote='殖民地在宗主国的统治机制里没有表决权。'; evidenceNature='殖民结构识别'; boundary='文章给出结构特征，没有把它们整理成必要充分的法律定义。' }
    [ordered]@{ evidenceId='E38'; ordinal=3693; section='殖民、帝国与民族解放'; claim='作者认为帝国把压倒性优势兑换成额外收益；依赖收益的组织成长后，维护霸权会同时推高成本和失败后果。'; quote='帝国的生命公式，就是“由霸权所带来的额外利益”要大于“维持霸权的成本”。'; evidenceNature='帝国收益与崩溃循环'; boundary='文章把强者以仁爱自我约束视为出路，没有展开国际制度方案。' }
    [ordered]@{ evidenceId='E39'; ordinal=1291; section='殖民、帝国与民族解放'; claim='作者认为非主权国家不能质疑宗主国意识形态，其政治研究只能在不触及根本依附的范围内运作。'; quote='非主权独立国家有一个先天的、不可克服的缺陷——它被剥夺了质疑、反对宗主国、殖民国意识形态的权利。'; evidenceNature='非主权国家的知识依附'; boundary='作者区分外部强加的殖民禁制与主权国家内部可调整的政治约束。' }
    [ordered]@{ evidenceId='E40'; ordinal=1672; section='殖民、帝国与民族解放'; claim='作者认为第三世界贫困地区需要长期、系统、组织化建设，不能靠迁移、消灭原住民或让富裕城市无限吸收人口。'; quote='这个办法是极其可贵的，因为这才是真正解决全球第三世界贫困问题的要害。'; evidenceNature='原住民整合与长期发展建设'; boundary='文章以大凉山为主要对象，把其经验向全球第三世界推广仍是作者提出的可能性。' }
    [ordered]@{ evidenceId='E41'; ordinal=3808; section='殖民、帝国与民族解放'; claim='作者主张中国把资源集中到友好或不强烈反华的第三世界国家，以实际援助形成长期现代化示范差距。'; quote='中国在非洲的目标，应该是在二十到四十年内让友好国家明显的拉开与敌对国家的现代化程度差距，而不是“广泛支持非洲”。'; evidenceNature='后殖民发展竞争与对非战略'; boundary='援助在本文被明确作为国家战略工具，而不是无条件、平均化救济。' }
    [ordered]@{ evidenceId='E42'; ordinal=3206; section='殖民、帝国与民族解放'; claim='作者认为永久并吞需要长期文化、组织和民意准备；没有内部民意基础的占领必然以撤退和失败结束。'; quote='没有充分民意根基的占领最终还是要结束的。而且结束时一定会是一种大失败。'; evidenceNature='殖民并吞、占领与惩戒战争'; boundary='作者没有因此主张所有越境战争都应并吞，而把无并吞决心的行动限定为迅速惩戒后撤退。' }

    [ordered]@{ evidenceId='E43'; ordinal=3797; section='民族主义、排外与跨群体秩序'; claim='作者把欧洲反犹解释为宗教法律观和竞争挫败的长期冲突，并主张中国以威慑和普惠公共产品同时应对对华敌意。'; quote='世界只关心你要采取什么措施来抬高对方的成本、降低对方的效率、阻止对方的意图。'; evidenceNature='群体敌意、文明解释与国家应对'; boundary='对犹太教、基督教和欧洲历史的因果叙述是本文模型，不能扩写成作者已完成的普遍宗教史。' }
    [ordered]@{ evidenceId='E44'; ordinal=3957; section='民族主义、排外与跨群体秩序'; claim='作者反对把霸权和周边恐惧视为民族崛起的必然，要求中国降低他者恐惧，把力量转成他者可以感知的利益和希望。'; quote='人因为我强而恐惧，这是耻辱。'; evidenceNature='和平发展与他者恐惧'; boundary='文章提出方向性要求，没有提供具体和平发展政策组合。' }
    [ordered]@{ evidenceId='E45'; ordinal=3233; section='民族主义、排外与跨群体秩序'; claim='作者反对把政府敌意扩展为对整个民族的无差别仇恨，要求普通爱国者区分政府、决策者和普通人民。'; quote='除了绝对无可避免的敌人，不为国家多制造任何一个敌人，除了实在不可争取的朋友，为民族争取每一个朋友，这是每一个真正爱国的普通人没有理由不去时刻遵循的行事原则。'; evidenceNature='爱国、敌我范围与争取朋友'; boundary='文章没有否认可避免的敌人，而要求普通人在缺少情报训练时不自行扩大敌我范围。' }
    [ordered]@{ evidenceId='E46'; ordinal=3868; section='民族主义、排外与跨群体秩序'; claim='作者区分外国人永久居留、入籍和无条件开放边境，认为开放型经济需要与其规模相称的居留制度。'; quote='这是“永久居留”，不是“入籍”。'; evidenceNature='居留、入籍与排外焦虑'; boundary='作者支持的是应有此类制度，没有给出申请门槛、配额和具体权利细则。' }
    [ordered]@{ evidenceId='E47'; ordinal=3703; section='民族主义、排外与跨群体秩序'; claim='作者区分移民、反歧视和全球化政策的方向与速度，认为多数所谓右转只是降低左向政策继续加码的速度。'; quote='实际上的主张并非是要把左满舵改成右满舵，而是要把左满舵往回扳一扳'; evidenceNature='全球政策方向与速度'; boundary='文章提供尺度辨析，没有逐国验证，也没有要求读者固定支持某一政策速度。' }
    [ordered]@{ evidenceId='E48'; ordinal=3770; section='民族主义、排外与跨群体秩序'; claim='作者认为全球互相依存使各种意识形态都必须学习与敌人共存，个人也必须从忍受异己走向经营关系。'; quote='对每一种意识形态而言，“与敌人们共存”都已经不再是选修课，而已经成了必修课，而且是一票否决式的绝对必修课。'; evidenceNature='异己共存与跨群体关系'; boundary='这是作者提出的时代伦理方向，具体共存框架在本文中仍未完成。' }
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
    if ($ordinal -lt 1 -or $ordinal -gt $corpus.Count) { throw "[$($item.evidenceId)] Ordinal outside corpus: $ordinal" }
    $article = $corpus[$ordinal - 1]
    if (-not $screenedIds.ContainsKey([string]$article.id)) { throw "[$($item.evidenceId)] Article not present in screening layer." }
    $quoteOk = ([string]$article.text).Contains([string]$item.quote, [StringComparison]::Ordinal)
    $date = [DateTimeOffset]::FromUnixTimeMilliseconds([int64]$article.publishedAt).ToOffset([TimeSpan]::FromHours(8)).ToString('yyyy-MM-dd')
    $rows.Add([pscustomobject][ordered]@{
        evidenceId = [string]$item.evidenceId
        section = [string]$item.section
        claim = [string]$item.claim
        evidenceNature = [string]$item.evidenceNature
        boundary = [string]$item.boundary
        ordinal = $ordinal
        id = [string]$article.id
        date = $date
        title = [string]$article.title
        url = [string]$article.url
        quote = [string]$item.quote
        quoteExact = $quoteOk
        sourceLayer = 'screened'
    })
}

$rows | Export-Csv -LiteralPath ([IO.Path]::GetFullPath($OutputPath)) -NoTypeInformation -Encoding utf8BOM
$requiredSections = @('民族概念、共同体与边界','血缘、谱系与历史形成','种族差异与歧视','国籍、公民与国家归属','移民、华人与离散处境','语言、文化与同化','殖民、帝国与民族解放','民族主义、排外与跨群体秩序')
$sectionCounts = [ordered]@{}
foreach ($section in $requiredSections) { $sectionCounts[$section] = @($rows | Where-Object section -eq $section).Count }
$missing = @($rows | Where-Object {
    [string]::IsNullOrWhiteSpace($_.claim) -or [string]::IsNullOrWhiteSpace($_.evidenceNature) -or
    [string]::IsNullOrWhiteSpace($_.boundary) -or [string]::IsNullOrWhiteSpace($_.quote)
}).Count
$stats = [ordered]@{
    corpusArticles = $corpus.Count
    screenedCandidates = $screenedIds.Count
    evidenceRows = $rows.Count
    uniqueEvidenceIds = @($rows.evidenceId | Sort-Object -Unique).Count
    uniqueArticleIds = @($rows.id | Sort-Object -Unique).Count
    uniqueOrdinals = @($rows.ordinal | Sort-Object -Unique).Count
    missingCoreFields = $missing
    exactQuoteFailures = @($rows | Where-Object { -not $_.quoteExact }).Count
    sectionCounts = $sectionCounts
    status = if (
        $rows.Count -eq 48 -and @($rows.evidenceId | Sort-Object -Unique).Count -eq 48 -and
        @($rows.id | Sort-Object -Unique).Count -eq 48 -and @($rows.ordinal | Sort-Object -Unique).Count -eq 48 -and
        $missing -eq 0 -and @($rows | Where-Object { -not $_.quoteExact }).Count -eq 0 -and
        @($requiredSections | Where-Object { $sectionCounts[$_] -ne 6 }).Count -eq 0
    ) { 'PASS' } else { 'REVIEW' }
}
$stats | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath ([IO.Path]::GetFullPath($StatsPath)) -Encoding utf8
$stats | ConvertTo-Json -Depth 5
if ($stats.status -ne 'PASS') { throw "Ethnicity/identity core evidence validation ended with status $($stats.status)." }
