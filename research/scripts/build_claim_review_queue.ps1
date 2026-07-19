param(
    [string]$EvidencePath = (Join-Path $PSScriptRoot '..\data\author_view_evidence.jsonl'),
    [string]$OutputPath = (Join-Path $PSScriptRoot '..\data\claim_review_queue.csv'),
    [int]$Limit = 500
)

$ErrorActionPreference = 'Stop'
$concepts = @('事实','证据','定义','概念','能力','学习','选择','自由','责任','后果','成本','总账','信用','信任','爱','回应','净输出','不掠夺','边界','许可','照料','家庭','劳动','组织','财富','市场','法律','秩序','权力','异议','技术','工程','文明','历史','心理','焦虑','抑郁','性别','身体','宗教','自然法')
$rows = foreach ($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($EvidencePath))) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $o = $line | ConvertFrom-Json
    $text = @($o.questionContext,$o.thesis,$o.reasoning,$o.conceptsInArticle,$o.authorActionAndEthicalJudgments,$o.sourceQuotes,$o.faithfulSummary) -join "`n"
    $hit = @($concepts | Where-Object { $text -match [regex]::Escape($_) })
    [pscustomobject]@{
        ordinal=[int]$o.ordinal; id=$o.id; title=$o.title; date=$o.date; url=$o.url
        conceptHitCount=$hit.Count; concepts=($hit -join '、');
        thesis=$o.thesis; reasoning=$o.reasoning; actionJudgment=$o.authorActionAndEthicalJudgments
        sourceQuotes=$o.sourceQuotes; sourceReadingFile=$o.sourceReadingFile
        reviewStatus='UNREVIEWED'; rawTextChecked=''; reviewerNote=''
    }
}
$rows | Sort-Object @{Expression='conceptHitCount';Descending=$true},ordinal | Select-Object -First $Limit | Export-Csv -LiteralPath ([IO.Path]::GetFullPath($OutputPath)) -NoTypeInformation -Encoding UTF8
[pscustomobject]@{outputPath=[IO.Path]::GetFullPath($OutputPath);queueCount=[math]::Min($Limit,$rows.Count);sourceCount=$rows.Count;status='PASS'} | ConvertTo-Json
