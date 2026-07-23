param(
    [string]$InputFile = (Join-Path $PSScriptRoot 'conversations.json'),
    [string]$OutputDirectory = (Join-Path $PSScriptRoot 'markdown')
)

$ErrorActionPreference = 'Stop'

function ConvertTo-SafeSlug {
    param([Parameter(Mandatory)][string]$Value)

    $slug = $Value.ToLowerInvariant()
    $slug = [regex]::Replace($slug, '[^a-z0-9]+', '-')
    $slug = $slug.Trim('-')

    if ([string]::IsNullOrWhiteSpace($slug)) {
        return 'conversation'
    }

    if ($slug.Length -gt 80) {
        $slug = $slug.Substring(0, 80).TrimEnd('-')
    }

    return $slug
}

function Format-Timestamp {
    param([string]$Value)

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return $null
    }

    try {
        return ([datetimeoffset]::Parse($Value)).ToString('yyyy-MM-dd HH:mm:ss UTC')
    }
    catch {
        return $Value
    }
}

function Get-AttachmentName {
    param($Attachment)

    foreach ($property in @('file_name', 'filename', 'name', 'title')) {
        if ($Attachment.PSObject.Properties.Name -contains $property) {
            $value = [string]$Attachment.$property
            if (-not [string]::IsNullOrWhiteSpace($value)) {
                return $value
            }
        }
    }

    return 'Unnamed attachment'
}

$json = [System.IO.File]::ReadAllText(
    (Resolve-Path -LiteralPath $InputFile),
    [System.Text.Encoding]::UTF8
)
$parsedJson = $json | ConvertFrom-Json
$conversations = [System.Collections.Generic.List[object]]::new()
foreach ($conversation in $parsedJson) {
    $conversations.Add($conversation)
}

[System.IO.Directory]::CreateDirectory($OutputDirectory) | Out-Null
$utf8 = [System.Text.UTF8Encoding]::new($false)
$writtenFiles = [System.Collections.Generic.List[string]]::new()

for ($index = 0; $index -lt $conversations.Count; $index++) {
    $conversation = $conversations[$index]
    $number = ($index + 1).ToString("D$($conversations.Count.ToString().Length)")
    $title = if ([string]::IsNullOrWhiteSpace([string]$conversation.name)) {
        "Conversation $number"
    } else {
        [string]$conversation.name
    }

    $slug = ConvertTo-SafeSlug -Value $title
    $fileName = "$number-$slug.md"
    $outputPath = Join-Path $OutputDirectory $fileName
    $lines = [System.Collections.Generic.List[string]]::new()

    $lines.Add("# $title")
    $lines.Add('')
    $lines.Add("**Conversation ID:** ``$($conversation.uuid)``  ")
    $lines.Add("**Created:** $(Format-Timestamp $conversation.created_at)  ")
    $lines.Add("**Updated:** $(Format-Timestamp $conversation.updated_at)")

    if (-not [string]::IsNullOrWhiteSpace([string]$conversation.summary)) {
        $lines.Add('')
        $lines.Add('## Summary')
        $lines.Add('')
        $lines.Add(([string]$conversation.summary).Trim())
    }

    $lines.Add('')
    $lines.Add('---')

    foreach ($message in @($conversation.chat_messages)) {
        $speaker = if ($message.sender -eq 'human') { 'User' } else { 'Claude' }
        $timestamp = Format-Timestamp $message.created_at

        $lines.Add('')
        $lines.Add("## $speaker")
        if ($timestamp) {
            $lines.Add('')
            $lines.Add("*$timestamp*")
        }
        $lines.Add('')
        $lines.Add(([string]$message.text).Trim())

        $attachments = @($message.attachments) + @($message.files)
        if ($attachments.Count -gt 0) {
            $lines.Add('')
            $lines.Add('**Attachments:**')
            $lines.Add('')
            foreach ($attachment in $attachments) {
                $lines.Add("- ``$(Get-AttachmentName $attachment)``")
            }
        }

        $lines.Add('')
        $lines.Add('---')
    }

    $markdown = ($lines -join "`n").TrimEnd() + "`n"
    [System.IO.File]::WriteAllText($outputPath, $markdown, $utf8)
    $writtenFiles.Add($outputPath)
}

Write-Output "Created $($writtenFiles.Count) Markdown files in $OutputDirectory"
$writtenFiles | ForEach-Object { Write-Output $_ }
