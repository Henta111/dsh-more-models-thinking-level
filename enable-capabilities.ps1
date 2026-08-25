$ErrorActionPreference = 'Stop'
$settings = Join-Path $env:USERPROFILE '.dsh\settings.yaml'
if (-not (Test-Path -LiteralPath $settings)) { throw "DSH settings not found: $settings" }
$backupDir = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) 'backup'
New-Item -ItemType Directory -Force -Path $backupDir | Out-Null
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
Copy-Item -LiteralPath $settings -Destination (Join-Path $backupDir "settings-$stamp.yaml") -Force
$text = Get-Content -Raw -LiteralPath $settings
$gpt = '{ off: null, minimal: minimal, low: low, medium: medium, high: high, xhigh: xhigh }'
$gemini = '{ off: null, minimal: minimal, low: low, medium: medium, high: high }'
$text = [regex]::Replace($text, '(?m)(\{ id: gpt-image-[^,}]+(?:, name: [^,}]+)?)( \})', ('$1, reasoningEfforts: false$2'))
$text = [regex]::Replace($text, '(?m)(\{ id: gemini-[^,}]+(?:, name: [^,}]+)?)( \})(?!.*reasoningEfforts)', ('$1, reasoningEfforts: ' + $gemini + '$2'))
# Apply the full reasoning map to every non-image model, including custom
# gateway IDs (for example: claude-*, qwen-*, deepseek-*, moonshot-*, or vendor-specific IDs).
$text = [regex]::Replace($text, '(?m)(\{ id: (?!gpt-image-)(?!gemini-)[^,}]+(?:, name: [^,}]+)?)( \})(?!.*reasoningEfforts)', ('$1, reasoningEfforts: ' + $gpt + '$2'))
Set-Content -LiteralPath $settings -Value $text -Encoding UTF8 -NoNewline
Write-Host 'Reasoning capabilities enabled for matching non-image models.'
