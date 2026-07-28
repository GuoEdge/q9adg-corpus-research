# q9adg（岐伯）公开文本系统研究

本仓库整理并研究q9adg（岐伯）截至2026年7月17日公开发表的4,050篇文章与动态，目标是在可复核证据基础上重建作者的概念、判断、推理、反驳对象、条件和行动建议。

研究只呈现岐伯的文本内观点。历史、法律、医学、心理、政治和科技内容均不加入AI模型自身的价值裁决；概念网络、命题分类和跨文体系均明确标记为研究重建，不倒写成作者自称理论。

## 主要成果

- 34篇编号研究论文，合计330,606个汉字；
- 1篇系统总论；
- 4,050篇逐篇结构化研究形成的作者中心证据体系；
- 23组概念网络、253组共现关系；
- 39条核心命题及10类论证动作；
- 20套专题核心证据，共839条；
- 11,978条登记短引全部通过`StringComparison.Ordinal`逐字验证；
- 891条论文直接短引全部在所引原文中精确命中，且均通过Lexical作者正文/引述块角色审计；
- 1,237组论文—文章引用涉及822个唯一原文ID，缺失0，URL-only引用0；
- 1,219组可唯一映射到原始语料的论文篇名提及均附文章ID或原始URL，歧义0、缺失入口0；
- 34词Lexical引述块敏感性覆盖4,050篇和204个时期—平台—术语单元，排除顶层引述块后最大篇级覆盖率差为1.89个百分点；
- 35篇知乎发布稿由1篇系列总序和34篇论文转换稿组成，发布清单状态为35/35 `READY`。

## 阅读入口

- [研究总目录](研究总目录.md)
- [系统研究总论](研究总论_内部观点重建.md)
- [研究方法与证据规范](research/papers/00_研究方法与证据规范.md)
- [语料画像](research/papers/01_语料画像.md)
- [结构化精读概念网络与命题分布](research/papers/17_全量概念网络与命题分布.md)
- [责任、自由与成本的跨域结构](research/papers/18_责任自由成本的跨域结构.md)
- [完整论文与数据说明](research/README.md)
- [知乎发布总序与清单](research/zhihu/00_系列总序.md)

## 仓库结构

```text
research/papers/   34篇编号研究论文
research/scripts/  PowerShell 7构建、统计和验证脚本
research/data/     可公开的统计、核心证据和审计结果
research/review/   可公开的方法复核与专题审读记录
research/zhihu/    1篇系列总序、34篇发布稿及发布清单
```

## 数据边界

本仓库不分发第三方文章全文、抓取缓存、会话凭据或可能实质性复现原文的全量中间层，包括：

- `sooon-q9adg-articles.jsonl`与抓取源文件；
- 逐篇精读全文衍生文件；
- 全量作者证据JSONL和全量短引账本；
- 含原始正文的人工核验批次包。

论文和核心证据保留研究所必需的短引、文章ID、标题、日期和原始URL。第三方原文的版权仍归原权利人，本仓库的许可不覆盖这些原文。

本地完整研究使用的只读语料文件SHA-256为：

```text
5C609F734DBD7AE27C96467C9D2AAFF17C12EF2EEA500B222A7314779ED9B06E
```

## 复现环境

推荐使用PowerShell 7：

```powershell
pwsh -NoLogo -NoProfile -File .\research\scripts\build_corpus_index.ps1
pwsh -NoLogo -NoProfile -File .\research\scripts\build_system_concept_network.ps1
pwsh -NoLogo -NoProfile -File .\research\scripts\build_core_term_quote_role_sensitivity.ps1
pwsh -NoLogo -NoProfile -File .\research\scripts\validate_all_paper_direct_quotes.ps1
```

依赖完整语料或非公开人工复审表的步骤会在缺少本地输入时停止，不会以公开仓库中的摘要数据替代原文。

## 许可

- `research/scripts/`中的原创代码采用[MIT License](LICENSE-CODE)；
- 研究论文、原创说明和原创统计结构采用[CC BY 4.0](LICENSE-RESEARCH)；
- 引用的第三方原文、文章标题、平台内容及外部链接不包含在上述授权中。
