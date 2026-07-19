param(
    [string]$CorpusPath = (Join-Path $PSScriptRoot '..\..\sooon-q9adg-articles.jsonl'),
    [string]$OutputDir = (Join-Path $PSScriptRoot '..\close-reading\packets'),
    [int]$BatchSize = 25
)

$ErrorActionPreference = 'Stop'
if ($BatchSize -lt 1) { throw 'BatchSize must be greater than zero.' }

$OutputDir = [System.IO.Path]::GetFullPath($OutputDir)
New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
Get-ChildItem -LiteralPath $OutputDir -Filter 'batch-*.jsonl' -File -ErrorAction SilentlyContinue | Remove-Item -Force

$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
$batch = [System.Collections.Generic.List[string]]::new()
$batchNumber = 0
$ordinal = 0
$packetRows = [System.Collections.Generic.List[object]]::new()

function Write-Batch {
    param(
        [int]$Number,
        [System.Collections.Generic.List[string]]$Lines,
        [string]$Directory,
        [System.Text.Encoding]$Encoding
    )

    if ($Lines.Count -eq 0) { return }
    $start = $Number * $BatchSize - $BatchSize + 1
    $end = $start + $Lines.Count - 1
    $name = 'batch-{0:D3}-{1:D4}-{2:D4}.jsonl' -f $Number, $start, $end
    [System.IO.File]::WriteAllLines((Join-Path $Directory $name), $Lines, $Encoding)
}

foreach ($line in [System.IO.File]::ReadLines([System.IO.Path]::GetFullPath($CorpusPath))) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $item = $line | ConvertFrom-Json
    $ordinal++
    $published = [DateTimeOffset]::FromUnixTimeMilliseconds([int64]$item.publishedAt).ToOffset([TimeSpan]::FromHours(8))
    $row = [ordered]@{
        ordinal = $ordinal
        id = [string]$item.id
        title = [string]$item.title
        question = [string]$item.question
        date = $published.ToString('yyyy-MM-dd')
        url = [string]$item.url
        text = [string]$item.text
    }
    $packetRows.Add([pscustomobject]$row)
    $batch.Add(($row | ConvertTo-Json -Compress -Depth 5))

    if ($batch.Count -eq $BatchSize) {
        $batchNumber++
        Write-Batch -Number $batchNumber -Lines $batch -Directory $OutputDir -Encoding $utf8NoBom
        $packetRows.Clear()
        $batch.Clear()
    }
}

if ($batch.Count -gt 0) {
    $batchNumber++
    Write-Batch -Number $batchNumber -Lines $batch -Directory $OutputDir -Encoding $utf8NoBom
}

Write-Output "Wrote $batchNumber packet files for $ordinal articles."
