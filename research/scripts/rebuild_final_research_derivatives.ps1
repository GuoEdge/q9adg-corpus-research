[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$cleanEvidence = Join-Path $root 'research\data\author_view_evidence_clean.jsonl'
$cleanClaims = Join-Path $root 'research\data\author_claims_clean.jsonl'
$reportPath = Join-Path $root 'research\data\final_derivative_rebuild.stats.json'
$results = [Collections.Generic.List[object]]::new()

function Invoke-ResearchScript {
    param(
        [Parameter(Mandatory)][string]$Name,
        [string[]]$Arguments = @()
    )
    $path = Join-Path $PSScriptRoot $Name
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Missing rebuild script: $path" }
    $started = [DateTimeOffset]::Now
    & pwsh -NoLogo -NoProfile -File $path @Arguments
    $code = $LASTEXITCODE
    $ended = [DateTimeOffset]::Now
    [void]$results.Add([pscustomobject][ordered]@{
        script = $Name
        exitCode = $code
        elapsedSeconds = [math]::Round(($ended - $started).TotalSeconds,3)
    })
    if ($code -ne 0) { throw "Rebuild step failed ($code): $Name" }
}

Invoke-ResearchScript 'build_clean_author_view_evidence.ps1'
Invoke-ResearchScript 'validate_source_quotes.ps1'
Invoke-ResearchScript 'build_author_claims.ps1' @('-EvidencePath',$cleanEvidence,'-OutputPath',$cleanClaims)
Invoke-ResearchScript 'build_claim_support_audit.ps1'
Invoke-ResearchScript 'build_system_concept_network.ps1'

$candidateScripts = @(
    'build_ai_machine_candidates.ps1',
    'build_art_culture_candidates.ps1',
    'build_crime_justice_candidates.ps1',
    'build_death_memorial_candidates.ps1',
    'build_ecology_nature_candidates.ps1',
    'build_education_knowledge_candidates.ps1',
    'build_ethnicity_identity_candidates.ps1',
    'build_family_kinship_candidates.ps1',
    'build_gender_body_consent_candidates.ps1',
    'build_intimacy_relationship_candidates.ps1',
    'build_media_public_opinion_candidates.ps1',
    'build_medical_care_candidates.ps1',
    'build_psychology_subject_candidates.ps1',
    'build_religion_natural_law_candidates.ps1',
    'build_technology_civilization_candidates.ps1',
    'build_war_diplomacy_candidates.ps1',
    'build_wealth_economy_candidates.ps1',
    'build_workplace_organization_candidates.ps1'
)
foreach ($script in $candidateScripts) { Invoke-ResearchScript $script }

$coreEvidenceScripts = @(
    'build_ai_machine_core_evidence.ps1',
    'build_art_culture_core_evidence.ps1',
    'build_crime_justice_core_evidence.ps1',
    'build_death_memorial_core_evidence.ps1',
    'build_diachronic_core_evidence.ps1',
    'build_ecology_nature_core_evidence.ps1',
    'build_education_learning_core_evidence.ps1',
    'build_epistemology_argument_core_evidence.ps1',
    'build_ethnicity_identity_core_evidence.ps1',
    'build_family_kinship_core_evidence.ps1',
    'build_gender_body_consent_core_evidence.ps1',
    'build_intimacy_relationship_core_evidence.ps1',
    'build_media_public_opinion_core_evidence.ps1',
    'build_medical_care_core_evidence.ps1',
    'build_psychology_subject_core_evidence.ps1',
    'build_religion_natural_law_core_evidence.ps1',
    'build_technology_civilization_core_evidence.ps1',
    'build_war_diplomacy_core_evidence.ps1',
    'build_wealth_economy_core_evidence.ps1',
    'build_workplace_organization_core_evidence.ps1'
)
foreach ($script in $coreEvidenceScripts) { Invoke-ResearchScript $script }

Invoke-ResearchScript 'build_core_evidence_registry.ps1'
Invoke-ResearchScript 'build_core_proposition_genealogy.ps1'
Invoke-ResearchScript 'build_core_term_concordance.ps1'

$failed = @($results | Where-Object exitCode -ne 0).Count
$gateFiles = @(
    'author_view_evidence_clean.stats.json',
    'source_quote_validation.stats.json',
    'author_claims_clean.stats.json',
    'claim_support_audit_500.stats.json',
    'system_concept_network.stats.json',
    'core_evidence_registry.stats.json',
    'core_proposition_genealogy.stats.json',
    'core_term_concordance.stats.json'
)
$gateStats = [Collections.Generic.List[object]]::new()
foreach ($name in $gateFiles) {
    $path = Join-Path $root "research\data\$name"
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        [void]$gateStats.Add([pscustomobject]@{ file=$name; status='MISSING' })
        continue
    }
    $stats = Get-Content -Raw -LiteralPath $path | ConvertFrom-Json
    [void]$gateStats.Add([pscustomobject]@{ file=$name; status=[string]$stats.status })
}
$failedGateCount = @($gateStats | Where-Object status -ne 'PASS').Count
[ordered]@{
    generatedAt = [DateTimeOffset]::Now.ToString('o')
    stepCount = $results.Count
    failedStepCount = $failed
    failedGateCount = $failedGateCount
    gates = @($gateStats)
    results = @($results)
    status = if ($failed -eq 0 -and $failedGateCount -eq 0) { 'PASS' } else { 'REVIEW' }
} | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $reportPath -Encoding utf8

Get-Content -Raw -LiteralPath $reportPath
if ($failed -ne 0 -or $failedGateCount -ne 0) { exit 1 }
