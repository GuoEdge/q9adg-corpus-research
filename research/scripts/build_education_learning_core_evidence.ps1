param(
    [string]$CorpusPath = '.\sooon-q9adg-articles.jsonl',
    [string]$ScreeningPath = '.\research\data\education_knowledge_screening.csv',
    [string]$OutputPath = '.\research\data\education_learning_core_evidence.csv',
    [string]$StatsPath = '.\research\data\education_learning_core_evidence.stats.json'
)

$ErrorActionPreference = 'Stop'

# The screened queue is a recall aid, not an exclusion rule. Ordinal 3611 is an
# audited supplement because the lexical screen omitted an article already used
# in the earlier education paper.
$approvedSupplements = @{
    3611 = 'Existing education core text recovered by direct corpus review.'
}

$items = @(
    [ordered]@{ evidenceId='E01'; ordinal=3752; section='学习本体、知识边界与错误'; claim='作者把客观世界及其规律视为不同立场交流和订约的共同底盘，同时把人类知识限定为可继续修正的“有质量的错误”。'; quote='人类能达到的极限，不过是“有质量的错误”。'; evidenceNature='知识边界与共同事实命题'; boundary='科学经典在文中是高质量世界描述而非终极真理，本文不替作者作外部科学史判断。' }
    [ordered]@{ evidenceId='E02'; ordinal=3785; section='学习本体、知识边界与错误'; claim='作者把终极真理定义为能够穷尽过去未来且永不修正的全知模型，并认为人只能依据有限知识作胜率不同的下注。'; quote='是赌注而已。'; evidenceNature='定义分析与认识限度推演'; boundary='文章批评的是把下注加冕为绝对真理，不是否定不同知识判断之间存在质量差异。' }
    [ordered]@{ evidenceId='E03'; ordinal=3611; section='学习本体、知识边界与错误'; claim='作者把承认记忆、意志、公正和预见能力的不足写成变强起点，并要求以记录、方法和系统降难度补足主体限制。'; quote='人是从谦卑开始变强的。'; evidenceNature='主体认识与能力建设原则'; boundary='文章讨论一般主体治理，并非专门学校制度文本；它在本专题中承担学习者模型。' }
    [ordered]@{ evidenceId='E04'; ordinal=3369; section='学习本体、知识边界与错误'; claim='作者要求复盘把个案稳定为问题样本，再把经验写入章程、流程、培训和职责，使错误成为可继承的组织知识。'; quote='所谓的解决方案，指且仅指组织规则的更新。'; evidenceNature='组织学习与经验固化程序'; boundary='该文主要讨论组织复盘，不能直接等同于个人反思或课堂复习。' }
    [ordered]@{ evidenceId='E05'; ordinal=1557; section='学习本体、知识边界与错误'; claim='作者把值得鼓励的错误限定在优于不作为且已尽能力提高质量的区间，并要求同时陈述行动与不行动风险。'; quote='人们鼓励你去犯的是好过不作为且凭你的能力能犯的最高质量的错误。'; evidenceNature='错误安全区与责任判断'; boundary='文章没有为任意试错免责，反而把他人成本、态度和能力上限列为责任条件。' }
    [ordered]@{ evidenceId='E06'; ordinal=648; section='学习本体、知识边界与错误'; claim='作者把学习扩展到全部生活过程，认为语言、习惯、家庭闲谈、批评经验和社会化准备都会进入学校学习。'; quote='对孩子来说，从睁眼到闭眼，甚至连在睡梦中都是在学习。'; evidenceNature='学习本体与环境判断'; boundary='文章同时讨论生理性障碍和社会化，其具体类比只记录为作者论证，不作外部医学或教育裁决。' }

    [ordered]@{ evidenceId='E07'; ordinal=243; section='能力、训练与实践形成'; claim='作者把学习成效首先放在了解、记住、掌握和熟练，而不是名次和升学，并要求父母帮助孩子获得知识与再加工知识的乐趣。'; quote='关心学习，只有一个真实的目标，就是增强孩子对学习的热爱。'; evidenceNature='学习成效与动机判断'; boundary='文章反对用贫困恐惧刺激学习，但没有否定所有考试反馈或升学信息。' }
    [ordered]@{ evidenceId='E08'; ordinal=3043; section='能力、训练与实践形成'; claim='作者认为多数专业能力不存在不可逾越的天堑，合适教师、资源、心理引导和持续改进能够把天赋兑现为服务能力。'; quote='老实说，人类是一种普遍有天赋的种族。'; evidenceNature='天赋与能力形成判断'; boundary='文章后半转入“补强”关系策略，不能把整篇压缩成无条件的天赋平等论。' }
    [ordered]@{ evidenceId='E09'; ordinal=2816; section='能力、训练与实践形成'; claim='作者主张以减少部分理论负担为条件增加劳动技能教育，把生产经验视为安全感、现实价值感和心理发育的重要来源。'; quote='基本的劳动技能对个人的成长——尤其是心理发育——有至关重要且不可替代的意义。'; evidenceNature='劳动教育与能力形成主张'; boundary='文中没有要求在原课程总量上继续叠加劳动教育，明确以总负担基本不变为条件。' }
    [ordered]@{ evidenceId='E10'; ordinal=596; section='能力、训练与实践形成'; claim='作者主张先进行与自身段位相配的足量实战，再以失误、侥幸和后怕指引回看理论，形成由实践定位知识缺口的学习顺序。'; quote='你需要一套覆盖面完整的题，然后在题的引导下去看书。'; evidenceNature='训练顺序与反馈机制'; boundary='文章要求实战适配段位、数量充分且有战略，不是以做题完全替代阅读和求教。' }
    [ordered]@{ evidenceId='E11'; ordinal=3299; section='能力、训练与实践形成'; claim='作者把艺术练习写成在安全范围内犯错、检查执念和寻找稳定方法的过程，并以压力下可重复性而非偶然最佳结果判断功夫。'; quote='停止发泄。'; evidenceNature='练习、复用与疗愈机制'; boundary='文章以画线和艺术为模型讨论疗愈，不构成临床治疗方案。' }
    [ordered]@{ evidenceId='E12'; ordinal=941; section='能力、训练与实践形成'; claim='作者区分被动忍受苦难与在示范、分段指导和直观成果中学习对抗困难，要求教育提高能力上限而不是只制造痛苦。'; quote='前者是忍受苦难的教育，而后者是对抗苦难的教育。'; evidenceNature='示范教学与困难训练方案'; boundary='作者只允许安排成果直观且有市场价值的繁重劳动，不把纯折磨写成教育。' }

    [ordered]@{ evidenceId='E13'; ordinal=3277; section='家庭教育与社会化'; claim='作者区分主动服从和暴力屈从，认为父母只有尊重判断、退出和不屈从，才可能取得让子女自愿协作的命令资格。'; quote='服从是一种决定。'; evidenceNature='家庭权柄与自主判断'; boundary='文章承认父母需要培养协作能力，但不把怒吼和强制产生的顺从视为真正服从。' }
    [ordered]@{ evidenceId='E14'; ordinal=1084; section='家庭教育与社会化'; claim='作者提出以长期、分龄、可兑现的奖励现金流积累胜利经验、资产安全感和亲子信任，并用奖励建设后天社会能力。'; quote='这个机制就是“给钱”。'; evidenceNature='家庭激励制度方案'; boundary='具体比例、年龄和借贷安排是作者的家庭方案，不是普遍财务规则或儿童发展定律。' }
    [ordered]@{ evidenceId='E15'; ordinal=157; section='家庭教育与社会化'; claim='作者把教育第一原则写成父母为世界代言，允许子女在安全范围内核实、犯错和超越父母，而不是把事故解释为不听话的惩罚。'; quote='你要吸取的教训不是“以后要听父母的”'; evidenceNature='父母角色与世界关系主张'; boundary='文章仍允许父母在危险条件下暂时看守，所反对的是把保护权变成永久服从。' }
    [ordered]@{ evidenceId='E16'; ordinal=385; section='家庭教育与社会化'; claim='作者认为学校不适应常与同伴恐惧、教师关系和社交破裂有关，因此把善良、友谊、家校合作和社会性置于成绩之前。'; quote='永远别忘了，社会性才是人类的第一专业，'; evidenceNature='学校适应与关系基础判断'; boundary='“第一专业”针对儿童学校生活的关系基础，不自动排除知识和技能学习的其他优先级。' }
    [ordered]@{ evidenceId='E17'; ordinal=139; section='家庭教育与社会化'; claim='作者把独立思考的条件放在安全感和多元关系网络，认为儿童在不怕孤独、能接触不同群体时才会自然比较不同叙事。'; quote='独立思考不用教，要教友立思考。'; evidenceNature='社会关系与独立判断机制'; boundary='文章没有把逻辑训练写成无用，而是反对父母借逻辑训练强迫子女接受既定立场。' }
    [ordered]@{ evidenceId='E18'; ordinal=248; section='家庭教育与社会化'; claim='作者把家庭晚餐设计为愉快、持续、前置的社会案例讨论，主张教育优先于事后惩罚，并在安全距离外练习价值判断。'; quote='是教育失败了，才轮到惩罚这种紧急避险的最后手段作为不得已的尾部补救。'; evidenceNature='家庭日常教育程序'; boundary='文章反对借吃饭训斥儿童，但没有主张所有教育都只能在晚餐或新闻讨论中发生。' }

    [ordered]@{ evidenceId='E19'; ordinal=3680; section='教师、批评与教育权柄'; claim='作者把批评限定为经过授权、从对方目标和已承认事实出发的逻辑服务，并要求控制讽刺、定罪、利益冲突和附带伤害。'; quote='批评权这东西，其实比黄金还贵。'; evidenceNature='批评授权与程序规范'; boundary='该文适用于一般批评关系，在教师专题中只作为通用上位条件。' }
    [ordered]@{ evidenceId='E20'; ordinal=964; section='教师、批评与教育权柄'; claim='作者要求批评在指出错误后提供能力范围内的新方法和目标，使屈辱、沮丧转化为控制感、兴趣和继续行动。'; quote='批评不是以“制造恰当的屈辱和沮丧”为目的的行为'; evidenceNature='批评完成标准与替代方案'; boundary='文章允许短期或长期情绪回弹两种路径，但不允许以制造低潮本身冒充批评。' }
    [ordered]@{ evidenceId='E21'; ordinal=1885; section='教师、批评与教育权柄'; claim='作者把师生关系限定在专业资质、岗位授权、保密边界和拒绝权内，反对教师与学生共同制造父母式或治疗式私人期待。'; quote='停止主动联系'; evidenceNature='师生角色边界与行动建议'; boundary='文章处理一个具体关系冲突，不是对全部师生亲近关系的禁止。' }
    [ordered]@{ evidenceId='E22'; ordinal=2238; section='教师、批评与教育权柄'; claim='作者认为教师职权来自政府、家长和学校基于忠于职守的授权，个人政治理想不得借岗位绕过监护人与公共程序灌输未成年人。'; quote='你个人的政治理想是你个人的事'; evidenceNature='教师岗位授权与政治表达边界'; boundary='文章允许通过说服成年人、取得监护人自愿或影响公共政策推广理念。' }
    [ordered]@{ evidenceId='E23'; ordinal=3906; section='教师、批评与教育权柄'; claim='作者要求教师承认所教并非终极真理而是有质量的错误，也要求学生以补强理解而非神化或恶意曲解表达尊敬。'; quote='我教的都是错的'; evidenceNature='教师知识边界与尊敬关系'; boundary='文章的尊师来自共同承担认识限度，不是无条件崇拜或免除教师责任。' }
    [ordered]@{ evidenceId='E24'; ordinal=338; section='教师、批评与教育权柄'; claim='作者把教师重构为知识的表演艺术家，要求把前因后果、画面、情感和参与感转成学生愿意追随的知识体验。'; quote='好的老师实际上是一名“表演艺术家”'; evidenceNature='教师角色与课堂影响力模型'; boundary='文章承认知识明星可能带来偶像崇拜问题，没有把娱乐性等同于教学全部标准。' }

    [ordered]@{ evidenceId='E25'; ordinal=1718; section='学校、课堂与作业制度'; claim='作者把作业的首要功能设为诚实暴露学习过程和不足，以工整、留痕和另行订正帮助教师低成本定位问题。'; quote='作业真正的作用是“帮助老师发现自己的学业不足，以便进一步指导”'; evidenceNature='作业功能与反馈设计'; boundary='“以美为先”是作者处理儿童作业焦虑的具体排序，不等于否认知识正确性。' }
    [ordered]@{ evidenceId='E26'; ordinal=1293; section='学校、课堂与作业制度'; claim='作者肯定学生讲课能够训练理解、表达和答疑，并以教师点评补充纠正，但把成效限定于生源、学风、班级传统、教师水平和学科。'; quote='这实际上是一个非常好的形式'; evidenceNature='课堂角色转换与条件判断'; boundary='文章明确不主张把这一形式不分条件地推广到全部理科课程。' }
    [ordered]@{ evidenceId='E27'; ordinal=321; section='学校、课堂与作业制度'; claim='作者要求课堂游戏采用无资质门槛、采集而非竞争、选择而非奖惩、自动记录且可回溯的规则，以防信用破产和同伴霸凌。'; quote='为人师者，与为王无异。'; evidenceNature='课堂制度设计与教师信用'; boundary='强权柄在文中与立法、执法、裁判和侦查责任同时出现，不是赋予教师任意裁量。' }
    [ordered]@{ evidenceId='E28'; ordinal=2163; section='学校、课堂与作业制度'; claim='作者认为既有学校体系只要未明显失灵就不宜轻率另起炉灶，因为独立系统会挤占额外资源；若改变，则要计算并承担成败。'; quote='要胜利。'; evidenceNature='学校体系选择与资源判断'; boundary='文章没有宣称既有系统总是先进，只把替代方案的成本、成功条件和权利后果纳入决定。' }
    [ordered]@{ evidenceId='E29'; ordinal=332; section='学校、课堂与作业制度'; claim='作者在AI工具尚不稳定的阶段主张AI先助教而不助学、助考，避免学生直接索取答案造成假掌握。'; quote='假掌握”，导致学习虚无化。'; evidenceNature='AI工具与基础教育阶段判断'; boundary='作者明确把结论限定为当前阶段，并承认未来学校制度可能形成不同流派。' }
    [ordered]@{ evidenceId='E30'; ordinal=135; section='学校、课堂与作业制度'; claim='作者区分能力平庸与作业拖拉所显示的责任问题，同时把努力和负责本身写成青少年仍在学习的一门长期课程。'; quote='因为学会努力和负责本身就是青少年发育中最重要的内容，本身就是一门课。'; evidenceNature='作业态度与发展过程判断'; boundary='文章既要求责任，也反对教育者把尚未学会责任过早解释为不可挽回的失败。' }

    [ordered]@{ evidenceId='E31'; ordinal=750; section='考试、竞争与选拔'; claim='作者区分语言水平和语文考试成绩，认为标准课程偏向语言工具的速成训练，而大量阅读、创作和批评通向更广的语言能力。'; quote='大量的阅读一定能提高人的语文水平。'; evidenceNature='能力与分数区分'; boundary='文章没有否定语文课程的工具价值，只否定考试分数能够穷尽语言能力。' }
    [ordered]@{ evidenceId='E32'; ordinal=2345; section='考试、竞争与选拔'; claim='作者把标准化考试限定为获得培养资格的信号，不把它等同于实际职业能力，并要求AI使用者继续为最终作品负责。'; quote='标准化考试考的东西，只是让你有被培养的资格。'; evidenceNature='考试资格与实际能力边界'; boundary='文章没有否定基本功和规范训练，反而反对依赖AI跳过修炼。' }
    [ordered]@{ evidenceId='E33'; ordinal=2377; section='考试、竞争与选拔'; claim='作者认为竞争兼有信息发现和资源配置功能，主张扩大参赛资格、降低分胜负的无谓损耗，并为失败准备仍指向胜利的下一方案。'; quote='无限的竞争是不容人类自己合谋关闭的自然法则，'; evidenceNature='竞争功能与制度设计判断'; boundary='文中反对的是消灭竞争，不等于赞成牺牲信用、身体和心理健康的无限投入。' }
    [ordered]@{ evidenceId='E34'; ordinal=1824; section='考试、竞争与选拔'; claim='作者反对把竞赛和名校当作唯一幸福入口，要求把竞争还原为磨练专长，并让真实用户和未来成果而非龙门身份判断价值。'; quote='参加各种竞赛的价值不应该是能不能拿来跳龙门，而应该还原到“借助激烈的竞争环境磨练自己的专长”上。'; evidenceNature='选拔入口与能力价值区分'; boundary='文章不反对参赛和进入名校，反对的是把入口本身写成价值终点。' }
    [ordered]@{ evidenceId='E35'; ordinal=1000; section='考试、竞争与选拔'; claim='作者以强硬定义把坚韧设为人才基本属性，认为不能绕过也不能承受应试挑战者不应借“人才被扼杀”解释失败。'; quote='坚韧是人才的基本属性。'; evidenceNature='应试、人才与坚韧强判断'; boundary='这是作者在短文中的极端人才定义，不能外推为全语料唯一的人才标准。' }
    [ordered]@{ evidenceId='E36'; ordinal=1006; section='考试、竞争与选拔'; claim='作者承认当事人可以确认自己确实不适合应试教育，但把这种确认设为另选道路并继续努力的起点，而不是停止行动的结论。'; quote='那么就以此为起点，好好地努力吧。'; evidenceNature='应试不适配与主体确认'; boundary='该文极短，只提供条件性承认和行动方向，没有展开替代教育制度。' }

    [ordered]@{ evidenceId='E37'; ordinal=3448; section='高等教育、专业与科研'; claim='作者把本科定位为获得信息辨别工具的起步阶段，不把学历自动等同于思想成熟、概念清晰或摆脱迷信。'; quote='“本科高等教育”其实只不过是个要求高一点的扫盲班水平而已。'; evidenceNature='本科学历与成熟度边界'; boundary='文章承认本科提供起步工具，不是否认高等教育本身的作用。' }
    [ordered]@{ evidenceId='E38'; ordinal=3597; section='高等教育、专业与科研'; claim='作者把哲学写成需要长期涉猎、自然科学、手艺和人生经验共同进入的思想艺术，反对年轻学习者过早宣称掌握。'; quote='哲学不是年轻人能宣称掌握甚至了解的学问。'; evidenceNature='哲学教育与经验条件'; boundary='文章鼓励阅读和涉猎哲学，反对的是把课程、术语和学派记忆等同于完成哲学。' }
    [ordered]@{ evidenceId='E39'; ordinal=1616; section='高等教育、专业与科研'; claim='作者把大学阶段学习失能解释为外部应激动力消失后的长期志向缺位，并要求先建立指向人类福祉的事业目标再选择方法。'; quote='看似这是个学习问题，实际上这是个人生观、价值观问题。'; evidenceNature='大学学习动机与事业方向'; boundary='“必须指向整个人类”是作者的强要求，不被改写成外部普遍职业指导。' }
    [ordered]@{ evidenceId='E40'; ordinal=1935; section='高等教育、专业与科研'; claim='作者把知识技能发展描述为由杂到精、由精而专、由专而博，并以真实客户、持续服务和行业成果区分专业与考试高分。'; quote='人的知识技能发展一般遵循这样一个“由杂到精，由精而专，由专而博”的过程。'; evidenceNature='专业形成与知识结构模型'; boundary='该阶段模型是作者概括，不表示所有职业必然按同一顺序发展。' }
    [ordered]@{ evidenceId='E41'; ordinal=63; section='高等教育、专业与科研'; claim='作者把未来仍具特殊价值的专业分为身体技能和强规范准入两类，并把大学价值转向意志、生活、社交、情绪和项目成长。'; quote='重要的是肌肉，不是杠铃。'; evidenceNature='AI时代专业与大学选择判断'; boundary='文章对专业前景的分类属于作者预测，不作外部就业市场验证。' }
    [ordered]@{ evidenceId='E42'; ordinal=643; section='高等教育、专业与科研'; claim='作者把学历视为只能提供有限等级线索的原石外壳，认为真实合作最终仍由项目表现和可观察成果决定。'; quote='学历崇拜，就像你在崇拜这些带着皮壳的原石。'; evidenceNature='学历信号与实际成果区分'; boundary='文章没有说学历完全无信息，只反对把学校标签当作成果保证。' }

    [ordered]@{ evidenceId='E43'; ordinal=3172; section='教育目的与多重尺度'; claim='作者以行为改变、经验传承长度、受益者自由和再传递系数衡量教育，不把制度评分和一次性普及率设为唯一成效。'; quote='教育的根本是改变人的行为'; evidenceNature='教育成效定义'; boundary='“长度而非宽度”针对作者讨论的传承模型，不能取消所有公共普及目标。' }
    [ordered]@{ evidenceId='E44'; ordinal=3894; section='教育目的与多重尺度'; claim='作者把世界史教育的目的从灌输固定史识转向训练辨材、怀疑、交叉观察和创新的史才，并要求保护受教育者的灵魂主权。'; quote='世界史教育的核心目标，不是为了造就知识，而是为了造就技能和技能的体验。'; evidenceNature='教育目的、怀疑能力与主体权柄'; boundary='文章称世界史第一重要，是其特定教育论中的强判断，不自动压倒社会性、劳动或事业等其他“第一”。' }
    [ordered]@{ evidenceId='E45'; ordinal=175; section='教育目的与多重尺度'; claim='作者认为教育传递过去经验必然滞后于未来，因而要求教育建立对有质量失败的容错，并把爱、正直和仁慈置于工具技能之前。'; quote='破题的关键在于要寻求绝对容错性。'; evidenceNature='未来教育与精神伦理判断'; boundary='文章的AI社会和需求碎片化是作者预测，“绝对容错性”也不等于取消责任或结果。' }
    [ordered]@{ evidenceId='E46'; ordinal=205; section='教育目的与多重尺度'; claim='作者把未来教育概括为说得清、做得出、卖得掉三类实际能力，使表达、生产、组织、成本、融资和客户共同进入安身立命。'; quote='未来的教育，一共三个主科：'; evidenceNature='AI时代能力与市场服务模型'; boundary='三主科是作者提出的未来方案，不是对现行课程的经验统计。' }
    [ordered]@{ evidenceId='E47'; ordinal=251; section='教育目的与多重尺度'; claim='作者把AI和自动化造成的就业变化与延长教育、新拓荒和空间扩张连接，要求未来教育面向新的生产边疆重新安排。'; quote='教育最终要面向这个新的时代重新安排。'; evidenceNature='教育制度与文明未来推演'; boundary='义务教育年限、太阳系开发和就业规模均为作者的未来推演，不作外部政策预测。' }
    [ordered]@{ evidenceId='E48'; ordinal=2554; section='教育目的与多重尺度'; claim='作者把低技能劳动等现实后果的考察和体验称为事实教育，认为教育应提供主体作决定所需的信息，而不是人为设计恐吓。'; quote='这是帮助你获得决策所需要的必要信息。'; evidenceNature='事实教育与决策信息原则'; boundary='文章允许展示客观选项，不把父母制造惩罚或夸大后果视为事实教育。' }
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
    $inScreening = $screenedIds.ContainsKey([string]$article.id)
    $isApprovedSupplement = $approvedSupplements.ContainsKey([int]$item.ordinal)
    if (-not $inScreening -and -not $isApprovedSupplement) {
        throw "[$($item.evidenceId)] Article is neither screened nor an approved direct-review supplement."
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
        sourceLayer = if ($inScreening) { 'screened' } else { 'direct-review-supplement' }
    })
}

$requiredSections = @(
    '学习本体、知识边界与错误',
    '能力、训练与实践形成',
    '家庭教育与社会化',
    '教师、批评与教育权柄',
    '学校、课堂与作业制度',
    '考试、竞争与选拔',
    '高等教育、专业与科研',
    '教育目的与多重尺度'
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

$outputFull = [IO.Path]::GetFullPath($OutputPath)
$statsFull = [IO.Path]::GetFullPath($StatsPath)
$rows | Export-Csv -LiteralPath $outputFull -NoTypeInformation -Encoding utf8BOM
$status = if (
    $rows.Count -eq 48 -and $uniqueEvidenceIds -eq 48 -and $uniqueArticleIds -eq 48 -and
    $screenedIds.Count -eq 851 -and $supplementRows.Count -eq 1 -and
    [int]$supplementRows[0].ordinal -eq 3611 -and $missingCoreFields -eq 0 -and
    $allSectionsCovered -and -not ($rows.quoteExact -contains $false)
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
$stats | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $statsFull -Encoding utf8
$stats | ConvertTo-Json -Depth 5
if ($status -ne 'PASS') { throw "Education and learning core evidence validation ended with status $status." }
