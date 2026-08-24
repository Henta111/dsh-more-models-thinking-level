param(
  [string]$Profile = $env:DSH_PROFILE
)
if ([string]::IsNullOrWhiteSpace($Profile)) { $Profile = 'desktop' }
$ErrorActionPreference = 'Stop'
$plugin = Split-Path -Parent $MyInvocation.MyCommand.Path
& (Join-Path $plugin 'disable-capabilities.ps1')
dsh plugin --profile $Profile remove dsh-more-models-thinking-level
if ($LASTEXITCODE -ne 0) { throw "DSH plugin removal failed: $LASTEXITCODE" }
Write-Host "Removed from profile '$Profile'. Restart DeepSeek Harness."
