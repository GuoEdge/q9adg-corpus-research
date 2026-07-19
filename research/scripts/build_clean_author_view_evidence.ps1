param(
    [string]$InputPath = (Join-Path $PSScriptRoot '..\data\author_view_evidence.jsonl'),
    [string]$OutputPath = (Join-Path $PSScriptRoot '..\data\author_view_evidence_clean.jsonl'),
    [string]$ReviewDir = (Join-Path $PSScriptRoot '..\review')
)
$ErrorActionPreference='Stop'
$leak='不是法律意见|不能替代.{0,20}(专业|医学|法律|现实危险|安全处置|危机机构|心理健康评估)|不能仅凭本文|不能据此(推断|判断)|未在正文中以外部证据|以上是研究者|研究者概括|研究者(需要|同时|应)|不是医学标准|不是医学或心理诊断|未提供专业(处置|方案|支持)|属于本文论证中的文本内主张|不当作外部事实|没有外部依据|现实.{0,20}应结合.{0,20}(制度|法律)|不能自动证明.{0,40}(普遍|现实)|不能用来替.{0,20}(免除|代替)|不能理解成把.{0,30}归咎于|现实组织中责任可能由多人共同承担|本文未展开|文章未提供|文中未提供|文中没有提供|文中未说明|未继续展开|没有给出.{0,20}(统一|具体|专业|完整|明确).{0,20}(方案|标准|程序|算法)|这(一|些)建议不能|这些判断仍是本文|具有.{0,20}(倾向|张力)|存在.{0,20}倾向|(?:伦理|制度|排除性|父权式修辞|现实|明显|重大|自身|关系性).{0,20}张力|(?:文章|本文|作者|其|这个解释|该模型|这项建议|这一转向|这套规则|该标准).{0,120}(?:留下|构成|存在|暴露|形成|带有|保留).{0,30}张力|与.{0,50}(家庭控制|个人自主|主体性|不平等|监督|权力滥用|法律边界|审美多样性).{0,20}张力|张力在于|张力所在|未解决的张力|未解张力|容易.{0,20}(正常化|美化)|任何读者若|不是已经证明|对现实.{0,30}讨论不足|过多归入|本文.*(外部核验|未作外部)|属于研究者|本文.*概括|未.{0,5}外部核验|未经外部核验|未获外部核验|外部核验'
$leak += '|研究者|本文研究|本研究|需另行核验|需要外部|未作外部|不构成.{0,40}(法律|医学|心理|专业)|专业支持|专业意见|医学诊断|心理健康评估|其局限|主要缺口|明显张力|未解张力|过于绝对|处理不足|讨论不足|没有充分处理|尚未展开'
$leak += '|(?:文章|本文|文本|正文|作者|该回答|这个回答|这套框架|这个框架|该方案|该模型|它|其).{0,80}(?:没有|未)(?:充分|具体|完整|继续|深入)?(?:讨论|展开|覆盖|说明|处理|核验|核实|涉及|考虑|区分|提供|分析)'
$leak += '|(?:没有|未)(?:充分|具体|完整|继续|深入)?(?:讨论|展开|覆盖|说明|处理|核验|核实|考虑).{0,80}(?:边界|风险|条件|限制|问题|方案|标准|差异|责任|成本|法域|程序)'
$leak += '|不是.{0,30}(?:治疗|医学|法律|临床|心理|专业).{0,30}(?:方案|建议|标准|意见|事实|结论)|不能(?:当作|视为|替代|作为|理解为).{0,100}(?:建议|标准|规则|结论|事实|诊断|处置|法律|医学|心理|专业|普遍)'
$leak += '|(?:未经|未作|没有经过|并未经过).{0,30}(?:外部|事实|现实|专业|医学|法律|临床|安全)?.{0,10}(?:核验|验证)|未核实.{0,80}(?:事实|数据|事故|人物|历史|现实|结论)'
$leak += '|(?:过于|高度).{0,30}(?:压缩|简化|金融化|商业化|道德化)|(?:忽略|忽视)了.{0,60}(?:条件|责任|差异|问题|功能|风险|成本|资源|权力|照料)|(?:应|需要)另行.{0,40}(?:核验|评估|建立|处理)'
function Clean-Field([string]$text,[ref]$removed){
    if([string]::IsNullOrWhiteSpace($text)){return $text}
    $parts=[regex]::Split($text,'(?<=[。！？；])')
    $keep=[Collections.Generic.List[string]]::new()
    foreach($p in $parts){
        if($p -notmatch $leak){
            [void]$keep.Add($p)
            continue
        }

        # Many annotations append a researcher caveat after first summarizing the
        # author's position. Keep that author-attributed prefix when the suffix is
        # independently identifiable as leakage; never reconstruct missing wording.
        $salvaged = $null
        foreach($splitPattern in @(
            '(?<=[，；])(?:但|不过|然而|与此同时|同时)(?=.{0,160}$)',
            '(?<=[，；])(?=(?:未|没有)(?:充分|具体|完整|继续|深入)?(?:讨论|展开|覆盖|说明|处理|核验|核实|涉及|考虑|区分|提供|分析))',
            '(?<=[，；])(?=不是.{0,30}(?:治疗|医学|法律|临床|心理|专业))'
        )){
            $segments=[regex]::Split($p,$splitPattern,2)
            if($segments.Count -ne 2){continue}
            if($segments[1] -notmatch $leak){continue}
            $prefix=$segments[0].Trim().TrimEnd('，','；')
            if($prefix.Length -ge 8){$salvaged=$prefix+'。';break}
        }
        if($null -ne $salvaged){[void]$keep.Add($salvaged)}
        $removed.Value++
    }
    return (($keep -join '').Trim() -replace '[；，、]+$','')
}
$manualTails = @{
    '1520:faithfulSummary' = '；但现实责任常是共同的.*$'
    '1048:authorActionAndEthicalJudgments' = '但未成年人旅行、休学.*$'
    '1048:faithfulSummary' = '它是一套强调自主体验的家庭方案.*$'
    '1088:authorActionAndEthicalJudgments' = '这个框架肯定了.*$'
    '1224:authorActionAndEthicalJudgments' = '但它没有给出“安全攻击”.*$'
    '489:authorActionAndEthicalJudgments' = '由于正文把遭遇违法胁迫.*$'
    '1300:authorActionAndEthicalJudgments' = '但面对持续吼叫.*$'
    '1300:faithfulSummary' = '它并未提供可靠的临床诊断.*$'
    '1330:authorActionAndEthicalJudgments' = '但文本的性别结论.*$'
    '1330:faithfulSummary' = '这个性别结论.*$'
    '623:authorActionAndEthicalJudgments' = '这些是文章的规范性主张.*$'
    '623:faithfulSummary' = '全文的预测和历史比较.*$'
    '873:authorActionAndEthicalJudgments' = '但文章没有提供安全的替代边界方法.*$'
    '873:faithfulSummary' = '这个推断没有个案或社会数据支撑.*$'
    '1084:authorActionAndEthicalJudgments' = '但文章的奖励制度涉及.*$'
    '1084:faithfulSummary' = '但制度把教育、亲情和借贷高度金融化.*$'
    '1339:authorActionAndEthicalJudgments' = '伦理上，拥有资源不等于.*$'
    '1339:faithfulSummary' = '作者用自然法解释社会的惩罚和保护.*$'
    '923:authorActionAndEthicalJudgments' = '这个边界有助于区分理解和裁判.*$'
    '923:faithfulSummary' = '但他过度排斥情绪确认和支持.*$'
    '971:authorActionAndEthicalJudgments' = '但“必须学到能鄙视大模型”.*$'
    '496:authorActionAndEthicalJudgments' = '劳动成果能提供证据.*$'
    '496:faithfulSummary' = '这个标准强调可检验实践.*$'
    '1041:authorActionAndEthicalJudgments' = '；但它没有讨论备考者.*$'
    '1041:faithfulSummary' = '这个判断依赖于目标价值.*$'
    '1082:authorActionAndEthicalJudgments' = '但这一原则不能被理解为.*$'
    '1082:faithfulSummary' = '；但这个认知策略.*$'
    '1129:authorActionAndEthicalJudgments' = '伦理上，这一框架强调.*$'
    '1129:faithfulSummary' = '这个框架强调自主和反控制.*$'
    '1295:authorActionAndEthicalJudgments' = '；但它没有充分处理.*$'
    '1295:faithfulSummary' = '该框架强调社会安全和资本约束.*$'
    '3976:authorActionAndEthicalJudgments' = '文本也承认维护秩序的成本很高.*$'
    '3976:faithfulSummary' = '；但改善时限.*$'
    '3185:authorActionAndEthicalJudgments' = '但文中“诱使对方先动手”.*$'
    '704:authorActionAndEthicalJudgments' = '文中谈及犯罪、法官、医生和飞行员.*$'
    '1078:thesis' = '文章的市场、人口和历史推演构成作者的解释框架.*$'
    '1078:authorActionAndEthicalJudgments' = '但它把对方称作“对手”.*$'
    '3895:authorActionAndEthicalJudgments' = '文章的伦理立场明显偏向保护和教养责任.*$'
    '1061:authorActionAndEthicalJudgments' = '但它把“让对方吃大亏”当作战略收益.*$'
    '2126:authorActionAndEthicalJudgments' = '但文章没有区分自愿亲密关系.*$'
    '3929:authorActionAndEthicalJudgments' = '但没有提出具体监管方案.*$'
    '3040:authorActionAndEthicalJudgments' = '文章没有深入处理当宗教实践.*$'
    '3178:authorActionAndEthicalJudgments' = '不过，它把“不敢反对”也视为没有有效反对.*$'
    '3010:authorActionAndEthicalJudgments' = '对明显的长期压力来源.*$'
    '1086:authorActionAndEthicalJudgments' = '但文章没有提供如何明确表达物品所有权.*$'
    '2056:authorActionAndEthicalJudgments' = '对演员或选手而言，签约前应获得独立法律意见.*$'
    '2097:authorActionAndEthicalJudgments' = '但“PTSD”是有严格诊断含义的创伤后应激障碍.*$'
    '3403:authorActionAndEthicalJudgments' = '这个框架有助于区分请求、同意和强制.*$'
    '3737:authorActionAndEthicalJudgments' = '作者也把社会的幸存与稳固放在解释中心.*$'
    '1057:authorActionAndEthicalJudgments' = '文中也没有讨论资本、身体、家庭负担和年龄歧视等限制.*$'
    '1899:authorActionAndEthicalJudgments' = '文本试图提醒照护者.*$'
    '2132:authorActionAndEthicalJudgments' = '这个框架能提醒求职者准备案例和作品集.*$'
    '3476:authorActionAndEthicalJudgments' = '文章把服从现状、避免表达怨恨当作职场生存技术.*$'
    '3634:authorActionAndEthicalJudgments' = '文中关于痛击、报复和板刀的段落.*$'
    '3657:authorActionAndEthicalJudgments' = '对原问题中的法定义务.*$'
    '408:authorActionAndEthicalJudgments' = '^.*$'
    '408:faithfulSummary' = '但未核验事故事实.*$'
    '435:authorActionAndEthicalJudgments' = '文中关于文化潜意识.*$'
    '435:faithfulSummary' = '文章没有调查具体关系.*$'
    '575:authorActionAndEthicalJudgments' = '^.*$'
    '575:faithfulSummary' = '现实中儿童保护.*$'
    '605:authorActionAndEthicalJudgments' = '文章没有要求每个人必须恋爱.*$'
    '605:faithfulSummary' = '；这是一种乐观的文本内历史推演.*$'
    '1105:authorActionAndEthicalJudgments' = '但它不等于要求人在真实危险.*$'
    '1105:faithfulSummary' = '这个框架能提醒人区分标签和情境.*$'
    '1135:authorActionAndEthicalJudgments' = '伦理上，文章肯定家庭完整.*$'
    '1135:faithfulSummary' = '文章没有具体回答休学耻感.*$'
    '1227:authorActionAndEthicalJudgments' = '伦理上，这个方向肯定儿童自主.*$'
    '1227:faithfulSummary' = '但把亲子关系高度商业化.*$'
    '1969:authorActionAndEthicalJudgments' = '^.*$'
    '1969:faithfulSummary' = '但临床焦虑.*$'
    '2047:authorActionAndEthicalJudgments' = '但愿景投资并不免除雇主.*$'
    '2047:faithfulSummary' = '但其模型不能替代.*$'
    '2860:authorActionAndEthicalJudgments' = '但文章又用“小矮人”.*$'
    '3334:faithfulSummary' = '文章的责任伦理很强.*$'
    '3081:authorActionAndEthicalJudgments' = '文章把独立与相爱并置.*$'
    '3081:faithfulSummary' = '文章把理解和独立结合起来.*$'
    '2007:faithfulSummary' = '它提供了撤回信任和不必忍受恶意的视角.*$'
    '2958:authorActionAndEthicalJudgments' = '但它没有展开受害者赔偿.*$'
    '3188:faithfulSummary' = '文章有强烈的心理和伦理洞察.*$'
    '3896:authorActionAndEthicalJudgments' = '与此同时，作者把公共服务与安全.*$'
    '3896:faithfulSummary' = '由于原文标注“未完，待续”.*$'
    '3983:authorActionAndEthicalJudgments' = '它肯定艺术为现实提供替代可能.*$'
    '3983:faithfulSummary' = '艺术边界、事实检验和社会责任.*$'
    '1326:authorActionAndEthicalJudgments' = '伦理上，概念精确有助于.*$'
    '1326:faithfulSummary' = '作者强调概念的现实力量.*$'
    '1885:faithfulSummary' = '这个边界分析具有现实提醒意义.*$'
    '2038:faithfulSummary' = '这个框架忽略了长期辍学和熬夜.*$'
    '2067:authorActionAndEthicalJudgments' = '这个去羞耻化方向有助于.*$'
    '2067:faithfulSummary' = '文章的去报复立场值得区分.*$'
    '2218:authorActionAndEthicalJudgments' = '文章没有讨论知识产权.*$'
    '3328:faithfulSummary' = '文章的原则清晰.*$'
    '3396:authorActionAndEthicalJudgments' = '文章对拉美裔、非裔移民.*$'
    '3396:faithfulSummary' = '其历史、人口和族群论断.*$'
}
$allowedTailFields = @('thesis','reasoning','authorActionAndEthicalJudgments','faithfulSummary')
$suggestionTails = @{}
$suggestionFiles = @(Get-ChildItem -LiteralPath $ReviewDir -Filter '*-clean-suggestions.csv' -File -ErrorAction SilentlyContinue)
foreach ($file in $suggestionFiles) {
    foreach ($suggestion in Import-Csv -LiteralPath $file.FullName) {
        if ($suggestion.action -ne 'DELETE_TAIL' -or $suggestion.field -notin $allowedTailFields) { continue }
        if ([string]::IsNullOrWhiteSpace([string]$suggestion.startPhrase)) { throw "Empty DELETE_TAIL startPhrase in $($file.FullName)." }
        $key = '{0}:{1}' -f [int]$suggestion.ordinal,[string]$suggestion.field
        if (-not $suggestionTails.ContainsKey($key)) { $suggestionTails[$key] = [Collections.Generic.List[string]]::new() }
        $pattern = [regex]::Escape([string]$suggestion.startPhrase) + '.*$'
        if (-not $suggestionTails[$key].Contains($pattern)) { [void]$suggestionTails[$key].Add($pattern) }
    }
}
$manualReplacements = @{
    '1899:authorActionAndEthicalJudgments' = '作者主张，父母、亲人和朋友应教会人理解责任的产生与分配，建立“承担责任也能得到真实奖励和安慰”的经验，不要单凭霸权强行规定责任。'
    '408:authorActionAndEthicalJudgments' = '作者主张新手换车后应依次建立车身尺度感、在低速场景反复练习、由专业陪练进入低流量道路、熟悉生活主场，再逐步扩展到高峰、天气、高速和不同路况；至少形成主场自信后才自主载人，并应认识到经验更丰富的配偶提醒可能放大焦虑。'
    '575:authorActionAndEthicalJudgments' = '作者主张按事件后果是否公开、是否仅为经济损失决定私下或公开处理；公开范围不超过原知情者，父母应说明原因和程度，并让子女自愿领罚。子女暂时不认错时，父母先承担家庭责任，私下陈明利害后再协商公开修复；当众惩罚不能变成当众伤害。'
    '1969:authorActionAndEthicalJudgments' = '作者主张不要回避不可避免的焦虑，应在年轻、责任较轻时反复经历考试、恋爱等小焦虑，以“焦虑未必成真、即使成真也可承受”的经验提高耐受；当小焦虑失去威力，睡眠、饮食、计算和劳动成果会反过来增加镇定。'
    '2341:authorActionAndEthicalJudgments' = '作者建议用观看圆柱的不同视角理解误导式加密：正确密钥使人看到目标明文，错误密钥则使人看到另一种仍然成形但方向错误的输出。'
    '3814:authorActionAndEthicalJudgments' = '作者把爱和被爱的能力并列为人最重要的能力，因而同时肯定向外付出爱与接受、回应他人之爱的能力。'
    '3915:authorActionAndEthicalJudgments' = '作者要求建筑3D打印的研究者和工程师把重点转向钢丝骨架、连接、装配和后续复合系统，不再把速凝水泥的挤出速度作为核心路线。'
}
$thesisSummaryFallbackOrdinals = [Collections.Generic.HashSet[int]]::new([int[]]@(
    733,773,1745,1993,2755,3026,3099,3117,3170,3198,3276,3296,3384,3391,
    3681,3759,3780,3784,3787,3799,3810,3830,3867,3873,3887,3912,3945,3953,
    3961,4018
))
$allowedReplacementFields = @('thesis','reasoning','authorActionAndEthicalJudgments','faithfulSummary','sourceQuotes')
$replacementFiles = @(
    Get-ChildItem -LiteralPath $ReviewDir -Filter '*-exact-replacements.csv' -File -ErrorAction SilentlyContinue |
        Where-Object {
            $header = Get-Content -LiteralPath $_.FullName -TotalCount 1
            $header -match '(?i)(^|,)"?replacementText"?(,|$)'
        } |
        # Residual strict-quote approvals are produced from the already-cleaned
        # quote registry and therefore must win over every earlier replacement
        # wave for the same article.  Keep the ordering explicit instead of
        # relying on lexical file-name order.
        Sort-Object @{ Expression = {
            if ($_.Name -like 'strict-quote-residual-batch-*-approved-exact-replacements.csv') { 1 }
            else { 0 }
        } }, Name
)
foreach ($file in $replacementFiles) {
    foreach ($replacement in Import-Csv -LiteralPath $file.FullName) {
        if ($replacement.field -notin $allowedReplacementFields) { throw "Unsupported replacement field '$($replacement.field)' in $($file.FullName)." }
        if ([string]::IsNullOrWhiteSpace([string]$replacement.replacementText) -and $replacement.field -ne 'sourceQuotes') { throw "Empty replacementText in $($file.FullName)." }
        $key = '{0}:{1}' -f [int]$replacement.ordinal,[string]$replacement.field
        if ($manualReplacements.ContainsKey($key) -and $manualReplacements[$key] -ne $replacement.replacementText) {
            $approvedStrictQuoteBatch =
                $file.Name -like 'strict-quote-review-batch-*-approved-exact-replacements.csv' -or
                $file.Name -like 'strict-quote-residual-batch-*-approved-exact-replacements.csv'
            if (-not ($replacement.field -eq 'sourceQuotes' -and $approvedStrictQuoteBatch)) {
                throw "Conflicting exact replacement for $key."
            }
        }
        $manualReplacements[$key] = [string]$replacement.replacementText
    }
}

$full = [IO.Path]::GetFullPath($OutputPath)
$w = [IO.StreamWriter]::new($full,$false,[Text.UTF8Encoding]::new($false))
$rows = 0
$removed = 0
$replaced = 0
$empty = 0
$restored = 0
$restoredKeys = [Collections.Generic.List[string]]::new()
$thesisSubstitutionCount = 0
$thesisSubstitutionKeys = [Collections.Generic.List[string]]::new()
try {
    foreach ($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($InputPath))) {
        if (-not $line) { continue }
        $o = $line | ConvertFrom-Json
        $r = 0
        $out = [ordered]@{
            ordinal = $o.ordinal
            id = $o.id
            title = $o.title
            date = $o.date
            url = $o.url
            questionContext = $o.questionContext
            thesis = Clean-Field ([string]$o.thesis) ([ref]$r)
            reasoning = Clean-Field ([string]$o.reasoning) ([ref]$r)
            conceptsInArticle = $o.conceptsInArticle
            authorActionAndEthicalJudgments = Clean-Field ([string]$o.authorActionAndEthicalJudgments) ([ref]$r)
            rhetoric = $o.rhetoric
            sourceQuotes = $o.sourceQuotes
            faithfulSummary = Clean-Field ([string]$o.faithfulSummary) ([ref]$r)
            sourceReadingFile = $o.sourceReadingFile
            evidencePolicy = 'High-confidence researcher-side external caveats are sentence-filtered; raw close reading and original evidence remain unchanged.'
        }
        foreach ($f in $allowedTailFields) {
            $value = [string]$out[$f]
            $value = $value -replace '研究者概括，','' -replace '但文章未提供外部数据.*$','' -replace '若涉及现实心理困扰.*$','' -replace '原文并未提供专业.*$'
            $manualKey = "$($o.ordinal):$f"
            if ($manualTails.ContainsKey($manualKey)) {
                $trimmed = $value -replace $manualTails[$manualKey],''
                if ($trimmed -ne $value) { $r++ }
                $value = $trimmed
            }
            if ($suggestionTails.ContainsKey($manualKey)) {
                foreach ($pattern in $suggestionTails[$manualKey]) {
                    $trimmed = $value -replace $pattern,''
                    if ($trimmed -ne $value) { $r++ }
                    $value = $trimmed
                }
            }
            if ($manualReplacements.ContainsKey($manualKey)) {
                if ($value -ne $manualReplacements[$manualKey]) { $replaced++ }
                $value = $manualReplacements[$manualKey]
            }
            elseif ($f -eq 'faithfulSummary' -and $thesisSummaryFallbackOrdinals.Contains([int]$o.ordinal)) {
                # These original summaries consisted wholly of researcher commentary.
                # Reuse the already-clean article thesis rather than inventing a new
                # claim or restoring the contaminated summary.
                if ($value -ne [string]$out.thesis) { $replaced++ }
                $value = [string]$out.thesis
            }
            $postReplacementRemoved = 0
            $value = Clean-Field $value ([ref]$postReplacementRemoved)
            $r += $postReplacementRemoved
            $out[$f] = ($value.Trim() -replace '[；，、]+$','')
            if ([string]::IsNullOrWhiteSpace($out[$f])) {
                if ($f -ne 'thesis' -and -not [string]::IsNullOrWhiteSpace([string]$out.thesis)) {
                    # An absent optional annotation field is safer than restoring
                    # researcher commentary. Reuse the clean thesis so every claim
                    # remains author-attributed and no new proposition is invented.
                    $out[$f] = [string]$out.thesis
                    $thesisSubstitutionCount++
                    [void]$thesisSubstitutionKeys.Add($manualKey)
                }
            }
        }
        $quoteKey = "$($o.ordinal):sourceQuotes"
        if ($manualReplacements.ContainsKey($quoteKey)) {
            if ([string]$out.sourceQuotes -ne $manualReplacements[$quoteKey]) { $replaced++ }
            $out.sourceQuotes = $manualReplacements[$quoteKey]
        }
        $removed += $r
        if ([string]::IsNullOrWhiteSpace($out.thesis) -or [string]::IsNullOrWhiteSpace($out.reasoning) -or [string]::IsNullOrWhiteSpace($out.authorActionAndEthicalJudgments) -or [string]::IsNullOrWhiteSpace($out.faithfulSummary)) { $empty++ }
        $w.WriteLine(($out | ConvertTo-Json -Compress -Depth 6))
        $rows++
    }
}
finally { $w.Dispose() }

$residualLeakCount = 0
$residualLeakKeys = [Collections.Generic.List[string]]::new()
foreach ($line in [IO.File]::ReadLines($full)) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $row = $line | ConvertFrom-Json
    foreach ($field in $allowedTailFields) {
        foreach ($sentence in [regex]::Split([string]$row.$field,'(?<=[。！？；])')) {
            if ($sentence -match $leak) {
                $residualLeakCount++
                [void]$residualLeakKeys.Add(('{0}:{1}' -f [int]$row.ordinal,$field))
            }
        }
    }
}

$stats = [ordered]@{
    rowCount = $rows
    removedSentenceCount = $removed
    exactReplacementCount = $replaced
    suggestionFileCount = $suggestionFiles.Count
    replacementFileCount = $replacementFiles.Count
    restoredFieldCount = $restored
    restoredFieldKeys = @($restoredKeys)
    thesisSubstitutionCount = $thesisSubstitutionCount
    thesisSubstitutionKeys = @($thesisSubstitutionKeys)
    emptyCoreFieldArticles = $empty
    residualLeakCount = $residualLeakCount
    residualLeakKeys = @($residualLeakKeys)
    status = if ($rows -ne 4050 -or $empty -ne 0 -or $residualLeakCount -ne 0) { 'REVIEW' } elseif ($restored -gt 0) { 'PASS_WITH_RESTORES' } else { 'PASS' }
}
$stats | ConvertTo-Json | Set-Content -LiteralPath ([IO.Path]::ChangeExtension($full,'.stats.json')) -Encoding UTF8
$stats | ConvertTo-Json
