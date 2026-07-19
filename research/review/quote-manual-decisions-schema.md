# 剩余短引人工决定格式

人工决定 CSV 使用以下字段：

- `ordinal`、`id`、`title`、`originalUnlocatedQuote`：继承原审校队列。
- `decision`：`ACCEPT_MULTI_SEGMENT` 或 `REJECT_DIRECT_QUOTE`。
- `verifiedSegmentsJson`：JSON 数组；每段包含 `text`、`start`、`length`。`start` 是该段在原始 JSONL `text` 字段中的零基字符位置。
- `reviewNote`：仅说明逐字定位、拆分依据或拒绝原因，不评价作者观点。

只有能够在同一篇原始 `text` 中逐字定位的完整原句才能进入 `verifiedSegmentsJson`。概括、改写、跨处拼接、缺字增字以及空正文均标记为 `REJECT_DIRECT_QUOTE`，不以近义句替换。
