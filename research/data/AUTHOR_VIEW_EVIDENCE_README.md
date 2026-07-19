# 岐伯作者视角证据层

本目录的 `author_view_evidence.jsonl` 是把 4,050 篇逐篇精读记录整理成的作者视角证据索引。它服务于后续专题论文和总论的检索、分组与回查，不替代原文。

## 证据优先级

1. `sooon-q9adg-articles.jsonl` 是最终证据，包含原始标题、日期、正文和 URL。
2. `close-reading/batch-*.md` 是逐篇解释层，记录问题语境、主旨、论证、概念、行动判断、修辞、短引和忠实概括。
3. `author_view_evidence.jsonl` 是从解释层提取的纯作者视角字段，排除了“限定与张力”等研究者批评性字段。

跨文章结论必须回到多篇原文核对；单篇 `faithfulSummary` 只是该篇的忠实概括，不是岐伯自称的完整理论。研究者不得把自己的规范判断、外部事实核验或理论术语写成作者主张。

## 字段

每行包含稳定序号、原始 ID、原始标题、原始日期和原始 URL，以及 `questionContext`、`thesis`、`reasoning`、`conceptsInArticle`、`authorActionAndEthicalJudgments`、`rhetoric`、`sourceQuotes`、`faithfulSummary`。原始元数据以 JSONL 为准；精读中的 Markdown 包裹、URL 主机别名和日期显示差异不会改变规范输出。

## 重建与校验

```powershell
pwsh -NoLogo -NoProfile -File .\research\scripts\build_author_view_evidence.ps1
```

统计结果写入 `author_view_evidence.stats.json`。`status: PASS` 表示 4,050 个序号均有记录、ID 无错链且作者视角核心字段无缺失。原始 JSONL 不会被该脚本修改。
## 引文层说明

`sourceQuotes` 保留逐篇精读记录中的短引候选，属于解释层字段，不能未经核对直接当作逐字原文。`verified_source_quotes.jsonl` 保留在原始 `text` 中完全、局部定位或经人工决定保留的原句。初始152条无法定位内容中，81条替换为完整原句；剩余71条经逐篇回查后，14条拆为54个带字符位置的逐字原句段，57条明确标为 `REJECT_DIRECT_QUOTE`。当前未解决队列为0。

## 作者原词层与研究概念层

`core_term_concordance.csv` 直接从原始正文提取34个核心术语所在段落，保留文章ID、日期、段落序号和逐字段落；`core_term_counts.csv` 与 `core_term_year_counts.csv` 分别记录总体和逐年精确出现情况。这一层可以证明作者是否实际使用某个词，但单独的词语出现仍不能证明其具体立场。

`system_concept_*` 文件使用宽口径同义和邻近词召回，用于寻找概念候选与跨文关系。它不能证明命中文章都采用同一词义，也不能把检索类目写成作者自称理论。例如，宽口径“净输出与不掠夺”类目命中427篇，而正文直接使用“净输出”18篇、“不掠夺”5篇。概念解释应依次核对作者原词、明示定义、全文论证和跨文条件差异。

`author_view_evidence_clean.jsonl` 是在此基础上对主旨、行动判断和忠实概括中的高置信度研究者外部提醒句进行句级隔离后的版本，共移除3,170句；2个字段因清洗后为空而回退原值，保留原始解释层以便审计。清洗不是把研究者概括变成原文，而是减少外部规范句进入作者视角检索的机会。
