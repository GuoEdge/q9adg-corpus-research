[CmdletBinding()]
param(
    [string]$PaperDir = (Join-Path $PSScriptRoot '..\papers'),
    [string]$ZhihuDir = (Join-Path $PSScriptRoot '..\zhihu'),
    [string]$RepositoryBase = 'https://github.com/GuoEdge/q9adg-corpus-research/blob/main'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$articleDir = Join-Path $ZhihuDir 'articles'
New-Item -ItemType Directory -Path $articleDir -Force | Out-Null

function Convert-LocalLinks([string]$Text) {
    $result = [regex]::Replace($Text,'\(D:\\岐伯论\\(?<path>[^)]+)\)',{
        param($match)
        $relative = $match.Groups['path'].Value.Replace('\','/')
        '(' + $RepositoryBase + '/' + ($relative -split '/' | ForEach-Object { [uri]::EscapeDataString($_) } | Join-String -Separator '/') + ')'
    })
    $result = [regex]::Replace($result,'\((?<file>\d{2}_[^)]+\.md)\)',{
        param($match)
        $file = $match.Groups['file'].Value
        '(' + $RepositoryBase + '/research/papers/' + [uri]::EscapeDataString($file) + ')'
    })
    return $result
}

$manifest = [Collections.Generic.List[object]]::new()
$introPath = Join-Path $ZhihuDir '00_系列总序.md'
$introTitle = ([IO.File]::ReadLines($introPath) | Select-Object -First 1) -replace '^#\s+',''
[void]$manifest.Add([pscustomobject][ordered]@{
    seriesNumber = 0
    title = $introTitle
    sourceFile = 'research/zhihu/00_系列总序.md'
    publishFile = 'research/zhihu/00_系列总序.md'
    chineseChars = [regex]::Matches([IO.File]::ReadAllText($introPath),'[\p{IsCJKUnifiedIdeographs}]').Count
    status = 'READY'
    zhihuUrl = ''
})

$papers = @(Get-ChildItem -LiteralPath $PaperDir -Filter '*.md' -File | Sort-Object Name)
for ($index = 0; $index -lt $papers.Count; $index++) {
    $paper = $papers[$index]
    $seriesNumber = $index + 1
    $raw = [IO.File]::ReadAllText($paper.FullName)
    $firstLine = [regex]::Match($raw,'(?m)^#\s+(?<title>.+)$')
    if (-not $firstLine.Success) { throw "Missing H1 title: $($paper.FullName)" }
    $originalTitle = $firstLine.Groups['title'].Value.Trim()
    $publishTitle = '岐伯公开文本系统研究（{0:D2}）｜{1}' -f $seriesNumber,$originalTitle
    $body = $raw.Remove($firstLine.Index,$firstLine.Length).TrimStart("`r","`n")
    $body = Convert-LocalLinks $body
    $sourceRelative = 'research/papers/' + $paper.Name
    $sourceUrl = $RepositoryBase + '/research/papers/' + [uri]::EscapeDataString($paper.Name)
    $prefix = @"
# $publishTitle

> 本文是“岐伯公开文本系统研究”系列第${seriesNumber}篇。研究只重建岐伯在公开文本中的判断、推理、条件和建议；跨文概念与分类均属研究重建，不加入AI自身的价值裁决。

> 完整研究、数据说明和可复现脚本：$RepositoryBase/README.md

"@
    $suffix = @"

---

**系列说明**

本系列以4,050篇公开文本为语料。直接短引均已返回对应原文逐字验证；文章ID和原始链接用于读者复核。研究开放版本：

$sourceUrl

项目总入口：https://github.com/GuoEdge/q9adg-corpus-research
"@
    $outputName = '{0:D2}_{1}' -f $seriesNumber,$paper.Name
    $outputPath = Join-Path $articleDir $outputName
    [IO.File]::WriteAllText($outputPath,($prefix + $body + $suffix),[Text.UTF8Encoding]::new($false))
    [void]$manifest.Add([pscustomobject][ordered]@{
        seriesNumber = $seriesNumber
        title = $publishTitle
        sourceFile = $sourceRelative
        publishFile = 'research/zhihu/articles/' + $outputName
        chineseChars = [regex]::Matches([IO.File]::ReadAllText($outputPath),'[\p{IsCJKUnifiedIdeographs}]').Count
        status = 'READY'
        zhihuUrl = ''
    })
}

$manifestPath = Join-Path $ZhihuDir 'zhihu-publishing-manifest.csv'
$manifest | Export-Csv -LiteralPath $manifestPath -NoTypeInformation -Encoding utf8BOM
$stats = [ordered]@{
    generatedAt = [DateTimeOffset]::Now.ToString('o')
    articleCount = $manifest.Count
    readyCount = @($manifest | Where-Object status -eq 'READY').Count
    totalChineseChars = [int](($manifest | Measure-Object chineseChars -Sum).Sum)
    status = if ($papers.Count -eq 34 -and $manifest.Count -eq 35) { 'PASS' } else { 'REVIEW' }
}
$stats | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $ZhihuDir 'zhihu-publishing-manifest.stats.json') -Encoding utf8
$stats | ConvertTo-Json -Depth 4
if ($stats.status -ne 'PASS') { exit 1 }
