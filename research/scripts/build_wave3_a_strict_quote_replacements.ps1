param(
    [string]$SuggestionPath = (Join-Path $PSScriptRoot '..\review\claim-review-wave3-A-strict-clean-suggestions.csv'),
    [string]$AutoCandidatePath = (Join-Path $PSScriptRoot '..\review\strict-quote-auto-replacement-candidates.csv'),
    [string]$CorpusPath = (Join-Path $PSScriptRoot '..\..\sooon-q9adg-articles.jsonl'),
    [string]$EvidencePath = (Join-Path $PSScriptRoot '..\data\author_view_evidence_clean.jsonl'),
    [string]$OutputPath = (Join-Path $PSScriptRoot '..\review\claim-review-wave3-A-strict-quote-exact-replacements.csv')
)

$ErrorActionPreference = 'Stop'
$manual = @{
    194 = '这份利益在事实上补偿完你的情绪痛苦，还有剩余，所以你才会“完全无法远离”。；一个真正有决心解决问题的态度，走的是“我已经做好了远离的最坏打算，但从心底里希望避免这个最极端的结果，请问还有什么可努力的途径和余地”的路线。；你可以远离。；你可以。；必须可以。'
    203 = '所谓的“不自在”，说白了就是对社会化、组织化的纪律成本、秩序成本有抗拒。；“不自在”和“低摩擦协作”是对称、平衡的。；又要“自在”，又要掺合不允许自在的要害职能，哪有这么两全其美的事？'
    379 = '所以，第一步你要学会归零，完美的归零，然后学会在一个归零周期里尽可能压低成本。；绝对的安全来自你在第二、第三专业中逐渐掌握的学习本身的规律和技巧。'
    434 = '你首先就在用比赛的思路在看不同理论之间的地位，那么在看这具体的理论本身的时候，如果这个理论自己还没有“这是竞争”的自觉，你当然就不会看好它了。；我爱上谁，一定会让对方有净收益而不是净亏损，一定让你感到你的机会和自由是比没和我在一起时扩大的。；爱如果是竞争，那么它争的就是不争。'
    478 = '把“亏掉”“赔掉”的钱视为建设品牌的成本，不但不要省，还要大笔的投入。；我得不偿失；那么，你也可以继续脑补我会再坐你家的飞机。'
    582 = '中国文化对生育、抚养看得重，但其实对性欲本身看得非常轻，这在诸多文化中算是不大不小的异类。；而中国走的是将性欲耻化的路线。；这个就是中国文化对性问题的系统方案——青春期网开一面，许你人不风流枉少年，过了青春期，你就要束发正冠，先天下之忧而忧，为子孙计，为天下谋，鞠躬尽瘁、死而后已。'
    1123 = '不同意就是不同意，不高兴就是不高兴，怎么，你要规定我对事务的感受、剥夺我拥有自己立场的权利？；人给人自由，极限只能到不制造阻碍为止。；你记住，在不同意的前提下，不动手制造困难，已经是支持。；但是【我不同意】，【我不支持】。'
    1286 = '那就是如果要追求“在尽可能降低厌学概率的前提下，防止一时厌学转变为弃学”。；在促学问题上，“先为不可败，再务其胜”是一个绝对不可动摇的中心原则。；所以，绝不要用“学习不好（甚至是“学习不如人”）就完了”“学习不好你还有什么用”“不好好学习太令我们失望”这样的手段去促学抑厌。；所以，你不是在以一个“连一米都跑不动”的失败者的身份在沮丧“怎么能跑的了一百米”，而是以一个已经跑过了十公里但却浑然不觉的人的身份，在绝望“怎么跑得了一百米”。'
    1861 = '第二，司法是人在做，这不是什么完美无缺的神迹，并不需要“一定有人在背后搞鬼”才会导致侦查无结果或者缺少足够证据。；司法存在的首要意义就是制止这种集体情绪凌驾于一切社会秩序的反文明灾难。；不要这样做，因为这是一副败相。'
    2168 = '凡打算揭露艰难事实的媒体，天然的就要承担作为尽可能消除致郁性的第一责任人的义务。；这不是法定义务，但这是道德义务。；你的“尽力避免”，要让人看见；你的“仍有遗憾”，要让人听见，这才是你自居高于众人、擅自高声教训人的原罪的免罪条件。'
    2288 = '人要分清楚一个至关重要的问题——是真理让人幸福，而不是“真相”。；你一定要有一个“某些事情我不打算了解”、“某些真相我不打算知道”的原则方法，并且根据自己的实践结果去不断地修缮、打磨、改进这个策略。；是真理使你自由，不是真相。'
    2498 = '那就是一件事做不做、一段关系要不要维持，不要用“值不值得”来做判断，而要用“适不适合”来判断。；你觉得痛苦和难以为继，这已经是充分的理由了，不要再靠欺骗自己“对方没前途”来弥补自己勇气的不足。；你要不要在这家企业里做下去，你只问几个简单的问题——既不是问这家企业的要求是不是荒谬，也不是问这家企业是不是有前途，而只要问它的信用是否令你满意、它的要求你是不是能胜任、它的要求是否符合你自己想要成长的方向。'
    2872 = '天赋权利，是指一切你可以办到且自行承担后果的自由。；后者只是你付出代价换取的某种【不可靠的】来自人类的服务。；任何时候你忘了这一点，最好给自己两耳光让自己清醒点。；然后你迟早有一天发现，ta们不是。'
    2986 = '父母要管理子女的期望，这很重要。；一个期待如果一路过关斩将到了能满足这三重条件，它就是一个合格的期待，一个有力量的、自带“实现驱动”的自然魔法。；父母要教的是如何去提问，如何去听，而不是代天作答。'
    3147 = '疫情要到所有的国家都更新了社会理念之后才会结束。；最后只能是人类社会对不可抗拒的自然新常态做出适应，而不太可能继续延续“人类我行我素，驯服不能与人类选择的道路相适应的自然”这样的模式。；人类要面对的挑战不仅仅是新冠变种，还包括随时可能爆发的其他传染病，以及日趋明显的生态问题和异常气候问题。；要么向中国看齐，要么不再被看好。'
    3175 = '资本家，是指以出借资本来分享利润的人。；资本家的价值观，是以“赚到钱”为诉求。；企业家的价值观，是以“做成事”为诉求。；要追求做个企业家，不要去追求当个资本家。'
    3187 = '这是因为中国人还全球化得不够。；全球化的大头是一个侨居海外的中国人，或者侨居中国的外国人，因为看到某个跨国资源整合的商机而做的创业工作。；中国还需要很长很长一段时间来补这个课。；但是，反过来想——这课没补上，也挤得对手们想吐……；比啥不好比上课。'
    3254 = '中国没有走完创新文化养成的完整历程。；因为迷信乱枪道，；于是会遵从乱枪道，；于是会实践乱枪道，；于是会证实乱枪道，；于是会继续迷信乱枪道。；绝大部分人是在赌博，并不是在创新。'
    3324 = '首先有一点要搞清楚——所有没有被人身禁锢的人，都在过自己想过的生活，哪怕ta在说“我不想过这样的生活”。；而真正的爱，是因为愿意给而给的，是对方自由的最好的实现和使用，而不是因为出于任何的限制不得不如此，是ta人完全自由的结果，每一点每一滴都必须是。；你到底是真的无力从石头上走开，还是在沉迷于坐在石头上的福利故意不从石头上走开，你在任何时候都可以用自己的行动证明是前者。；记住，在最终意义上，不是人类不允许人对爱作弊，是这个世界不允许。'
    3482 = '这一制度的核心，是任何公民如果没有能力找到合适的岗位，都可以自主的选择无限继续学习。；唯有时间，而不是任何证券化的能源、物质，更不是什么“加密数字货币”是人类真正最后的硬通货。；谁拥有算力资源，谁就拥有了真正本质的铸币权，谁也就将在最后通过这项最终货币无限供给，最终赎买下人间一切的权利——无论你在旧的货币体系下做多高的开价，都一样支付得起。'
    3903 = '不要相信这给出的任何确切诊断！；来访者的自述如果不经过复杂的追问考核是根本不能采信的。；他不是来求诊断，诊断他自己已经做了，他只是来求这个诊断前提下的进一步的治疗建议的。；他们的任务应该是不断的拷问你自己的自我诊断的漏洞，引导你自我深入思考，提高你的思维能力和逻辑自洽性，从而让一个逻辑能力提高过的你自己对你自己的问题有新的诊断。；如果他是知道而不理会，那么就是为了吸粉而根本不在乎你后果如何。'
}

$requested = @(
    Import-Csv -LiteralPath $SuggestionPath |
        Where-Object { $_.field -eq 'sourceQuotes' -and $_.action -in @('REPLACE_FIELD','REEXTRACT_QUOTES') } |
        ForEach-Object { [int]$_.ordinal } |
        Sort-Object -Unique
)
$auto = @{}
foreach ($row in Import-Csv -LiteralPath $AutoCandidatePath) { $auto[[int]$row.ordinal] = [string]$row.replacementText }
$evidenceByOrdinal = @{}
foreach ($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($EvidencePath))) {
    if ($line) { $row=$line|ConvertFrom-Json; $evidenceByOrdinal[[int]$row.ordinal]=$row }
}
$rawById = @{}
foreach ($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($CorpusPath))) {
    if ($line) { $row=$line|ConvertFrom-Json; $rawById[[string]$row.id]=[string]$row.text }
}

$rows = foreach ($ordinal in $requested) {
    $replacement = if ($manual.ContainsKey($ordinal)) { [string]$manual[$ordinal] } elseif ($auto.ContainsKey($ordinal)) { [string]$auto[$ordinal] } else { throw "No replacement for ordinal $ordinal." }
    $evidence = $evidenceByOrdinal[$ordinal]
    if ($null -eq $evidence) { throw "Missing evidence ordinal $ordinal." }
    $rawText = $rawById[[string]$evidence.id]
    $quotes = @($replacement -split '；' | ForEach-Object { $_.Trim() } | Where-Object { $_ })
    $failed = @($quotes | Where-Object { -not $rawText.Contains($_,[StringComparison]::Ordinal) })
    if ($failed.Count -ne 0) { throw "Ordinal validation failed at $($ordinal): $($failed -join ' | ')" }
    [pscustomobject]@{
        ordinal = $ordinal
        field = 'sourceQuotes'
        replacementText = $replacement
        reason = if ($manual.ContainsKey($ordinal)) { 'Strict manual re-extraction from contiguous raw-text segments; every segment passes StringComparison.Ordinal.' } else { 'High-confidence unique raw-sentence mapping; every segment passes StringComparison.Ordinal.' }
    }
}
$rows | Export-Csv -LiteralPath ([IO.Path]::GetFullPath($OutputPath)) -NoTypeInformation -Encoding UTF8
[ordered]@{
    requestedCount = $requested.Count
    replacementCount = $rows.Count
    manualCount = @($requested | Where-Object { $manual.ContainsKey($_) }).Count
    autoCount = @($requested | Where-Object { -not $manual.ContainsKey($_) -and $auto.ContainsKey($_) }).Count
    uniqueOrdinalCount = @($rows.ordinal | Sort-Object -Unique).Count
    ordinalFailures = 0
    status = if ($rows.Count -eq $requested.Count) { 'PASS' } else { 'REVIEW' }
} | ConvertTo-Json
