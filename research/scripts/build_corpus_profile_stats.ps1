param(
    [string]$IndexPath = (Join-Path $PSScriptRoot '..\data\corpus_index.csv'),
    [string]$OutputPath = (Join-Path $PSScriptRoot '..\data\corpus_profile_stats.json')
)

$ErrorActionPreference = 'Stop'

function Get-Percentile {
    param(
        [Parameter(Mandatory)] [int[]] $Values,
        [Parameter(Mandatory)] [double] $Percentile
    )

    if ($Values.Count -eq 0) { return 0 }
    $sorted = @($Values | Sort-Object)
    $index = [Math]::Floor(($sorted.Count - 1) * $Percentile)
    return $sorted[$index]
}

function Get-Platform([string] $Url) {
    $uriHost = ([uri]$Url).Host.ToLowerInvariant()
    if ($uriHost.Contains('zhihu', [StringComparison]::Ordinal)) { return '知乎' }
    if (
        $uriHost.Contains('ifdian', [StringComparison]::Ordinal) -or
        $uriHost.Contains('afdian', [StringComparison]::Ordinal)
    ) { return '爱发电' }
    return $uriHost
}

$rows = @(Import-Csv -LiteralPath $IndexPath)
$profileRows = @(
    foreach ($row in $rows) {
        $themeCount = if ([string]::IsNullOrWhiteSpace($row.themes)) {
            0
        }
        else {
            @($row.themes -split ';').Count
        }

        [pscustomobject]@{
            id = $row.id
            year = [int]$row.publishedYear
            month = $row.publishedMonth
            platform = Get-Platform $row.url
            charCount = [int]$row.charCount
            paragraphCount = [int]$row.paragraphCount
            themeCount = $themeCount
        }
    }
)

$platformDistribution = [ordered]@{}
$profileRows | Group-Object platform | Sort-Object Count -Descending | ForEach-Object {
    $platformDistribution[$_.Name] = [ordered]@{
        articleCount = $_.Count
        sharePct = [Math]::Round(100 * $_.Count / $profileRows.Count, 2)
    }
}

$yearProfiles = [ordered]@{}
$profileRows | Group-Object year | Sort-Object { [int]$_.Name } | ForEach-Object {
    $group = @($_.Group)
    $lengths = [int[]]@($group.charCount)
    $platforms = [ordered]@{}
    $group | Group-Object platform | Sort-Object Name | ForEach-Object {
        $platforms[$_.Name] = $_.Count
    }

    $yearProfiles[$_.Name] = [ordered]@{
        articleCount = $group.Count
        activeMonthCount = @($group.month | Sort-Object -Unique).Count
        characterTotal = ($group | Measure-Object charCount -Sum).Sum
        characterMean = [Math]::Round(($group | Measure-Object charCount -Average).Average, 2)
        characterMedian = Get-Percentile -Values $lengths -Percentile 0.5
        characterP25 = Get-Percentile -Values $lengths -Percentile 0.25
        characterP75 = Get-Percentile -Values $lengths -Percentile 0.75
        platforms = $platforms
    }
}

$lengthBandDefinitions = @(
    [pscustomobject]@{ name = '0'; test = { param($n) $n -eq 0 } },
    [pscustomobject]@{ name = '1-499'; test = { param($n) $n -ge 1 -and $n -le 499 } },
    [pscustomobject]@{ name = '500-999'; test = { param($n) $n -ge 500 -and $n -le 999 } },
    [pscustomobject]@{ name = '1000-1999'; test = { param($n) $n -ge 1000 -and $n -le 1999 } },
    [pscustomobject]@{ name = '2000-3999'; test = { param($n) $n -ge 2000 -and $n -le 3999 } },
    [pscustomobject]@{ name = '4000+'; test = { param($n) $n -ge 4000 } }
)
$lengthBands = [ordered]@{}
foreach ($definition in $lengthBandDefinitions) {
    $count = @($profileRows | Where-Object { & $definition.test $_.charCount }).Count
    $lengthBands[$definition.name] = [ordered]@{
        articleCount = $count
        sharePct = [Math]::Round(100 * $count / $profileRows.Count, 2)
    }
}

$themeOverlap = [ordered]@{}
$profileRows | Group-Object themeCount | Sort-Object { [int]$_.Name } | ForEach-Object {
    $themeOverlap[$_.Name] = [ordered]@{
        articleCount = $_.Count
        sharePct = [Math]::Round(100 * $_.Count / $profileRows.Count, 2)
    }
}

$late = @($profileRows | Where-Object year -ge 2024)
$emptyBodyIds = @($profileRows | Where-Object charCount -eq 0 | Select-Object -ExpandProperty id)
$stats = [ordered]@{
    generatedAt = (Get-Date).ToString('o')
    indexPath = [System.IO.Path]::GetFullPath($IndexPath)
    articleCount = $profileRows.Count
    platformMethod = 'URL host mapping: zhihu => 知乎; ifdian or afdian => 爱发电.'
    platformDistribution = $platformDistribution
    yearProfiles = $yearProfiles
    lengthBands = $lengthBands
    themeOverlapMethod = 'Count of broad retrieval themes assigned by build_corpus_index.ps1; overlap is descriptive, not topic classification.'
    themeOverlap = $themeOverlap
    latePeriod = [ordered]@{
        period = '2024-2026-07-17'
        articleCount = $late.Count
        ifdianArticleCount = @($late | Where-Object platform -eq '爱发电').Count
        ifdianSharePct = [Math]::Round(100 * @($late | Where-Object platform -eq '爱发电').Count / $late.Count, 2)
    }
    emptyBodyCount = $emptyBodyIds.Count
    emptyBodyIds = $emptyBodyIds
}

$outputDirectory = Split-Path -Parent ([System.IO.Path]::GetFullPath($OutputPath))
New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
$stats | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $OutputPath -Encoding utf8
Write-Output "Wrote corpus profile stats for $($profileRows.Count) articles to $OutputPath"
