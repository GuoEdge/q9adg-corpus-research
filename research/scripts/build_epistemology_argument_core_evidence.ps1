param(
    [string]$CorpusPath = '.\sooon-q9adg-articles.jsonl',
    [string]$ScreeningPath = '.\research\data\education_knowledge_screening.csv',
    [string]$OutputPath = '.\research\data\epistemology_argument_core_evidence.csv',
    [string]$StatsPath = '.\research\data\epistemology_argument_core_evidence.stats.json'
)

$ErrorActionPreference = 'Stop'

# Ordinal 3752 is inside the 851-item screening layer but was routed only to
# education. Direct review confirms that its common-world and fallibility claims
# are also core epistemology evidence.
$approvedCrossRouteSupplements = @{
    3752 = 'Screened education-route article recovered by direct epistemology review.'
}

$items = @(
    [ordered]@{ evidenceId='K01'; ordinal=3752; section='共同世界、真理与知识边界'; claim='作者把不服从愿望的客观世界视为不同立场交流和订约的共同底盘，同时把人的知识限定为可继续改进的高质量错误。'; quote='人类能达到的极限，不过是“有质量的错误”。'; evidenceNature='共同事实与知识可错命题'; boundary='科学经典在文中是必须兼容的世界描述之一，不是终极真理或完整价值体系。' }
    [ordered]@{ evidenceId='K02'; ordinal=3785; section='共同世界、真理与知识边界'; claim='作者把终极真理定义为能够无限正确回溯和预测且永不修改的全知模型，并认为人只能依据有限知识下注。'; quote='是赌注而已。'; evidenceNature='终极真理定义与认识限度推演'; boundary='文章没有取消不同知识判断的质量差异，只否定人把高胜率赌注直接加冕为终极真理。' }
    [ordered]@{ evidenceId='K03'; ordinal=3988; section='共同世界、真理与知识边界'; claim='作者认为科学实践也依赖规律时空均一、同一条件产生同一结果等无法被穷尽证明的前提，因而不能被写成无信仰的全知体系。'; quote='全无分毫证据，只是信了而已。'; evidenceNature='科学前提与信仰边界分析'; boundary='文章讨论科学主义的认识根基，不是否定实验、数据和规律研究的有效性。' }
    [ordered]@{ evidenceId='K04'; ordinal=3999; section='共同世界、真理与知识边界'; claim='作者认为科学在数据可靠、价值目标清楚时可以给出答案，但面对复杂人生和组织选择往往只能诚实回答不知道；决策者仍必须下注。'; quote='因为“不选”本身不可选。'; evidenceNature='科学能力边界与决策责任'; boundary='信仰在文中承担不确定条件下承受选择后果的功能，不表示所有选择无需事实与数据。' }
    [ordered]@{ evidenceId='K05'; ordinal=3726; section='共同世界、真理与知识边界'; claim='作者把傲慢定义为可证伪问题上证据强度与确信强度失配，要求主体知道自己的高把握结论仍是有限证据上的胜率判断。'; quote='傲慢就是对有可证伪性的问题只有三分证据，却有十分把握。'; evidenceNature='证据—确信刻度定义'; boundary='文章同时反对仅凭他人情绪降低判断，观点修正仍需要新证据、新论证或明确错误。' }
    [ordered]@{ evidenceId='K06'; ordinal=3258; section='共同世界、真理与知识边界'; claim='作者认为知识应用无法消除错误，成熟目标是在授权和必要行动范围内选择后果更可控、更多由自己承担的错误。'; quote='去犯正确的错误。'; evidenceNature='应用知识与可错行动原则'; boundary='“正确的错误”是作者对错误类型和后果的排序，不是把错误本身改写成正确。' }

    [ordered]@{ evidenceId='K07'; ordinal=3633; section='定义、题面与概念边界'; claim='作者把偷换概念限定为论者违反自己明确提出或共同接受的定义，反对把未接受他人定义直接判成逻辑错误。'; quote='进步本身即是概念的更新。'; evidenceNature='定义权与内部一致命题'; boundary='重新定义需要承担解释和前后一致义务，不能靠更换词义逃避自己已经承诺的标准。' }
    [ordered]@{ evidenceId='K08'; ordinal=3325; section='定义、题面与概念边界'; claim='作者要求读者先按论述者自己的定义检查结论和论证，再检查该主张是否与论述者的其他承诺相协调。'; quote='定义权是论述者当然的特权，'; evidenceNature='论证阅读与内部批评程序'; boundary='文中也指出逻辑有效不自动等于论述值得接受，定义一致只是第一道检查。' }
    [ordered]@{ evidenceId='K09'; ordinal=2841; section='定义、题面与概念边界'; claim='作者把子女提出的内容先保留为未定性的诉求，再区分乞求、祈求、请求、需求和权利要求，以阻止名称提前分配拒绝权。'; quote='子女对父母提出的东西，在被定性之前，只能看做诉求。'; evidenceNature='题面重构与类型区分'; boundary='该分类用于家庭诉求处理，不自动成为所有公共请求的统一分类法。' }
    [ordered]@{ evidenceId='K10'; ordinal=2935; section='定义、题面与概念边界'; claim='作者区分评价者的不满意与对象的不合理，只有能够证明存在可行、更优且成本收益成立的方案时，才取得“不合理”的论证资格。'; quote='你手头上其实就只有“不满意”，没有“不合理”。'; evidenceNature='评价词定义与举证责任'; boundary='文章没有取消不满表达，而是限制把主观不满升级为对他人方案的客观定性。' }
    [ordered]@{ evidenceId='K11'; ordinal=342; section='定义、题面与概念边界'; claim='作者区分不认同行为定性与否认行为事实：前者承认发生了什么却不认为其错，后者则连具体行为也争辩。'; quote='认识不到错误，会对行为本身直言不讳；不愿承认错误，则会对行为本身争执不休。'; evidenceNature='事实承认与规范定性区分'; boundary='文章还讨论恐惧和羞辱如何破坏认错，具体惩罚安排属于其关系修复模型。' }
    [ordered]@{ evidenceId='K12'; ordinal=4037; section='定义、题面与概念边界'; claim='作者先按定义把思考与直觉分开，再明确承认当前不知道无语言思考是否可能，也难以设计足以证实肯定结论的研究。'; quote='我们不知道能不能，但我们知道我们很难做出可以证实肯定结论的研究。'; evidenceNature='定义分析、未知声明与猜想标注'; boundary='文末随机念头模型被作者标明为猜想，不能改写成已经证实的大脑机制。' }

    [ordered]@{ evidenceId='K13'; ordinal=1249; section='观察、证据与验证'; claim='作者要求政策观察越过标题和篇首语，逐项阅读具体措施和落实机制，反对仅凭“出台政策”反推领域已经失败。'; quote='重点在于这逐条列出的具体政策、办法，而不是那个标题、那个篇首语。'; evidenceNature='政策文本观察方法'; boundary='该文只提供短篇阅读原则，没有完成所涉政策效果的经验评估。' }
    [ordered]@{ evidenceId='K14'; ordinal=323; section='观察、证据与验证'; claim='作者认为父母凭发言、裁判和举证优势使用儿童无法验证的故事，会使儿童放弃表达；论证应尽量使用其经历过或可现场核验的事实。'; quote='孩子们很早就会发现父母有语言霸权。'; evidenceNature='可验证证据与话语权判断'; boundary='文章允许超出儿童经验的内容暂缓说明，不要求所有知识只能来自个人亲历。' }
    [ordered]@{ evidenceId='K15'; ordinal=2002; section='观察、证据与验证'; claim='作者把判断一种手段是否值得写成样本观察、解释假说和预测性实验的连续过程，使社会规则回到可观察后果。'; quote='你（指子女）作为研究者，你应该建立一个统计样本库，'; evidenceNature='观察—假说—预测验证程序'; boundary='文章以亲子顶嘴为案例，其样本库和实验要求是作者方法示范，不是完成的行为科学研究。' }
    [ordered]@{ evidenceId='K16'; ordinal=2915; section='观察、证据与验证'; claim='作者同时保护挑战政治正确的学术权利和挑战者的严肃责任，要求提出者先对自己的怀疑作最强反向质问与证据审查。'; quote='你要先给自己的怀疑最大的反向质问'; evidenceNature='反向审查与知识共同体提交程序'; boundary='文章要求先向有资格的知识共同体提交，不表示所有公共议题都必须由同一机构裁定。' }
    [ordered]@{ evidenceId='K17'; ordinal=1155; section='观察、证据与验证'; claim='作者区分个人感受与历史趋势证据，要求用跨时期、跨文明材料、数据和高质量异议校正互联网回音壁产生的趋势错觉。'; quote='你的个人感受，只能作为你研究的动力，不应该产生信度贡献。'; evidenceNature='趋势判断与证据权重原则'; boundary='文章关于性别矛盾实际烈度的判断仍是作者自身历史解释，不因方法主张自动获得外部验证。' }
    [ordered]@{ evidenceId='K18'; ordinal=2959; section='观察、证据与验证'; claim='作者把诚实写成事实保险：说话者不保证全知正确，而要明确担保事项、验证方式和出错后的责任。'; quote='“诚实”在实践意义上是一种“事实保险业务”。'; evidenceNature='事实担保与责任模型'; boundary='这一定义处理信息信用，不表示所有误陈述都可仅靠赔偿完成修复。' }

    [ordered]@{ evidenceId='K19'; ordinal=930; section='逻辑、模型与推理'; claim='作者认为逻辑能力主要来自事实知识、专业实践和现实例外，而不只来自形式符号和语言口才。'; quote='逻辑的功夫在诗外。'; evidenceNature='逻辑能力与经验关系判断'; boundary='文章没有否定形式逻辑，而是反对把范式训练当作事实理解的替代品。' }
    [ordered]@{ evidenceId='K20'; ordinal=3116; section='逻辑、模型与推理'; claim='作者区分理论的解释目标与行动处方，认为进化心理学以繁殖成功为目标，不能未经转换直接推出当代个体应如何生活。'; quote='你该在意的问题，根本不在于你觉得进化心理学对在哪，而应该在于你觉得它错在哪。'; evidenceNature='描述—处方转换限制'; boundary='文中对进化心理学速度和目标的判断只记录为作者的理论评价。' }
    [ordered]@{ evidenceId='K21'; ordinal=3921; section='逻辑、模型与推理'; claim='作者把复杂工程理解为误差的继承、交联、抵消和磨合，认为成品图纸不能穷尽工艺、团队和场景知识。'; quote='工程师就是误差的巫师。'; evidenceNature='复杂系统与隐性知识模型'; boundary='航空发动机和工程组织的具体判断属于作者工业解释，不作外部技术史裁决。' }
    [ordered]@{ evidenceId='K22'; ordinal=3827; section='逻辑、模型与推理'; claim='作者把计划可靠性写成关键路径步骤可靠性的乘积，要求先用原理、界定、测试和质检建立SOP，再组合成计划。'; quote='计划的可靠性，完全是由计划关键路径上的步骤的可靠性的乘积决定。'; evidenceNature='可靠性模型与程序推理'; boundary='具体概率和六西格玛类比是作者示范，不能无条件外推到所有人生计划。' }
    [ordered]@{ evidenceId='K23'; ordinal=1219; section='逻辑、模型与推理'; claim='作者以能否生存、及格和避免违约区分主要矛盾与影响舒适、优秀的次要矛盾，并把第一性原理与历史经验并列为识别工具。'; quote='主要矛盾是影响你能不能及格、能不能生存、会不会违约的矛盾，'; evidenceNature='问题优先级与模型边界'; boundary='文中承认经营和人生的大量因素无法精确建模，必须由经验与历史承担剩余判断。' }
    [ordered]@{ evidenceId='K24'; ordinal=2882; section='逻辑、模型与推理'; claim='作者把认知战写成低成本、低门槛攻击与高成本辟谣之间的不对称系统，认为防守方不能假定更多理性论证必然取胜。'; quote='希望只可能在非认知战手段上。'; evidenceNature='不对称传播模型与失败条件'; boundary='文中关于认知战胜负的宏观结论是作者模型，不能当作已完成的传播统计。' }

    [ordered]@{ evidenceId='K25'; ordinal=2282; section='语言、达意与相互理解'; claim='作者提出表达者完全自负达意责任：只要事后证明对方未理解，就先把失败纳入自己可以训练和改进的范围。'; quote='每个人都要为自己的表达承担达意责任，这是一种基本服务。'; evidenceNature='表达责任与渐进训练原则'; boundary='文章不否认听者可以主动承担理解责任，但不允许表达者把它设为默认前提。' }
    [ordered]@{ evidenceId='K26'; ordinal=3460; section='语言、达意与相互理解'; claim='作者把语文首要功能设为准确、完整、简洁且抗歧义地说明问题、理由和方案，以降低共同决策与合作冲突。'; quote='语文不是用来作诗的，不是用来写散文的，而是首先用来说事的，'; evidenceNature='语言功能与表达刚度判断'; boundary='文章把语言能力与社会位置强连接，这是作者判断；诗歌和文学并未被说成没有价值。' }
    [ordered]@{ evidenceId='K27'; ordinal=3290; section='语言、达意与相互理解'; claim='作者把相互理解写成共同文本、双方自我满意、相互确认和愿意承担误解责任的信任过程，而非可由外部仪器绝对认证的同一状态。'; quote='理解的要害，不在于正确，而在于宽容。'; evidenceNature='理解条件与误差承担模型'; boundary='宽容在文中处理理解误差，不等于取消事实核对或接受一切解释。' }
    [ordered]@{ evidenceId='K28'; ordinal=236; section='语言、达意与相互理解'; claim='作者要求儿童练习按人物、时间、进入方式和行动复述全过程，把清晰、完整、准确又简洁的白描作为归因和求助基础。'; quote='甚至描述为“一切能力之母”也不为过。'; evidenceNature='叙事复述与信息完整性训练'; boundary='“一切能力之母”是作者对故事复述的强判断，不被外推为唯一认知能力。' }
    [ordered]@{ evidenceId='K29'; ordinal=787; section='语言、达意与相互理解'; claim='作者认为精准用词依赖词源、源流和近义词内部差异，也依赖经典文本的长期输入，使语言同时传达事实、感情、立场和态度。'; quote='用词精准，其实总是从辞源开始，'; evidenceNature='词义辨析与语言材料积累'; boundary='词源在文中是形成语感的方法之一，不自动决定现代语境中的全部正确用法。' }
    [ordered]@{ evidenceId='K30'; ordinal=3373; section='语言、达意与相互理解'; claim='作者把求知与公开说明责任连接：知道仇恨建立在谎言和误解上时，知识者可以讲究方式，却不能把技巧变成完全沉默。'; quote='要么你不要追求真知，要么你不要闭口不言。'; evidenceNature='知识传播责任与发言原则'; boundary='文章不要求知识者阻止一切冲突，只要求避免明知的谎言和可阻止的误解继续作用。' }

    [ordered]@{ evidenceId='K31'; ordinal=3680; section='质疑、批评与修复'; claim='作者把批评限定为经过授权、从对方目标、事实和逻辑出发的服务，明确排除讽刺、定罪、构陷和强迫服从。'; quote='批评只能给逻辑、给疑问、给论证，不可以讽刺，不可以定罪，更不可以用作构陷的工具。'; evidenceNature='批评授权与行动红线'; boundary='文章区分私人批评和公共批评，授权方式不能在不同场景中直接互换。' }
    [ordered]@{ evidenceId='K32'; ordinal=964; section='质疑、批评与修复'; claim='作者要求批评在指出错误后提供能力范围内的新方法和目标，使屈辱、沮丧转向控制感、兴趣与继续行动。'; quote='批评不是以“制造恰当的屈辱和沮丧”为目的的行为'; evidenceNature='批评完成标准与替代方案'; boundary='作者允许短期或长期回弹两种路径，但不允许以制造低潮本身冒充批评。' }
    [ordered]@{ evidenceId='K33'; ordinal=1175; section='质疑、批评与修复'; claim='作者认为未经邀请指出错误体现位格不对等，缺少判断权者应以诚实疑惑、求解和谦卑传递客观问题，而不是自封裁判。'; quote='你只是凭着谦卑，担任问题的使者而已。'; evidenceNature='指出错误权与问题使者模型'; boundary='文章承认能力、帮助和供养关系会改变影响力，但没有赋予任何一方无限定罪权。' }
    [ordered]@{ evidenceId='K34'; ordinal=2717; section='质疑、批评与修复'; claim='作者把质疑理解为已确信发现破绽后要求对方或旁观者接受的上位教育行为，因此反对未经授权自行取得质疑权。'; quote='自授质疑权即为侵犯。'; evidenceNature='质疑与求证的言语行为区分'; boundary='文章允许以求证、求解惑和不确定姿态提出问题，限制的是预设有罪式盘问。' }
    [ordered]@{ evidenceId='K35'; ordinal=3516; section='质疑、批评与修复'; claim='作者把道歉拆成精确定义事项、说明违反的价值与逻辑、提出降低复发概率的计划，并用可承受成本封住免罚漏洞。'; quote='你需要的是真诚。'; evidenceNature='道歉定义、修正和成本程序'; boundary='文章拒绝保证永不再犯，也不把取得原谅设为道歉者可以单方面控制的结果。' }
    [ordered]@{ evidenceId='K36'; ordinal=2265; section='质疑、批评与修复'; claim='作者把修和之礼写成赔偿、防止重演措施和正式声明，其中制度性防复发是对方能够原谅的核心前提。'; quote='这个“防止再次发生的措施”，才是这个道歉的核心本质部分，'; evidenceNature='公共道歉与制度修复结构'; boundary='文章关于战争历史和国家责任的事实判断只记录为作者主张，不作外部史料裁决。' }

    [ordered]@{ evidenceId='K37'; ordinal=3369; section='记录、研究与知识生产'; claim='作者要求复盘稳定问题样本、重建时间线并把结论写入章程、流程、培训、职责和计划，使经验成为组织可继承知识。'; quote='所谓的解决方案，指且仅指组织规则的更新。'; evidenceNature='组织研究与规则更新程序'; boundary='复盘对象是问题及制度条件，不等同于追责会议或个人反省。' }
    [ordered]@{ evidenceId='K38'; ordinal=4; section='记录、研究与知识生产'; claim='作者把持续修史解释为经验主义知识基础：记录形成数据，数据积累经验与智慧，使后来者能够应对变化。'; quote='数据出经验，经验出智慧，智慧保繁荣。'; evidenceNature='历史记录与经验传承命题'; boundary='中国修史传统和繁荣因果是作者历史解释，记录仍需后来者在新情境中重新理解。' }
    [ordered]@{ evidenceId='K39'; ordinal=2563; section='记录、研究与知识生产'; claim='作者拒绝以体制内外划分科学，要求所有研究者直接面对数据、表达式、逻辑、图表、论证和实验，并承担同一学术标准。'; quote='世界上只有一种科学研究者，就是讲科学的科学研究者。'; evidenceNature='研究资格与方法标准'; boundary='文章不否认体制化研究的历史必要性，反对的是把制度身份当作科学性本身。' }
    [ordered]@{ evidenceId='K40'; ordinal=2005; section='记录、研究与知识生产'; claim='作者把知识文化建设放到三代周期：第一代亲自求教研究，第二代继承实践，第三代把学习内化为无需反复说服的家风。'; quote='不要计划“一代翻身”。'; evidenceNature='代际知识生产与传承模型'; boundary='三代周期是作者的长期家庭方案，不是所有学习结果必经的固定世代数。' }
    [ordered]@{ evidenceId='K41'; ordinal=4025; section='记录、研究与知识生产'; claim='作者认为芯片知识不只存在于设计文件，而分布在制造、材料、工序、良率、专家协作和企业制度中，设计与制造相互生成。'; quote='设计源于制造，制造本身就是设计的一部分。'; evidenceNature='产业知识、隐性工艺与组织生产'; boundary='芯片历史、产业能力和未来路线属于作者技术判断，不作外部产业评估。' }
    [ordered]@{ evidenceId='K42'; ordinal=2170; section='记录、研究与知识生产'; claim='作者认为个人无法掌握全部专业知识并不构成人类知识上限，因为导论、进阶、专精和人口分工能够分布、保存与继续扩展知识。'; quote='知识的上限不会是人类的智力能力。'; evidenceNature='分布式知识与传承能力判断'; boundary='文章把更大威胁放在制度、污染、财富集中和灾难，这是作者的文明风险推演。' }

    [ordered]@{ evidenceId='K43'; ordinal=3979; section='不确定性、预测与决策'; claim='作者区分事实与超出事实的乐观或悲观，认为证据不足不能授权主体把看不见希望判成客观无望。'; quote='人没有资格凭着自己的智慧就绝望。'; evidenceNature='证据权限与希望判断'; boundary='文章要求希望与事实相容，不允许用乐观扭曲明确风险。' }
    [ordered]@{ evidenceId='K44'; ordinal=3415; section='不确定性、预测与决策'; claim='作者认为个人对可承受风险的临场判断无法阻止首次大错，因而用历史稳定时薪作为可检验预期锚，隔离意外超额收益。'; quote='永不期待超出自己时薪的收益。'; evidenceNature='风险预期算法与行为约束'; boundary='这是作者针对赌博和投机提出的强约束，不是所有投资收益的普遍经济定律。' }
    [ordered]@{ evidenceId='K45'; ordinal=3628; section='不确定性、预测与决策'; claim='作者反对把专业与人生交给身边人的“都说”，要求由本人调查和下注，并优先选择不因单一趋势变化就淘汰的基础能力。'; quote='真正永远不错的，是万变。'; evidenceNature='选择主体与长期稳健性判断'; boundary='文章同时包含对中国科技路线的预测，本文不把这些预测当作已验证结果。' }
    [ordered]@{ evidenceId='K46'; ordinal=3744; section='不确定性、预测与决策'; claim='作者把认知的实际功能放在预测下一步和决定行动，并主张把探索设计成可记录、可复用的实验，使不理想结果仍产生经验。'; quote='只有真实的未知，才是历史留给你的礼物。'; evidenceNature='预测、实验与未知价值模型'; boundary='文章承认当经验无法再利用或传承、且主体只看盈利成败时，失败豁免会失效。' }
    [ordered]@{ evidenceId='K47'; ordinal=1059; section='不确定性、预测与决策'; claim='作者要求父母面对无法完全拦截的新信息时，先公平了解规则与成败案例，再提出共享智力资源后仍未解决的真实怀疑。'; quote='有效的怀疑比坚决反对和严厉批判更好。'; evidenceNature='未知信息与有效怀疑程序'; boundary='文章仍承认父母有尽职过滤权，所反对的是跳过了解和好奇直接否定。' }
    [ordered]@{ evidenceId='K48'; ordinal=4038; section='不确定性、预测与决策'; claim='作者以可控核聚变推演技术能力、热污染、经济竞争和全球管制之间的连锁风险，反对把单项技术突破直接等同于繁荣。'; quote='热也可以是一种污染。'; evidenceNature='技术情景推演与二阶后果'; boundary='聚变进度、能源需求和全球制度均是作者未来推演，不作外部科技与气候裁决。' }
)

$corpus = [Collections.Generic.List[object]]::new()
foreach ($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($CorpusPath))) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $corpus.Add(($line | ConvertFrom-Json))
}
if ($corpus.Count -ne 4050) { throw "Expected 4050 corpus articles, found $($corpus.Count)." }

$screenedIds = @{}
$epistemologyRouteIds = @{}
foreach ($row in Import-Csv -LiteralPath ([IO.Path]::GetFullPath($ScreeningPath))) {
    $screenedIds[[string]$row.id] = $true
    if ([string]$row.topicRoutes -like '*认识论、知识与论证*') {
        $epistemologyRouteIds[[string]$row.id] = $true
    }
}

$rows = [Collections.Generic.List[object]]::new()
foreach ($item in $items) {
    if ($item.ordinal -lt 1 -or $item.ordinal -gt $corpus.Count) { throw "[$($item.evidenceId)] Invalid ordinal $($item.ordinal)." }
    $article = $corpus[$item.ordinal - 1]
    if (-not $screenedIds.ContainsKey([string]$article.id)) { throw "[$($item.evidenceId)] Article is not in the screened candidate layer." }
    $inEpistemologyRoute = $epistemologyRouteIds.ContainsKey([string]$article.id)
    $isApprovedCrossRouteSupplement = $approvedCrossRouteSupplements.ContainsKey([int]$item.ordinal)
    if (-not $inEpistemologyRoute -and -not $isApprovedCrossRouteSupplement) {
        throw "[$($item.evidenceId)] Article is neither in the epistemology route nor an approved cross-route supplement."
    }
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
        sourceLayer = if ($inEpistemologyRoute) { 'epistemology-route' } else { 'screened-cross-route-supplement' }
    })
}

$requiredSections = @(
    '共同世界、真理与知识边界',
    '定义、题面与概念边界',
    '观察、证据与验证',
    '逻辑、模型与推理',
    '语言、达意与相互理解',
    '质疑、批评与修复',
    '记录、研究与知识生产',
    '不确定性、预测与决策'
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
$crossRouteRows = @($rows | Where-Object sourceLayer -eq 'screened-cross-route-supplement')

$outputFull = [IO.Path]::GetFullPath($OutputPath)
$statsFull = [IO.Path]::GetFullPath($StatsPath)
$rows | Export-Csv -LiteralPath $outputFull -NoTypeInformation -Encoding utf8BOM
$status = if (
    $rows.Count -eq 48 -and $uniqueEvidenceIds -eq 48 -and $uniqueArticleIds -eq 48 -and
    $screenedIds.Count -eq 851 -and $epistemologyRouteIds.Count -eq 523 -and
    $crossRouteRows.Count -eq 1 -and [int]$crossRouteRows[0].ordinal -eq 3752 -and
    $missingCoreFields -eq 0 -and $allSectionsCovered -and -not ($rows.quoteExact -contains $false)
) { 'PASS' } else { 'REVIEW' }
$stats = [ordered]@{
    corpusArticles = $corpus.Count
    screenedCandidates = $screenedIds.Count
    epistemologyRouteCandidates = $epistemologyRouteIds.Count
    evidenceRows = $rows.Count
    uniqueEvidenceIds = $uniqueEvidenceIds
    uniqueArticleIds = $uniqueArticleIds
    epistemologyRouteEvidenceRows = @($rows | Where-Object sourceLayer -eq 'epistemology-route').Count
    screenedCrossRouteSupplements = $crossRouteRows.Count
    crossRouteSupplementOrdinals = @($crossRouteRows.ordinal)
    missingCoreFields = $missingCoreFields
    exactQuoteFailures = @($rows | Where-Object quoteExact -eq $false).Count
    sectionCounts = $sectionCounts
    status = $status
}
$stats | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $statsFull -Encoding utf8
$stats | ConvertTo-Json -Depth 5
if ($status -ne 'PASS') { throw "Epistemology and argument core evidence validation ended with status $status." }
