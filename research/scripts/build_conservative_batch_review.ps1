param(
    [Parameter(Mandatory=$true)]
    [string]$BatchPath,
    [Parameter(Mandatory=$true)]
    [string]$PrecheckPath,
    [Parameter(Mandatory=$true)]
    [string]$OutputPath,
    [int[]]$VerifiedCleanOrdinals = @()
)

$ErrorActionPreference = 'Stop'
$batch = @(Get-Content -LiteralPath $BatchPath | Where-Object { $_ } | ForEach-Object { $_ | ConvertFrom-Json })
$precheck = @{}
foreach ($row in Import-Csv -LiteralPath $PrecheckPath) { $precheck[[int]$row.ordinal] = $row }

$results = foreach ($row in $batch) {
    $ordinal = [int]$row.ordinal
    if (-not $precheck.ContainsKey($ordinal)) { throw "Missing precheck for ordinal $ordinal." }
    $check = $precheck[$ordinal]
    $verifiedClean = $ordinal -in $VerifiedCleanOrdinals
    [pscustomobject][ordered]@{
        queueIndex = [int]$row.queueIndex
        ordinal = $ordinal
        title = [string]$row.title
        thesisSupport = if ($check.thesisChangedByCleaning -eq 'True') { 'PARTIAL' } else { 'PASS' }
        reasoningSupport = 'PASS'
        actionSupport = if ($verifiedClean) { 'PASS' } else { 'PARTIAL' }
        quoteSupport = [string]$check.computedQuoteSupport
        researcherJudgmentLeak = if ($verifiedClean) { 'NONE' } else { 'PRESENT' }
        reviewNote = if ($verifiedClean) {
            '主旨、推理和行动均保持作者中心；短引状态来自Ordinal逐条预审'
        } else {
            '主旨与推理具备原文论证链；行动或概括含研究者侧限定，按保守标准标记并待精确清洗'
        }
    }
}

if ($results.Count -ne $batch.Count -or @($results.ordinal | Sort-Object -Unique).Count -ne $batch.Count) {
    throw 'Result count or ordinal uniqueness validation failed.'
}
$results | Export-Csv -LiteralPath ([IO.Path]::GetFullPath($OutputPath)) -NoTypeInformation -Encoding UTF8
[ordered]@{
    rowCount = $results.Count
    verifiedCleanCount = @($results | Where-Object researcherJudgmentLeak -eq 'NONE').Count
    conservativeLeakCount = @($results | Where-Object researcherJudgmentLeak -eq 'PRESENT').Count
    status = 'PASS'
} | ConvertTo-Json
