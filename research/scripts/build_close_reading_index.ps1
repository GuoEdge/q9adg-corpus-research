param(
    [string]$CorpusPath = (Join-Path $PSScriptRoot '..\..\sooon-q9adg-articles.jsonl'),
    [string]$OutputPath = (Join-Path $PSScriptRoot '..\close-reading\index.csv'),
    [int]$BatchSize = 25
)

$ErrorActionPreference = 'Stop'
if ($BatchSize -lt 1) { throw 'BatchSize must be greater than zero.' }

$rows = [System.Collections.Generic.List[object]]::new()
$ordinal = 0
foreach ($line in [System.IO.File]::ReadLines([System.IO.Path]::GetFullPath($CorpusPath))) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $item = $line | ConvertFrom-Json
    $ordinal++
    $published = [DateTimeOffset]::FromUnixTimeMilliseconds([int64]$item.publishedAt).ToOffset([TimeSpan]::FromHours(8))
    $batch = [int][math]::Ceiling($ordinal / $BatchSize)
    $start = ($batch - 1) * $BatchSize + 1
    $end = [math]::Min($batch * $BatchSize, 4050)
    $batchFile = 'batch-{0:D3}-{1:D4}-{2:D4}.md' -f $batch, $start, $end
    $rows.Add([pscustomobject][ordered]@{
        ordinal = $ordinal
        id = [string]$item.id
        title = [string]$item.title
        date = $published.ToString('yyyy-MM-dd')
        url = [string]$item.url
        batch = $batch
        batchFile = $batchFile
    })
}

$full = [System.IO.Path]::GetFullPath($OutputPath)
New-Item -ItemType Directory -Path ([System.IO.Path]::GetDirectoryName($full)) -Force | Out-Null
$rows | Export-Csv -LiteralPath $full -NoTypeInformation -Encoding utf8BOM
Write-Output "Wrote $($rows.Count) rows to $full"
