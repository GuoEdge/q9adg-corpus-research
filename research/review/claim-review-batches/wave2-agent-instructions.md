# Wave 2 high-risk claim review

Review only the assigned 30-row JSONL batch. The raw article text is authoritative and read-only.

## Author-centered rule

- Reconstruct only q9adg/岐伯's claims, definitions, reasoning, rebuttal targets, assumptions, and advice.
- Do not add legal, medical, psychological, political, scientific, ethical, or safety judgments from the reviewer.
- Researcher-created cross-text labels are out of scope for this row-level audit.

## Inputs

- `claim-review-wave2-X.jsonl`: raw text, original annotation, clean annotation, and result schema.
- `claim-review-wave2-X-precheck.csv`: mechanically verified quote counts/status and clean-field differences.

The precheck quote status was calibrated against 60 independently reviewed articles with zero article-level mismatches. Spot-check it, but spend review time on thesis, reasoning, action, and stance attribution.

## Required outputs

Write only batch-specific files. Do not modify the combined result, clean script, corpus, or another batch.

1. `claim-review-results-wave2-X.csv`
   - exact schema from `requiredResult`
   - exactly 30 unique assigned ordinals
2. `claim-review-wave2-X-clean-suggestions.csv`
   - columns: `ordinal,field,startPhrase,action,reason`
   - actions: `DELETE_TAIL`, `REPLACE_FIELD`, or `REEXTRACT_QUOTES`
   - every `startPhrase` must occur exactly once in the assigned original field using `[StringComparison]::Ordinal`
3. `claim-review-wave2-X-exact-replacements.csv`
   - columns: `ordinal,field,replacementText,reason`
   - required for every `REPLACE_FIELD` and `REEXTRACT_QUOTES` suggestion
   - allowed fields: `thesis`, `authorActionAndEthicalJudgments`, `faithfulSummary`, `sourceQuotes`
   - every individual replacement quote must be a contiguous `[StringComparison]::Ordinal` match in `rawText`

## Completion checks

- 30 results, no missing or duplicate ordinals.
- No empty required fields.
- Result `quoteSupport` agrees with the precheck unless the precheck parser is demonstrably wrong; document any exception.
- All replacement quotes have zero Ordinal failures.
- Report classification counts, suggestion counts, replacement counts, and validation failures.
