$ErrorActionPreference = 'Stop'
$settings = Join-Path $env:USERPROFILE '.dsh\settings.yaml'
if (-not (Test-Path -LiteralPath $settings)) { return }
$text = Get-Content -Raw -LiteralPath $settings
$text = [regex]::Replace($text, ', reasoningEfforts: \{ off: null, minimal: minimal, low: low, medium: medium, high: high, xhigh: xhigh \}', '')
$text = [regex]::Replace($text, ', reasoningEfforts: \{ off: null, minimal: minimal, low: low, medium: medium, high: high \}', '')
$text = $text.Replace(', reasoningEfforts: false', '')
$text = [regex]::Replace($text, '(?m)^          reasoning: medium,\r?\n', '')
Set-Content -LiteralPath $settings -Value $text -Encoding UTF8
Write-Host 'Reasoning capability declarations removed.'
