# UserPromptSubmit hook: warn when the chat's context has grown large.
#
# Every new message re-sends the whole conversation, so a long chat drains the user's quota
# fast. Once the last request used $WarnTokens tokens, this hook tells Claude to open its reply
# with a warning, and asks Claude Code to show the user a warning line as well.
#
# The measure is absolute tokens, not a percentage of the model's window: quota cost follows
# tokens, and the hook input does not say how large the window is.
# Note: on a 200K-window model auto-compaction runs before 250K, so the warning never fires there.
# Windows PowerShell 5.1, no other dependencies.

$WarnTokens = 250000
$StrongTokens = 300000

$ErrorActionPreference = 'Stop'
try {
  [Console]::InputEncoding = New-Object System.Text.UTF8Encoding $false
  [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding $false
  $hookInput = [Console]::In.ReadToEnd().Trim([char]0xFEFF, ' ', "`r", "`n", "`t") | ConvertFrom-Json
  $path = $hookInput.transcript_path
  if (-not $path -or -not (Test-Path -LiteralPath $path)) { exit 0 }

  # Claude Code keeps the transcript open for writing, so open it with shared read/write.
  $stream = New-Object System.IO.FileStream($path, 'Open', 'Read', 'ReadWrite')
  $reader = New-Object System.IO.StreamReader($stream, [System.Text.Encoding]::UTF8)
  $lines = $reader.ReadToEnd() -split "`n"
  $reader.Close()

  # Context size of the last main-conversation request: input + cache creation + cache read.
  # A compaction after it means the old figure no longer applies.
  $tokens = 0
  for ($i = $lines.Length - 1; $i -ge 0; $i--) {
    $line = $lines[$i]
    if ($line.Contains('"subtype":"compact_boundary"')) { break }
    if (-not $line.Contains('"usage":{') -or $line.Contains('"isSidechain":true')) { continue }
    try { $u = ($line | ConvertFrom-Json).message.usage } catch { continue }
    if (-not $u) { continue }
    $t = [int64]$u.input_tokens + [int64]$u.cache_creation_input_tokens + [int64]$u.cache_read_input_tokens
    if ($t -gt 0) { $tokens = $t; break }
  }

  if ($tokens -lt $WarnTokens) { exit 0 }
  $k = [int][math]::Floor($tokens / 1000)

  if ($tokens -ge $StrongTokens) {
    $shown = "⛔ This chat is ~${k}K tokens. Every message re-sends all of it, so each one now costs a lot of quota. Finish this ticket and start a new chat (/clear)."
    $line = "⛔ This chat is ~${k}K tokens. Every message re-sends all of it, so each question now costs a lot of quota. Finish this ticket and start a new chat (/clear). If you still need this conversation, run /compact first."
  } else {
    $shown = "⚠️ This chat is ~${k}K tokens. Every message re-sends all of it. If this is a new ticket or topic, start a new chat (/clear)."
    $line = "⚠️ This chat is ~${k}K tokens. Every message re-sends all of it, so each new question costs much more quota. If this is a new ticket or topic, start a new chat (/clear) and ask there."
  }
  $ctx = "Context check from this repo's context-guard hook (see CLAUDE.md, One ticket per chat): the conversation is about ${k}K tokens. Start your reply with this warning as its own first line, translated into the language the user is writing in: $line Then answer the question normally."

  @{
    systemMessage      = $shown
    hookSpecificOutput = @{ hookEventName = 'UserPromptSubmit'; additionalContext = $ctx }
  } | ConvertTo-Json -Compress -Depth 3
} catch {
  # Never block or disturb the user's prompt because the check failed.
  exit 0
}
