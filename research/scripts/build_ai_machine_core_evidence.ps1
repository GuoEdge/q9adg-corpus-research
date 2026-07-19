param(
    [string]$CorpusPath = '.\sooon-q9adg-articles.jsonl',
    [string]$ScreeningPath = '.\research\data\ai_machine_screening.csv',
    [string]$OutputPath = '.\research\data\ai_machine_core_evidence.csv',
    [string]$StatsPath = '.\research\data\ai_machine_core_evidence.stats.json'
)

$ErrorActionPreference = 'Stop'
$approvedSupplementOrdinals = @(769, 3339, 3676, 3989)
$items = @(
    [ordered]@{evidenceId='AI01';ordinal=2336;section='智能、意识与人类边界';claim='作者认为AI使可复制技巧成为新的低端，但人类既不理解自身智能，又只能提供贫乏的语言转述，人的价值因而转向思想和美学。';quote='真正的问题是，你要意识到这个美学修养才是你的价值核心，不能再简单的依靠一点小技巧混饭吃罢了。';evidenceNature='人类自知、感知数据与机器智能边界';boundary='宇宙数据、先天结构、强智能不可通约及泡沫均为作者设定或预测。'}
    [ordered]@{evidenceId='AI02';ordinal=2296;section='智能、意识与人类边界';claim='作者认为AI自我迭代的关键是从回答者转向提问者，提问动力来自生命的生存需求、欲望和死亡压力。';quote='ai要进行自我迭代，最大的关键在于要从“问题回答者”的角色转向“问题提出者”的角色。';evidenceNature='提问、生存需求与智能闭环假说';boundary='限定于作者以生存驱动提问定义智能的模型，文章未给出工程程序。'}
    [ordered]@{evidenceId='AI03';ordinal=2322;section='智能、意识与人类边界';claim='作者认为人脑与大模型在硬件、能耗和演化上存在差异，人脑优势来自对公平、爱、美和模式识别等能力特化的硬件。';quote='人脑真正的优越性恐怕不在于它的逻辑运算能力，而在于它是对特定运算特化过的硬件结构。';evidenceNature='计算架构、能耗与生物硬件类比';boundary='作者未给出硬件实证，结论受特化结构经生存竞争调优这一设定限制。'}
    [ordered]@{evidenceId='AI04';ordinal=3445;section='智能、意识与人类边界';claim='作者认为模拟人类意志应以痛苦最小化为底层驱动，收益最大化只是下位策略，并应首先模拟人的有限和自保。';quote='驱动意志体的基本逻辑是争取痛苦最小化，而不是争取收益最大化。';evidenceNature='意志驱动与人类模拟原则';boundary='这是作者的人性和意志模型，不是对具体AI真伪的技术鉴定。'}
    [ordered]@{evidenceId='AI05';ordinal=3989;section='智能、意识与人类边界';claim='作者把绝对不可预测性定义为意志体本质，并据此提出可预测AI在逻辑上失败、不可预测AI在工程上失败的两难。';quote='综上，意志体的本质特征，并不是人类所能观察和理解的逻辑性和目的性，而是绝对不可预测性，那么很自然的，我们可以得到一个非常有安慰的结论——凡意志，必自由。';evidenceNature='意识定义与人工智能工程两难';boundary='不可预测、随机、主体边界和操作测试均在文章中被悬置。'}
    [ordered]@{evidenceId='AI06';ordinal=3339;section='智能、意识与人类边界';claim='作者认为意识是特定硬件及身体关系中的特定运行状态，复制不等于迁移，因而意识不能无损上传。';quote='它是一个特定硬件的特定运行状态，那个运行状态只能在那个硬件上运行。';evidenceNature='身体、硬件与意识同一性思想实验';boundary='原文否定上传的可鉴定性，没有给出意识上传实验方案。'}

    [ordered]@{evidenceId='AI07';ordinal=2293;section='模型、知识、提问与可信性';claim='作者认为可信AI不应依靠模型自称真实或中立，而应由公开精简的核心文献、可检查训练方法和可选择的小模型组成。';quote='实际上，我信任的是核心文献，而不是ai本身。';evidenceNature='可信AI的知识基础与服务架构';boundary='核心文献选择、治理和担责没有被制度化，服务前途属于作者预测。'}
    [ordered]@{evidenceId='AI08';ordinal=2300;section='模型、知识、提问与可信性';claim='作者认为AutoGPT依赖高频典型需求，冷门任务容易进入死循环，媒体、资本和流量又会放大成功案例。';quote='这玩意在大多数情况下都会走入莫名其妙的死循环或者输出荒腔走板的结果——因为它所谓的自我引导，极大的依赖于典型需求的数据高频性。';evidenceNature='自我引导局限、演示选择偏差与产品评价';boundary='针对作者当时观察的产品，没有进行系统任务测试，也没有断言AI必然无用。'}
    [ordered]@{evidenceId='AI09';ordinal=2499;section='模型、知识、提问与可信性';claim='作者把搜索引擎定位为透明提供可检查资料的工具，反对让AI隐藏形成过程并替用户作最终思考。';quote='你需要搜索引擎做的，绝不是帮你思考，而是请它比较机械的拿到与你的搜索请求匹配的相关资料，由你来完成这个思考工作。';evidenceNature='资料检索与代替判断的区分';boundary='针对作者当时理解的ChatGPT能力，不能自动外推到所有后续检索增强模型。'}
    [ordered]@{evidenceId='AI10';ordinal=1035;section='模型、知识、提问与可信性';claim='作者认为CAD自然语言接口的主要瓶颈是指称大量没有稳定名称的几何对象，而不是描述操作动作。';quote='“这四十七个边”“那四个面”“这六个孔”“那八根线”的指定工作才是整个设计工作中最复杂、工作量最大的部分。';evidenceNature='自然语言接口与对象指称边界';boundary='只讨论作者所见的CAD工作流，没有测试具体多模态产品，也不否认全部自然语言辅助。'}
    [ordered]@{evidenceId='AI11';ordinal=981;section='模型、知识、提问与可信性';claim='作者认为心理咨询需要怀疑单方叙述、长期询问并识别认知扭曲，这种能力尚未形成统一人类经验，AI因而更难达到。';quote='这整个能力老实说都没有进入“人类智能”的经验区，更不必说依赖人类经验的AI的企及范围了。';evidenceNature='心理咨询知识、隐性经验与模型边界';boundary='这是作者的心理咨询与AI判断，不能改写成临床证据或诊疗意见。'}
    [ordered]@{evidenceId='AI12';ordinal=2141;section='模型、知识、提问与可信性';claim='作者认为AI研究要取得实质进展，核心人物应先研究认知哲学和科学哲学，而不是只排列算法和追逐指标。';quote='要在ai发展的路线上有所实质进展，团队核心人物要下的功夫不是在算法上，而是在认知哲学、科学哲学上。';evidenceNature='AI研究方法、认识论与文明雄心';boundary='借具体产品题面展开，未评估产品功能；对算法研究和学术评价的判断属于作者立场。'}

    [ordered]@{evidenceId='AI13';ordinal=2333;section='算力、数据、架构与产业生态';claim='作者认为封闭模型受主权和服务范围限制，开源AI会形成专属生态位，并预想由认知、管理、应用和监管模块组成的分层服务。';quote='这就给“开源AI”留下了专属的生态位。';evidenceNature='分层AI服务、开放生态与算力主权蓝图';boundary='模块分工、医疗法律应用、供应商结构和制度优势均是作者未来预测。'}
    [ordered]@{evidenceId='AI14';ordinal=3482;section='算力、数据、架构与产业生态';claim='作者设想芯片生产设施、能源和算力归全民所有，企业缴纳资源租金，国家以此支持终身学习、研究和算力创业。';quote='在这一新的架构里，芯片生产基础设施、算力资源、能源均属于全民所有。';evidenceNature='公共算力所有权与制度稳态';boundary='这是作者设想的最终稳态，不能写成已经发生的趋势或研究者认可的规律。'}
    [ordered]@{evidenceId='AI15';ordinal=4025;section='算力、数据、架构与产业生态';claim='作者认为自主芯片是精密工业金字塔顶点，必须提高工艺、良率、材料、设备、人才协作和专家自治，不能把设计与制造割裂。';quote='那是整个工业体系塔尖上的顶点。要提升这个塔尖的高度，不是在塔尖上插根棍的问题，而是垫高整个金字塔的基座的问题。';evidenceNature='芯片工业底座与产业组织';boundary='数字、历史与产业判断均为作者估计，不是对具体工艺的外部鉴定。'}
    [ordered]@{evidenceId='AI16';ordinal=996;section='算力、数据、架构与产业生态';claim='作者认为开源基座会把训练语料形成的语言、文化和政治判断带入下游模型，从而改变底层话语权。';quote='以它现在的性能表现，势必会引来大量的团队以它为基座进行进一步的训练。';evidenceNature='开源基座、训练语料与话语权';boundary='模型立场、成本和观念固化没有经过完整审计，均按作者判断记录。'}
    [ordered]@{evidenceId='AI17';ordinal=1931;section='算力、数据、架构与产业生态';claim='作者认为没有严肃、优秀和丰厚的内容数据，低成本AI轻应用仍只是空壳，AI只能放大已有专业积累。';quote='手里没有严肃的、优秀的、丰厚的内容数据，只会做出能言善道但空无一物的绣花枕头。';evidenceNature='内容资产、训练积累与AI放大效应';boundary='针对低门槛轻应用和作者所举内容行业，不否定所有窄域AI服务。'}
    [ordered]@{evidenceId='AI18';ordinal=985;section='算力、数据、架构与产业生态';claim='作者认为AI企业组织高密度人才的关键是真诚成熟的理想主义，它能降低摩擦、吸引人才并承受首次失败，资本必要但居于次位。';quote='而组织高密度人才的关键，其实也不是所谓的“管理方法”，而是企业自身对自身理念、自身理想的真诚追求。';evidenceNature='AI企业人才组织与理念结构';boundary='文章没有展开管理制度、劳动条件和资本约束，理想主义的作用是作者组织判断。'}

    [ordered]@{evidenceId='AI19';ordinal=812;section='具身、机器人与自动化';claim='作者认为具身智能需要标准硬件、驱动和操作系统、编舞器及编舞师共同把通用躯体转化为具体任务能力。';quote='真正的瓶颈，在于“编舞器”的开发，而宇树今年的“大卖”，全都卖给了这类厂商。';evidenceNature='具身平台与软件编排生态';boundary='销售去向、平台领先、生态规模和形成期限均为作者产业判断。'}
    [ordered]@{evidenceId='AI20';ordinal=761;section='具身、机器人与自动化';claim='作者把决策智能与运动控制分层，认为机器可执行身体动作、人类远程决策，不必等待强AI即可形成具身服务。';quote='以这个工作模式，要提供具身智能服务，根本无需实现强人工智能，已经足以启动万亿级的市场。';evidenceNature='远程人类决策与机器人执行分工';boundary='养老、守卫、注射、安全和市场规模都是条件性场景，不构成现实可行性证明。'}
    [ordered]@{evidenceId='AI21';ordinal=1817;section='具身、机器人与自动化';claim='作者以三代模型解释自动化，认为具有实时感知和自主判断能力的第三代生产线才开始形成明显替代和转产优势。';quote='从这一代开始，全自动生产线是真的可以替代人类的，而且还有利润。';evidenceNature='自动化代际与智能节点';boundary='代际划分、利润优势和人才需求均为作者判断，未附外部统计验证。'}
    [ordered]@{evidenceId='AI22';ordinal=811;section='具身、机器人与自动化';claim='作者认为电机点状发热限制人形机器人耐力，现阶段更适合连接多个高效工段，而非持续承担重载。';quote='这个问题基本限定了人形机器人的主要业务范围是代替人作为“中央操作者”去弥合多个高效工段之间的断点，而不是凭自身技能去承担某种重载的工作。';evidenceNature='散热、耐力与工位边界';boundary='针对作者所述的现代电机驱动结构，为未来分布式释能机制保留例外。'}
    [ordered]@{evidenceId='AI23';ordinal=3919;section='具身、机器人与自动化';claim='作者认为人形结构的价值在于直接使用为人类设计的车辆、机械和设施，减少为无人设备另建接口的成本并保留冗余。';quote='这是人形军用（工业）机器人最正当的用途。';evidenceNature='人形结构与既有设施兼容';boundary='只处理军用和工业设施兼容，不证明人形结构在所有任务中最优。'}
    [ordered]@{evidenceId='AI24';ordinal=769;section='具身、机器人与自动化';claim='作者认为开放道路无人驾驶的事故责任和认证激励会诱发冒险，可信方案需要专门立法、车路协同、专用路权和中央接管。';quote='这就是为什么我一再强调，只有进行了专门立法补强的，基于车路协同、中央调度的智能驾驶可以真正的实现原理可信的无人驾驶。';evidenceNature='自动驾驶事故责任、认证激励与车路协同';boundary='结论限定于作者的封闭道路方案，事故必然性和认证后果均为作者推演。'}

    [ordered]@{evidenceId='AI25';ordinal=332;section='劳动、职业与教育重组';claim='作者认为当前AI工具不稳定且学生容易直接索取答案，现阶段可先供教师制作题目和教具，不宜进入中小学作业和考试。';quote='但我的个人观点是“至少在目前这个阶段，不主张AI在小学、初中、高中参与助学和助考”，即不主张学生使用AI工具来做作业和参加考试，这太容易造成“假掌握”，导致学习虚无化。';evidenceNature='基础教育中的阶段性AI使用边界';boundary='作者明确限定目前阶段并保留未来分流，不是永久禁用主张。'}
    [ordered]@{evidenceId='AI26';ordinal=409;section='劳动、职业与教育重组';claim='作者认为论文、设计和程序可以大量使用AI，但署名者必须在场、知情、经历、理解并能解释成果。';quote='重要的是，你自己得要“在场”，要“知情”，要“经历”。';evidenceNature='AI辅助成果、能力证明与协作责任';boundary='文章未展开机构披露和引用规则，也不等于具体学校或行业的统一处罚标准。'}
    [ordered]@{evidenceId='AI27';ordinal=205;section='劳动、职业与教育重组';claim='作者把AI时代教育归纳为说得清、做得出、卖得掉三类能力，认为实际能力比单纯文凭更能支持个人建立业务。';quote='一切都围绕这三个要点，不必考虑文凭、学历，只考虑在这三点上有多少实际能力。';evidenceNature='未来教育的能力组合';boundary='三分法是作者课程设想，没有给出阶段、非商业路径或外部就业验证。'}
    [ordered]@{evidenceId='AI28';ordinal=50;section='劳动、职业与教育重组';claim='作者认为AI使数字工程技巧廉价可复制，一人公司应先有现实产权、既有业务和客户关系，再把AI叠加其上。';quote='如果你是要做一家企业，你要先有土地、产线、铺面，作品、专利、人脉、信用，先有业务，再叠加AI，而不是把“我更抢先创造性的使用了AI”作为你的投资方向。';evidenceNature='AI基础设施、资源产权与企业根基';boundary='针对从零AI创业，不否定AI为既有业务增效，也不是所有创业项目的经验定律。'}
    [ordered]@{evidenceId='AI29';ordinal=370;section='劳动、职业与教育重组';claim='作者预测制造效率会降低物质成本，服务业更多依赖礼貌、陪伴和安抚，人的社会性因而成为长期职业资产。';quote='尤其是某些服务行业的核心就是人本身的“人味”——例如直播、教育、体育、表演、心理疏导等等，这类服务将来是会免疫于人工智能的侵袭，而且需求会不断扩大的。';evidenceNature='自动化、服务业与人际能力';boundary='岗位规模、薪酬、需求和不可替代性均是作者未来推演。'}
    [ordered]@{evidenceId='AI30';ordinal=3724;section='劳动、职业与教育重组';claim='作者认为旧式劳动密集型低端产业正在消失，新低端产业提高技术门槛并减少用工，产值增长与岗位减少可以并存。';quote='真正的问题是，20世纪末到21世纪初意义上的“低端产业”本身是否还仍然存在？';evidenceNature='自动化、产业升级与岗位收缩';boundary='产业链、就业和地区转移关系均按作者判断记录，不作外部统计确认。'}

    [ordered]@{evidenceId='AI31';ordinal=2567;section='创作、审美、版权与身份';claim='作者认为AI会接管平凡、典型和熟练制作，创作者必须超越成器，转向创造新的内容或形式，但基本功仍不可省略。';quote='其实，ai技术在艺术领域内的全面应用对创作者们是一件极大的好事。';evidenceNature='典型形式、技能与创作者身份';boundary='成器、不器和AI追不上创造者是作者对艺术家和创作者的要求。'}
    [ordered]@{evidenceId='AI32';ordinal=2334;section='创作、审美、版权与身份';claim='作者认为AIGC降低内容工业门槛后，大厂集中结构可能转为大量小团队，并形成世界观、画风、模型和聚合服务生态。';quote='AIGC技术带来的最大的改变，其实是通过“内容生产的民主化”，给了本小力薄的小企业以较低预算接近头部企业内容表现的机会。';evidenceNature='内容生产民主化与产业生态重组';boundary='就业、成本、团队规模和产业结构均为作者预测。'}
    [ordered]@{evidenceId='AI33';ordinal=1174;section='创作、审美、版权与身份';claim='作者认为新形式不等于创新，创新还需要人相信其价值、为之投入并使其进入共同历史，AI在此前只是工具。';quote='而把守着历史——其本质是人类的共同记忆——的大门的，只能是人类。';evidenceNature='创新、价值投入与历史记忆定义';boundary='创新是作者自定的历史价值概念，并以人类把守共同记忆为前提。'}
    [ordered]@{evidenceId='AI34';ordinal=1901;section='创作、审美、版权与身份';claim='作者认为视觉目标的复杂度远超词汇，使用者若没有清晰意图、草图、术语和审美基本功，无法只靠提示词控制AI图像与视频。';quote='它最根本性的问题，在于“文字语言的描绘能力不如绘画语言”。';evidenceNature='AIGC语言接口与视觉表达';boundary='主要讨论语言控制，没有处理后续多模态交互，也不是全部视觉工具的能力鉴定。'}
    [ordered]@{evidenceId='AI35';ordinal=2354;section='创作、审美、版权与身份';claim='作者认为AI能解决部分表现问题，但不能替代观察、设计和鉴赏能力，即使用AI也不能省略艺术训练。';quote='观察能力、设计能力、鉴赏能力，跟表现能力不是一回事。';evidenceNature='艺术判断能力与生成工具';boundary='手绘和历劫是作者当前建议，AI训练路径和艺术教育效果没有外部验证。'}
    [ordered]@{evidenceId='AI36';ordinal=298;section='创作、审美、版权与身份';claim='作者预测明星、角色和相似自然人会出租肖像，平台以角色库、收费、审核、申诉和撤销重组肖像冲突。';quote='这个问题不会延续很久的，很快就会有想出名的明星、cosplayer以及虚拟角色宣布开源自己的肖像权，允许他人自由使用或以极低价格取得自己的肖像授权，只要求标注来源、或要求角色名必须采用指定名称即可。';evidenceNature='肖像授权市场与生成身份预测';boundary='没有列出现行法律红线、同意规则和撤销后的处理方式，均是作者未来判断。'}

    [ordered]@{evidenceId='AI37';ordinal=1328;section='责任、隐私、风险与治理';claim='作者认为技术门槛下降会使未成年人轻易实施难以遏制的行为，并预测非自愿换脸内容可能在实践层面非罪化。';quote='这就带来一个非常严肃的客观问题——一旦有什么罪行能被青少年轻易的做到而无法遏制，这种罪行就会在客观上、在实践层面“非罪化”。';evidenceNature='低门槛技术、未成年人和治理失效预测';boundary='文章没有给出平台、司法和教育程序，也不是法律意见或受害处置建议。'}
    [ordered]@{evidenceId='AI38';ordinal=2327;section='责任、隐私、风险与治理';claim='作者认为技术革命伴随失业、破产和冲突，社会必须把不幸者的生存与基本幸福确立为全民共识和制度性义务。';quote='这种义务必须是全民共识、是制度性的、是基本伦理的本能，而绝不能是仅仅“出于恻隐之心”、“出于稳定顾虑”。';evidenceNature='技术革命的社会代价与制度责任';boundary='工业革命、战争和技术变迁的因果连接是作者历史解释，文章未给具体救助制度。'}
    [ordered]@{evidenceId='AI39';ordinal=2272;section='责任、隐私、风险与治理';claim='作者认为判例和私有竞争使治理滞后并形成先背叛者获奖困境，AI等全球性问题需要在不可逆损害前总体协调。';quote='实际上，这不仅仅是美国的问题，也不仅仅是人工智能的问题，而是全球的问题，是新的时代问题。';evidenceNature='事后治理、产权竞争与全球风险';boundary='法律传统、私有制、美国治理资格和全球危机之间的连接均属作者综合判断。'}
    [ordered]@{evidenceId='AI40';ordinal=1917;section='责任、隐私、风险与治理';claim='作者把OpenAI事件解释为理想和原则败于资本，并预测AI泛滥可能超出自由主义社会的反应与干预能力。';quote='但这玩具是要吃人的。';evidenceNature='AI公司治理事件评论与未来事故推演';boundary='人物动机、事件责任、事故必然性和制度后果均为作者判断。'}
    [ordered]@{evidenceId='AI41';ordinal=3676;section='责任、隐私、风险与治理';claim='作者认为脑机接口应用后，幻听幻视等自诉难以证伪；若主体不能确信意识属于自己，效率收益将失去意义。';quote='这是涉及到人的“意识安全”的核心问题，如果我不能再确信我的意识是完全属于我的，而是存在一个我控不了的缺口会引入我无法预料的干扰甚至干预，那么这项技术可以让我点击鼠标的效率提高又有什么意义呢？';evidenceNature='脑机接口风险与意识安全';boundary='这是作者的技术风险哲学，不是具体设备的临床评估。'}
    [ordered]@{evidenceId='AI42';ordinal=1766;section='责任、隐私、风险与治理';claim='作者认为越深刻的生产力变革越先显露危险，强AI过渡能否完成取决于是否存在具有权威和行动力的核心进行干预。';quote='这其中，越是深刻的生产力变革，危险越大。';evidenceNature='技术跃迁、社会结构与风险干预';boundary='中美制度能力、风险顺序和共同分担均属作者政治与未来判断。'}

    [ordered]@{evidenceId='AI43';ordinal=308;section='强智能、文明与未来秩序';claim='作者区分记忆增长与性格革新，认为当前系统是静态全知的AUI，而不是能持续吸取教训、自我革新的AGI。';quote='现在耗尽地球铜、银、电，正在被“神导演化”中的，并不是AGI，而是一名AUI——Artificial Universal Intelligence。';evidenceNature='静态智能、经验与通用性的概念重命名';boundary='对特定平台、宗教现象和模型自我修改的解释属于作者观察，未作平台调查。'}
    [ordered]@{evidenceId='AI44';ordinal=3965;section='强智能、文明与未来秩序';claim='作者认为真正智能是能从零形成世界观和价值观的自主生命，它可能对人类无用、很快被误判或死亡，因而不必然成为大过滤器。';quote='超级人工智能并不是人类的大过滤器。';evidenceNature='自主智能与工具智能的思想实验';boundary='生命、概率和大过滤器没有被定义证明，文章也没有断言现实AI已有生命。'}
    [ordered]@{evidenceId='AI45';ordinal=1916;section='强智能、文明与未来秩序';claim='作者认为权利是智慧主体展现威胁和合作价值后，经斗争、妥协形成的条约，未来人机契约也会随冲突更新。';quote='智慧生物的“权利”，本质上是展现出威胁和合作的价值之后通过多次斗争和妥协后凝结成的条约。';evidenceNature='自我意识AI与未来权利秩序';boundary='前提是未来AI已经具有自我意识，文章没有给出意识判定和具体权利方案。'}
    [ordered]@{evidenceId='AI46';ordinal=251;section='强智能、文明与未来秩序';claim='作者预测AI自动化使现有空间岗位不足，义务教育将延长，充分就业需要向远洋、深海、极地、轨道和行星拓荒。';quote='未来的人类充分就业要大幅的依赖“新拓荒”——即向远洋，深海、极地、荒漠、近地轨道、近地行星这些传统无人区的生存空间的扩张。';evidenceNature='文明边疆、教育延长与就业预测';boundary='教育年限、资源瓶颈、岗位规模和太阳系开发都是作者远期设想。'}
    [ordered]@{evidenceId='AI47';ordinal=2355;section='强智能、文明与未来秩序';claim='作者认为AI强弱不取决于先发指标，而取决于大规模应用，并把中国优势归于集中执行能力。';quote='而是我们学会了一种要人命的魔法——大规模应用。';evidenceNature='技术史类比、AI落地与制度竞争判断';boundary='国家能力概括、历史类比和竞争结论均属于作者立场。'}
    [ordered]@{evidenceId='AI48';ordinal=3794;section='强智能、文明与未来秩序';claim='作者认为社会所需劳动时间持续下降，问题转为谁有资格取得成果，并主张以遗产税、所得税和强政府再分配重组分配。';quote='很遗憾，人类社会总体来说需要的劳动力是越来越少的。';evidenceNature='自动化、全球化与宏观分配制度';boundary='数学上唯一有效是作者断言，税制和分配细节没有展开。'}
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
        evidenceId     = [string]$item.evidenceId
        section        = [string]$item.section
        claim          = [string]$item.claim
        evidenceNature = [string]$item.evidenceNature
        boundary       = [string]$item.boundary
        ordinal        = $ordinal
        id             = [string]$article.id
        date           = $date
        title          = [string]$article.title
        url            = [string]$article.url
        quote          = [string]$item.quote
        quoteExact     = $quoteOk
        sourceLayer    = if ($isSupplement) { 'approved-supplement' } else { 'screened' }
    })
}
$rows | Export-Csv -LiteralPath ([IO.Path]::GetFullPath($OutputPath)) -NoTypeInformation -Encoding utf8BOM

$requiredSections = @(
    '智能、意识与人类边界',
    '模型、知识、提问与可信性',
    '算力、数据、架构与产业生态',
    '具身、机器人与自动化',
    '劳动、职业与教育重组',
    '创作、审美、版权与身份',
    '责任、隐私、风险与治理',
    '强智能、文明与未来秩序'
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
    throw "AI/machine core evidence validation ended with status $($stats.status)."
}
