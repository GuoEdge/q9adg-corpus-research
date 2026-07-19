param(
    [string]$CorpusPath = '.\sooon-q9adg-articles.jsonl',
    [string]$ScreeningPath = '.\research\data\intimacy_relationship_screening.csv',
    [string]$OutputPath = '.\research\data\intimacy_relationship_core_evidence.csv',
    [string]$StatsPath = '.\research\data\intimacy_relationship_core_evidence.stats.json'
)

$ErrorActionPreference = 'Stop'

$approvedSupplements = @{
    3 = 'Direct love-definition text recovered by corpus review.'
}

$approvedUrlCorrections = @{
    89 = 'https://www.zhihu.com/question/2036557109429543087/answer/2040828882861942775'
}

$items = @(
    [ordered]@{ evidenceId='I01'; ordinal=95; section='爱欲、依恋与爱的定义'; claim='作者区分以得到关系结果为中心的恋，与不以两人结果为前提、希望对方得好的爱。'; quote='你这是恋，不是爱。'; evidenceNature='恋与爱的直接定义'; boundary='文章不否定恋的存在，而是要求正确命名其中的占有和结果诉求。' }
    [ordered]@{ evidenceId='I02'; ordinal=3; section='爱欲、依恋与爱的定义'; claim='作者认为挑剔常来自等待被爱和担心付出无回报，真正的关切会使人先看见对方闪光点，再由爱生出赞赏。'; quote='是爱生赞赏，而不是赞赏生爱。'; evidenceNature='爱与评价顺序判断'; boundary='文章没有取消择偶判断，只反对把发现完美对象设为开始爱人的唯一前提。' }
    [ordered]@{ evidenceId='I03'; ordinal=2642; section='爱欲、依恋与爱的定义'; claim='作者认为不成熟者相爱是常态，开始与结束应取决于本人意愿，只要仍为对方保留完整自由，就不必以避免失败为恋爱前提。'; quote='人生要紧的是不留白，不是不吃亏。'; evidenceNature='恋爱开始、失败与自由判断'; boundary='“尽力而为”不表示关系必须持续，文章同时保留本人决定结束的自由。' }
    [ordered]@{ evidenceId='I04'; ordinal=1470; section='爱欲、依恋与爱的定义'; claim='作者把持续的爱写成明知未来可能有分手、遗忘和无常，仍认为已经得到的幸福足以覆盖预期痛苦。'; quote='爱是过去已经有的、未来可能有的折磨，都已经被直到此刻已经得到的幸福覆盖了'; evidenceNature='爱与不确定未来的时间判断'; boundary='文章没有承诺未来回报，而是反对把当前痛苦当作必然兑换未来奖赏的投资。' }
    [ordered]@{ evidenceId='I05'; ordinal=284; section='爱欲、依恋与爱的定义'; claim='作者认为父母、恋人、朋友、子女和同道之爱可以共同缓解孤独，却各有不可互相抹平的味道；真正的爱不要求排除其他爱。'; quote='你用不着考虑用谁替代谁。'; evidenceNature='多种爱与不可替代性'; boundary='文章讨论爱的支持功能，不表示不同关系具有相同责任、亲密形式和成员资格。' }
    [ordered]@{ evidenceId='I06'; ordinal=1088; section='爱欲、依恋与爱的定义'; claim='作者提出爱的重点是劳动，爱的核心关系在人与自然和客观世界之间，人际安慰主要用于解除摩擦并使人重返生产创造。'; quote='爱的核心关系，是你和自然界的关系。'; evidenceNature='爱的生产轴与客观世界关系'; boundary='这是作者对爱的一条强定义，与其他文章的人际净输出轴并存，文本没有给出统一排序公式。' }

    [ordered]@{ evidenceId='I07'; ordinal=3295; section='相识、择偶与关系形成'; claim='作者区分短期求欢者的瞬时投入与婚姻追求者的长期责任，要求离开金钱外貌竞赛并寻找能够共同承担真实爱的对象。'; quote='临时求欢者有两大优势。'; evidenceNature='追求策略、关系期限与择偶标准'; boundary='文章的性别和婚恋市场判断只作为作者模型，不被认证为普遍经验事实。' }
    [ordered]@{ evidenceId='I08'; ordinal=2411; section='相识、择偶与关系形成'; claim='作者反对以恋爱时长自动证明慎重，主张像国情研究一样观察对方的制度观念、反应方式和行动能力，并设置进展与退出机制。'; quote='你一个恋爱谈得有多久，其实主要取决于你的国情研究做得有多快，以及你的退出机制是否可靠。'; evidenceNature='关系考察与时间边界'; boundary='文章允许耐心，却明确反对在没有客观进展信号时无限等待。' }
    [ordered]@{ evidenceId='I09'; ordinal=76; section='相识、择偶与关系形成'; claim='作者把善良和积极勤奋设为结婚选择的两项核心条件，认为外貌、学历、职位和暂时贫穷可以放宽，持续消极却难以共同承担生活。'; quote='要结婚，对方可以穷、可以不帅、可以职位低、可以学历不高，但一定要两条——要善良，要积极/勤奋。'; evidenceNature='择偶条件与合作动能'; boundary='这是作者的择偶排序，不表示善良勤奋足以保证婚姻成功。' }
    [ordered]@{ evidenceId='I10'; ordinal=1509; section='相识、择偶与关系形成'; claim='作者把亲密关系写成心领神会的表达艺术，认为关系确认不能只依靠标准表白话术，而要由诚意与相处形成双方对多层含义的理解。'; quote='亲密关系是心领神会的艺术，是表达的巅峰。'; evidenceNature='关系形成与表达同调'; boundary='文章强调默契形成，不表示明确表达、确认同意或讨论关系状态本身无用。' }
    [ordered]@{ evidenceId='I11'; ordinal=2716; section='相识、择偶与关系形成'; claim='作者把关系是否值得投入连接到对方事业是否真诚且有公共意义，认为共同支持有益于他人的追求可以承接亲密关系中的牺牲。'; quote='爱与不爱，其实是看对方的人生追求值不值得你牺牲。'; evidenceNature='择偶、事业与公共意义判断'; boundary='文章讨论牺牲理由，不把公共事业自动写成对伴侣责任和边界的豁免。' }
    [ordered]@{ evidenceId='I12'; ordinal=1868; section='相识、择偶与关系形成'; claim='作者主张父母面对未成年人恋爱应避免只用强制禁止，转而教育双方善待彼此、保护自己并不让关系损害双方发展。'; quote='无论如何，不能让爱成为彼此的诅咒、成为彼此不能成为最好的自己的原因。'; evidenceNature='未成年恋爱与父母监护接口'; boundary='文章仍承认父母的法律监护权限，并要求双方父母知情和承担连带保护责任。' }

    [ordered]@{ evidenceId='I13'; ordinal=16; section='承诺、信任与婚姻联盟'; claim='作者认为婚前经济分歧若不能被双方感情承诺填补，问题不只是价格，而是婚姻联盟尚未成熟，需要婚后继续完成恋爱。'; quote='你要做的都不该是“重新谈一个价格”。'; evidenceNature='婚前协商与承诺强度'; boundary='文章承认婚前经济可以谈，所反对的是用谈妥数额替代关系信任是否成立的判断。' }
    [ordered]@{ evidenceId='I14'; ordinal=144; section='承诺、信任与婚姻联盟'; claim='作者把彩礼冲突的中心放在伴侣是否坚定站队、是否使对方孤立无援，而不是只看金额高低。'; quote='真正破坏关系的，其实是这个“孤立无援”，而不是这个金额的高昂。'; evidenceNature='婚姻联盟与家庭阻力'; boundary='文章没有否定彩礼金额和父母意见的现实作用，而是把伴侣联盟置于解释中心。' }
    [ordered]@{ evidenceId='I15'; ordinal=1508; section='承诺、信任与婚姻联盟'; claim='作者把婚姻设为两个成年人的直接结盟，要求各自过滤本方父母请求，并独自承担面对本方父母的责任。'; quote='配偶之间商量决定，决定了之后对抗各自父母的责任就全在自己身上，而不在配偶身上。'; evidenceNature='夫妻联盟与姻亲边界'; boundary='父母在文中仍是贵客，失去的是越过自己子女直接指挥配偶的资格。' }
    [ordered]@{ evidenceId='I16'; ordinal=3100; section='承诺、信任与婚姻联盟'; claim='作者要求婚恋参与者对自己的意愿、承诺和社会关系负责，不能把父母意见伪装成关系规则，同时继续让对方相信个人承诺有效。'; quote='作为一个人，处理自己的社会关系是自己的事。'; evidenceNature='承诺主体与第三方责任'; boundary='文章允许把父母要求作为具体条件提出并协商，反对的是隐藏本人立场与责任。' }
    [ordered]@{ evidenceId='I17'; ordinal=99; section='承诺、信任与婚姻联盟'; claim='作者区分恋爱温存与婚姻中共同承担社会责任的爱，并以“孤证不立”要求记录、询问协商和持续改良后再判断长期冷漠。'; quote='重大关系有一个简单的原则——孤证不立。'; evidenceNature='婚姻责任与关系判断程序'; boundary='文章没有保证反复协商一定修复关系，而是限制用单次表现完成总体定性。' }
    [ordered]@{ evidenceId='I18'; ordinal=3552; section='承诺、信任与婚姻联盟'; claim='作者要求婚姻决定不追求绝对成功概率，而要设计失败损失管理，并把发生冲突时选择想办法还是选择定罪作为关系能力指标。'; quote='真正的要害，在于双方在这个节点上是选择想办法，还是选择定罪。'; evidenceNature='婚姻决策、失败管理与忍耐'; boundary='文章的忍耐指不轻率定罪，不等于取消拒绝、边界和退出。' }

    [ordered]@{ evidenceId='I19'; ordinal=3934; section='婚礼、金钱与财产安排'; claim='作者主张婚前把财产、家务报酬、公共开销、父母义务、子女抚养和无理由离婚写入协议，以能否接受对方自由检验结婚适配性。'; quote='能签这协议的，就能结。'; evidenceNature='婚前协议与关系权利边界'; boundary='具体协议是作者方案，不被本文认证为不同法域中的有效合同。' }
    [ordered]@{ evidenceId='I20'; ordinal=1650; section='婚礼、金钱与财产安排'; claim='作者认为夫妻共同财产需要查询与救济机制，重视财务独立者应通过婚前或婚内书面协议建立账户、出资和借贷规则。'; quote='因为需要签下这个还肯在一起，本身就已经有足够的爱。'; evidenceNature='婚内财产透明与书面协议'; boundary='文章的法律解释只归属于作者，本文不验证具体查询权和协议效力。' }
    [ordered]@{ evidenceId='I21'; ordinal=3347; section='婚礼、金钱与财产安排'; claim='作者反对一方上交全部收入，主张各自支配劳动所得，只把固定额度放入共同账户，并使对等支付义务对应对等议事权。'; quote='谁赚的，还是归谁自己支配。'; evidenceNature='夫妻收入、共同账户与议事权'; boundary='文章允许共同投资和按约暂欠，不把收入独立解释为家庭开支互不负责。' }
    [ordered]@{ evidenceId='I22'; ordinal=2026; section='婚礼、金钱与财产安排'; claim='作者把进入小夫妻账户的彩礼嫁妆与婚礼消费区分，认为前者是家庭股本转移，不应被直接算成一方完全损失。'; quote='结婚本质上只是把财产换了个账户重新存储，这谈不上“花掉”。'; evidenceNature='彩礼嫁妆与婚姻总账'; boundary='文章关于彩礼资格和婚姻市场的解释属于作者判断，不作外部经济事实认证。' }
    [ordered]@{ evidenceId='I23'; ordinal=74; section='婚礼、金钱与财产安排'; claim='作者认为彩礼争议的沟通应区分金额负担与破坏既有承诺，避免用质问翻脸同时发送舍不得出钱、能力不足和不守约等多重信号。'; quote='我对这个婚事产生动摇，不会是因为这几千块钱，而会是因为这会破了这个例'; evidenceNature='彩礼增额与承诺信号'; boundary='文章给出等值物品补足的具体方案，只服务于该次协商，不是统一彩礼规则。' }
    [ordered]@{ evidenceId='I24'; ordinal=967; section='婚礼、金钱与财产安排'; claim='作者认为健康关系应由两个能独立覆盖生存成本的个体结合并产生额外净输出，彩礼房车应追加建设已经成立的关系，而非成为其成立前提。'; quote='爱一定是对外产生净输出的，本身就是泉水。'; evidenceNature='关系自生能力与外部资源位置'; boundary='这是作者对爱情与共生合作的强区分，不表示伴侣不能接受家庭帮助。' }

    [ordered]@{ evidenceId='I25'; ordinal=15; section='日常照料、劳动与互惠'; claim='作者把约会打扮理解为可能包含身体不适的奉献，要求回应者不只欣赏结果，也辨认并怜惜其中的成本。'; quote='诚敬邀请-牺牲以奉-欣赏怜惜'; evidenceNature='奉献识别与关系回应'; boundary='文章讨论特定约会信号，不把高跟鞋或性别角色规定为普遍亲密义务。' }
    [ordered]@{ evidenceId='I26'; ordinal=82; section='日常照料、劳动与互惠'; claim='作者认为合理目标不自动产生对伴侣的指挥权，爱的关系中应以请、望、托、求提出需要并保留拒绝空间。'; quote='只有我请你、望你、托你、求你，没有让你。'; evidenceNature='日常请求与决定权'; boundary='文章针对未经询问要求女友做饭的场景，不否定伴侣之间协商家务。' }
    [ordered]@{ evidenceId='I27'; ordinal=89; section='日常照料、劳动与互惠'; claim='作者把关系由浓转淡后的低配照料比作油盐饭，要求双方减少把被抛弃焦虑混入相处并持续保持净输出。'; quote='所以，第一要害，就是要坚定的咬住“爱必须坚持净输出”的原则。'; evidenceNature='激情衰减与日常净输出'; boundary='净输出是作者的方向原则，不表示关系必须继续或付出可以忽略接受者边界。' }
    [ordered]@{ evidenceId='I28'; ordinal=232; section='日常照料、劳动与互惠'; claim='作者要求婚姻中的需求提案说明对家庭和伴侣的具体益处，允许对方基于自身利益拒绝，并以此增加未来自愿合作。'; quote='你只能基于这对我们家、对我本人有何益处来说服我做什么变化，进而顺带满足你自己的需求'; evidenceNature='共同收益与需求表达'; boundary='共同收益不取消个人需要，只限制把“我有需要”直接转换成对方改变义务。' }
    [ordered]@{ evidenceId='I29'; ordinal=287; section='日常照料、劳动与互惠'; claim='作者反对逼问配偶爱不爱，主张以日常义务、危机照料和合作效果是否持续改善判断关系，并在实践中学习相处能力。'; quote='这个“一加一小于二”才是爱与不爱的关键，不是海誓山盟、神魂颠倒。'; evidenceNature='婚姻合作与爱之判断'; boundary='文章允许关系早期配合低效，只要存在从负到正的持续改善，并未保证所有磨合都值得继续。' }
    [ordered]@{ evidenceId='I30'; ordinal=7; section='日常照料、劳动与互惠'; claim='作者认为关系需要双方的不完美反应权，不必对每次分享强装热情；无法长期维持的情绪周全会累积疲惫和愤怒。'; quote='从容轻松，才可长久。'; evidenceNature='情绪回应强度与可持续性'; boundary='文章仍要求最低限度地看见分享，不把不感兴趣解释为可以惩罚性无视。' }

    [ordered]@{ evidenceId='I31'; ordinal=3580; section='冲突、沟通与关系修复'; claim='作者认为关系中的道理必须事先约定并有双方认可的仲裁机制，爱不能被用来替对方单方面立法和定罪。'; quote='讲道理之前要先把道理约好，而且要先约好仲裁机制，这是“讲道理”本身的道理。'; evidenceNature='关系规则、仲裁与反思'; boundary='文章不把对方全部情绪自动判为正确，只限制未经同意拿私人规则审判对方。' }
    [ordered]@{ evidenceId='I32'; ordinal=1452; section='冲突、沟通与关系修复'; claim='作者主张冲突发生本身可以去罪化，双方应为冲突未及时结束、反复发生和升级道歉，并把精力用于复盘修复。'; quote='我们不为这事的发生道歉，我们会为这事没有及时结束、为它反复发生、为它愈演愈烈而道歉。'; evidenceNature='冲突去罪化与修复责任'; boundary='文章讨论父母怎样向儿童展示冲突处理，不表示任何争吵方式都因此被允许。' }
    [ordered]@{ evidenceId='I33'; ordinal=2660; section='冲突、沟通与关系修复'; claim='作者区分主动放弃部分占有、因对方得到而共同欢喜的爱，与双方耗尽后被迫分配剩余利益的妥协。'; quote='爱是两次被成全的牺牲。'; evidenceNature='目标冲突中的爱与妥协定义'; boundary='文章的概念区分不取消协商本身，而是比较协商前的动机和结果体验。' }
    [ordered]@{ evidenceId='I34'; ordinal=1990; section='冲突、沟通与关系修复'; claim='作者区分在伴侣面前表达对外部的不满与朝伴侣发泄，并要求发泄方按对方承受力调整，被发泄方先确认联盟再表达边界。'; quote='那不是因为“爱你”，而是因为“相信你的爱”。'; evidenceNature='情绪表达、承诺与承受额度'; boundary='文章的情绪和生理建议只作为作者关系理论，不被写成心理治疗方案。' }
    [ordered]@{ evidenceId='I35'; ordinal=3179; section='冲突、沟通与关系修复'; claim='作者认为道歉不能追着对方兑换原谅；联系存在时应拉开表达频率并用后续行动改变，联系中断时不打扰本身成为服务。'; quote='你无法合乎逻辑地用“证明不爱的方式”去传递“爱的证据”'; evidenceNature='道歉、原谅与不打扰'; boundary='文章保留复合可能，却禁止把复合希望作为持续纠缠的行动依据。' }
    [ordered]@{ evidenceId='I36'; ordinal=98; section='冲突、沟通与关系修复'; claim='作者把冷处理定义为冻结暂时无法解决的分歧，同时在无分歧领域继续合作并增强互信，而不是冷遇、无视或惩罚性拖延。'; quote='“冻结分歧”是“冷”，“增强互信”是“处理”，合起来才是“冷处理”。'; evidenceNature='延期争议与关系维护程序'; boundary='该方法以仍有合作基础且争议可以延期为前提，不适用于所有反复侵害情境。' }

    [ordered]@{ evidenceId='I37'; ordinal=3059; section='自由、同意与亲密边界'; claim='作者反对强迫伴侣交代全部过去，认为现实亲密更像重复的小额交易，安全应由体检、避险、程序和边界建立。'; quote='我爱你的第一表现，就是我接受你对我保持一切怀疑、保持一切戒备。'; evidenceNature='隐私、过去与安全机制'; boundary='文章反对全面倒查，不表示已约定事项可以欺骗或隐瞒现实安全信息。' }
    [ordered]@{ evidenceId='I38'; ordinal=1548; section='自由、同意与亲密边界'; claim='作者要求伴侣承认彼此与他人交往的自由，各自管理占有欲，不以查岗和上缴记录预先控制对方，同时尊重恋人的关系位置。'; quote='我们其实从一开始，就只能基于“互相尊重隐私，各自管理自己的占有欲”的基本原则行事。'; evidenceNature='交往自由、占有欲与隐私'; boundary='文章同时反对炫耀与他人的亲密，不把自由解释为故意贬低伴侣位置。' }
    [ordered]@{ evidenceId='I39'; ordinal=1711; section='自由、同意与亲密边界'; claim='作者把真爱从内心感情改写为尊重对方意志的行为规范，明确拒绝出现后应克制、停止施压，不把自己的快乐建立在对方痛苦上。'; quote='一句“我不希望这样”，如果是真爱，那就解决了。'; evidenceNature='拒绝后的克制与关系行为'; boundary='文章针对明确拒绝后的纠缠，不表示关系中的所有分歧只能用一句话处理。' }
    [ordered]@{ evidenceId='I40'; ordinal=3370; section='自由、同意与亲密边界'; claim='作者把性关系的心理前提设为清醒接受风险与不可交换性，反对用性换取终身关系、优待和安全，并要求重视健康信息。'; quote='爱虽然温柔到极点，但任何一丁点都是绝对的英勇行为，它只可能发生在两个无畏的人之间。'; evidenceNature='性、风险与不可交换性'; boundary='文中的健康和风险判断只作为作者主张，不替代专业医学信息和现实同意程序。' }
    [ordered]@{ evidenceId='I41'; ordinal=1129; section='自由、同意与亲密边界'; claim='作者要求人减少介意，不把介意包装成限制伴侣自由的天然权利；若自己不能承受，则应承认不适配并退出关系。'; quote='爱以“介意”为耻。'; evidenceNature='介意、自由与退出责任'; boundary='文章明确区分以介意为耻与做到毫无介意，前者是追求减少而非否认实际感受。' }
    [ordered]@{ evidenceId='I42'; ordinal=937; section='自由、同意与亲密边界'; claim='作者提出爱可以接受伴侣困难造成的连累，却不包含承受侮辱、攻击和责任转嫁；失控后拒绝道歉会破坏修复基础。'; quote='爱接受连累，不接受迫害。'; evidenceNature='情绪困难、侵害与关系红线'; boundary='文章区分负面情绪与用负面情绪侵害对方，不把一切痛苦表达都判为迫害。' }

    [ordered]@{ evidenceId='I43'; ordinal=3803; section='分手、离婚与独身路径'; claim='作者认为爱不要求关系保本或对等回报，即使分手也不应把既有付出转成报复和债务追索，结果不成首先归于自身能力和选择。'; quote='爱是爱，贪是贪。'; evidenceNature='分手、净收益与不追债'; boundary='文章的数学表达是作者关系模型，不表示受损者放弃已经明确约定的合同权利。' }
    [ordered]@{ evidenceId='I44'; ordinal=1516; section='分手、离婚与独身路径'; claim='作者把反复相似的失恋结果解释为选择相似对象、重复相似谈法，并把失恋视为迫使人识别无效模式的强反馈。'; quote='你总是找一样的人、一样的谈，你当然总谈出一样的结果啊。'; evidenceNature='失恋反馈与关系模式学习'; boundary='文章讨论重复模式，不把一切失恋都归为当事人单方造成。' }
    [ordered]@{ evidenceId='I45'; ordinal=3218; section='分手、离婚与独身路径'; claim='作者把挽回术的黑盒子视为试图改变他人自由决定的暴力，要求以自己的失落换取对方自由，并警惕成功强化继续操控。'; quote='你有用自己应分的失落换别人得享自由的责任。'; evidenceNature='挽回、自由意志与成功陷阱'; boundary='文章针对操控性复合术，不禁止对方自愿重新协商关系。' }
    [ordered]@{ evidenceId='I46'; ordinal=164; section='分手、离婚与独身路径'; claim='作者把特定主体的自愿独身解释为多次受挫、亏欠恐惧和自我否定后的能量耗尽，而不是简单的独立觉醒。'; quote='我只是没有力气了。'; evidenceNature='独身、耗尽与再次投入能力'; boundary='这是文章中的一条叙事路径，不能外推为所有独身者的动机。' }
    [ordered]@{ evidenceId='I47'; ordinal=1953; section='分手、离婚与独身路径'; claim='作者建议重大隐瞒、人生规划分歧和价值冲突先真实分开，再以新的事实和条件考虑是否复合，使双方恢复独立与再次自愿。'; quote='凡遇到可能导致走不下去的问题，建议考虑先分开，再考虑要不要以新的条件复合。'; evidenceNature='分开、复合与再次自愿'; boundary='先分开是一种降低后悔的作者方案，不表示所有重大分歧都必然终止关系。' }
    [ordered]@{ evidenceId='I48'; ordinal=3227; section='分手、离婚与独身路径'; claim='作者认为离婚后的首要工作之一是让子女看到父母仍可幸福，并展示从挫折中反思、恢复和重新经营幸福的过程。'; quote='证明离婚后也可以幸福。'; evidenceNature='离婚后的子女安全感与恢复过程'; boundary='文章不把离婚本身写成无损事件，而要求父母展示处理过程并降低子女的归责与恐惧。' }
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
    $article = $corpus[$item.ordinal - 1]
    $inScreening = $screenedIds.ContainsKey([string]$article.id)
    $isApprovedSupplement = $approvedSupplements.ContainsKey([int]$item.ordinal)
    if (-not $inScreening -and -not $isApprovedSupplement) { throw "[$($item.evidenceId)] Article is neither screened nor an approved supplement." }
    $quoteOk = ([string]$article.text).Contains([string]$item.quote, [StringComparison]::Ordinal)
    if (-not $quoteOk) { throw "[$($item.evidenceId)] Exact quote validation failed: $($item.quote)" }
    $date = [DateTimeOffset]::FromUnixTimeMilliseconds([int64]$article.publishedAt).ToOffset([TimeSpan]::FromHours(8)).ToString('yyyy-MM-dd')
    $resolvedUrl = if ($approvedUrlCorrections.ContainsKey([int]$item.ordinal)) { $approvedUrlCorrections[[int]$item.ordinal] } else { [string]$article.url }
    $rows.Add([pscustomobject][ordered]@{
        evidenceId=$item.evidenceId; section=$item.section; claim=$item.claim; evidenceNature=$item.evidenceNature; boundary=$item.boundary
        ordinal=$item.ordinal; id=[string]$article.id; date=$date; title=[string]$article.title; url=$resolvedUrl
        quote=$item.quote; quoteExact=$quoteOk; sourceLayer=if($inScreening){'screened'}else{'direct-review-supplement'}
    })
}

$requiredSections = @(
    '爱欲、依恋与爱的定义','相识、择偶与关系形成','承诺、信任与婚姻联盟','婚礼、金钱与财产安排',
    '日常照料、劳动与互惠','冲突、沟通与关系修复','自由、同意与亲密边界','分手、离婚与独身路径'
)
$sectionCounts=[ordered]@{}; foreach($section in $requiredSections){$sectionCounts[$section]=@($rows|Where-Object section -eq $section).Count}
$uniqueEvidenceIds=@($rows.evidenceId|Sort-Object -Unique).Count
$uniqueArticleIds=@($rows.id|Sort-Object -Unique).Count
$missingCoreFields=@($rows|Where-Object{[string]::IsNullOrWhiteSpace($_.claim)-or[string]::IsNullOrWhiteSpace($_.boundary)-or[string]::IsNullOrWhiteSpace($_.quote)}).Count
$allSectionsCovered=@($requiredSections|Where-Object{$sectionCounts[$_] -ne 6}).Count -eq 0
$supplementRows=@($rows|Where-Object sourceLayer -eq 'direct-review-supplement')
$rows|Export-Csv -LiteralPath ([IO.Path]::GetFullPath($OutputPath)) -NoTypeInformation -Encoding utf8BOM
$status=if($rows.Count-eq48-and$uniqueEvidenceIds-eq48-and$uniqueArticleIds-eq48-and$screenedIds.Count-eq775-and$supplementRows.Count-eq1-and[int]$supplementRows[0].ordinal-eq3-and$missingCoreFields-eq0-and$allSectionsCovered-and-not($rows.quoteExact-contains$false)){'PASS'}else{'REVIEW'}
$stats=[ordered]@{corpusArticles=$corpus.Count;screenedCandidates=$screenedIds.Count;evidenceRows=$rows.Count;uniqueEvidenceIds=$uniqueEvidenceIds;uniqueArticleIds=$uniqueArticleIds;screenedEvidenceRows=@($rows|Where-Object sourceLayer -eq 'screened').Count;directReviewSupplements=$supplementRows.Count;supplementOrdinals=@($supplementRows.ordinal);approvedUrlCorrections=$approvedUrlCorrections.Count;urlCorrectionOrdinals=@($approvedUrlCorrections.Keys);missingCoreFields=$missingCoreFields;exactQuoteFailures=@($rows|Where-Object quoteExact -eq $false).Count;sectionCounts=$sectionCounts;status=$status}
$stats|ConvertTo-Json -Depth 5|Set-Content -LiteralPath ([IO.Path]::GetFullPath($StatsPath)) -Encoding utf8
$stats|ConvertTo-Json -Depth 5
if($status-ne'PASS'){throw "Intimacy core evidence validation ended with status $status."}
