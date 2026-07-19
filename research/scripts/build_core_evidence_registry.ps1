param(
    [string]$DataDir = (Join-Path $PSScriptRoot '..\data'),
    [string]$OutputPath = (Join-Path $PSScriptRoot '..\data\core_evidence_registry.csv')
)

$ErrorActionPreference = 'Stop'
$statsFiles = @(Get-ChildItem -LiteralPath $DataDir -Filter '*_core_evidence.stats.json' -File | Sort-Object Name)
$rows = @(
    foreach ($file in $statsFiles) {
        $stats = Get-Content -LiteralPath $file.FullName -Raw | ConvertFrom-Json
        $evidenceRows = if ($null -ne $stats.evidenceRows) {
            [int]$stats.evidenceRows
        }
        elseif ($null -ne $stats.evidenceRowCount) {
            [int]$stats.evidenceRowCount
        }
        else { -1 }

        $quoteFailures = if ($null -ne $stats.exactQuoteFailures) {
            [int]$stats.exactQuoteFailures
        }
        elseif ($null -ne $stats.quoteFailures) {
            [int]$stats.quoteFailures
        }
        elseif ($null -ne $stats.quoteOrdinalFailureCount) {
            [int]$stats.quoteOrdinalFailureCount
        }
        else { -1 }

        [pscustomobject][ordered]@{
            file = $file.Name
            status = [string]$stats.status
            evidenceRows = $evidenceRows
            quoteOrdinalFailures = $quoteFailures
        }
    }
)

New-Item -ItemType Directory -Path (Split-Path -Parent ([IO.Path]::GetFullPath($OutputPath))) -Force | Out-Null
$rows | Export-Csv -LiteralPath $OutputPath -NoTypeInformation -Encoding utf8BOM
$invalid = @($rows | Where-Object { $_.status -ne 'PASS' -or $_.evidenceRows -lt 0 -or $_.quoteOrdinalFailures -ne 0 })
$stats = [ordered]@{
    generatedAt = (Get-Date).ToString('o')
    registryRows = $rows.Count
    passRows = @($rows | Where-Object status -eq 'PASS').Count
    totalEvidenceRows = ($rows | Measure-Object evidenceRows -Sum).Sum
    quoteOrdinalFailures = ($rows | Measure-Object quoteOrdinalFailures -Sum).Sum
    invalidFiles = @($invalid | ForEach-Object { $_.file })
    status = if ($rows.Count -eq 20 -and $invalid.Count -eq 0) { 'PASS' } else { 'REVIEW' }
}
$stats | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath ([IO.Path]::ChangeExtension([IO.Path]::GetFullPath($OutputPath), '.stats.json')) -Encoding utf8
$stats | ConvertTo-Json -Depth 4
