param(
    [string]$CorpusPath = (Join-Path $PSScriptRoot '..\..\sooon-q9adg-articles.jsonl'),
    [string]$YearOutputPath = (Join-Path $PSScriptRoot '..\data\diachronic_zhihu_year_term_sensitivity.csv'),
    [string]$PeriodOutputPath = (Join-Path $PSScriptRoot '..\data\diachronic_zhihu_period_term_sensitivity.csv'),
    [string]$LeaveOneYearOutPath = (Join-Path $PSScriptRoot '..\data\diachronic_zhihu_leave_one_year_out_sensitivity.csv'),
    [string]$EqualYearWeightPath = (Join-Path $PSScriptRoot '..\data\diachronic_zhihu_equal_year_weight_sensitivity.csv'),
    [string]$LengthStandardizedPath = (Join-Path $PSScriptRoot '..\data\diachronic_zhihu_length_standardized_sensitivity.csv'),
    [string]$StatsPath = (Join-Path $PSScriptRoot '..\data\diachronic_zhihu_sensitivity.stats.json')
)

$ErrorActionPreference = 'Stop'

$terms = @(
    [pscustomobject]@{ key = 'love'; literal = '爱' }
    [pscustomobject]@{ key = 'naturalLaw'; literal = '自然法' }
    [pscustomobject]@{ key = 'labor'; literal = '劳动' }
    [pscustomobject]@{ key = 'responsibility'; literal = '责任' }
    [pscustomobject]@{ key = 'freedom'; literal = '自由' }
    [pscustomobject]@{ key = 'ethics'; literal = '伦理' }
    [pscustomobject]@{ key = 'fact'; literal = '事实' }
    [pscustomobject]@{ key = 'ability'; literal = '能力' }
)

$periods = @(
    [pscustomobject]@{ key = 'early'; label = '2018-2020'; startYear = 2018; endYear = 2020 }
    [pscustomobject]@{ key = 'middle'; label = '2021-2023'; startYear = 2021; endYear = 2023 }
    [pscustomobject]@{ key = 'late'; label = '2024-2026'; startYear = 2024; endYear = 2026 }
)

$windows = @(
    [pscustomobject]@{
        key = 'full_period'
        label = '三阶段原始完整窗口'
        rule = '各阶段纳入知乎子集中全部日期；晚期2026仅有截至2026-07-14的知乎观测'
    }
    [pscustomobject]@{
        key = 'exclude_2026'
        label = '晚期排除2026'
        rule = '早中期不变；晚期仅纳入2024-01-01至2025-12-31'
    }
    [pscustomobject]@{
        key = 'matched_jan01_jun30'
        label = '等月份窗口'
        rule = '每个构成年只纳入1月1日至6月30日（含首尾，即六个完整月份）'
    }
    [pscustomobject]@{
        key = 'matched_jan01_jun30_exclude_2018'
        label = '等月份且排除2018窗口'
        rule = '每个构成年只纳入1月1日至6月30日（含首尾），并排除知乎仅从6月11日起观测的2018年'
    }
)

function Get-NodeText {
    param([Parameter(Mandatory)][object]$Node)

    $builder = [Text.StringBuilder]::new()
    $stack = [Collections.Generic.Stack[object]]::new()
    $stack.Push($Node)
    while ($stack.Count -gt 0) {
        $current = $stack.Pop()
        $textProperty = $current.psobject.Properties['text']
        if ($null -ne $textProperty -and $null -ne $textProperty.Value) {
            [void]$builder.Append([string]$textProperty.Value)
        }
        $childrenProperty = $current.psobject.Properties['children']
        if ($null -eq $childrenProperty -or $null -eq $childrenProperty.Value) { continue }
        $children = @($childrenProperty.Value)
        for ($index = $children.Count - 1; $index -ge 0; $index--) {
            $stack.Push($children[$index])
        }
    }
    return $builder.ToString()
}

function Get-Platform {
    param([string]$Url)
    if ($Url -match 'zhihu\.com') { return 'Zhihu' }
    if ($Url -match '(ifdian\.net|afdian\.com)') { return 'Afdian' }
    return 'Other'
}

function Test-InWindow {
    param(
        [Parameter(Mandatory)][object]$Record,
        [Parameter(Mandatory)][object]$Period,
        [Parameter(Mandatory)][string]$WindowKey
    )

    if ($Record.year -lt $Period.startYear -or $Record.year -gt $Period.endYear) { return $false }
    if ($WindowKey -eq 'exclude_2026' -and $Period.key -eq 'late' -and $Record.year -eq 2026) { return $false }
    if ($WindowKey -like 'matched_jan01_jun30*') {
        if ($WindowKey -eq 'matched_jan01_jun30_exclude_2018' -and $Record.year -eq 2018) { return $false }
        return ($Record.month -le 6)
    }
    return $true
}

function Get-Direction {
    param([double]$First, [double]$Second)
    if ($Second -gt $First) { return 'increase' }
    if ($Second -lt $First) { return 'decrease' }
    return 'flat'
}

function Get-Trajectory {
    param([double]$Early, [double]$Middle, [double]$Late)
    $first = Get-Direction -First $Early -Second $Middle
    $second = Get-Direction -First $Middle -Second $Late
    if ($first -eq 'increase' -and $second -eq 'increase') { return 'increase_in_both_transitions' }
    if ($first -eq 'decrease' -and $second -eq 'decrease') { return 'decrease_in_both_transitions' }
    if ($first -eq 'decrease' -and $second -eq 'increase') { return 'down_then_up' }
    if ($first -eq 'increase' -and $second -eq 'decrease') { return 'up_then_down' }
    return "$first`_then`_$second"
}

function Test-OppositeDirection {
    param([string]$First, [string]$Second)
    return (
        ($First -eq 'increase' -and $Second -eq 'decrease') -or
        ($First -eq 'decrease' -and $Second -eq 'increase')
    )
}

function Get-AggregateRows {
    param(
        [Parameter(Mandatory)][object[]]$SelectedRecords,
        [Parameter(Mandatory)][System.Collections.IDictionary]$CommonFields
    )

    $articleCount = $SelectedRecords.Count
    $authorTextCharCount = [int64](($SelectedRecords | Measure-Object authorTextCharCount -Sum).Sum)
    $authorNonWhitespaceCharCount = [int64](($SelectedRecords | Measure-Object authorNonWhitespaceCharCount -Sum).Sum)
    $fullLexicalCharCount = [int64](($SelectedRecords | Measure-Object fullLexicalCharCount -Sum).Sum)
    $fullLexicalNonWhitespaceCharCount = [int64](($SelectedRecords | Measure-Object fullLexicalNonWhitespaceCharCount -Sum).Sum)

    foreach ($term in $terms) {
        $authorHitArticleCount = @($SelectedRecords | Where-Object { $_.authorHits[$term.key] }).Count
        $fullHitArticleCount = @($SelectedRecords | Where-Object { $_.fullHits[$term.key] }).Count
        $authorOccurrenceCount = [int64](($SelectedRecords | ForEach-Object { $_.authorOccurrences[$term.key] } | Measure-Object -Sum).Sum)
        $fullOccurrenceCount = [int64](($SelectedRecords | ForEach-Object { $_.fullOccurrences[$term.key] } | Measure-Object -Sum).Sum)
        $authorArticleCoverageUnrounded = if ($articleCount -gt 0) { $authorHitArticleCount / $articleCount } else { $null }
        $occurrenceRateUnrounded = if ($authorNonWhitespaceCharCount -gt 0) {
            100000 * $authorOccurrenceCount / $authorNonWhitespaceCharCount
        } else { $null }
        $values = [ordered]@{}
        foreach ($key in $CommonFields.Keys) { $values[$key] = $CommonFields[$key] }
        $values['articleCount'] = $articleCount
        $values['term'] = $term.key
        $values['literal'] = $term.literal
        $values['authorHitArticleCount'] = $authorHitArticleCount
        $values['authorArticleCoverage'] = if ($null -ne $authorArticleCoverageUnrounded) { [math]::Round($authorArticleCoverageUnrounded, 8) } else { $null }
        $values['authorArticleCoverageUnrounded'] = $authorArticleCoverageUnrounded
        $values['fullLexicalHitArticleCount'] = $fullHitArticleCount
        $values['excludedQuoteOnlyHitArticleCount'] = $fullHitArticleCount - $authorHitArticleCount
        $values['authorOccurrenceCount'] = $authorOccurrenceCount
        $values['occurrencesPer100kAuthorNonWhitespaceChars'] = if ($null -ne $occurrenceRateUnrounded) { [math]::Round($occurrenceRateUnrounded, 6) } else { $null }
        $values['occurrencesPer100kAuthorNonWhitespaceCharsUnrounded'] = $occurrenceRateUnrounded
        $values['fullLexicalOccurrenceCount'] = $fullOccurrenceCount
        $values['excludedQuoteOccurrenceCount'] = $fullOccurrenceCount - $authorOccurrenceCount
        $values['authorTextCharCount'] = $authorTextCharCount
        $values['authorNonWhitespaceCharCount'] = $authorNonWhitespaceCharCount
        $values['fullLexicalCharCount'] = $fullLexicalCharCount
        $values['fullLexicalNonWhitespaceCharCount'] = $fullLexicalNonWhitespaceCharCount
        $values['excludedTopLevelQuoteCharCount'] = $fullLexicalCharCount - $authorTextCharCount
        [pscustomobject]$values
    }
}

$records = [Collections.Generic.List[object]]::new()
$seenIds = [Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
$invalidIdCount = 0
$duplicateIdCount = 0
$lexicalMissingCount = 0
$lexicalParseFailureCount = 0
$negativeArticleTermDeltaCount = 0
$negativeOccurrenceDeltaCount = 0
$negativeCharacterDeltaCount = 0
$minDate = $null
$maxDate = $null

foreach ($line in [IO.File]::ReadLines([IO.Path]::GetFullPath($CorpusPath))) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $article = $line | ConvertFrom-Json
    $id = [string]$article.id
    if ([string]::IsNullOrWhiteSpace($id)) { $invalidIdCount++ }
    elseif (-not $seenIds.Add($id)) { $duplicateIdCount++ }

    $date = [DateTimeOffset]::FromUnixTimeMilliseconds([int64]$article.publishedAt).ToOffset([TimeSpan]::FromHours(8))
    if ($null -eq $minDate -or $date -lt $minDate) { $minDate = $date }
    if ($null -eq $maxDate -or $date -gt $maxDate) { $maxDate = $date }

    $fullTextBuilder = [Text.StringBuilder]::new()
    $authorTextBuilder = [Text.StringBuilder]::new()
    $fullOccurrences = [ordered]@{}
    $authorOccurrences = [ordered]@{}
    foreach ($term in $terms) {
        $fullOccurrences[$term.key] = 0
        $authorOccurrences[$term.key] = 0
    }

    if ([string]::IsNullOrWhiteSpace([string]$article.lexical)) {
        $lexicalMissingCount++
    } else {
        try {
            $lexical = [string]$article.lexical | ConvertFrom-Json
            foreach ($node in @($lexical.root.children)) {
                $nodeText = Get-NodeText -Node $node
                [void]$fullTextBuilder.Append($nodeText)
                $isAuthorNode = ([string]$node.type -ne 'quote')
                if ($isAuthorNode) { [void]$authorTextBuilder.Append($nodeText) }
                foreach ($term in $terms) {
                    $count = [regex]::Matches($nodeText, [regex]::Escape($term.literal)).Count
                    $fullOccurrences[$term.key] += $count
                    if ($isAuthorNode) { $authorOccurrences[$term.key] += $count }
                }
            }
        } catch {
            $lexicalParseFailureCount++
        }
    }

    $fullText = $fullTextBuilder.ToString()
    $authorText = $authorTextBuilder.ToString()
    $fullHits = [ordered]@{}
    $authorHits = [ordered]@{}
    foreach ($term in $terms) {
        $fullHits[$term.key] = ($fullOccurrences[$term.key] -gt 0)
        $authorHits[$term.key] = ($authorOccurrences[$term.key] -gt 0)
        if ([int]$authorHits[$term.key] -gt [int]$fullHits[$term.key]) { $negativeArticleTermDeltaCount++ }
        if ([int64]$authorOccurrences[$term.key] -gt [int64]$fullOccurrences[$term.key]) { $negativeOccurrenceDeltaCount++ }
    }
    $fullNonWhitespace = [regex]::Replace($fullText, '\s', '').Length
    $authorNonWhitespace = [regex]::Replace($authorText, '\s', '').Length
    if ($authorText.Length -gt $fullText.Length -or $authorNonWhitespace -gt $fullNonWhitespace) {
        $negativeCharacterDeltaCount++
    }

    [void]$records.Add([pscustomobject]@{
        id = $id
        title = [string]$article.title
        url = [string]$article.url
        platform = Get-Platform -Url ([string]$article.url)
        year = $date.Year
        month = $date.Month
        day = $date.Day
        date = $date
        fullHits = $fullHits
        authorHits = $authorHits
        fullOccurrences = $fullOccurrences
        authorOccurrences = $authorOccurrences
        fullLexicalCharCount = [int64]$fullText.Length
        authorTextCharCount = [int64]$authorText.Length
        fullLexicalNonWhitespaceCharCount = [int64]$fullNonWhitespace
        authorNonWhitespaceCharCount = [int64]$authorNonWhitespace
    })
}

$zhihuRecords = @($records | Where-Object platform -eq 'Zhihu')
$analysisRecords = @($zhihuRecords | Where-Object { $_.year -ge 2018 -and $_.year -le 2026 })
$yearRows = foreach ($year in ($zhihuRecords.year | Sort-Object -Unique)) {
    $selected = @($zhihuRecords | Where-Object year -eq $year)
    $coverage = if ($year -eq 2017) { 'partial_from_2017-09-08' } elseif ($year -eq 2026) { 'partial_to_latest_observed_zhihu_article' } else { 'complete_calendar_year' }
    Get-AggregateRows -SelectedRecords $selected -CommonFields ([ordered]@{
        year = $year
        yearCoverage = $coverage
    })
}

$periodRows = foreach ($window in $windows) {
    foreach ($period in $periods) {
        $selected = @($analysisRecords | Where-Object { Test-InWindow -Record $_ -Period $period -WindowKey $window.key })
        Get-AggregateRows -SelectedRecords $selected -CommonFields ([ordered]@{
            window = $window.key
            windowLabel = $window.label
            dateRule = $window.rule
            period = $period.key
            periodLabel = $period.label
        })
    }
}

$baselineRows = @($periodRows | Where-Object window -eq 'full_period')
$leaveOneYearOutRows = @(
    foreach ($omittedYear in 2018..2026) {
        $omittedPeriod = $periods | Where-Object { $omittedYear -ge $_.startYear -and $omittedYear -le $_.endYear }
        $alternativeRows = @(
            foreach ($period in $periods) {
                $selected = @($analysisRecords | Where-Object {
                    $_.year -ge $period.startYear -and $_.year -le $period.endYear -and $_.year -ne $omittedYear
                })
                Get-AggregateRows -SelectedRecords $selected -CommonFields ([ordered]@{
                    period = $period.key
                    periodLabel = $period.label
                })
            }
        )
        foreach ($term in $terms) {
            $early = $alternativeRows | Where-Object { $_.period -eq 'early' -and $_.term -eq $term.key }
            $middle = $alternativeRows | Where-Object { $_.period -eq 'middle' -and $_.term -eq $term.key }
            $late = $alternativeRows | Where-Object { $_.period -eq 'late' -and $_.term -eq $term.key }
            $baselineTermRows = @($baselineRows | Where-Object term -eq $term.key)
            $baselineEarly = $baselineTermRows | Where-Object period -eq 'early'
            $baselineMiddle = $baselineTermRows | Where-Object period -eq 'middle'
            $baselineLate = $baselineTermRows | Where-Object period -eq 'late'
            $baselineDirection = Get-Direction -First $baselineEarly.authorArticleCoverageUnrounded -Second $baselineLate.authorArticleCoverageUnrounded
            $alternativeDirection = Get-Direction -First $early.authorArticleCoverageUnrounded -Second $late.authorArticleCoverageUnrounded
            $baselineTrajectory = Get-Trajectory -Early $baselineEarly.authorArticleCoverageUnrounded -Middle $baselineMiddle.authorArticleCoverageUnrounded -Late $baselineLate.authorArticleCoverageUnrounded
            $alternativeTrajectory = Get-Trajectory -Early $early.authorArticleCoverageUnrounded -Middle $middle.authorArticleCoverageUnrounded -Late $late.authorArticleCoverageUnrounded
            [pscustomobject][ordered]@{
                omittedYear = $omittedYear
                omittedPeriod = $omittedPeriod.key
                term = $term.key
                literal = $term.literal
                earlyArticleCount = $early.articleCount
                earlyHitArticleCount = $early.authorHitArticleCount
                earlyArticleCoverage = $early.authorArticleCoverage
                middleArticleCount = $middle.articleCount
                middleHitArticleCount = $middle.authorHitArticleCount
                middleArticleCoverage = $middle.authorArticleCoverage
                lateArticleCount = $late.articleCount
                lateHitArticleCount = $late.authorHitArticleCount
                lateArticleCoverage = $late.authorArticleCoverage
                baselineTrajectory = $baselineTrajectory
                alternativeTrajectory = $alternativeTrajectory
                trajectoryChanged = ($baselineTrajectory -ne $alternativeTrajectory)
                baselineEarlyLateDirection = $baselineDirection
                alternativeEarlyLateDirection = $alternativeDirection
                earlyLateDirectionFlip = Test-OppositeDirection -First $baselineDirection -Second $alternativeDirection
            }
        }
    }
)

$equalYearWeightRows = @(
    foreach ($term in $terms) {
        $baselineTermRows = @($baselineRows | Where-Object term -eq $term.key)
        $equalRates = [ordered]@{}
        $annualRateText = [ordered]@{}
        foreach ($period in $periods) {
            $annualRates = @(
                foreach ($year in $period.startYear..$period.endYear) {
                    $selected = @($analysisRecords | Where-Object year -eq $year)
                    $hitCount = @($selected | Where-Object { $_.authorHits[$term.key] }).Count
                    [pscustomobject]@{
                        year = $year
                        articleCount = $selected.Count
                        hitArticleCount = $hitCount
                        rate = if ($selected.Count -gt 0) { $hitCount / $selected.Count } else { 0.0 }
                    }
                }
            )
            $equalRates[$period.key] = [double](($annualRates.rate | Measure-Object -Average).Average)
            $annualRateText[$period.key] = ($annualRates | ForEach-Object { '{0}:{1}/{2}={3:F8}' -f $_.year, $_.hitArticleCount, $_.articleCount, $_.rate }) -join ';'
        }
        $baselineEarly = $baselineTermRows | Where-Object period -eq 'early'
        $baselineMiddle = $baselineTermRows | Where-Object period -eq 'middle'
        $baselineLate = $baselineTermRows | Where-Object period -eq 'late'
        $baselineTrajectory = Get-Trajectory -Early $baselineEarly.authorArticleCoverageUnrounded -Middle $baselineMiddle.authorArticleCoverageUnrounded -Late $baselineLate.authorArticleCoverageUnrounded
        $equalTrajectory = Get-Trajectory -Early $equalRates.early -Middle $equalRates.middle -Late $equalRates.late
        $baselineDirection = Get-Direction -First $baselineEarly.authorArticleCoverageUnrounded -Second $baselineLate.authorArticleCoverageUnrounded
        $equalDirection = Get-Direction -First $equalRates.early -Second $equalRates.late
        [pscustomobject][ordered]@{
            term = $term.key
            literal = $term.literal
            earlyArticleWeightedCoverage = $baselineEarly.authorArticleCoverage
            middleArticleWeightedCoverage = $baselineMiddle.authorArticleCoverage
            lateArticleWeightedCoverage = $baselineLate.authorArticleCoverage
            earlyEqualYearCoverage = [math]::Round($equalRates.early, 8)
            middleEqualYearCoverage = [math]::Round($equalRates.middle, 8)
            lateEqualYearCoverage = [math]::Round($equalRates.late, 8)
            earlyAnnualRates = $annualRateText.early
            middleAnnualRates = $annualRateText.middle
            lateAnnualRates = $annualRateText.late
            baselineTrajectory = $baselineTrajectory
            equalYearTrajectory = $equalTrajectory
            trajectoryChanged = ($baselineTrajectory -ne $equalTrajectory)
            baselineEarlyLateDirection = $baselineDirection
            equalYearEarlyLateDirection = $equalDirection
            earlyLateDirectionFlip = Test-OppositeDirection -First $baselineDirection -Second $equalDirection
        }
    }
)

function Get-LengthStratum {
    param([int64]$Length, [int64]$Q1, [int64]$Q2, [int64]$Q3)
    if ($Length -le $Q1) { return 'Q1_shortest' }
    if ($Length -le $Q2) { return 'Q2' }
    if ($Length -le $Q3) { return 'Q3' }
    return 'Q4_longest'
}

$zeroLengthRecords = @($analysisRecords | Where-Object authorTextCharCount -eq 0)
$lengthEligibleRecords = @($analysisRecords | Where-Object authorTextCharCount -gt 0)
$sortedLengths = @($lengthEligibleRecords.authorTextCharCount | Sort-Object)
$q1 = [int64]$sortedLengths[[math]::Ceiling($sortedLengths.Count * 0.25) - 1]
$q2 = [int64]$sortedLengths[[math]::Ceiling($sortedLengths.Count * 0.50) - 1]
$q3 = [int64]$sortedLengths[[math]::Ceiling($sortedLengths.Count * 0.75) - 1]
$strata = @('Q1_shortest', 'Q2', 'Q3', 'Q4_longest')
$stratumCounts = [ordered]@{}
$stratumWeights = [ordered]@{}
foreach ($stratum in $strata) {
    $count = @($lengthEligibleRecords | Where-Object { (Get-LengthStratum -Length $_.authorTextCharCount -Q1 $q1 -Q2 $q2 -Q3 $q3) -eq $stratum }).Count
    $stratumCounts[$stratum] = $count
    $stratumWeights[$stratum] = $count / $lengthEligibleRecords.Count
}

$lengthStandardizedRows = @(
    foreach ($term in $terms) {
        $rawRates = [ordered]@{}
        $standardizedRates = [ordered]@{}
        $periodCounts = [ordered]@{}
        foreach ($period in $periods) {
            $selected = @($lengthEligibleRecords | Where-Object { $_.year -ge $period.startYear -and $_.year -le $period.endYear })
            $periodCounts[$period.key] = $selected.Count
            $rawRates[$period.key] = @($selected | Where-Object { $_.authorHits[$term.key] }).Count / $selected.Count
            $standardizedRate = 0.0
            foreach ($stratum in $strata) {
                $layer = @($selected | Where-Object { (Get-LengthStratum -Length $_.authorTextCharCount -Q1 $q1 -Q2 $q2 -Q3 $q3) -eq $stratum })
                if ($layer.Count -eq 0) { throw "Length stratum $stratum is empty in period $($period.key)." }
                $layerRate = @($layer | Where-Object { $_.authorHits[$term.key] }).Count / $layer.Count
                $standardizedRate += $stratumWeights[$stratum] * $layerRate
            }
            $standardizedRates[$period.key] = $standardizedRate
        }
        $rawTrajectory = Get-Trajectory -Early $rawRates.early -Middle $rawRates.middle -Late $rawRates.late
        $standardizedTrajectory = Get-Trajectory -Early $standardizedRates.early -Middle $standardizedRates.middle -Late $standardizedRates.late
        $rawDirection = Get-Direction -First $rawRates.early -Second $rawRates.late
        $standardizedDirection = Get-Direction -First $standardizedRates.early -Second $standardizedRates.late
        [pscustomobject][ordered]@{
            term = $term.key
            literal = $term.literal
            excludedZeroLengthArticleCount = $zeroLengthRecords.Count
            earlyEligibleArticleCount = $periodCounts.early
            middleEligibleArticleCount = $periodCounts.middle
            lateEligibleArticleCount = $periodCounts.late
            earlyRawCoverage = [math]::Round($rawRates.early, 8)
            middleRawCoverage = [math]::Round($rawRates.middle, 8)
            lateRawCoverage = [math]::Round($rawRates.late, 8)
            earlyLengthStandardizedCoverage = [math]::Round($standardizedRates.early, 8)
            middleLengthStandardizedCoverage = [math]::Round($standardizedRates.middle, 8)
            lateLengthStandardizedCoverage = [math]::Round($standardizedRates.late, 8)
            rawTrajectory = $rawTrajectory
            lengthStandardizedTrajectory = $standardizedTrajectory
            trajectoryChanged = ($rawTrajectory -ne $standardizedTrajectory)
            rawEarlyLateDirection = $rawDirection
            lengthStandardizedEarlyLateDirection = $standardizedDirection
            earlyLateDirectionFlip = Test-OppositeDirection -First $rawDirection -Second $standardizedDirection
        }
    }
)

$outputDirectory = Split-Path -Parent ([IO.Path]::GetFullPath($StatsPath))
New-Item -ItemType Directory -Force -Path $outputDirectory | Out-Null
$yearRows | Export-Csv -LiteralPath $YearOutputPath -NoTypeInformation -Encoding utf8BOM
$periodRows | Export-Csv -LiteralPath $PeriodOutputPath -NoTypeInformation -Encoding utf8BOM
$leaveOneYearOutRows | Export-Csv -LiteralPath $LeaveOneYearOutPath -NoTypeInformation -Encoding utf8BOM
$equalYearWeightRows | Export-Csv -LiteralPath $EqualYearWeightPath -NoTypeInformation -Encoding utf8BOM
$lengthStandardizedRows | Export-Csv -LiteralPath $LengthStandardizedPath -NoTypeInformation -Encoding utf8BOM

# Re-import generated CSVs so integrity checks cover serialized artifacts.
$savedYearRows = @(Import-Csv -LiteralPath $YearOutputPath)
$savedPeriodRows = @(Import-Csv -LiteralPath $PeriodOutputPath)
$savedLeaveOneYearOutRows = @(Import-Csv -LiteralPath $LeaveOneYearOutPath)
$savedEqualYearWeightRows = @(Import-Csv -LiteralPath $EqualYearWeightPath)
$savedLengthStandardizedRows = @(Import-Csv -LiteralPath $LengthStandardizedPath)
$denominatorErrors = [Collections.Generic.List[string]]::new()
foreach ($group in @($savedYearRows | Group-Object year)) {
    if ($group.Count -ne $terms.Count -or @($group.Group.articleCount | Sort-Object -Unique).Count -ne 1) {
        [void]$denominatorErrors.Add("year:$($group.Name)")
    }
}
foreach ($group in @($savedPeriodRows | Group-Object window,period)) {
    $articleDenominators = @($group.Group.articleCount | Sort-Object -Unique)
    $characterDenominators = @($group.Group.authorNonWhitespaceCharCount | Sort-Object -Unique)
    if ($group.Count -ne $terms.Count -or $articleDenominators.Count -ne 1 -or $characterDenominators.Count -ne 1) {
        [void]$denominatorErrors.Add("period:$($group.Name)")
    }
}
foreach ($group in @($savedLeaveOneYearOutRows | Group-Object omittedYear)) {
    if ($group.Count -ne $terms.Count) { [void]$denominatorErrors.Add("leaveOneYearOut:$($group.Name)") }
}

$expectedWindowCounts = [ordered]@{}
foreach ($window in $windows) {
    foreach ($period in $periods) {
        $key = "$($window.key)|$($period.key)"
        $expectedWindowCounts[$key] = @($analysisRecords | Where-Object { Test-InWindow -Record $_ -Period $period -WindowKey $window.key }).Count
        $savedCount = @($savedPeriodRows | Where-Object { $_.window -eq $window.key -and $_.period -eq $period.key } | Select-Object -ExpandProperty articleCount -Unique)
        if ($savedCount.Count -ne 1 -or [int]$savedCount[0] -ne $expectedWindowCounts[$key]) {
            [void]$denominatorErrors.Add("serialized:$key")
        }
    }
}

$serializedNegativeArticleDeltas = @($savedYearRows + $savedPeriodRows | Where-Object { [int]$_.excludedQuoteOnlyHitArticleCount -lt 0 }).Count
$serializedNegativeOccurrenceDeltas = @($savedYearRows + $savedPeriodRows | Where-Object { [int64]$_.excludedQuoteOccurrenceCount -lt 0 }).Count
$serializedNegativeCharacterDeltas = @($savedYearRows + $savedPeriodRows | Where-Object { [int64]$_.excludedTopLevelQuoteCharCount -lt 0 }).Count

$directionSummary = @(
    foreach ($window in $windows) {
        foreach ($term in $terms) {
            $termRows = @($periodRows | Where-Object { $_.window -eq $window.key -and $_.term -eq $term.key })
            $early = $termRows | Where-Object period -eq 'early'
            $middle = $termRows | Where-Object period -eq 'middle'
            $late = $termRows | Where-Object period -eq 'late'
            $coverageTrajectory = Get-Trajectory -Early $early.authorArticleCoverageUnrounded -Middle $middle.authorArticleCoverageUnrounded -Late $late.authorArticleCoverageUnrounded
            $occurrenceTrajectory = Get-Trajectory -Early $early.occurrencesPer100kAuthorNonWhitespaceCharsUnrounded -Middle $middle.occurrencesPer100kAuthorNonWhitespaceCharsUnrounded -Late $late.occurrencesPer100kAuthorNonWhitespaceCharsUnrounded
            $coverageEarlyLate = Get-Direction -First $early.authorArticleCoverageUnrounded -Second $late.authorArticleCoverageUnrounded
            $occurrenceEarlyLate = Get-Direction -First $early.occurrencesPer100kAuthorNonWhitespaceCharsUnrounded -Second $late.occurrencesPer100kAuthorNonWhitespaceCharsUnrounded
            [pscustomobject][ordered]@{
                term = $term.key
                literal = $term.literal
                window = $window.key
                earlyArticleCoverage = $early.authorArticleCoverage
                middleArticleCoverage = $middle.authorArticleCoverage
                lateArticleCoverage = $late.authorArticleCoverage
                articleCoverageEarlyLateDifference = [math]::Round($late.authorArticleCoverage - $early.authorArticleCoverage, 8)
                articleCoverageTrajectory = $coverageTrajectory
                articleCoverageEarlyLateDirection = $coverageEarlyLate
                earlyOccurrencesPer100kChars = $early.occurrencesPer100kAuthorNonWhitespaceChars
                middleOccurrencesPer100kChars = $middle.occurrencesPer100kAuthorNonWhitespaceChars
                lateOccurrencesPer100kChars = $late.occurrencesPer100kAuthorNonWhitespaceChars
                occurrenceRateEarlyLateDifference = [math]::Round($late.occurrencesPer100kAuthorNonWhitespaceChars - $early.occurrencesPer100kAuthorNonWhitespaceChars, 6)
                occurrenceRateTrajectory = $occurrenceTrajectory
                occurrenceRateEarlyLateDirection = $occurrenceEarlyLate
                coverageOccurrenceTrajectoryChanged = ($coverageTrajectory -ne $occurrenceTrajectory)
                coverageVsOccurrenceEarlyLateDirectionFlip = Test-OppositeDirection -First $coverageEarlyLate -Second $occurrenceEarlyLate
            }
        }
    }
)

$windowSensitivity = @(
    foreach ($term in $terms) {
        $baseline = $directionSummary | Where-Object { $_.term -eq $term.key -and $_.window -eq 'full_period' }
        foreach ($alternativeWindow in @('exclude_2026', 'matched_jan01_jun30', 'matched_jan01_jun30_exclude_2018')) {
            $alternative = $directionSummary | Where-Object { $_.term -eq $term.key -and $_.window -eq $alternativeWindow }
            [pscustomobject][ordered]@{
                term = $term.key
                literal = $term.literal
                alternativeWindow = $alternativeWindow
                baselineArticleCoverageTrajectory = $baseline.articleCoverageTrajectory
                alternativeArticleCoverageTrajectory = $alternative.articleCoverageTrajectory
                trajectoryChanged = ($baseline.articleCoverageTrajectory -ne $alternative.articleCoverageTrajectory)
                baselineEarlyLateDirection = $baseline.articleCoverageEarlyLateDirection
                alternativeEarlyLateDirection = $alternative.articleCoverageEarlyLateDirection
                earlyLateDirectionFlip = Test-OppositeDirection -First $baseline.articleCoverageEarlyLateDirection -Second $alternative.articleCoverageEarlyLateDirection
            }
        }
    }
)

$yearCount = @($zhihuRecords.year | Sort-Object -Unique).Count
$yearArticleDenominators = [ordered]@{}
foreach ($year in ($zhihuRecords.year | Sort-Object -Unique)) {
    $yearArticleDenominators[[string]$year] = @($zhihuRecords | Where-Object year -eq $year).Count
}
$stageEligibleCount = @($records | Where-Object { $_.year -ge 2018 -and $_.year -le 2026 }).Count
$fullWindowZhihuCount = $expectedWindowCounts['full_period|early'] + $expectedWindowCounts['full_period|middle'] + $expectedWindowCounts['full_period|late']
$corpusFullPath = [IO.Path]::GetFullPath($CorpusPath)
$corpusSha256 = (Get-FileHash -LiteralPath $corpusFullPath -Algorithm SHA256).Hash
$expectedCorpusSha256 = '5C609F734DBD7AE27C96467C9D2AAFF17C12EF2EEA500B222A7314779ED9B06E'
$firstZhihu2018 = $analysisRecords | Where-Object year -eq 2018 | Sort-Object date | Select-Object -First 1
$lastZhihu2026 = $analysisRecords | Where-Object year -eq 2026 | Sort-Object date -Descending | Select-Object -First 1

$integrityChecks = [ordered]@{
    corpusArticleCountIs4050 = ($records.Count -eq 4050)
    uniqueIdCountIs4050 = ($seenIds.Count -eq 4050)
    corpusSha256MatchesExpected = ($corpusSha256 -eq $expectedCorpusSha256)
    noInvalidOrDuplicateIds = ($invalidIdCount -eq 0 -and $duplicateIdCount -eq 0)
    allLexicalParsed = ($lexicalMissingCount -eq 0 -and $lexicalParseFailureCount -eq 0)
    observedYearsAre2017Through2026 = ($yearCount -eq 10 -and ($zhihuRecords.year | Measure-Object -Minimum).Minimum -eq 2017 -and ($zhihuRecords.year | Measure-Object -Maximum).Maximum -eq 2026)
    stageEligibleCorpusDenominatorIs4049 = ($stageEligibleCount -eq 4049)
    fullWindowZhihuDenominatorMatches = ($fullWindowZhihuCount -eq $analysisRecords.Count)
    zeroLengthZhihuAuthorTextCountIs2 = ($zeroLengthRecords.Count -eq 2)
    lengthStrataCoverEligibleRecords = ((($stratumCounts.Values | Measure-Object -Sum).Sum) -eq $lengthEligibleRecords.Count)
    yearOutputShapeMatches = ($savedYearRows.Count -eq ($yearCount * $terms.Count))
    periodOutputShapeMatches = ($savedPeriodRows.Count -eq ($windows.Count * $periods.Count * $terms.Count))
    leaveOneYearOutShapeMatches = ($savedLeaveOneYearOutRows.Count -eq (9 * $terms.Count))
    equalYearWeightShapeMatches = ($savedEqualYearWeightRows.Count -eq $terms.Count)
    lengthStandardizedShapeMatches = ($savedLengthStandardizedRows.Count -eq $terms.Count)
    serializedDenominatorsMatch = ($denominatorErrors.Count -eq 0)
    noNegativeArticleDeltas = ($negativeArticleTermDeltaCount -eq 0 -and $serializedNegativeArticleDeltas -eq 0)
    noNegativeOccurrenceDeltas = ($negativeOccurrenceDeltaCount -eq 0 -and $serializedNegativeOccurrenceDeltas -eq 0)
    noNegativeCharacterDeltas = ($negativeCharacterDeltaCount -eq 0 -and $serializedNegativeCharacterDeltas -eq 0)
}
$failedIntegrityChecks = @($integrityChecks.GetEnumerator() | Where-Object { -not $_.Value } | ForEach-Object Key)
$windowTrajectoryChangedCount = @($windowSensitivity | Where-Object trajectoryChanged).Count
$windowEarlyLateDirectionFlipCount = @($windowSensitivity | Where-Object earlyLateDirectionFlip).Count
$coverageOccurrenceTrajectoryChangedCount = @($directionSummary | Where-Object coverageOccurrenceTrajectoryChanged).Count
$coverageOccurrenceDirectionFlipCount = @($directionSummary | Where-Object coverageVsOccurrenceEarlyLateDirectionFlip).Count
$leaveOneYearOutTrajectoryChangedCount = @($leaveOneYearOutRows | Where-Object trajectoryChanged).Count
$leaveOneYearOutEarlyLateDirectionFlipCount = @($leaveOneYearOutRows | Where-Object earlyLateDirectionFlip).Count
$equalYearWeightTrajectoryChangedCount = @($equalYearWeightRows | Where-Object trajectoryChanged).Count
$equalYearWeightEarlyLateDirectionFlipCount = @($equalYearWeightRows | Where-Object earlyLateDirectionFlip).Count
$lengthStandardizedTrajectoryChangedCount = @($lengthStandardizedRows | Where-Object trajectoryChanged).Count
$lengthStandardizedEarlyLateDirectionFlipCount = @($lengthStandardizedRows | Where-Object earlyLateDirectionFlip).Count
$hasInterpretiveSensitivity = (
    $windowTrajectoryChangedCount -gt 0 -or
    $windowEarlyLateDirectionFlipCount -gt 0 -or
    $coverageOccurrenceTrajectoryChangedCount -gt 0 -or
    $coverageOccurrenceDirectionFlipCount -gt 0 -or
    $leaveOneYearOutTrajectoryChangedCount -gt 0 -or
    $leaveOneYearOutEarlyLateDirectionFlipCount -gt 0 -or
    $equalYearWeightTrajectoryChangedCount -gt 0 -or
    $equalYearWeightEarlyLateDirectionFlipCount -gt 0 -or
    $lengthStandardizedTrajectoryChangedCount -gt 0 -or
    $lengthStandardizedEarlyLateDirectionFlipCount -gt 0
)

$zeroLengthMetadata = @($zeroLengthRecords | Sort-Object date | ForEach-Object {
    [pscustomobject][ordered]@{
        id = $_.id
        title = $_.title
        url = $_.url
        publishedDate = $_.date.ToString('yyyy-MM-dd')
    }
})
$windowRules = [ordered]@{}
foreach ($window in $windows) { $windowRules[$window.key] = $window.rule }
$stats = [ordered]@{
    generatedAt = [DateTimeOffset]::UtcNow.ToString('o')
    scriptVersion = '2.0.0'
    inputCorpusFile = 'sooon-q9adg-articles.jsonl'
    inputCorpusSha256 = $corpusSha256
    expectedCorpusSha256 = $expectedCorpusSha256
    methodology = [ordered]@{
        platform = 'Zhihu URL only'
        timezone = 'Asia/Shanghai (UTC+08:00)'
        sourceVersion = 'text/lexical is the version visible at collection time, not a historical snapshot at publication time; updatedAt semantics were not independently verified'
        field = 'Lexical root children excluding top-level type=quote nodes'
        termMatching = 'case-sensitive literal substring counts; compounds are included (for example, 爱 also matches 爱情)'
        characterDenominator = 'UTF-16 code-unit count after removing all whitespace from author text'
        equalYearWeighting = 'Arithmetic mean of the three constituent annual article-coverage rates in each period; no p-values are used because the observed corpus is not treated as a random sample'
        lengthStandardization = 'Exclude zero-length author texts; define fixed nearest-rank quartile cutpoints on author-text UTF-16 character counts for all 2018-2026 eligible Zhihu texts; directly standardize each period to the full-period stratum weights'
        windowRules = $windowRules
        periods = @($periods)
    }
    corpusArticleCount = $records.Count
    uniqueIdCount = $seenIds.Count
    zhihuArticleCount = $zhihuRecords.Count
    stageEligibleCorpusArticleCount = $stageEligibleCount
    stageEligibleZhihuArticleCount = $fullWindowZhihuCount
    minimumPublishedDate = $minDate.ToString('yyyy-MM-dd')
    maximumPublishedDate = $maxDate.ToString('yyyy-MM-dd')
    firstZhihu2018Article = [ordered]@{ id = $firstZhihu2018.id; title = $firstZhihu2018.title; publishedDate = $firstZhihu2018.date.ToString('yyyy-MM-dd') }
    lastZhihu2026Article = [ordered]@{ id = $lastZhihu2026.id; title = $lastZhihu2026.title; publishedDate = $lastZhihu2026.date.ToString('yyyy-MM-dd') }
    zeroLengthZhihuAuthorTextArticles = $zeroLengthMetadata
    lengthStandardization = [ordered]@{
        eligibleArticleCount = $lengthEligibleRecords.Count
        excludedZeroLengthArticleCount = $zeroLengthRecords.Count
        quartileCutPointsAuthorTextUtf16Chars = [ordered]@{ q1 = $q1; q2 = $q2; q3 = $q3 }
        fullPeriodStratumCounts = $stratumCounts
        fullPeriodStratumWeights = $stratumWeights
    }
    termCount = $terms.Count
    yearCount = $yearCount
    yearOutputRowCount = $savedYearRows.Count
    periodOutputRowCount = $savedPeriodRows.Count
    leaveOneYearOutRowCount = $savedLeaveOneYearOutRows.Count
    equalYearWeightRowCount = $savedEqualYearWeightRows.Count
    lengthStandardizedRowCount = $savedLengthStandardizedRows.Count
    yearArticleDenominators = $yearArticleDenominators
    windowArticleDenominators = $expectedWindowCounts
    lexicalMissingCount = $lexicalMissingCount
    lexicalParseFailureCount = $lexicalParseFailureCount
    denominatorErrors = @($denominatorErrors)
    negativeDeltaCounts = [ordered]@{
        inMemoryArticleTerm = $negativeArticleTermDeltaCount
        inMemoryOccurrence = $negativeOccurrenceDeltaCount
        inMemoryCharacter = $negativeCharacterDeltaCount
        serializedArticleTerm = $serializedNegativeArticleDeltas
        serializedOccurrence = $serializedNegativeOccurrenceDeltas
        serializedCharacter = $serializedNegativeCharacterDeltas
    }
    integrityChecks = $integrityChecks
    failedIntegrityChecks = $failedIntegrityChecks
    directionSummary = $directionSummary
    windowSensitivity = $windowSensitivity
    windowTrajectoryChangedCount = $windowTrajectoryChangedCount
    windowEarlyLateDirectionFlipCount = $windowEarlyLateDirectionFlipCount
    coverageOccurrenceTrajectoryChangedCount = $coverageOccurrenceTrajectoryChangedCount
    coverageOccurrenceDirectionFlipCount = $coverageOccurrenceDirectionFlipCount
    leaveOneYearOutTrajectoryChangedCount = $leaveOneYearOutTrajectoryChangedCount
    leaveOneYearOutEarlyLateDirectionFlipCount = $leaveOneYearOutEarlyLateDirectionFlipCount
    leaveOneYearOutChanges = @($leaveOneYearOutRows | Where-Object { $_.trajectoryChanged -or $_.earlyLateDirectionFlip })
    equalYearWeightTrajectoryChangedCount = $equalYearWeightTrajectoryChangedCount
    equalYearWeightEarlyLateDirectionFlipCount = $equalYearWeightEarlyLateDirectionFlipCount
    equalYearWeightChanges = @($equalYearWeightRows | Where-Object { $_.trajectoryChanged -or $_.earlyLateDirectionFlip })
    lengthStandardizedTrajectoryChangedCount = $lengthStandardizedTrajectoryChangedCount
    lengthStandardizedEarlyLateDirectionFlipCount = $lengthStandardizedEarlyLateDirectionFlipCount
    lengthStandardizedChanges = @($lengthStandardizedRows | Where-Object { $_.trajectoryChanged -or $_.earlyLateDirectionFlip })
    interpretiveStatus = if ($hasInterpretiveSensitivity) { 'REVIEW' } else { 'PASS' }
    status = if ($failedIntegrityChecks.Count -eq 0) { 'PASS' } else { 'REVIEW' }
}
$stats | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $StatsPath -Encoding utf8
[pscustomobject][ordered]@{
    status = $stats.status
    interpretiveStatus = $stats.interpretiveStatus
    corpusArticleCount = $records.Count
    stageEligibleZhihuArticleCount = $fullWindowZhihuCount
    generatedCsvCount = 5
    failedIntegrityChecks = $failedIntegrityChecks
}
