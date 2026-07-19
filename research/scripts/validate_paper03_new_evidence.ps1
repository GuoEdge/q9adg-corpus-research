param(
    [string]$CorpusPath = (Join-Path $PSScriptRoot '..\..\sooon-q9adg-articles.jsonl'),
    [string]$OutputPath = (Join-Path $PSScriptRoot '..\review\paper03-new-evidence-raw-check.csv'),
    [string]$StatsPath = (Join-Path $PSScriptRoot '..\review\paper03-new-evidence-raw-check.stats.json')
)

$ErrorActionPreference = 'Stop'

$checks = @(
    [pscustomobject]@{ referenceNumber=24; id='5a49c3ea-822e-5e88-9b69-b28345b46506'; expectedTitle='道德绑架'; exactAnchor='只有对方用你没同意过、尤其是你明确反对过的道德规范来要求你，这个才算道德绑架。' },
    [pscustomobject]@{ referenceNumber=25; id='24394a0a-7e31-5d3b-bee2-fd434354ad9b'; expectedTitle='欢迎不客气'; exactAnchor='但从任何意义上都请不要误认为“不必客气”意味着你可以超额透支、逾期还款或者骗贷。' },
    [pscustomobject]@{ referenceNumber=26; id='88f6cc45-e9e6-5f6e-be62-c55309d38e84'; expectedTitle='感谢'; exactAnchor='不要表达没有行动的愿望。' },
    [pscustomobject]@{ referenceNumber=27; id='5b10c323-2fe2-5bea-9bbd-616bcfd9180d'; expectedTitle='盗名'; exactAnchor='你之前拿我的名义办事，无非是想用我欠人情换你现得利。' },
    [pscustomobject]@{ referenceNumber=28; id='f6347ba6-aad3-5f7f-8b08-353683f03410'; expectedTitle='潜藏无形'; exactAnchor='权力最容易出问题的地方，不是它本身有多大、多绝对，而在于潜藏无形。' },
    [pscustomobject]@{ referenceNumber=29; id='ea9197ca-0a2e-51ee-beeb-ca4773d4a549'; expectedTitle='持公器'; exactAnchor='荣耀附带着权力，任何权力在本质上都是公器。' },
    [pscustomobject]@{ referenceNumber=30; id='375bbeb5-3d6c-5be6-a19c-c0b252263579'; expectedTitle='实习生'; exactAnchor='享有特殊权柄的前提，就是你要有特殊的温柔，超出常人的温柔。' },
    [pscustomobject]@{ referenceNumber=31; id='ed76587c-4978-562f-bf91-82c47bf305fe'; expectedTitle='寒症'; exactAnchor='窄边界策略的坏处是要额外建设很多防御工事、付出很大的精力搞边界管理。' },
    [pscustomobject]@{ referenceNumber=32; id='523c4064-2745-5b68-92dd-d8209abaf022'; expectedTitle='反叛逆'; exactAnchor='人自负成本、自担风险去追求自己的意愿的决定是要被尊重的。' },
    [pscustomobject]@{ referenceNumber=33; id='a464d0ff-9c7c-5003-a8a0-b3e0fb0df61a'; expectedTitle='中国的不足'; exactAnchor='中国现在最大的问题，是被宏观组织的有效性掩盖的微观组织的无效性。' }
)

$rawById = @{}
foreach ($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($CorpusPath))) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $row = $line | ConvertFrom-Json
    $rawById[[string]$row.id] = $row
}

$results = foreach ($check in $checks) {
    $found = $rawById.ContainsKey($check.id)
    $row = if ($found) { $rawById[$check.id] } else { $null }
    $titleExact = $found -and ([string]$row.title).Equals($check.expectedTitle,[StringComparison]::Ordinal)
    $anchorExact = $found -and ([string]$row.text).Contains($check.exactAnchor,[StringComparison]::Ordinal)
    [pscustomobject]@{
        referenceNumber = $check.referenceNumber
        id = $check.id
        title = $check.expectedTitle
        foundInCorpus = $found
        titleExact = $titleExact
        anchorExactOrdinal = $anchorExact
        exactAnchor = $check.exactAnchor
        status = if ($found -and $titleExact -and $anchorExact) { 'PASS' } else { 'REVIEW' }
    }
}

New-Item -ItemType Directory -Force -Path (Split-Path -Parent ([IO.Path]::GetFullPath($OutputPath))) | Out-Null
$results | Export-Csv -LiteralPath $OutputPath -NoTypeInformation -Encoding UTF8
$failures = @($results | Where-Object status -ne 'PASS').Count
$stats = [ordered]@{
    paper = '03_伦理作为社会技术_权力互惠与社会资本.md'
    comparison = 'StringComparison.Ordinal'
    checkedNewReferences = $results.Count
    exactRawAnchors = @($results | Where-Object anchorExactOrdinal).Count
    failures = $failures
    status = if ($failures -eq 0) { 'PASS' } else { 'REVIEW' }
}
$stats | ConvertTo-Json | Set-Content -LiteralPath $StatsPath -Encoding UTF8
$stats | ConvertTo-Json

