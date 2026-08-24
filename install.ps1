param(
  [string]$Profile = $env:DSH_PROFILE
)
if ([string]::IsNullOrWhiteSpace($Profile)) { $Profile = 'desktop' }
$ErrorActionPreference = 'Stop'
$plugin = Split-Path -Parent $MyInvocation.MyCommand.Path
& (Join-Path $plugin 'enable-capabilities.ps1')
dsh plugin --profile $Profile add $plugin
if ($LASTEXITCODE -ne 0) { throw "DSH plugin installation failed: $LASTEXITCODE" }
Write-Host "Installed to profile '$Profile'. Restart DeepSeek Harness."
