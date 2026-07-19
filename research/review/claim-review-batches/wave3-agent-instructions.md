# Wave 3 high-risk claim review

Review the assigned batch of up to 80 JSONL rows. A final remainder batch may contain fewer than 80 rows. The raw article text is authoritative and read-only.

## Author-centered rule

- Reconstruct only q9adg/岐伯's claims, definitions, reasoning, rebuttal targets, assumptions, and advice.
- Do not add legal, medical, psychological, political, scientific, ethical, or safety judgments from the reviewer.
- Mark researcher-created cross-text structures as reconstructions; they are out of scope for row-level author claims.

## Inputs

- `claim-review-wave3-X.jsonl`: raw text, original annotation, clean annotation, and result schema.
- `claim-review-wave3-X-precheck.csv`: mechanically computed quote counts and clean-field differences.

The precheck is a recall aid only. Review thesis, reasoning, action, stance attribution, and each registered quote against the raw article.

## Required outputs

Write only batch-specific files. Do not modify the combined result, clean script, corpus, or another batch.

1. `claim-review-results-wave3-X-strict.csv`
   - exact schema from `requiredResult`
   - exactly the unique ordinals assigned to the batch
2. `claim-review-wave3-X-strict-clean-suggestions.csv`
   - columns: `ordinal,field,startPhrase,action,reason`
   - actions: `DELETE_TAIL`, `REPLACE_FIELD`, or `REEXTRACT_QUOTES`
   - each `startPhrase` must occur exactly once in the assigned original field using `[StringComparison]::Ordinal`
3. `claim-review-wave3-X-strict-exact-replacements.csv`
   - columns: `ordinal,field,replacementText,reason`
   - required for each `REPLACE_FIELD` and `REEXTRACT_QUOTES` suggestion
   - allowed fields: `thesis`, `authorActionAndEthicalJudgments`, `faithfulSummary`, `sourceQuotes`
   - each replacement quote must be a contiguous `[StringComparison]::Ordinal` match in `rawText`

## Completion checks

- No missing or duplicate assigned ordinals.
- No empty required result fields.
- Every quote status is independently recomputed with `[StringComparison]::Ordinal`.
- Every replacement quote has zero Ordinal failures.
- Report classification, suggestion, replacement, and validation-failure counts.
