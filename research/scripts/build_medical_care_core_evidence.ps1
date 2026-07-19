param(
    [string]$CorpusPath = '.\sooon-q9adg-articles.jsonl',
    [string]$OutputPath = '.\research\data\medical_care_core_evidence.csv',
    [string]$StatsPath = '.\research\data\medical_care_core_evidence.stats.json'
)

$ErrorActionPreference = 'Stop'

$items = @(
    [ordered]@{ evidenceId='M01'; ordinal=1258; section='护理与照顾者可持续性'; claim='护理先达到可长期维持的稳定，再追求高于维生底线的改善；照顾者不以透支自身换取短期完美。'; quote='必须要量力而行，按照自己可以尽可能长期承受的前提去提供高于维生底线的恰当照顾，而不是透支自身的完美照顾。'; evidenceNature='明示行动原则'; boundary='适用于该文讨论的长期精神病患护理结构。' }
    [ordered]@{ evidenceId='M02'; ordinal=105; section='探病与社会回归'; claim='探病不仅处理病情，还分担家庭、工作与社会位置中断造成的焦虑；非医生不应给出无依据的医疗保证。'; quote='4）避免以不专业的身份给出乐观医疗判断。'; evidenceNature='明示专业边界'; boundary='文章讨论亲友探病，不是诊疗指南。' }
    [ordered]@{ evidenceId='M03'; ordinal=1485; section='临终抚慰与未尽责任'; claim='临终抚慰应区分对死亡本身的恐惧与对遗属、事业、义务和拖累亲友的担忧，并针对后者提供具体安排。'; quote='在这个基础上，你要注意观察当事人自己的心态，是不愿意面对死亡的可能，还是可以面对死亡的可能，但对死亡的后果感到焦虑。'; evidenceNature='明示行动区分'; boundary='宗教与临终判断均只作为作者文本内主张。' }
    [ordered]@{ evidenceId='M04'; ordinal=530; section='拒医、死亡与失能恐惧'; claim='老人拒绝住院在文中被解释为害怕离开生活常态、无法回家、长期失能并拖累子孙，而不只是一项宗教迷信。'; quote='“住院”是从生活常态通向死亡的必经中转站，ta们的年纪，一旦住院，就怕再也回不了家了。'; evidenceNature='作者因果解释'; boundary='动机解释未经外部调查，文章也未给出现实诊疗决定。' }
    [ordered]@{ evidenceId='M05'; ordinal=3711; section='养老、死亡教育与意义'; claim='养老院在作者设想中不仅提供舒适护理，还应成为讨论生存、死亡和临终价值的学术机构。'; quote='养老院首先应该是一所关于生存和死亡的学术机构。'; evidenceNature='明示制度设想'; boundary='这是作者的养老制度构想，不是现有机构事实。' }
    [ordered]@{ evidenceId='M06'; ordinal=954; section='治疗的确定性模型'; claim='治疗被定义为在受控制的过程中注入确定性；情绪驱动且未经计划的冲突不能因偶然好结果被重新命名为治疗。'; quote='寻求治疗，有一个最基本的原则，那就是要在受控制的过程中进行。'; evidenceNature='明示定义与行动原则'; boundary='作者把医疗模型类比到咨询和亲子关系，类比范围需按原文保留。' }
    [ordered]@{ evidenceId='M07'; ordinal=1657; section='专家意见与独立复核'; claim='重大疑难问题需要专家意见，但专家只能担当判断系统中的一个组件；互不关联的多次诊断用于降低既有叙事污染。'; quote='专家只能在这个系统里担当一个组件。'; evidenceNature='明示认识论原则'; boundary='具体就诊步骤是作者建议，不替代现实医疗流程。' }
    [ordered]@{ evidenceId='M08'; ordinal=3903; section='诊断、自述与确认偏差'; claim='网络回答和未经追问的自述不能直接构成确切诊断；作者要求治疗者持续检验来访者既有自我诊断。'; quote='不要相信这给出的任何确切诊断！'; evidenceNature='明示诊断边界'; boundary='作者对来访者动机的概括属于其文本判断。' }
    [ordered]@{ evidenceId='M09'; ordinal=2740; section='怀疑、猜疑与可验证路径'; claim='面对医药价格疑问，作者先利用处方外购等渠道降低风险，再区分可证伪的怀疑与无法调查的猜疑。'; quote='我对在这个具体案例中医生是不是借此牟利这种无实据可言的猜疑没有兴趣。'; evidenceNature='明示判断与行动建议'; boundary='关于回扣机制的经验判断未作外部核验。' }
    [ordered]@{ evidenceId='M10'; ordinal=1235; section='医患沟通与反馈格式'; claim='求助者应具体说明执行了什么、发生何种变化、尚未达到什么目标，使专业意见能够继续修正。'; quote='这是一个“自认为已经付出了代价，质问医疗方案”的句式。'; evidenceNature='明示沟通诊断'; boundary='作者对患者群体比例和责任的概括只作为其判断。' }
    [ordered]@{ evidenceId='M11'; ordinal=1054; section='康复意愿与医患共同用力'; claim='文章把患者是否真正想恢复置于诊断和待遇诉求之前，并解释为医生决定是否继续投入的重要信号。'; quote='怎么说呢，医生对你是不是真的想好起来是有直觉的。'; evidenceNature='作者医患因果解释'; boundary='动机、抑郁和自伤判断不作外部医学认证。' }
    [ordered]@{ evidenceId='M12'; ordinal=1885; section='非专业照护与授权'; claim='教师、朋友等普通关系不自动承担医疗和危机处置职责；保密承诺、专业资格、拒绝权和持续联系需要事先界定。'; quote='如果有，为什么不应该寻求医疗帮助，而要去向并无医疗资质和恰当训练的L寻求帮助？'; evidenceNature='明示角色边界'; boundary='具体个案责任和法律判断未作外部认证。' }
    [ordered]@{ evidenceId='M13'; ordinal=1565; section='家庭环境与抑郁应对'; claim='子女抑郁的应对不能只外包给专家；家长应整理亲子历史、改变自身互动，并共同制定权利边界和回归社会的过渡安排。'; quote='这个问题的解决，绝不是“一个神仙从天而降，用强力符咒把孩子身上的邪毒拔除，然后你送几只烧鸡”这个模式，而是你自己作为子女社会环境的最大要素，必须有所改变。'; evidenceNature='明示家庭系统判断'; boundary='文章方案不等同于临床治疗标准。' }
    [ordered]@{ evidenceId='M14'; ordinal=26; section='痛苦、自我解释与二次负担'; claim='重大事件引发的短期沮丧，与事后把事件解释成整个人无能造成的长期负担，被作者分成两个阶段。'; quote='停止往你的背包里塞土。'; evidenceNature='明示行动隐喻'; boundary='抑郁因果和动物类比均只作作者文本内解释。' }
    [ordered]@{ evidenceId='M15'; ordinal=1284; section='身体差异与恐惧叙事'; claim='身体缺损在文中被重新命名为可以创造独特造型、故事并影响他人恐惧的资源。'; quote='当你遭遇他人所恐惧的变故——无论是残疾还是疾病，就等于你也同时被赐予了成为“恐惧疫苗“的天命。'; evidenceNature='明示意义重构'; boundary='这是作者的英雄化叙事，不外推为所有患者义务。' }
    [ordered]@{ evidenceId='M16'; ordinal=1670; section='出院、社会适应与机构判定'; claim='精神病院出院在文中不取决于反复证明自己正常，而取决于机构是否相信患者能够稳定、自食其力并回归社会。'; quote='想要出精神病院，你需要证明的不是“我很正常”，而是“我无怨无害，希望自食其力”。'; evidenceNature='作者机构逻辑解释'; boundary='具体出院标准和患者判断未作外部核验。' }
    [ordered]@{ evidenceId='M17'; ordinal=737; section='婚检告知与程序留痕'; claim='作者用逐条告知、录像确认和事前同意设计婚检信息边界，并试图以此降低医生事后责任。'; quote='如果想要防患于未然，可以像证券公司开户那样，写一个告知书，请体检双方对着录像机逐条听取告知内容并清晰回答“了解并同意”。'; evidenceNature='明示程序设想'; boundary='免责效力、隐私和第三方知情均未作外部法律判断。' }
    [ordered]@{ evidenceId='M18'; ordinal=2507; section='医院建设与可实现性'; claim='扩建正规医院必须进入土地、拆建、地基、交通、停车、容量和专业协作等实务条件，不能以方向口号替代方案。'; quote='别的不说，“扩建正规医院”这条。'; evidenceNature='明示工程化追问'; boundary='具体城市建设事实只作为作者主张。' }
    [ordered]@{ evidenceId='M19'; ordinal=1769; section='医疗制度比较与定义'; claim='比较公私医疗制度时，作者要求先把费用、服务或其他指标定义为可讨论问题，不用模糊道德词直接封闭论辩。'; quote='如果说是“医院一旦私有化就会出现人均医疗费用暴涨”，那么这个议题尚属可以讨论。'; evidenceNature='明示论证程序'; boundary='医疗费用和制度优劣未作外部验证。' }
    [ordered]@{ evidenceId='M20'; ordinal=1732; section='医疗供给与制度想象'; claim='文章设想中国以可负担医疗和养老服务吸引外国患者，并把这种能力归因于社会主义制度优势。'; quote='将来中国会有一个有意思的现象——韩日乃至欧美的国民大批的赴华做手术治疗，用他们私人的资金来享受中国医疗服务。'; evidenceNature='作者未来预测'; boundary='产业、费用和制度比较均未作外部事实核验。' }
    [ordered]@{ evidenceId='M21'; ordinal=1344; section='公共财富与医疗可及性'; claim='医疗保障被写成国民分享公共财富的一部分；私人账户增加不等于公共服务可及性同步增加。'; quote='因为这份个人财富真正的意义并不是简单的拿来变成吃喝而已，它在本质上还可以被认为是你个人对公共财富的分享资格。'; evidenceNature='明示财富定义'; boundary='国家比较和费用推演只作作者文本内判断。' }
    [ordered]@{ evidenceId='M22'; ordinal=3836; section='疫情中的低风险支持'; claim='疫情中非前线地区保持高谨慎，被作者解释为释放本地医疗余量、支持前线医护轮休的一种间接行动。'; quote='如果你在非武汉非湖北地区，那么这段时间对待任何疾病风险都保持高谨慎策略，好让你本地的医疗系统可以放心派出援助。'; evidenceNature='明示行动建议'; boundary='针对2020年具体疫情情境。' }
    [ordered]@{ evidenceId='M23'; ordinal=3584; section='公共卫生与下一场传染病'; claim='疫苗和医疗技术只处理具体病原体，作者把未知传染病准备放在公共卫生制度、弱国卫生能力和国际合作上。'; quote='真正的应对，不是依靠医疗技术的事后抵抗，而只能依靠强有力的公共卫生制度，以及对穷国、弱国的卫生体系的大力援助。'; evidenceNature='明示公共卫生判断'; boundary='生态、流行病和国家能力预测未作外部核验。' }
    [ordered]@{ evidenceId='M24'; ordinal=3856; section='超级城市与系统防疫'; claim='高密度城市的效率与传染病脆弱性被放入同一系统；作者提出医学进步和强社会感知、判断、干预两条路线。'; quote='无论你现在如何繁荣昌盛，如果你没有系统的解决传染病问题，目前的人口密度和超级城市形态就都是等待着爆炸的未爆弹。'; evidenceNature='作者系统风险判断'; boundary='封城、监测和产业判断只记录文本立场。' }
    [ordered]@{ evidenceId='M25'; ordinal=2643; section='医学信息、权威与行政'; claim='医学科普信息被作者视为能够强烈改变公共行为的权威，因此其传播不被理解成与政治和行政完全分离。'; quote='少扯什么“科学与政治无关”。'; evidenceNature='明示政治判断'; boundary='具体平台与行政制度主张未作外部裁决。' }
)

$corpus = [Collections.Generic.List[object]]::new()
foreach ($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($CorpusPath))) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $corpus.Add(($line | ConvertFrom-Json))
}

$rows = [Collections.Generic.List[object]]::new()
$failures = [Collections.Generic.List[object]]::new()
foreach ($item in $items) {
    $article = $corpus[$item.ordinal - 1]
    $quoteOk = ([string]$article.text).Contains([string]$item.quote, [StringComparison]::Ordinal)
    if (-not $quoteOk) {
        $failures.Add([pscustomobject]@{ evidenceId=$item.evidenceId; ordinal=$item.ordinal; title=$article.title; quote=$item.quote })
    }
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

$rows | Export-Csv -LiteralPath ([IO.Path]::GetFullPath($OutputPath)) -NoTypeInformation -Encoding utf8BOM
$stats = [ordered]@{
    corpusArticles = $corpus.Count
    evidenceRows = $rows.Count
    uniqueEvidenceIds = @($rows.evidenceId | Sort-Object -Unique).Count
    uniqueArticleIds = @($rows.id | Sort-Object -Unique).Count
    quoteFailures = $failures.Count
    failures = @($failures)
    status = if ($corpus.Count -eq 4050 -and $rows.Count -eq 25 -and $failures.Count -eq 0) { 'PASS' } else { 'REVIEW' }
}
$stats | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath ([IO.Path]::GetFullPath($StatsPath)) -Encoding utf8
$stats | ConvertTo-Json -Depth 6

if ($failures.Count -gt 0) { exit 1 }
