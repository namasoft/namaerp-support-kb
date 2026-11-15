# Status line: model and how full the chat's context is, red with a /clear hint from 50%.
# Windows PowerShell 5.1, no other dependencies.

try {
  [Console]::InputEncoding = New-Object System.Text.UTF8Encoding $false
  [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding $false
  $s = [Console]::In.ReadToEnd().Trim([char]0xFEFF, ' ', "`r", "`n", "`t") | ConvertFrom-Json
  $model = $s.model.display_name
  $p = $s.context_window.used_percentage
  if ($null -eq $p) { [Console]::Write($model); exit 0 }
  $pct = [int][math]::Floor([double]$p)
  $e = [char]27
  if ($pct -ge 75) {
    [Console]::Write("$model · $e[1;31m⛔ context $pct% — finish this ticket, then /clear$e[0m")
  } elseif ($pct -ge 50) {
    [Console]::Write("$model · $e[31m⚠ context $pct% — new topic? /clear$e[0m")
  } else {
    [Console]::Write("$model · context $pct%")
  }
} catch {
  exit 0
}
