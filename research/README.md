# 岐伯（q9adg）公开文本研究集

本目录是对 `sooon-q9adg-articles.jsonl` 中4,050篇公开文本的系统研究。目标不是替作者建立教义，也不是摘录“金句”，而是在可复核文本证据上重建其反复出现的问题意识、概念关系、论证程序、应用领域与内在张力。

实时进度、严格核验数量和未完成项见 [`当前进度与质量.md`](当前进度与质量.md)。

## 逐篇细读主体

宏观论文只承担研究地图和跨文比较功能；逐篇细读记录在 [`close-reading`](close-reading/README.md) 中，是本项目“充分理解每篇文章”的主体成果。当前已完成并校验 `4050/4050` 篇，连续覆盖序号 `0001—4050`，无重复序号、无错误 ID、无缺失 ID。项目已完成逐篇细读，未列入批次文档的文章为 0 篇。

细读分包、4050 条稳定索引和校验脚本已经落盘：

- `close-reading/packets/`：每 5 篇一个原文包
- `close-reading/batch-*.md`：逐篇细读记录；本轮以每个子 agent 10 篇的批量方式完成，最后一批为 5 篇
- `close-reading/index.csv`：序号、ID、题目、日期、URL 和批次映射
- `scripts/build_close_reading_packets.ps1`：重建原文包
- `scripts/build_close_reading_index.ps1`：重建索引
- `scripts/validate_close_reading.ps1`：检查覆盖、重复、ID 错链和缺失字段

阶段性检查：

```powershell
pwsh -NoLogo -NoProfile -File .\research\scripts\validate_close_reading.ps1
```

## 语料边界

- 抓取时间：2026-07-17
- 文本时间：2017-09-08 至 2026-07-17
- 有效记录：4,050；ID 唯一记录：4,050；JSON 解析失败：0
- 正文字符总量：4,620,564；篇均 1,140.88；中位数 883
- 来源平台包括知乎、爱发电等，原始 URL 保留在每篇记录和研究索引中
- 本研究只能讨论这批公开文本呈现的“文本作者形象”，不推断作者未公开的个人身份、动机或现实行为

## 论文目录

当前共35篇成文研究：`research/papers` 中34篇编号研究文本，以及根目录1篇总体系论文。编号文本同时包含方法、语料、数据、概念、命题、历时和领域专题，不把所有文件夸大为完成度相同的专题论文。论文正文直接引用的文章ID均须通过引用审计在原始JSONL中核验。

1. [研究方法与证据规范](papers/00_研究方法与证据规范.md)
2. [语料画像：九年四千篇问答的规模、结构与研究边界](papers/01_语料画像.md)
3. [实践伦理的工程学：思想体系总论](papers/02_实践伦理的工程学_思想体系总论.md)
4. [伦理作为社会技术：权力、互惠与社会资本](papers/03_伦理作为社会技术_权力互惠与社会资本.md)
5. [从基本照护到家族记忆：家庭、亲属与代际秩序](papers/04_家庭与亲属秩序.md)
6. [从愿人得好到再次自愿：亲密关系、婚姻与分离秩序](papers/05_亲密关系与婚恋.md)
7. [职场组织与协作：产出、分功与体谅](papers/06_职场组织与协作.md)
8. [从服从世界到治理处境：思想体系长篇总论](papers/07_从服从世界到治理处境_思想体系总论.md)
9. [从有质量的错误到教育权柄：学习、能力形成与教育秩序](papers/08_可错知识与教育实践.md)
10. [从共同世界到可修正行动：知识、证据与论证程序](papers/09_定义达意与批评_论证修辞研究.md)
11. [财富、劳动与经济伦理](papers/10_财富劳动与经济伦理.md)
12. [上帝、自然法与可持续性：宗教语言和世俗论证](papers/11_宗教自然法与世俗论证.md)
13. [国家、法律、秩序与公民异议](papers/12_国家法律秩序与公民异议.md)
14. [从工业基础到文明眠种：技术、产业、智能与历史继承](papers/13_技术文明产业路径与历史经验.md)
15. [心理主体修复与情绪劳动](papers/14_心理主体修复与情绪劳动.md)
16. [从公共论辩到生活伦理：历时演变研究](papers/15_从公共论辩到生活伦理_历时演变研究.md)
17. [从平权到不被物化：性别、身体、性、同意与照料](papers/16_性别身体性与同意.md)
18. [结构化精读概念网络与命题分布](papers/17_全量概念网络与命题分布.md)
19. [责任、自由与成本：跨域结构](papers/18_责任自由成本的跨域结构.md)
20. [内部张力与条件差异](papers/19_内部张力与条件差异.md)
21. [核心概念词典与语义结构](papers/20_核心概念词典与语义结构.md)
22. [从作者术语到行动语法](papers/21_作者术语与行动语法.md)
23. [核心命题谱系与论证类型](papers/22_核心命题谱系与论证类型.md)
24. [方法与稳健性附录：平台控制、原词检索与文章配对](papers/23_平台控制后的概念迁移与历时配对.md)
25. [条件不是附注：二十五组内部张力的扩展重建](papers/24_扩展内部张力与条件矩阵.md)
26. [从病患主体到公共卫生：医疗、疾病与照料秩序](papers/25_医疗疾病与照料秩序.md)
27. [从怀疑到重返合作：犯罪、刑罚与司法秩序](papers/26_犯罪刑罚与司法秩序.md)
28. [从胜利定义到修和之礼：战争、军事与外交秩序](papers/27_战争军事外交与大国秩序.md)
29. [从价值辨认到秩序中心：艺术、审美与文化生产](papers/28_艺术审美与文化生产.md)
30. [从有根消息到公共器具：媒体、舆论与公共认知秩序](papers/29_媒体舆论与公共认知秩序.md)
31. [从必死信念到历史存在：死亡、祭祀与纪念秩序](papers/30_死亡祭祀与纪念秩序.md)
32. [从文化认同到与异己共存：民族、族群与身份秩序](papers/31_民族族群与身份秩序.md)
33. [从应付自然到管理文明：生态、能源与自然秩序](papers/32_生态能源与自然秩序.md)
34. [从提问者到文明协调：人工智能、机器与未来秩序](papers/33_人工智能机器与未来秩序.md)
35. [岐伯文本的行动—关系—秩序体系：总论](../研究总论_内部观点重建.md)

推荐先读 00、01，再对照阅读 02 与 07。前者用“实践伦理工程学”解释关系机制，后者从本体论、认识论、人类学、价值论和秩序论重建完整体系。两者是竞争性、互补性的研究解释，不被强行合并为作者自称的教义。

截至2026-07-28，15号保留为历时解释主文；23号重构为方法与稳健性附录，集中报告平台控制、34词检索、24篇平衡配对、16篇系统替代/挑战案例、Lexical顶层引述排除、2026截断、完整月份、年度等权、逐年剔除、字符密度和固定长度四分位标准化。构建完整性为 `PASS`；真实解释敏感性标记为 `REVIEW`：责任与自由在部分窗口、年度或篇幅口径下改变局部方向，不能写成已经证明思想转向或已排除题材与篇幅影响。20号核心概念词典的30项代表证据均重新核对，其中17项更换或扩充代表短引；代表性判断来自语义审读，机器验证只证明ID、标题和连续短引匹配。

专题论文已完成理论转化审校。03—09号和25号在已有证据上新增差异化的变量、转换机制和失灵条件；10—16号及26—33号经逐篇检查，已经具有跨层命题链、问题模型、条件矩阵或反馈循环，不再机械叠加同义框架。审计口径与逐篇处理见 `review/theoretical-transformation-audit.md`。

## 数据与复现

### 作者视角证据层

逐篇精读完成后，另建了 `data/author_view_evidence.jsonl` 作为机器可检索的作者视角证据层。它按原始文章序号逐条对应 4,050 篇，保留问题语境、本文主旨、论证推进、本文概念用法、行动与伦理判断、修辞与语气、正文短引和忠实概括，并回填原始语料的标题、日期、ID 与 URL。

证据优先级固定为：

1. `sooon-q9adg-articles.jsonl` 原始正文及其元数据；
2. `close-reading/batch-*.md` 逐篇精读记录；
3. `data/author_view_evidence.jsonl` 由精读记录抽出的结构化索引。

结构化索引是解释和定位工具，不替代原文。`faithfulSummary` 是研究者对单篇文章的忠实概括，不是岐伯自称的统一理论；任何跨文综合、概念关系或体系结论都必须回查多篇原文。精读记录中的“限定与张力”可能包含研究者对未展开处的提示，默认不进入作者视角证据层，不能直接改写成岐伯的判断。

可用以下命令重建并检查证据层：

```powershell
pwsh -NoLogo -NoProfile -File .\research\scripts\build_author_view_evidence.ps1
Get-Content .\research\data\author_view_evidence.stats.json
```

- `data/corpus_index.csv`：文章级研究索引，含 ID、题名、问题、URL、日期、长度和宽口径主题标签
- `data/system_coverage_matrix.csv`：领域、概念、论文与证据层覆盖矩阵
- `data/system_concept_article_counts.csv`：23组概念在4,050篇中的召回覆盖率，含“民族与身份”“生态与自然”“人工智能与机器”三组专题路由
- `data/article_system_concept_map.csv`：4,050篇逐篇对应到23组体系概念的全量映射，ID唯一且零未分类
- `data/article_paper_route_map.csv`：4,050篇逐篇对应到可继续回查的专题论文，零未路由；它是研究导航，不表示每篇已经在论文正文逐字引用
- `data/system_concept_cooccurrence.csv`：概念共现文章数和比例
- `data/system_concept_period_rates.csv`：2017—2020、2021—2023、2024—2026三阶段概念召回率
- `data/system_concept_network.stats.json`：概念网络构建统计与状态
- `data/core_concept_dictionary.csv`：30项作者核心概念的用法、相邻概念、边界、条件、代表原文和证据性质
- `data/core_concept_dictionary.stats.json`：词典术语唯一性、代表ID、标题和逐字短引校验结果
- `data/core_term_concordance.csv`：直接从原始正文建立的34词逐段索引，共13,622条“文章—术语”记录
- `data/core_term_counts.csv`：34个作者原词的精确文章覆盖数和出现次数
- `data/core_term_year_counts.csv`：34个作者原词的逐年文章覆盖率和出现次数
- `data/core_term_period_platform_counts.csv`：34个原词按时期与平台拆分后的文章覆盖率和出现次数
- `data/core_term_quote_role_sensitivity.csv`：4,050篇Lexical结构排除顶层引述块后的34词时期×平台复算，共204个统计单元
- `data/core_term_quote_role_sensitivity.stats.json`：复算覆盖、异常差值和最大篇级覆盖率变化；当前状态 `PASS`
- `data/diachronic_zhihu_year_term_sensitivity.csv`：8词知乎逐年作者文本统计
- `data/diachronic_zhihu_period_term_sensitivity.csv`：完整、排除2026及两种1—6月窗口的阶段统计
- `data/diachronic_zhihu_leave_one_year_out_sensitivity.csv`：2018—2026逐年剔除的轨迹诊断
- `data/diachronic_zhihu_equal_year_weight_sensitivity.csv`：阶段内年度等权结果
- `data/diachronic_zhihu_length_standardized_sensitivity.csv`：固定全期长度四分位直接标准化结果
- `data/diachronic_zhihu_sensitivity.stats.json`：输入哈希、窗口规则、分母、零长度文章及完整性/解释诊断；`status=PASS`、`interpretiveStatus=REVIEW`
- `data/diachronic_alternative_case_pool.csv`：8条轨迹各1篇替代、1篇挑战，共16篇
- `data/diachronic_alternative_case_pool.stats.json`：候选编号、角色配对、Lexical节点、问题字段、核心重合与短引审计；当前状态 `PASS`
- `data/core_proposition_genealogy.csv`：39条核心命题的前提、推理动作、行动结论、条件、反驳对象、支持/对照ID和历时位置
- `data/core_proposition_genealogy.stats.json`：39条命题的ID、元数据和代表短引逐字校验结果
- `data/core_evidence_registry.csv`：20套专题/历时核心证据统计汇总，当前20/20状态为 `PASS`
- `data/paper_inventory.csv`：34篇编号研究文本的字符量、标题层级和唯一UUID引用数清单
- `data/paper_named_source_coverage_audit.csv`：论文中可唯一识别的篇名与来源入口覆盖审计
- `data/paper_named_source_coverage_audit.stats.json`：1,233组篇名提及，歧义0、缺失入口0，状态 `PASS`
- `data/medical_care_candidates.csv`：由28个临床相关原词召回的554篇医疗、疾病与照料候选，含分类、相关度和清洗作者视角字段
- `data/medical_care_candidates.stats.json`：554篇候选、6类分层、ID唯一性和证据字段完整性校验
- `data/medical_care_core_evidence.csv`：25篇医疗核心证据，含命题、证据性质、边界、原文连续短引和元数据
- `data/medical_care_core_evidence.stats.json`：25条医疗核心短引逐字校验结果
- `data/crime_justice_candidates.csv`：由27个犯罪司法原词召回的732篇候选，含罪责、刑罚、审判复核和警察执法分类
- `data/crime_justice_candidates.stats.json`：732篇候选、4类分层、ID唯一性和证据字段完整性校验
- `data/crime_justice_core_evidence.csv`：30篇司法核心证据，覆盖8个问题层，含作者命题、证据性质、适用边界和原文连续短引
- `data/crime_justice_core_evidence.stats.json`：30个唯一ID、核心字段缺失0、逐字短引失败0，状态 `PASS`
- `data/war_diplomacy_candidates.csv`：由37个战争、军事、武器、外交和动员原词召回的1,057篇宽口径候选，保留命中位置与五类路由
- `data/war_diplomacy_candidates.stats.json`：1,057篇唯一候选、五类分层、核心证据字段缺失0，状态 `PASS`
- `data/war_diplomacy_screening.csv`：从宽候选中保留65篇标题/问题直接命中及224篇双窄词命中，合并去重后形成261篇优先精读队列
- `data/war_diplomacy_screening.stats.json`：1,057→261两级召回、唯一ID与证据字段完整性校验，状态 `PASS`
- `data/war_diplomacy_core_evidence.csv`：32篇战争军事外交核心证据，覆盖8个问题层，含命题、证据性质、边界和原文连续短引
- `data/war_diplomacy_core_evidence.stats.json`：32个唯一ID、八层各4篇、核心字段缺失0、逐字短引失败0，状态 `PASS`
- `data/art_culture_candidates.csv`：以47个艺术、审美、文学、影像、创作和文化遗产原词召回的1,747篇宽口径候选，排除“美”对“美国”的系统误召回
- `data/art_culture_screening.csv`：从宽候选中保留190篇标题/问题直接命中及288篇双窄词命中，合并去重后形成404篇优先精读队列
- `data/art_culture_screening.stats.json`：1,747→404两级召回、唯一ID和证据字段完整性校验，状态 `PASS`
- `data/art_culture_core_evidence.csv`：36篇艺术审美与文化生产核心证据，覆盖6个问题层，含作者命题、证据性质、边界和原文连续短引
- `data/art_culture_core_evidence.stats.json`：36个唯一ID、六层各6篇、核心字段缺失0、逐字短引失败0，状态 `PASS`
- `data/media_public_opinion_candidates.csv`：以62个新闻、舆论、宣传、信源、自媒体和平台原词召回的939篇宽候选，保留五类路由
- `data/media_public_opinion_candidates.stats.json`：939篇唯一宽候选、五类覆盖、证据字段缺失0，状态 `PASS`
- `data/media_public_opinion_screening.csv`：从宽候选中保留96篇标题或问题窄词直接命中及239篇双窄词命中，合并去重后形成298篇优先精读队列
- `data/media_public_opinion_screening.stats.json`：939→298两级召回、唯一ID和证据字段完整性校验，状态 `PASS`
- `data/media_public_opinion_core_evidence.csv`：32篇媒体舆论核心证据，覆盖8个问题层，含作者命题、证据性质、边界和原文连续短引
- `data/media_public_opinion_core_evidence.stats.json`：32个唯一ID、八层各4篇、核心字段缺失0、逐字短引失败0，状态 `PASS`
- `data/death_memorial_candidates.csv`：以77个死亡、丧葬、哀悼、祭祀、纪念和遗愿原词召回的872篇宽候选，保留六类路由
- `data/death_memorial_candidates.stats.json`：872篇唯一宽候选、六类覆盖、证据字段缺失0，状态 `PASS`
- `data/death_memorial_screening.csv`：从宽候选中保留59篇标题或问题窄词直接命中及128篇双窄词命中，合并去重后形成159篇优先精读队列
- `data/death_memorial_screening.stats.json`：872→159两级召回、唯一ID和证据字段完整性校验，状态 `PASS`
- `data/death_memorial_core_evidence.csv`：36篇死亡祭祀与纪念核心证据，覆盖6个问题层，含作者命题、证据性质、边界和原文连续短引
- `data/death_memorial_core_evidence.stats.json`：36个唯一ID、六层各6篇、核心字段缺失0、逐字短引失败0，状态 `PASS`
- `data/education_knowledge_candidates.csv`：以125个知识、错误、学习、学校、考试、社会化和论证原词召回的3,726篇宽候选，按8类保留原始命中与作者视角字段
- `data/education_knowledge_candidates.stats.json`：3,726篇唯一宽候选、8类覆盖、证据字段缺失0，状态 `PASS`
- `data/education_knowledge_screening.csv`：将宽候选压缩为851篇双路由优先材料，其中教育、学习与能力形成450篇，认识论、知识与论证523篇，交叉122篇
- `data/education_knowledge_screening.stats.json`：双路由数量、唯一ID和核心字段完整性校验，状态 `PASS`
- `data/education_learning_core_evidence.csv`：48篇教育、学习与能力形成核心证据，覆盖学习本体、能力实践、家庭社会化、教师权柄、学校课堂、考试选拔、高等教育和教育目的8层
- `data/education_learning_core_evidence.stats.json`：48个唯一ID、八层各6篇、47篇筛选证据加1篇原文回查补录、核心字段缺失0、逐字短引失败0，状态 `PASS`
- `data/epistemology_argument_core_evidence.csv`：48篇认识论、知识与论证核心证据，覆盖共同世界、定义、证据、模型、达意、批评、知识生产和不确定决策8层
- `data/epistemology_argument_core_evidence.stats.json`：48个唯一ID、八层各6篇、47篇认识论路由证据加1篇筛选层跨路由补录、核心字段缺失0、逐字短引失败0，状态 `PASS`
- `data/family_kinship_candidates.csv`：以145个家庭、亲属、抚养、赡养、家务、财产和传承原词召回的2,076篇宽候选，保留八类路由和作者视角字段
- `data/family_kinship_screening.csv`：从宽候选中保留510篇标题/问题直接命中及182篇正文多词命中，合并形成692篇优先精读材料
- `data/family_kinship_core_evidence.csv`：48篇家庭与亲属核心证据，覆盖基本照护、父母权柄、养老、扩展亲属、家庭资源、危机照料、日常协作和家族传承八层
- `data/family_kinship_core_evidence.stats.json`：48个唯一ID、八层各6篇、47篇筛选证据加1篇原文补录、核心字段缺失0、逐字短引失败0，状态 `PASS`
- `data/intimacy_relationship_candidates.csv`：以134个恋爱、婚姻、承诺、财产、互惠、冲突、同意和分离原词召回的2,947篇宽候选，保留八类路由
- `data/intimacy_relationship_screening.csv`：从宽候选中保留341篇标题/问题直接命中及434篇正文多词命中，合并形成775篇优先材料
- `data/intimacy_relationship_core_evidence.csv`：48篇亲密关系核心证据，覆盖爱欲定义、择偶形成、承诺联盟、婚姻财务、日常互惠、冲突修复、自由同意和分离路径八层
- `data/intimacy_relationship_core_evidence.stats.json`：48个唯一ID、八层各6篇、47篇筛选证据加1篇原文补录、1处URL尾括号纠正、核心字段缺失0、逐字短引失败0，状态 `PASS`
- `data/workplace_organization_candidates.csv`：以129个劳动、职业、组织、管理和未来工作词召回的3,490篇职场组织宽候选，保留八类路由
- `data/workplace_organization_screening.csv`：从宽候选中保留标题/问题直接命中或正文至少六个职场组织词的1,278篇优先材料
- `data/workplace_organization_core_evidence.csv`：48篇职场组织核心证据，覆盖劳动意义、职业发展、产出交付、协作分功、权柄管理、组织政治、竞争制度和离职未来八层
- `data/workplace_organization_core_evidence.stats.json`：48个唯一ID、八层各6篇、47篇筛选证据加1篇原文补录（`208《好战之徒》`）、核心字段缺失0、逐字短引失败0，状态 `PASS`
- `data/technology_civilization_candidates.csv`：以98个技术、工程、产业、AI、记录、能源和治理词召回的3,007篇技术文明宽候选，保留八类路由
- `data/technology_civilization_screening.csv`：从宽候选中保留235篇标题/问题直接命中及855篇正文双窄词命中，合并去重后形成974篇优先材料
- `data/technology_civilization_core_evidence.csv`：48篇技术文明核心证据，覆盖工程路线、基础设施、产业所有权、劳动失业、AI边界、记录继承、能源环境和技术治理八层
- `data/technology_civilization_core_evidence.stats.json`：48个唯一ID、八层各6篇、47篇筛选证据加1篇原文补录（`80《续白诗》`）、核心字段缺失0、逐字短引失败0，状态 `PASS`
- `data/gender_body_consent_candidates.csv`：以193个性别、身体、欲望、同意、性健康、生育和照料词召回的1,768篇宽候选，保留八类路由
- `data/gender_body_consent_screening.csv`：从宽候选中保留295篇标题/问题直接命中及75篇正文至少五词命中，形成370篇优先材料
- `data/gender_body_consent_core_evidence.csv`：48篇性别身体核心证据，覆盖角色权力、身体外貌、欲望取向、同意暴力、性教育健康、生育选择、照料劳动和尊严信号八层
- `data/gender_body_consent_core_evidence.stats.json`：48个唯一ID、八层各6篇、全部来自筛选层、核心字段缺失0、逐字短引失败0，状态 `PASS`
- `data/ethnicity_identity_candidates.csv`：以97个民族、族群、种族、国籍、移民、语言、殖民和全球化词召回的666篇宽候选，保留八类路由
- `data/ethnicity_identity_screening.csv`：修正普通“歧视”和“全球化”的标题直召回后，从666篇压缩为153篇优先材料
- `data/ethnicity_identity_core_evidence.csv`：48篇民族族群与身份核心证据，覆盖民族共同体、血缘历史、种族歧视、国籍爱国、移民华人、语言同化、殖民帝国和跨群体秩序八层
- `data/ethnicity_identity_core_evidence.stats.json`：48个唯一ID、八层各6篇、全部来自修正后筛选层、核心字段缺失0、逐字短引失败0，状态 `PASS`
- `data/ecology_nature_candidates.csv`：以109个自然、生态、能源、灾害、农业、动物和污染词召回的2,358篇宽候选
- `data/ecology_nature_screening.csv`：从宽候选压缩出的158篇优先材料，其中标题或问题直接命中87篇
- `data/ecology_nature_core_evidence.csv`：48篇生态能源与自然核心证据，八层各6篇，46篇筛选证据加`822、2087`两篇显式补录
- `data/ecology_nature_core_evidence.stats.json`：48个唯一ID、核心字段缺失0、逐字短引失败0，状态 `PASS`
- `data/ai_machine_candidates.csv`：修正英文词内`AI`误召回后形成的276篇人工智能与机器宽候选
- `data/ai_machine_screening.csv`：从宽候选压缩出的89篇优先材料，其中标题或问题直接命中47篇
- `data/ai_machine_core_evidence.csv`：48篇人工智能与机器核心证据，八层各6篇，44篇筛选证据加`769、3339、3676、3989`四篇显式补录
- `data/ai_machine_core_evidence.stats.json`：48个唯一ID、核心字段缺失0、逐字短引失败0，状态 `PASS`
- `data/psychology_subject_candidates.csv`：以87个心理、情绪、主体、咨询、创伤和行动词召回的3,458篇宽候选，保留八类路由
- `data/psychology_subject_screening.csv`：从宽候选压缩出的1,804篇优先材料，其中标题或问题直接命中285篇
- `data/psychology_subject_core_evidence.csv`：48篇心理主体与情绪劳动核心证据，覆盖八个问题层、每层6篇
- `data/psychology_subject_core_evidence.stats.json`：48个唯一ID与ordinal、八层各6篇、代表短引Ordinal失败0，状态 `PASS`
- `data/author_claims.jsonl`：从4,050条作者视角记录抽出的12,150条稳定命题索引（主旨、行动判断、忠实概括三类），不是新增AI观点
- `data/author_view_evidence_clean.jsonl`：句级清除5,794个研究者侧句段、应用2,300个精确字段替换后的作者视角层；原始解释层保留不覆盖，核心字段空值0、研究者泄漏0，状态 `PASS`
- `data/author_claims_clean.jsonl`：由清洗版证据生成的12,150条命题索引
- `data/author_claims.stats.json`：命题索引构建统计
- `data/system_tensions_matrix.csv`：25组跨文内部张力、两端证据ID、共同条件、未统一处和当前处理方式
- `data/claim_review_queue.csv`：按跨域概念密度和论证完整度排序的500篇人工原文核验队列
- `review/claim-review-results.csv`：500篇高风险命题核验权威总表，500个唯一ordinal；主旨483 `PASS`/17 `PARTIAL`，推理498 `PASS`/2 `PARTIAL`，行动152 `PASS`/348 `PARTIAL`，引文179 `EXACT`/291 `PARTIAL`/30 `NONE`，研究者侧泄漏433 `PRESENT`/67 `NONE`
- `review/claim-review-next40-clean-deletion-suggestions.csv`：早期40篇扩充批次的历史中间文件；最终状态以500篇权威总表为准
- `review/paper-author-centering-audit.md`：早期论文纯作者视角审校规则、8篇改写范围和当前结果
- `review/theoretical-transformation-audit.md`：专题论文的证据锚定、变量、转换机制、条件、张力和跨域接口审计；记录本轮8篇直接修订及其余专题不机械增补的理由
- `review/crime-justice-evidence-review.md`：第二模型独立审读的29篇司法证据、43条连续短引及八层内部连接
- `review/media-public-opinion-evidence-review.md`：媒体专题32篇核心原文、八组张力和六环跨文综合的命题支持复核，已修订2处过度综合
- `review/education-learning-evidence-review.md`：教育专题初选逐篇复核、体系结构审查、错层调整、筛选漏召回处理和最终48篇主线程裁决记录
- `review/family-kinship-evidence-review.md`：家庭专题双模型选文审查、三处换文、原文补录、18组张力和过度综合控制记录
- `review/intimacy-relationship-evidence-review.md`：亲密关系专题选文裁决、四条跨文链、18组张力和作者归属控制记录
- `review/workplace-organization-evidence-review.md`：职场专题双模型选文审查、八层核心冻结、补录说明、20组张力和过度综合控制记录
- `review/technology-civilization-evidence-review.md`：技术专题核心冻结、日期校正、跨层材料裁决、24组条件关系与内部张力和长篇重写后的过度综合控制记录
- `review/gender-body-consent-evidence-review.md`：性别身体专题核心冻结、六篇筛选漏召回外围材料、五条对读路径、24组条件关系和过度综合控制记录
- `review/ethnicity-identity-evidence-review.md`：民族族群专题独立选文、筛选漏召回修正、八层核心冻结、六条跨文链和过度综合控制记录
- `review/ecology-nature-evidence-review.md`：生态专题独立选文、两篇漏召回补录、误召回、八层核心冻结、六条跨文链和短引字符修正记录
- `review/ai-machine-evidence-review.md`：AI专题检索边界修正、两套独立选文分歧、四篇补录、主线程裁决和短引字符修正记录
- `data/claim_support_audit_500.csv`：500篇主旨/论证/行动判断四字片段覆盖率、短引状态、外部提醒删除量和风险排序
- `data/source_quote_validation_all.csv`：清洗证据层11,978条登记短引的严格逐字检查结果
- `data/source_quote_validation_failures.csv`：最终为空；未按 `StringComparison.Ordinal` 逐字命中的短引为0
- `data/source_quote_validation.stats.json`：严格短引定位统计；11,978条全部逐字命中，状态 `PASS`
- `review/quote-corrections-reviewed.csv`：500篇异常审计中的26条人工决定；16条以完整原句纠正，10条拒绝直接引文资格
- `review/quote-corrections-consolidated.csv`：全量152条异常中的81条满足原短引完整包含于原文句子的机械纠正
- `review/quote-manual-decisions.csv`：对剩余71条的逐篇原文人工决定；14条拆为54个逐字定位原句段，57条标为 `REJECT_DIRECT_QUOTE`
- `data/verified_source_quotes.jsonl`：旧版归一化定位层，仅作历史记录；严格逐字核验以 `source_quote_validation_all.csv` 为准
- `data/verified_source_quotes.stats.json`：旧版引文层统计，不再作为严格逐字结论
- `data/paper_citation_audit.stats.json`：34篇编号研究文本的1,250组论文—文章引用审计，822个唯一ID全部存在于原始语料；URL-only引用为0
- `review/claim-review-results.csv`：500篇高风险命题核验权威总表，A、B、C三批严格结果均已合并，500个唯一ordinal
- 500篇严格结果合计：主旨483 `PASS`/17 `PARTIAL`，推理498 `PASS`/2 `PARTIAL`，行动152 `PASS`/348 `PARTIAL`，引文179 `EXACT`/291 `PARTIAL`/30 `NONE`，研究者侧泄漏433 `PRESENT`/67 `NONE`
- `review/strict-quote-batches-100/strict-quote-review-manifest.csv`：第一阶段896篇、1,110条严格短引复审记录，9批已全部审计并应用
- `review/strict-quote-residual-batches-100/strict-quote-review-manifest.csv`：第二阶段1,027篇、1,534条残余候选，10个100篇批次加27篇尾批，全部审计并应用
- `data/strict_quote_residual_batch_summary.stats.json`：第二阶段1,485条精确替换、9条改写、40条删除，11批全部批准，状态 `PASS`
- `review/strict-quote-auto-audit-80-decisions.csv`：80条高风险自动映射的独立审计；71接受、8编辑、1拒绝，拦截1条主语反转
- `scripts/validate_all_paper_direct_quotes.ps1`：验证34篇论文的中文直接短引均能在所引原文中按Ordinal命中
- `scripts/validate_paper_quote_roles.ps1`：解析Lexical结构，确保论文直接短引命中作者正文，而不是仅命中提问或引述块
- `scripts/build_core_term_quote_role_sensitivity.ps1`：对4,050篇Lexical结构排除顶层引述块并重算34词时期×平台覆盖
- `scripts/build_diachronic_zhihu_sensitivity.ps1`：重建8词知乎年度、窗口、逐年剔除、等年权重和固定长度四分位敏感性
- `scripts/build_diachronic_alternative_case_pool.ps1`：重建8条轨迹的16篇替代/挑战案例，并验证逐轨迹角色、Lexical节点和短引
- `scripts/promote_paper_url_only_citations.ps1`：为能映射到原始语料的论文URL引用补入稳定UUID
- `scripts/promote_paper_named_source_citations.ps1`：为论文中可唯一映射的篇名补入稳定ID、日期和原始URL入口
- `scripts/validate_paper_named_source_coverage.ps1`：审计篇名提及是否均有可追踪来源入口
- `scripts/validate_paper_citations.ps1`：验证全部论文引用ID存在，并将任何URL-only引用列为非PASS
- `scripts/build_zhihu_series.ps1`：由最终论文重建1篇系列总序、34篇知乎稿和发布清单
- `data/corpus_stats.json`：总体统计、年度/月度分布、概念词篇级与出现次数
- `data/theme_examples.json`：各召回主题的前 25 条候选例文，用于人工抽样，不代表典型性排序
- `data/07_思想体系证据.csv`：长篇总论使用的 34 条核心证据，含短引、用途和证据性质
- `scripts/build_corpus_index.ps1`：从原始 JSONL 重建上述数据；使用 PowerShell 7 执行
- `scripts/build_core_term_concordance.ps1`：从原始正文重建核心术语逐段索引、总体统计和逐年分布
- `scripts/validate_core_concept_dictionary.ps1`：验证30项词典的必填字段、代表文章和逐字短引
- `scripts/build_core_proposition_genealogy.ps1`：从原始正文补全并验证39条核心命题谱系的元数据、关联ID和代表短引
- `scripts/build_medical_care_candidates.ps1`：从原始正文和清洗证据层重建554篇医疗专题候选
- `scripts/build_medical_care_core_evidence.ps1`：重建25篇医疗核心证据并逐字验证代表短引
- `scripts/build_crime_justice_candidates.ps1`：从原始正文和清洗证据层重建732篇犯罪刑罚与司法候选
- `scripts/build_crime_justice_core_evidence.ps1`：重建30篇司法核心证据并以 `Ordinal` 连续子串逐条验证代表短引
- `scripts/build_war_diplomacy_candidates.ps1`：从原始正文和清洗证据层重建战争军事与外交宽口径候选；战略、胜利等比喻性命中须在核心层排除
- `scripts/build_war_diplomacy_screening.ps1`：以标题/问题直接命中或正文至少两个窄词，将1,057篇候选压缩为261篇优先队列，同时保留外围候选
- `scripts/build_war_diplomacy_core_evidence.ps1`：从261篇优先队列重建32篇八层核心证据，并逐条验证元数据和原文连续短引
- `scripts/build_art_culture_candidates.ps1`：从原始正文和清洗证据层重建艺术审美与文化生产宽候选及六类路由
- `scripts/build_art_culture_screening.ps1`：以标题/问题直接命中或正文至少两个窄词，将1,747篇候选压缩为404篇优先队列
- `scripts/build_art_culture_core_evidence.ps1`：从404篇优先队列重建36篇六层核心证据，并逐条验证元数据和原文连续短引
- `scripts/build_media_public_opinion_candidates.ps1`：从原始正文和清洗证据层重建媒体舆论宽候选及五类路由
- `scripts/build_media_public_opinion_screening.ps1`：仅以标题或问题中的窄媒体词、或全文至少两个窄词，将939篇宽候选压缩为298篇优先队列
- `scripts/build_media_public_opinion_core_evidence.ps1`：从298篇优先队列重建32篇八层核心证据，并逐条验证元数据和原文连续短引
- `scripts/build_death_memorial_candidates.ps1`：从原始正文和清洗证据层重建死亡祭祀与纪念宽候选及六类路由
- `scripts/build_death_memorial_screening.ps1`：仅以标题或问题中的窄词、或全文至少两个窄词，将872篇宽候选压缩为159篇优先队列
- `scripts/build_death_memorial_core_evidence.ps1`：从159篇优先队列重建36篇六层核心证据，并逐条验证元数据和原文连续短引
- `scripts/build_education_knowledge_candidates.ps1`：从原始正文和清洗证据层重建3,726篇认识论与教育宽候选及八类路由
- `scripts/build_education_knowledge_screening.ps1`：按标题/问题直接命中或正文至少六个路由窄词，将宽候选压缩为教育与认识论两条可分别精读的优先队列
- `scripts/build_education_learning_core_evidence.ps1`：冻结48篇教育核心证据；允许显式登记筛选漏召回的原文补录，并以 `Ordinal` 验证元数据和连续短引
- `scripts/build_epistemology_argument_core_evidence.ps1`：冻结48篇认识论核心证据；显式登记筛选层跨路由补录，并以 `Ordinal` 验证元数据和连续短引
- `scripts/build_family_kinship_candidates.ps1`：从原始正文和清洗证据层重建2,076篇家庭亲属宽候选及八类路由
- `scripts/build_family_kinship_screening.ps1`：以标题/问题直接命中或正文至少五个家庭亲属词，将宽候选压缩为692篇优先材料
- `scripts/build_family_kinship_core_evidence.ps1`：冻结48篇家庭亲属核心证据，显式登记筛选漏召回的《探病》，并以 `Ordinal` 验证元数据和连续短引
- `scripts/build_intimacy_relationship_candidates.ps1`：从原始正文和清洗证据层重建2,947篇亲密关系宽候选及八类路由
- `scripts/build_intimacy_relationship_screening.ps1`：以标题/问题直接命中或正文至少五个亲密关系词，将宽候选压缩为775篇优先材料
- `scripts/build_intimacy_relationship_core_evidence.ps1`：冻结48篇亲密关系核心证据，显式登记筛选漏召回的《小小红花》，并以 `Ordinal` 验证元数据和连续短引
- `scripts/build_workplace_organization_candidates.ps1`：从原始正文和清洗证据层重建3,490篇职场组织宽候选及八类路由
- `scripts/build_workplace_organization_screening.ps1`：以标题/问题直接命中或正文至少六个职场组织词，将宽候选压缩为1,278篇优先材料
- `scripts/build_workplace_organization_core_evidence.ps1`：冻结48篇职场组织核心证据，显式登记筛选漏召回的《好战之徒》，并以 `Ordinal` 验证元数据和连续短引
- `scripts/build_technology_civilization_candidates.ps1`：从原始正文和清洗证据层重建3,007篇技术文明宽候选及八类路由
- `scripts/build_technology_civilization_screening.ps1`：以标题/问题直接命中或正文至少两个技术窄词，将宽候选压缩为974篇优先材料
- `scripts/build_technology_civilization_core_evidence.ps1`：冻结48篇技术文明核心证据，显式登记筛选漏召回的《续白诗》，并以 `Ordinal` 验证元数据和连续短引
- `scripts/build_gender_body_consent_candidates.ps1`：从原始正文和清洗证据层重建1,768篇性别身体宽候选及八类路由
- `scripts/build_gender_body_consent_screening.ps1`：以标题/问题直接命中或正文至少五个不同词，将宽候选压缩为370篇优先材料
- `scripts/build_gender_body_consent_core_evidence.ps1`：冻结48篇性别身体核心证据，并以 `Ordinal` 验证48个唯一ID、日期和连续短引
- `scripts/build_ethnicity_identity_candidates.ps1`：从原始正文和清洗证据层重建666篇民族族群与身份宽候选及八类路由
- `scripts/build_ethnicity_identity_screening.ps1`：以标题/问题直接命中或正文至少三个不同窄词，将宽候选压缩为153篇优先材料
- `scripts/build_ethnicity_identity_core_evidence.ps1`：冻结48篇民族族群与身份核心证据，并以 `Ordinal` 验证元数据和连续短引
- `scripts/build_ecology_nature_candidates.ps1`：从原始正文和清洗证据层重建2,358篇生态能源与自然宽候选
- `scripts/build_ecology_nature_screening.ps1`：以标题/问题直接命中或正文至少五个不同窄词，将宽候选压缩为158篇优先材料
- `scripts/build_ecology_nature_core_evidence.ps1`：冻结48篇生态能源与自然核心证据，显式登记`822、2087`两篇补录，并以`Ordinal`验证元数据和连续短引
- `scripts/build_ai_machine_candidates.ps1`：以英文字母边界和中文AI词从原始正文重建276篇人工智能与机器宽候选
- `scripts/build_ai_machine_screening.ps1`：以标题/问题直接命中或正文至少两个不同AI窄词，将宽候选压缩为89篇优先材料
- `scripts/build_ai_machine_core_evidence.ps1`：冻结48篇人工智能与机器核心证据，显式登记`769、3339、3676、3989`四篇补录，并以`Ordinal`验证元数据和连续短引
- `scripts/build_psychology_subject_candidates.ps1`：从原始正文和清洗证据层重建3,458篇心理主体宽候选及八类路由
- `scripts/build_psychology_subject_screening.ps1`：以标题/问题直接命中或正文至少四个不同心理主体词，将宽候选压缩为1,804篇优先材料
- `scripts/build_psychology_subject_core_evidence.ps1`：冻结48篇心理主体与情绪劳动核心证据，以`Ordinal`验证48个唯一ID、日期和连续短引

```powershell
pwsh -NoLogo -NoProfile -File .\research\scripts\build_corpus_index.ps1
```

## 引证规则

论文采用“标题 + 日期 + 文章 ID + 原始 URL”的内部引证。正文中的概括分为三种证据强度：

1. **明示命题**：原文直接定义或断言，可用短引语核对。
2. **重复模式**：在跨文本抽样或检索中反复出现，但不是作者自称的统一理论。
3. **研究者解释**：用社会理论、伦理学或组织研究术语对文本作出的重构，必须明确标示为解释。

宽口径关键词标签只用于检索。它们允许一文多类，也可能误召回，不能直接解释为主题占比或立场强度。

## 当前定稿状态

医疗、司法、战争、艺术、媒体、死亡、教育、认识论、家庭、亲密关系、职场、财富、宗教、心理、技术、性别、民族、生态和人工智能专题均已建立候选层、核心证据层和独立成文层。500篇高风险命题核验、第一阶段896篇短引复审和第二阶段1,027篇残余复审均已完成；clean层11,978条登记短引全部按 `StringComparison.Ordinal` 命中。20套专题核心证据共839条，逐字定位失败0。15号与23号已经分为历时解释主文和方法附录；后者已完成窗口、年度、篇幅和16篇替代池敏感性，并如实保留责任与自由的局部不稳定。20号词典完成17项代表证据语义复审；1,233组可唯一识别篇名均有来源入口；35篇知乎稿已经由当前论文重建并校验为 `READY`。宽口径召回始终只用于研究队列和跨文抽样，不直接当作作者立场或主题占比；全套研究只重建岐伯的判断、推理、条件和建议，不加入AI自身的伦理、政治、医学、科技或法律裁决。
