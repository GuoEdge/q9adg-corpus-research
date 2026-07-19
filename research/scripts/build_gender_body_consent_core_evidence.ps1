param(
    [string]$CorpusPath = '.\sooon-q9adg-articles.jsonl',
    [string]$ScreeningPath = '.\research\data\gender_body_consent_screening.csv',
    [string]$OutputPath = '.\research\data\gender_body_consent_core_evidence.csv',
    [string]$StatsPath = '.\research\data\gender_body_consent_core_evidence.stats.json'
)

$ErrorActionPreference = 'Stop'

$items = @(
    [ordered]@{ evidenceId='G01'; ordinal=4021; section='性别概念、角色与权力'; claim='作者区分公共领域的对等平权与私权领域的自由主张，认为女权是女性平等使用普遍权利，而非女性独享的特殊权利。'; quote='平权在私权领域，则根本不以追求“对等”为特征，而是以“各凭条件做最大的主张”为基本样式。'; evidenceNature='公域平权与私域竞争的概念区分'; boundary='这是作者对平权和私权的定义，不是现行权利制度或法律边界说明。' }
    [ordered]@{ evidenceId='G02'; ordinal=3248; section='性别概念、角色与权力'; claim='作者把女权崛起连接到现代国家动员全部人口的竞争需要，并把平权界定为制度不在群体博弈中预先偏向任何一方。'; quote='平权的本质，是指制度将不再在群体博弈之间偏向于任何一方，仅此而已。'; evidenceNature='女权历史成因与制度平权'; boundary='文章对女权与女权主义作出作者自己的概念划分，相关国家竞争史只按文本内解释记录。' }
    [ordered]@{ evidenceId='G03'; ordinal=1392; section='性别概念、角色与权力'; claim='作者断言女权在历史趋势上必胜，理由涉及女性在生育、生产、总体动员和国家稳定中的位置及其独立生存能力。'; quote='历史的看，女权是必胜的，“反女权”的路根本行不通。'; evidenceNature='女权历史趋势与国家动员'; boundary='这是作者的历史与政治预测，不由本研究确认其外部必然性。' }
    [ordered]@{ evidenceId='G04'; ordinal=3142; section='性别概念、角色与权力'; claim='作者把大男子主义的核心解释为成为弱者所崇拜的典狱长，并认为现代社会已失去传统夫权赖以运行的现实监禁结构。'; quote='大男子主义是一种自我神化和崇拜渴望。'; evidenceNature='传统夫权与现代关系位置'; boundary='文章批评特定大男子主义结构，不等于否定男性自信、承担或全部传统性别表达。' }
    [ordered]@{ evidenceId='G05'; ordinal=3081; section='性别概念、角色与权力'; claim='作者认为女性面对暴力、骚扰、家庭惩罚、职场歧视和举证成本时处于与男性不同的风险世界，并要求理解这种不安全感。'; quote='男性是真的很难理解女性的不安全感。'; evidenceNature='性别化风险经验与独立能力'; boundary='这是作者对女性风险处境的概括，不是风险发生率的外部统计。' }
    [ordered]@{ evidenceId='G06'; ordinal=3509; section='性别概念、角色与权力'; claim='作者认为女权运动不能只靠拒绝和否定积累力量，还需要说明肯定性目标并形成共同纲领和内部规范。'; quote='你不能单纯的通过“破”来替代“立”。'; evidenceNature='女权运动的肯定性目标'; boundary='文章以未完待续结束，没有给出其所说新规范的完整内容。' }

    [ordered]@{ evidenceId='G07'; ordinal=3451; section='身体、外貌与身体自主'; claim='作者把用身体换未来重新定义为所有劳动和生命投入，反对把女性身体窄化为性器官或性交易资源。'; quote='有什么未来不是用身体换的？'; evidenceNature='身体劳动与性别污名'; boundary='文章使用宽义身体概念，不表示作者支持任何具体身体交易。' }
    [ordered]@{ evidenceId='G08'; ordinal=1499; section='身体、外貌与身体自主'; claim='作者反对把人拆成可消费器官的组合，认为局部凝视会使被观察者感到自己被切割和物化。'; quote='人不是器官的组合，不是一种嵌入了可食用部分的经济作物。'; evidenceNature='整体身体与局部凝视'; boundary='文章处理凝视和物化感受，不是对所有视线行为的法律定性。' }
    [ordered]@{ evidenceId='G09'; ordinal=3843; section='身体、外貌与身体自主'; claim='作者把外貌和时尚理解为经过编码的身份表达，要求先回答自我定位、表达边界和受众识别，再处理视觉搭配。'; quote='记住，你的外貌应该是一道编过码的半透膜——识得的人，就是值得的人；不值得的人，就识不得。'; evidenceNature='外貌编码、身份与关系筛选'; boundary='这是作者的时尚与人格表达模型，不是普遍审美标准。' }
    [ordered]@{ evidenceId='G10'; ordinal=1188; section='身体、外貌与身体自主'; claim='作者认为女性认可的颜值更多依赖审美逻辑、技艺和道德感受，而不是无需解释的直觉吸引。'; quote='那是功夫，是能力，是智慧和艺术，不是简单的“好看”。'; evidenceNature='性别化审美方法与外貌技艺'; boundary='文章对男女审美作出概括性区分，本文不把它外推为所有人的固定性别本质。' }
    [ordered]@{ evidenceId='G11'; ordinal=874; section='身体、外貌与身体自主'; claim='作者把化妆解释为使人化身为被理想他者爱着的自我，从而取得信心、勇气和宁静，而非单纯取悦现实男性。'; quote='化妆带来的快感，并不是“修饰面容”“突出优点”这么浅薄，它是在化身为一个“理想的自我”。'; evidenceNature='化妆、理想自我与信仰体验'; boundary='这是作者对化妆精神动力的解释，不排除其他现实动机。' }
    [ordered]@{ evidenceId='G12'; ordinal=15; section='身体、外貌与身体自主'; claim='作者要求看到女性穿高跟和全妆赴约可能承担的身体不适，并以怜惜回应付出，而不是只评价外貌。'; quote='如果你的感受是“很好看，但是好心疼”，那么以后估计是她听你的。'; evidenceNature='身体成本、打扮与关系回应'; boundary='文章把具体打扮作为关系试探情境，不表示所有高跟或化妆都为特定对象牺牲。' }

    [ordered]@{ evidenceId='G13'; ordinal=121; section='欲望、性行为与性取向'; claim='作者区分性的重要性这一价值判断与性是否属于所有人生存刚需这一事实判断，并否认后者。'; quote='但“性重不重要”是一个价值判断，“性是不是刚需”却是一个事实判断。'; evidenceNature='性的重要性与刚需概念区分'; boundary='这是作者对性需求的事实判断，本研究不作医学或心理学验证。' }
    [ordered]@{ evidenceId='G14'; ordinal=2208; section='欲望、性行为与性取向'; claim='作者反对把没有性生活自动病理化，认为性欲可以被克服，人的独立人格比满足欲望更值得担忧。'; quote='没有性应该引起的焦虑，远不及没有人格该造成的焦虑强。'; evidenceNature='性压抑、欲望控制与人格'; boundary='文章借传统宗教和古代社会说明禁欲可能性，不是临床诊断意见。' }
    [ordered]@{ evidenceId='G15'; ordinal=3881; section='欲望、性行为与性取向'; claim='作者反对把性感道德化为罪，并把勇气、理想、修养和磨砺后的表达也纳入性感，要求系统的性文化教育。'; quote='没有性自卑的人，才能健康的看待别人的性感。'; evidenceNature='性感、性羞耻与性文化'; boundary='这是作者的性文化判断，不是对具体展示尺度的统一规范。' }
    [ordered]@{ evidenceId='G16'; ordinal=3945; section='欲望、性行为与性取向'; claim='作者用是否出于爱作为同性关系行为的条件性判断入口，同时把证明责任交还给自称出于爱的人。'; quote='你是出于爱，什么都不是罪。'; evidenceNature='同性关系与爱的条件判断'; boundary='短文没有继续说明爱是否还必须包含同意、不伤害、忠诚或其他条件，不能扩展成完整同性伦理。' }
    [ordered]@{ evidenceId='G17'; ordinal=3370; section='欲望、性行为与性取向'; claim='作者把性关系的最低心理条件放在对风险和不可交换性的清醒接受，并反对以安全幻觉和利益预期进入性行为。'; quote='爱虽然温柔到极点，但任何一丁点都是绝对的英勇行为，它只可能发生在两个无畏的人之间。'; evidenceNature='性风险、侥幸与行动条件'; boundary='文章是作者的性伦理与风险判断，不是医疗风险评估或法律同意标准。' }
    [ordered]@{ evidenceId='G18'; ordinal=498; section='欲望、性行为与性取向'; claim='作者反对把拥有大量性伴侣设为社会应保障的竞争标准，认为所谓性资源丰富与婚配、生育和人口流动结构相冲突。'; quote='这种事，自己不要执着，随缘随缘，别整天纠结焦虑，甚至搞起“社会控诉”来。'; evidenceNature='性稀缺、竞争标准与人口结构'; boundary='这是作者的社会与人口解释，不是性机会分布的外部统计。' }

    [ordered]@{ evidenceId='G19'; ordinal=4029; section='同意、边界与性暴力'; claim='作者以身体和繁殖条件解释某些动物中的雌性选择能力，同时限制强奸概念只能用于存在可被强迫意志和控制关系的情境。'; quote='因为基本上动物中的“女权”是天然成立的。'; evidenceNature='雌性选择、控制与强奸概念边界'; boundary='这是动物行为与人类概念的类比，文章本身承认部分定性有争议，不能直接转为人类法律判断。' }
    [ordered]@{ evidenceId='G20'; ordinal=435; section='同意、边界与性暴力'; claim='作者认为问题不在于性欲本身，而在于未经主动许可便以不在乎后果的方式公然提出性要求。'; quote='问题不出在对方有没有这个欲念，而在于对方敢于在你没有主动给许可之前就公然流露。'; evidenceNature='性欲表达、主动许可与轻佻伤害'; boundary='文章同时讨论文化信号和潜意识影响，但不能用成因解释取消行为者对表达方式的责任。' }
    [ordered]@{ evidenceId='G21'; ordinal=2256; section='同意、边界与性暴力'; claim='作者区分关系中的伤害承认与法律上的有罪认定，认为公共标准应由中立司法裁决，当事人不应自行宣布绝对无罪。'; quote='你自己要站一个“我不确定我有没有罪”的立场，而不是一个不等法庭裁定就自行宣布地“我绝对没罪”的立场。'; evidenceNature='性骚扰评价、关系伦理与司法位置'; boundary='这是作者的程序与关系策略，不是性骚扰法律标准说明。' }
    [ordered]@{ evidenceId='G22'; ordinal=3522; section='同意、边界与性暴力'; claim='作者承认题述行为可能含性骚扰成分，却反对把性质、情节和人的整体价值合成无污点的道德总判决。'; quote='这话严格说的确有性骚扰的可能成分'; evidenceNature='性骚扰情节与道德主义'; boundary='文章反对道德总判决，不等于否认性骚扰成分或取消具体责任。' }
    [ordered]@{ evidenceId='G23'; ordinal=1976; section='同意、边界与性暴力'; claim='作者建议性骚扰处置先固定证据，再用可测且可逆的赔偿和有律师参与的谅解协议减少后患。'; quote='固定证据。'; evidenceNature='骚扰后的证据、赔偿与协议'; boundary='这是作者提出的私下处置路径，不是本研究的法律建议，也不代表所有案件都适宜和解。' }
    [ordered]@{ evidenceId='G24'; ordinal=2754; section='同意、边界与性暴力'; claim='作者区分青春期性向往与侵犯性、粗暴、公开的性语言，并主张首次教育、重复行为留痕和监护介入。'; quote='但是有了性向往，用这种侵犯和粗暴的语言来表达，这是不正当的。'; evidenceNature='未成年人性表达、教育与骚扰记录'; boundary='文章针对未成年人情境，不能直接扩展为所有成人骚扰的统一处置程序。' }

    [ordered]@{ evidenceId='G25'; ordinal=28; section='性知识、教育与健康'; claim='作者要求父母提供生理、避孕、性病、隐私和性权利知识，同时管理自己的焦虑，不把教育转成窥探和审讯。'; quote='然后相信ta们会善用这些知识保护好自己。'; evidenceNature='亲子性教育、隐私与自主'; boundary='文章是家庭教育原则，不是完整的性健康课程或医学指南。' }
    [ordered]@{ evidenceId='G26'; ordinal=1482; section='性知识、教育与健康'; claim='作者认为家长与子女谈性需要先取得关系资格和克制嫌恶的素养，否则只能单向提供材料，不能强迫子女敞开。'; quote='所谓资格，是指你的子女对跟你聊这个没有抵触和焦虑。'; evidenceNature='性教育者的关系资格'; boundary='文章讨论家长资格，不表示子女没有其他教育与求助渠道。' }
    [ordered]@{ evidenceId='G27'; ordinal=3172; section='性知识、教育与健康'; claim='作者把性教育的成效放在行为改变和继续传递，而不把一次性覆盖率或体制评分当作唯一尺度。'; quote='教育的根本是改变人的行为，而不是改变人在“体制”中的评分。'; evidenceNature='性教育的行为与传递尺度'; boundary='文章用一般教育理论回应性教育普及问题，不提供具体课程内容。' }
    [ordered]@{ evidenceId='G28'; ordinal=1946; section='性知识、教育与健康'; claim='作者反对把HIV感染者视为洪水猛兽，认为直接询问和关系中的风险沟通比污名化更可取。'; quote='不要把人家看成洪水猛兽。'; evidenceNature='HIV、风险沟通与去污名判断'; boundary='这是作者对感染者关系行为的概括，不是传染概率、诊疗或母婴阻断意见。' }
    [ordered]@{ evidenceId='G29'; ordinal=737; section='性知识、教育与健康'; claim='作者设想以逐条录像告知和事前免责处理婚检信息披露风险，并提醒无报警不等于安全保障。'; quote='婚检无报警不代表任何安全保障'; evidenceNature='婚检告知、同意与信息风险'; boundary='文章没有证明该免责安排在现实法律和医疗伦理上有效，本文只记录作者设想。' }
    [ordered]@{ evidenceId='G30'; ordinal=831; section='性知识、教育与健康'; claim='作者把性行为写成与生命后果相连的风险决定，要求进入关系前具有不会伤害对方的信念和承担错误后果的决心。'; quote='没有这“她不会害我”的把握和这个“错了我认了”的决心就不要开口。'; evidenceNature='性风险、信任与承担'; boundary='文章的性别化语言和风险判断属于作者立场，不是医学、刑法或有效同意的完整标准。' }

    [ordered]@{ evidenceId='G31'; ordinal=2987; section='生育、妊娠与生殖选择'; claim='作者反对用男性可能参战证明男性天然应有更多权利，并把历史孕产风险视为女性被低估的广泛牺牲。'; quote='实话实说，综合来看，从古算到今，做女人和当兵，谁风险更大还难讲得很。'; evidenceNature='孕产风险、战争风险与性别权利'; boundary='文章中的历史伤亡比较属于作者估计，本研究不作人口史或医学统计确认。' }
    [ordered]@{ evidenceId='G32'; ordinal=1474; section='生育、妊娠与生殖选择'; claim='作者把生育期痛苦放入婚姻保障和女性对未来坠落的恐惧中，认为伴侣的感应、照顾和响应构成关键心理支撑。'; quote='她在这段期间，唯一能抵抗对未知的恐怖想象的依靠就是你，你懂不懂？'; evidenceNature='生育风险、婚姻保障与情绪支持'; boundary='文章对传统宗族和现代婚姻保障的比较属于作者解释，不是产后抑郁的临床病因模型。' }
    [ordered]@{ evidenceId='G33'; ordinal=2342; section='生育、妊娠与生殖选择'; claim='作者把产后泌乳视为必须面对的身体事实，并把争论具体化为直接哺乳、挤奶及乳汁处理方式。'; quote='你们的争论本质上仅仅只是让婴儿直接吮吸，还是用挤奶器'; evidenceNature='产后泌乳与喂养方式'; boundary='文章没有充分裁决伴侣关系中的命令和同意问题，也不能替代哺乳医学建议。' }
    [ordered]@{ evidenceId='G34'; ordinal=1071; section='生育、妊娠与生殖选择'; claim='作者认为妊娠中的生育决定由女性单方面作出，而孩子出生后生物学父亲身份和抚养责任不能用事后声明取消。'; quote='女性对受孕胚胎的生育权是专断的，不受男方的干预。'; evidenceNature='妊娠决定权与出生后父职'; boundary='这是作者对其所理解法律框架的判断，不是现行法的权威解释。' }
    [ordered]@{ evidenceId='G35'; ordinal=3096; section='生育、妊娠与生殖选择'; claim='作者用宗教文本内部前提追问反避孕立场的责任边界，认为人口扩张后果无法保证时，避孕可能是人类的活路。'; quote='给人类避孕套，而不是给人类核末日。'; evidenceNature='避孕、宗教命令与后果责任'; boundary='这是作者的宗教文本内反驳，不是避孕医学指南或对全部宗教立场的概括。' }
    [ordered]@{ evidenceId='G36'; ordinal=3712; section='生育、妊娠与生殖选择'; claim='作者反对父母用英明理由给生育加冕，认为生育常由偶然、本能、压力和具体时机形成，重点是善待已经出生的子女。'; quote='生育子女，并没有什么理由，而只有当时机缘巧合原因。'; evidenceNature='生育理由、偶然与对子女的债务'; boundary='文章不是说所有生育都无行动原因，而是取消父母借理由向子女索取的正当化。' }

    [ordered]@{ evidenceId='G37'; ordinal=3596; section='性别化照料与家庭劳动'; claim='作者允许全职太太作为条件性选择，却要求其不是保姆替代物，仍保有事业、专业、社会接触和人格发展。'; quote='全职太太可以做，但是不是那种“保姆/清洁工综合替代物”。'; evidenceNature='全职太太、财富条件与人格发展'; boundary='文章把这一安排限定在少数富有且尊重人格的家庭，不把它当作女性普遍道路。' }
    [ordered]@{ evidenceId='G38'; ordinal=3541; section='性别化照料与家庭劳动'; claim='作者区分因从容选择和因不信任他人而亲自带娃，认为相同行为的动机会改变其对子女的长期影响。'; quote='动机是一种魔法。'; evidenceNature='全职照料的动机与教育影响'; boundary='文章中心是父母照料和教育授权，不只针对女性，也不能据此判断所有全职照料。' }
    [ordered]@{ evidenceId='G39'; ordinal=732; section='性别化照料与家庭劳动'; claim='作者认为真正值得企业调整制度的妈妈岗更可能服务于难以替代的中高级女性人才，而低端杂务反而依赖固定出勤。'; quote='妈妈岗更可能是财务总监、大客户经理、咨询顾问这一类的中高级职位。'; evidenceNature='生育、弹性工作与人才保留'; boundary='这是作者对企业交换成本和岗位适配的判断，不是就业政策或职场统计。' }
    [ordered]@{ evidenceId='G40'; ordinal=3221; section='性别化照料与家庭劳动'; claim='作者认为离婚后抚养义务在实践中可被隐瞒收入、制造失业、转移财产和拖延执行削弱，从而把照料成本压给一方。'; quote='不愿再承担抚养义务的人在事实上是有大量的手段逃脱离婚后的抚养义务的。'; evidenceNature='离婚抚养、执行成本与照料负担'; boundary='文章对判决和执行效果的描述按作者事实判断记录，不是法律建议或普遍案件结论。' }
    [ordered]@{ evidenceId='G41'; ordinal=99; section='性别化照料与家庭劳动'; claim='作者反对把孩子和家庭正常支出记成妻子对丈夫的情感债务，并要求以多次记录、询问和改良判断婚姻冷漠。'; quote='重大关系有一个简单的原则——孤证不立。'; evidenceNature='婚姻支出、照料与孤证不立'; boundary='文章处理具体婚姻账户，不能扩展为所有经济付出都不需要被承认。' }
    [ordered]@{ evidenceId='G42'; ordinal=3023; section='性别化照料与家庭劳动'; claim='作者把女性对成熟男性的期待解释为寻找经现实验证、能够承担家庭责任的人，同时承认年轻男性不可能跳过成长阶段。'; quote='所以，我们说人的幼稚总是绝对的，成熟只是相对的。'; evidenceNature='男性成熟、家庭承担与阶段差'; boundary='这是作者对一种女性择偶标准的解释，不是所有女性或男性的固定心理模型。' }

    [ordered]@{ evidenceId='G43'; ordinal=543; section='尊严、保护与文化信号'; claim='作者把物化界定为不再把对方视为平等的人，并将色情行业中的物化连接到违法、污名、债务和救济缺失。'; quote='意思是不再把对方看成人类，而是某种低人一等的事物，可以像对待签字、扳手、电吹风一样随便处理。'; evidenceNature='物化、性行业与社会支持'; boundary='文章不认为从事表演或性相关职业本身自动构成物化，关键在拒绝权和社会救济。' }
    [ordered]@{ evidenceId='G44'; ordinal=1703; section='尊严、保护与文化信号'; claim='作者认为缺少事后实锤不能证明事前戒备纯属幻想，并把男性凝视解释为可能存在占有或窥伺意图的风险预期。'; quote='男性的觊觎，也是出自女性的想象吗？'; evidenceNature='凝视、觊觎与风险预期'; boundary='文章反对把风险预期直接当成妄想，也明确没有据此给所有具体男性定罪。' }
    [ordered]@{ evidenceId='G45'; ordinal=316; section='尊严、保护与文化信号'; claim='作者认为贤妻良母虽曾是褒奖词，却因与忍辱牺牲和从属角色长期相连而不再适合作为现代女性的稳妥赞美。'; quote='贤妻良母这个词主要是被传统社会用得太多，给用坏了。'; evidenceNature='传统称谓、赞美与角色框定'; boundary='文章没有否定妻子和母亲身份，而是反对用角色称谓替代对具体人格和贡献的见证。' }
    [ordered]@{ evidenceId='G46'; ordinal=8; section='尊严、保护与文化信号'; claim='作者认为判断男性是否尊重女性不能只看其是否保护，还要看他是否承认女性原有能力，并在冲突时不以保护居功索取。'; quote='真诚的人不会拿这个居功，不会拿这个说“没有功劳也有苦劳”，不会说“你看我对你多好”。'; evidenceNature='保护、能力承认与居功检验'; boundary='文章提供关系观察角度，一次表态不能证明长期尊重。' }
    [ordered]@{ evidenceId='G47'; ordinal=224; section='尊严、保护与文化信号'; claim='作者认为女性通过竞技和对抗训练形成野性与不可预测的反击气质，可以提高潜在骚扰者对冒犯成本的判断。'; quote='生为女性，野性是最好的祛邪避凶的镇魂神器。'; evidenceNature='身体训练、自卫气质与骚扰预防'; boundary='这是作者的预防性判断，不表示骚扰责任转移给女性，也不是自卫效果统计。' }
    [ordered]@{ evidenceId='G48'; ordinal=3219; section='尊严、保护与文化信号'; claim='作者把物化的重点界定为无视人说不的权利，并区分正常交易中的条件服务与取消选择、贫困胁迫和拒绝后继续纠缠。'; quote='“物化”是指无视人的权利——这重点是指不考虑人说“不”的权利。'; evidenceNature='物化、拒绝权与交易边界'; boundary='这是作者的物化概念，不等于所有利用服务或商业交换都把人当作物。' }
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
    if (-not $screenedIds.ContainsKey([string]$article.id)) { throw "[$($item.evidenceId)] Article is not in screening layer." }
    $quoteOk = ([string]$article.text).Contains([string]$item.quote, [StringComparison]::Ordinal)
    if (-not $quoteOk) { throw "[$($item.evidenceId)] Exact quote validation failed: $($item.quote)" }
    $date = [DateTimeOffset]::FromUnixTimeMilliseconds([int64]$article.publishedAt).ToOffset([TimeSpan]::FromHours(8)).ToString('yyyy-MM-dd')
    $rows.Add([pscustomobject][ordered]@{
        evidenceId = $item.evidenceId
        section = $item.section
        claim = $item.claim
        evidenceNature = $item.evidenceNature
        boundary = $item.boundary
        ordinal = $ordinal
        id = [string]$article.id
        date = $date
        title = [string]$article.title
        url = [string]$article.url
        quote = $item.quote
        quoteExact = $quoteOk
        sourceLayer = 'screened'
    })
}

$requiredSections = @('性别概念、角色与权力','身体、外貌与身体自主','欲望、性行为与性取向','同意、边界与性暴力','性知识、教育与健康','生育、妊娠与生殖选择','性别化照料与家庭劳动','尊严、保护与文化信号')
$sectionCounts = [ordered]@{}
foreach ($section in $requiredSections) { $sectionCounts[$section] = @($rows | Where-Object section -eq $section).Count }
$uniqueEvidenceIds = @($rows.evidenceId | Sort-Object -Unique).Count
$uniqueArticleIds = @($rows.id | Sort-Object -Unique).Count
$uniqueOrdinals = @($rows.ordinal | Sort-Object -Unique).Count
$missingCoreFields = @($rows | Where-Object {
    [string]::IsNullOrWhiteSpace($_.claim) -or [string]::IsNullOrWhiteSpace($_.evidenceNature) -or
    [string]::IsNullOrWhiteSpace($_.boundary) -or [string]::IsNullOrWhiteSpace($_.quote)
}).Count
$exactQuoteFailures = @($rows | Where-Object quoteExact -eq $false).Count
$allSectionsCovered = @($requiredSections | Where-Object { $sectionCounts[$_] -ne 6 }).Count -eq 0

$rows | Export-Csv -LiteralPath ([IO.Path]::GetFullPath($OutputPath)) -NoTypeInformation -Encoding utf8BOM
$status = if ($rows.Count -eq 48 -and $uniqueEvidenceIds -eq 48 -and $uniqueArticleIds -eq 48 -and $uniqueOrdinals -eq 48 -and $missingCoreFields -eq 0 -and $exactQuoteFailures -eq 0 -and $allSectionsCovered) { 'PASS' } else { 'REVIEW' }
$stats = [ordered]@{
    corpusArticles = $corpus.Count
    screenedCandidates = $screenedIds.Count
    evidenceRows = $rows.Count
    uniqueEvidenceIds = $uniqueEvidenceIds
    uniqueArticleIds = $uniqueArticleIds
    uniqueOrdinals = $uniqueOrdinals
    screenedEvidenceRows = $rows.Count
    directReviewSupplements = 0
    missingCoreFields = $missingCoreFields
    exactQuoteFailures = $exactQuoteFailures
    sectionCounts = $sectionCounts
    status = $status
}
$stats | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath ([IO.Path]::GetFullPath($StatsPath)) -Encoding utf8
$stats | ConvertTo-Json -Depth 5
if ($status -ne 'PASS') { throw "Gender/body/consent core evidence validation ended with status $status." }
