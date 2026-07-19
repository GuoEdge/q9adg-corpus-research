param(
    [string]$CorpusPath = '.\sooon-q9adg-articles.jsonl',
    [string]$ScreeningPath = '.\research\data\technology_civilization_screening.csv',
    [string]$OutputPath = '.\research\data\technology_civilization_core_evidence.csv',
    [string]$StatsPath = '.\research\data\technology_civilization_core_evidence.stats.json'
)

$ErrorActionPreference = 'Stop'
$approvedSupplementOrdinals = @(80)

$items = @(
    [ordered]@{ evidenceId='T01'; ordinal=4025; section='可实现性与工程路线'; claim='作者认为芯片路线应先补足能把多道工序、材料、设备和人才组织起来的工业基础，不能在基础能力不足时直接追逐最高端目标。'; quote='在轮子都还造不圆的时代，要把钱和精力先放在学造轮子上，不能放在造火车上。'; evidenceNature='芯片工程路线与基础能力'; boundary='这是作者对芯片产业建设阶段的判断，不是对具体芯片工艺的外部技术鉴定。' }
    [ordered]@{ evidenceId='T02'; ordinal=3921; section='可实现性与工程路线'; claim='作者把复杂工业系统理解为误差纵向继承、横向交联的系统，工程师的任务是管理误差并使系统能够运行和自维护。'; quote='工程师就是误差的巫师。'; evidenceNature='工程误差、系统整合及其认识论延伸'; boundary='文章先提出作者的工程一般论，后把误差关系延伸到认识论；它不是工程学术语定义、技术标准或具体项目验收结果。' }
    [ordered]@{ evidenceId='T03'; ordinal=3589; section='可实现性与工程路线'; claim='作者认为技术物件只有在道路、维护和组织等配套条件形成后才真正获得社会技术身份，单独发明物件不等于完成技术革命。'; quote='能让载重马车跑起来不散架不翻车的路，才是高科技。'; evidenceNature='道路基础与技术落地'; boundary='本文讨论车轮与道路的历史性条件，不是对所有高科技产品的价值排名。' }
    [ordered]@{ evidenceId='T04'; ordinal=3247; section='可实现性与工程路线'; claim='作者把创新分成由复现、补全到探索未知的层级，并认为创新能力的起点是认识价值并进行成本收益核算。'; quote='是清楚的认知创新的价值、进行正确的成本收益核算。'; evidenceNature='创新层级与成本核算'; boundary='文章标明未完待续；成本收益核算只是作者所称培养创新能力的起点，不能当作完整创新方法论。原文列出L0至L5却自称五级，本文不替作者消解这一编号差异。' }
    [ordered]@{ evidenceId='T05'; ordinal=2188; section='可实现性与工程路线'; claim='作者认为不同需求会产生不同技术路线，路线的竞争与需求、资本、时间、市场和实践经验相连，并据此反对把技术突破恒定归于西方。'; quote='大家需求不同，很自然就有不同的技术路线、产生不同的实践经验，催生进一步的不同技术。'; evidenceNature='技术路线、市场条件与文明比较'; boundary='文章把技术差距放入市场和殖民历史解释；全球市场导致技术领先和文化积淀的因果关系均只按作者主张记录。' }
    [ordered]@{ evidenceId='T06'; ordinal=3254; section='可实现性与工程路线'; claim='作者反对以无规划的试错赌博替代创新系统，主张把大项目拆成具有中间价值、知识沉淀和可交易成果的多条路径。'; quote='绝大部分人是在赌博，并不是在创新。'; evidenceNature='创新治理与失败价值'; boundary='作者提出经规划的创新可以无风险、真正创新没有全然失败，这是其规范性定义和组织设想，不是对研发风险的实证证明；也不能据此把所有失败项目都称作赌博。' }

    [ordered]@{ evidenceId='T07'; ordinal=3926; section='工具、材料与基础设施'; claim='作者把5G解释为带宽、骨干网、传感、算力和产业应用共同变化的基础设施信号，而非单纯提高手机速度。'; quote='5G本质意义是一个明确的信号弹。'; evidenceNature='通信基础设施与产业触发'; boundary='这是作者对5G产业意义的预测性解释，不是通信标准的技术规范。' }
    [ordered]@{ evidenceId='T08'; ordinal=3056; section='工具、材料与基础设施'; claim='作者认为工业互联网的关键障碍在企业围绕供应商和信息标准形成封闭阵营，互联互通必须处理标准、利益和组织权力。'; quote='工业互联网有一个很大的关键，是行业内一些信息标准的拟定和推行会受到私营企业的抵抗。'; evidenceNature='工业互联网与标准协调'; boundary='文章讨论企业标准博弈和中国组织条件，不是对现实工业互联网覆盖率的统计。' }
    [ordered]@{ evidenceId='T09'; ordinal=2760; section='工具、材料与基础设施'; claim='作者以重型装备能否独立制造作为工业体系的物理证据，认为芯片是体系顶端的钻石而非全部工业基础。'; quote='一个国家只要能独立生产重型武器装备，尤其是飞机、核潜艇、坦克、洲际导弹这几大件，就足以证明它的工业体系不但存在，而且还很健全。'; evidenceNature='工业体系与装备基础'; boundary='这是作者的工业体系判断，涉及俄罗斯的历史和现实描述均按文本内主张记录。' }
    [ordered]@{ evidenceId='T10'; ordinal=883; section='工具、材料与基础设施'; claim='作者认为不同车型之间整块电池的通用性有限，换电站却可按外轮廓、重量和充电参数同时兼容多类电池，产品层有限通用与站点层宽兼容可以并存。'; quote='不同车型之间的通用性、互换性势必是有限的'; evidenceNature='电池通用层级与换电站兼容'; boundary='文章区分整块电池和换电站两个兼容层次，不能压成笼统的“电池标准应有限兼容”；它也不是新能源汽车行业标准的外部结论。' }
    [ordered]@{ evidenceId='T11'; ordinal=4016; section='技术治理、风险与公共目标'; claim='作者认为前沿基础研究越来越依赖少数国家或联盟控制的大型观测设施，并把互联网对权力、产权、隐私、伦理、信息自由和主权的挑战称为新的基础研究问题。'; quote='基础研究已经渐渐变成了一种特权，一种内部机密。'; evidenceNature='科研观测特权与互联网治理基础问题'; boundary='文章正文重心是互联网治理和知识权力；大型设施只是其问题入口，不是科研开放程度的测量。' }
    [ordered]@{ evidenceId='T12'; ordinal=3312; section='工具、材料与基础设施'; claim='作者把汉字基准字形视为所有电子产品都应低成本提供的公共文化基础设施，反对将其完全交给单个商家竞争。'; quote='汉字因为其特殊性，其基准字形资源是一个不可以交付给单独商家来通过所谓“市场竞争”来自由博弈决定的公共事业。'; evidenceNature='数字字体与公共文化基础'; boundary='这是作者对汉字字体治理的公共事业设想，不是现行字体政策说明。' }

    [ordered]@{ evidenceId='T13'; ordinal=3978; section='产业组织、所有权与商业化'; claim='作者主张以开放知识、公共晶圆厂、统一标准和国际合作组织化解芯片专利封锁，使可用技术成为全球生产力基础设施。'; quote='我们只需要做出可用的芯片来，送给全人类用。'; evidenceNature='开放芯片与知识产权秩序'; boundary='这是作者的产业和国际合作设想，不代表已经存在的联盟或商业模式。' }
    [ordered]@{ evidenceId='T14'; ordinal=2378; section='产业组织、所有权与商业化'; claim='作者要求中国企业从全球贸易的助手位置转为承担研发、营销和品牌风险的直接参与者，并吸收海外人才建立全球中心。'; quote='要开始尝试作为玩家'; evidenceNature='全球产业组织与品牌升级'; boundary='文章针对中国制造企业的战略建议，具体国际市场判断属于作者推演。' }
    [ordered]@{ evidenceId='T15'; ordinal=50; section='产业组织、所有权与商业化'; claim='作者认为AI降低数字化工程复制成本后，现实业务、作品、专利、土地、产线、人脉和信用等所有权资产构成企业持续经营的必要根基之一。'; quote='重要的始终是所有权本身'; evidenceNature='AI商业化与现实产权'; boundary='文章同时强调客户、营销、经营和社会化能力，不能把所有权资产写成企业持续的充分条件；本文也不把它改写成产权法定义。' }
    [ordered]@{ evidenceId='T16'; ordinal=3507; section='产业组织、所有权与商业化'; claim='作者认为先进制造业将带来研发、管理、维护和围绕新产线创业的职业与商业机会，制造业不是简单的低端就业场所。'; quote='智能制造前途非常光明。'; evidenceNature='智能制造与产业机会'; boundary='这是作者对产业前景和职业机会的预测，不是就业市场统计。' }
    [ordered]@{ evidenceId='T17'; ordinal=1815; section='产业组织、所有权与商业化'; claim='作者以家庭市场、汽车更新周期、可出口性以及上下游和维修保养附属产值，论证汽车可以成为房地产之后的支柱产业候选。'; quote='中国的汽车不是卖给中国人而已，是卖给全世界。'; evidenceNature='汽车产业、更新周期与全球市场'; boundary='文章中的八千万辆和十几万亿元属于作者基于假设的情景推算，不能从其他工业文章补入完整制造门类与研发体系，也不外推为实际市场份额。' }
    [ordered]@{ evidenceId='T18'; ordinal=863; section='产业组织、所有权与商业化'; claim='作者认为创新项目应选择绕不开的关键问题，并让专利、经验、数据、工具和方法在研发过程中形成可交易的阶段性价值。'; quote='真正的创新的风险是自赎的。'; evidenceNature='创新商业化与阶段价值'; boundary='这是作者对创新风险和价值回收的抽象表述，不是财务模型。' }

    [ordered]@{ evidenceId='T19'; ordinal=3482; section='技术、劳动与失业'; claim='作者设想AI普及后以公共算力、能源和终身学习研究津贴重建就业与分配，使算力成为新的铸币权和公共秩序核心。'; quote='谁拥有算力资源，谁就拥有了真正本质的铸币权'; evidenceNature='智能失业与公共算力设想'; boundary='这是作者对未来制度的设想，不是现行经济制度描述或已证实预测。' }
    [ordered]@{ evidenceId='T20'; ordinal=3724; section='技术、劳动与失业'; claim='作者判断传统低端产业正在因工艺升级和自动化而萎缩，工业总产值上升与产业链岗位下降可以同时发生。'; quote='中国真正的危机并不是工业总产值下降——因为根本没下降，也不会下降——而是尽管工业总产值在上升，但是产业链上的岗位数量在下降。'; evidenceNature='低端产业收缩与岗位减少'; boundary='这是作者对产业和就业关系的结构性判断，不由本研究作外部统计确认。' }
    [ordered]@{ evidenceId='T21'; ordinal=1817; section='技术、劳动与失业'; claim='作者认为其所划分的第三代自动化从特定工位的高自由度、实时感知和自主判断开始，才形成真正替代人类并产生利润的能力。'; quote='全自动生产线是真的可以替代人类的，而且还有利润。'; evidenceNature='第三代自动化节点与利润条件'; boundary='文章讨论作者划分的自动化代际和特定工位起点，不是对所有现有全自动生产线的实证评估。' }
    [ordered]@{ evidenceId='T22'; ordinal=3157; section='技术、劳动与失业'; claim='作者预测劳动密集型制造业整体收缩，最低端工业形态可能是机器人生产线，主要问题转向低文化水平人口的长期过剩。'; quote='未来最底端产业就是机器人生产线。'; evidenceNature='机器人制造与劳动力过剩'; boundary='这是作者对未来五十年的推演，不能改写成已经发生的就业事实。' }
    [ordered]@{ evidenceId='T23'; ordinal=2733; section='技术、劳动与失业'; claim='作者把高失业率的根本问题归因于没有创造足够就业机会，而不是年轻人拒绝劳动，并把宏伟事业与组织军队对外战争列作理论上的两条充分就业道路。'; quote='失业率高的真正问题在于创造不出足够的就业机会，不在于“年轻人摆烂”。'; evidenceNature='失业归因与充分就业道路'; boundary='两条道路是作者在论证中的区分，并非等价行动建议；相关政治经济因果只按文本内判断记录。' }
    [ordered]@{ evidenceId='T24'; ordinal=3727; section='技术、劳动与失业'; claim='作者认为工业软件替代和自主工业体系会提供产业窗口，但机会不自动属于现有程序员，进入工业软件等专业细分需要额外学习和能力转换。'; quote='工业软件，这才是中国制造业最大的短板！'; evidenceNature='工业软件窗口与职业转换'; boundary='文章讨论产业机会和个人能力转换，不能简化成人人都能从软件替代中受益；“行业知识和长期技术积累”不是原文逐项列出的并列公式。' }

    [ordered]@{ evidenceId='T25'; ordinal=812; section='AI、机器与智能边界'; claim='作者认为具身智能的瓶颈不在单个机器人展示动作，而在标准化硬件、操作系统、编舞器和编舞师组成的生态。'; quote='人形机器人现在其实有两个方向。'; evidenceNature='具身智能与生态分工'; boundary='这是文章对人形机器人路线的分类入口，具体技术判断属于作者文本内分析。' }
    [ordered]@{ evidenceId='T26'; ordinal=2336; section='AI、机器与智能边界'; claim='作者认为AI会使普遍技巧迅速低端化，人的核心价值转向思想和美学修养，而不是少数可复制技巧。'; quote='真正的问题是，你要意识到这个美学修养才是你的价值核心，不能再简单的依靠一点小技巧混饭吃罢了。'; evidenceNature='AI替代与人类价值边界'; boundary='“价值核心”是作者的人类学判断，不是本文或外部社会的价值裁决。' }
    [ordered]@{ evidenceId='T27'; ordinal=2333; section='AI、机器与智能边界'; claim='作者预期封闭大模型生态会受到主权与意识形态限制，开源AI、多层供应商和区域认知层将形成新的算力生态。'; quote='这就给“开源AI”留下了专属的生态位。'; evidenceNature='开源AI与区域生态'; boundary='这是作者对未来AI产业结构的预测，不是现状市场份额报告。' }
    [ordered]@{ evidenceId='T28'; ordinal=2293; section='AI、机器与智能边界'; claim='作者认为大模型生态存在原则性的可信性困难，可信AI应以可核查核心文献、公开信念和自由选择的小型服务组成。'; quote='实际上，我信任的是核心文献，而不是ai本身。'; evidenceNature='AI可信性与核心文献'; boundary='文章提出的是作者的知识与服务模型，不是AI安全标准或法律意见。' }
    [ordered]@{ evidenceId='T29'; ordinal=1174; section='AI、机器与智能边界'; claim='作者认为形式独特性本身并不稀缺，AI生成的新形式只有在人的价值信念、投入和历史记忆中才可能获得创新地位。'; quote='独特性本身并不稀缺'; evidenceNature='AI生成与创新资格'; boundary='这是作者对“创新”概念的内部区分，不是版权或艺术史裁判。' }
    [ordered]@{ evidenceId='T30'; ordinal=1901; section='AI、机器与智能边界'; claim='作者认为AI图像和视频生成的关键限制常来自用户无法形成可描述、可检验的意图，AI最终是创作工具而非创作本身。'; quote='ai终极只是创作的工具，不是创作本身。'; evidenceNature='AIGC工具性与创作者能力'; boundary='文章讨论创作流程和审美判断，不是对所有生成式AI产品性能的测评。' }

    [ordered]@{ evidenceId='T31'; ordinal=4; section='历史经验、记录与知识继承'; claim='作者把历史记录解释为经验主义的代际接口：记录形成数据，数据积累经验和智慧，智慧用于保存繁荣。'; quote='数据出经验，经验出智慧，智慧保繁荣。'; evidenceNature='记录、数据与经验传递'; boundary='这是作者对中国历史记录传统的解释，相关文明史判断按文本内叙述记录。' }
    [ordered]@{ evidenceId='T32'; ordinal=1265; section='历史经验、记录与知识继承'; claim='作者要求家族史记录同时保证采集质量、叙事连续、事实核实和多地长期保存，使家族经验能够被后代调用。'; quote='采访要留出足够多的时间——不是几个小时，而是几天，甚至几周时间。'; evidenceNature='家族档案与长期保存'; boundary='文章是家族史记录方法建议，不是档案学规范的完整替代。' }
    [ordered]@{ evidenceId='T33'; ordinal=3894; section='历史经验、记录与知识继承'; claim='作者认为世界史教育提供跨文明交流的上下文和史才训练，教育应教鉴定材料、保留怀疑和交叉观察的方法。'; quote='一个人所掌握的世界史的版本决定了这个人的“交流频宽”'; evidenceNature='世界史与文明沟通能力'; boundary='这是作者对历史教育功能的判断，不是对课程效果的外部评估。' }
    [ordered]@{ evidenceId='T34'; ordinal=837; section='历史经验、记录与知识继承'; claim='作者把中国前三十年工业化的关键成果定义为大量劳动者获得按图纸、标准、技术员和工友组织生产的经验，并把中国道路概括为生产关系和人的工业化超前于生产资料的充分成熟。'; quote='前三十年工业化最大的成就是造就了一整个受到了工业文化洗礼的工人阶级。'; evidenceNature='中国工业经验与人的继承'; boundary='“人的工业化超前”是作者对中国工业化特殊道路的概括，不是所有国家的普遍先后规律，也不是社会史统计结论。' }
    [ordered]@{ evidenceId='T35'; ordinal=3128; section='历史经验、记录与知识继承'; claim='作者认为中低端工业化是原理性研究落地的基础，所谓人才流失部分来自产业和学术岗位结构转型，而非单纯人才短缺。'; quote='没有技术上的基础条件，没有补足工业化的课'; evidenceNature='工业基础与人才流动'; boundary='引文是作者因果链的连续片段，人才流动和产业史判断不作外部核验。' }
    [ordered]@{ evidenceId='T36'; ordinal=80; section='历史经验、记录与知识继承'; claim='作者认为机构继承不能停留在模仿创始人风格，应把个人遗产转化为地点、主张或流派资产，供后来者继续使用。'; quote='一个大所不能被限定在一个小圈子里，搞成一个活生生的古墓派。'; evidenceNature='机构遗产与集体继承'; boundary='本篇是经原文复核批准的筛选层补录，讨论建筑事务所继承，不是一般企业继承法。' }

    [ordered]@{ evidenceId='T37'; ordinal=27; section='文明保存、能源与环境'; claim='作者把传统手艺和纯手工能力比作原始种，认为它们即使暂时退出市场，也应以最低资源保存为文明重新生长保留能力。'; quote='是我们整个技术文明的原始胚芽。'; evidenceNature='手工技艺与文明可再生能力'; boundary='这是作者的文明保存比喻，不是要求传统技艺重新成为主流生产方式。' }
    [ordered]@{ evidenceId='T38'; ordinal=4038; section='文明保存、能源与环境'; claim='作者认为可控核聚变解除能源约束后会放大放热、消费和国家竞争风险，必须先有超越现有气候协议的全球管制。'; quote='热也可以是一种污染。'; evidenceNature='聚变能源与热污染风险'; boundary='这是作者的未来风险设想，不是聚变工程或气候科学的外部结论。' }
    [ordered]@{ evidenceId='T39'; ordinal=3038; section='文明保存、能源与环境'; claim='作者把煤电、核电和绿电放入能源基础设施、技术标准、制造能力和长期秩序的竞争中，强调国内应用市场会反过来形成技术竞争力。'; quote='核电其实是比高铁更强大的一体化工具'; evidenceNature='能源基础设施与技术秩序'; boundary='文章包含作者对国际能源市场和地缘关系的推演，不能改写成现实政策结论。' }
    [ordered]@{ evidenceId='T40'; ordinal=3180; section='文明保存、能源与环境'; claim='作者认为气候异常时代的治理目标应从防灾和抗灾扩展到容灾，提高灾害发生后的限制、缓冲和恢复能力。'; quote='不但要加强防灾力、抗灾力，还要增强容灾率。'; evidenceNature='气候风险与容灾能力'; boundary='这是作者的灾害治理框架，不是对具体气候趋势或应急资源的评估。' }
    [ordered]@{ evidenceId='T41'; ordinal=3125; section='文明保存、能源与环境'; claim='作者设想未来农业将并入能源、交通和工业条件更优的集约系统，同时要求把土地转向有层次、有弹性的生态系统以增加文明容错。'; quote='让生态圈增厚，把更多的资源交到这位教师手里'; evidenceNature='农业工业化与生态容错'; boundary='文章是作者对农村和农业未来的长期设想，不是农业技术路线图。' }
    [ordered]@{ evidenceId='T42'; ordinal=3584; section='文明保存、能源与环境'; claim='作者认为传染病高发期需要公共卫生制度、自我治理和国际合作，事后医疗技术不能替代社会层面的预防和治理。'; quote='真正的应对，不是依靠医疗技术的事后抵抗，而只能依靠强有力的公共卫生制度'; evidenceNature='技术能力与公共卫生治理'; boundary='文章属于作者对未来传染病风险的判断，不是医学诊疗意见。' }

    [ordered]@{ evidenceId='T43'; ordinal=3677; section='技术治理、风险与公共目标'; claim='作者认为大型产业政策必须容纳失败和受控竞争，不能因试错成本就把早期执行者简单定罪，计划经济也可以设计多机构竞争。'; quote='计划经济完全可以计划竞争。'; evidenceNature='产业政策与受控竞争'; boundary='这是作者对产业政策和试错责任的制度设想，不是对具体项目责任的法律判定。' }
    [ordered]@{ evidenceId='T44'; ordinal=2453; section='技术治理、风险与公共目标'; claim='作者认为复杂建模工具只有嵌入设计、审查和责任流程才会真正落地，审查者无法理解模型时会通过冗余和保守标准压低创新风险。'; quote='问题是，你的图算不出问题就没问题？'; evidenceNature='BIM审查与技术治理'; boundary='这是作者对建筑信息模型落地条件的分析，不是建筑规范或事故责任意见。' }
    [ordered]@{ evidenceId='T45'; ordinal=2587; section='工具、材料与基础设施'; claim='作者认为重大工程必须在和平假设失效后重新估算防护、运输、保险和保安成本，技术基础设施的可靠性需要重新定价。'; quote='和平假设被打破了。'; evidenceNature='基础设施安全与风险定价'; boundary='文章讨论地缘风险情境下的基础设施设想，并可跨层用于风险治理；它不是对具体事件责任或安全等级的认定。' }
    [ordered]@{ evidenceId='T46'; ordinal=1639; section='技术治理、风险与公共目标'; claim='作者认为现代信息技术和管理已使百万级组织的有效监管成为可能，旧有“基层不会被监管”的经验正在失效。'; quote='现代信息技术，有效监管百万人规模的组织'; evidenceNature='信息技术与组织监管'; boundary='这是作者对监管能力变化的判断，不是对现实行政腐败程度的统计分析。' }
    [ordered]@{ evidenceId='T47'; ordinal=3714; section='技术治理、风险与公共目标'; claim='作者区分技术可能性与围绕技术的设想、开发、传播、应用和管制行为，认为后者都负有价值与后果责任。'; quote='技术本身是价值中立的，但是围绕着技术的行为——从设想技术，到开发技术、到传播技术、应用技术、管制技术等等等等——没有一个是所谓中立的。'; evidenceNature='技术中立、传播与先见责任'; boundary='文章把责任高度集中于最先看见危险可能性的人，却没有给出风险阈值和制度化分责程序；本文只重建这一作者判断。' }
    [ordered]@{ evidenceId='T48'; ordinal=3733; section='技术治理、风险与公共目标'; claim='作者拒绝在大众媒体把大规模伤害技术当作好奇或智力竞赛公开讨论，认为工具中立不能免除传播者对使用后果的责任。'; quote='技术/工具无罪论是一种可怕的天真——如果不是一种邪恶的话。'; evidenceNature='伤害性知识的公开传播边界'; boundary='文章设置的是大众传播底线，不等于停止全部研究，也没有完整讨论受控实验、专业审查和防御性知识的区分。' }
)

$corpus = [Collections.Generic.List[object]]::new()
foreach ($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($CorpusPath))) { if (-not [string]::IsNullOrWhiteSpace($line)) { $corpus.Add(($line | ConvertFrom-Json)) } }
if ($corpus.Count -ne 4050) { throw "Expected 4050 corpus articles, found $($corpus.Count)." }
$screenedIds = @{}; foreach ($row in Import-Csv -LiteralPath ([IO.Path]::GetFullPath($ScreeningPath))) { $screenedIds[[string]$row.id] = $true }
$rows = [Collections.Generic.List[object]]::new()
foreach ($item in $items) {
    $ordinal=[int]$item.ordinal
    if ($ordinal -lt 1 -or $ordinal -gt $corpus.Count) { throw "[$($item.evidenceId)] Ordinal outside corpus: $ordinal" }
    $article=$corpus[$ordinal-1]; $isScreened=$screenedIds.ContainsKey([string]$article.id); $isSupplement=$approvedSupplementOrdinals -contains $ordinal
    if (-not $isScreened -and -not $isSupplement) { throw "[$($item.evidenceId)] Article neither screened nor approved supplement." }
    if ($isScreened -and $isSupplement) { throw "[$($item.evidenceId)] Supplement unexpectedly screened." }
    $quoteOk=([string]$article.text).Contains([string]$item.quote,[StringComparison]::Ordinal)
    if (-not $quoteOk) { throw "[$($item.evidenceId)] Exact quote validation failed: $($item.quote)" }
    $date=[DateTimeOffset]::FromUnixTimeMilliseconds([int64]$article.publishedAt).ToOffset([TimeSpan]::FromHours(8)).ToString('yyyy-MM-dd')
    $rows.Add([pscustomobject][ordered]@{ evidenceId=$item.evidenceId; section=$item.section; claim=$item.claim; evidenceNature=$item.evidenceNature; boundary=$item.boundary; ordinal=$ordinal; id=[string]$article.id; date=$date; title=[string]$article.title; url=[string]$article.url; quote=$item.quote; quoteExact=$quoteOk; sourceLayer=if($isScreened){'screened'}else{'approved-supplement'} })
}
$requiredSections=@('可实现性与工程路线','工具、材料与基础设施','产业组织、所有权与商业化','技术、劳动与失业','AI、机器与智能边界','历史经验、记录与知识继承','文明保存、能源与环境','技术治理、风险与公共目标')
$sectionCounts=[ordered]@{}; foreach($s in $requiredSections){$sectionCounts[$s]=@($rows|Where-Object section -eq $s).Count}
$uniqueEvidenceIds=@($rows.evidenceId|Sort-Object -Unique).Count; $uniqueArticleIds=@($rows.id|Sort-Object -Unique).Count; $uniqueOrdinals=@($rows.ordinal|Sort-Object -Unique).Count
$missingCoreFields=@($rows|Where-Object{[string]::IsNullOrWhiteSpace($_.claim)-or[string]::IsNullOrWhiteSpace($_.evidenceNature)-or[string]::IsNullOrWhiteSpace($_.boundary)-or[string]::IsNullOrWhiteSpace($_.quote)}).Count
$exactQuoteFailures=@($rows|Where-Object quoteExact -eq $false).Count; $allSectionsCovered=@($requiredSections|Where-Object{$sectionCounts[$_] -ne 6}).Count -eq 0
$screenedEvidenceRows=@($rows|Where-Object sourceLayer -eq 'screened').Count; $supplementRows=@($rows|Where-Object sourceLayer -eq 'approved-supplement'); $supplementOrdinals=@($supplementRows.ordinal|Sort-Object); $supplementSetMatches=@(Compare-Object -ReferenceObject @($approvedSupplementOrdinals|Sort-Object) -DifferenceObject $supplementOrdinals).Count -eq 0
$rows|Export-Csv -LiteralPath ([IO.Path]::GetFullPath($OutputPath)) -NoTypeInformation -Encoding utf8BOM
$status=if($rows.Count-eq48-and$uniqueEvidenceIds-eq48-and$uniqueArticleIds-eq48-and$uniqueOrdinals-eq48-and$screenedEvidenceRows-eq47-and$supplementRows.Count-eq1-and$supplementSetMatches-and$missingCoreFields-eq0-and$exactQuoteFailures-eq0-and$allSectionsCovered){'PASS'}else{'REVIEW'}
$stats=[ordered]@{ corpusArticles=$corpus.Count; screenedCandidates=$screenedIds.Count; evidenceRows=$rows.Count; uniqueEvidenceIds=$uniqueEvidenceIds; uniqueArticleIds=$uniqueArticleIds; uniqueOrdinals=$uniqueOrdinals; screenedEvidenceRows=$screenedEvidenceRows; directReviewSupplements=$supplementRows.Count; supplementOrdinals=$supplementOrdinals; missingCoreFields=$missingCoreFields; exactQuoteFailures=$exactQuoteFailures; sectionCounts=$sectionCounts; status=$status }
$stats|ConvertTo-Json -Depth 5|Set-Content -LiteralPath ([IO.Path]::GetFullPath($StatsPath)) -Encoding utf8; $stats|ConvertTo-Json -Depth 5
if($status-ne'PASS'){throw "Technology civilization core evidence validation ended with status $status."}
