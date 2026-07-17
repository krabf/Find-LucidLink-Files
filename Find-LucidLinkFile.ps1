#!/usr/bin/env pwsh
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Find LucidLink File
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🔍
# @raycast.argument1 { "type": "text", "placeholder": "lucid:// link (optional, reads clipboard if left blank)", "optional": true }
# @raycast.packageName LucidLink

# Documentation:
# @raycast.description Parses a LucidLink Classic direct link (typed in or read from clipboard), finds the matching file on the mounted volume, and reveals it in File Explorer.
# @raycast.author krabf

param(
    [Parameter(Position = 0)]
    [string]$Link
)

# --- CONFIG: change this to match your actual LucidLink mount drive/folder ---
$MountRoot = "L:\REPLACE_WITH_YOUR_FILESPACE_NAME"

if (-not $Link) {
    $Link = Get-Clipboard
}

if (-not $Link) {
    Write-Host "No link provided or found on clipboard."
    exit 1
}

if (-not (Test-Path $MountRoot)) {
    Write-Host "Mount not found at $MountRoot."
    Write-Host "Check that the filespace is connected, or update `$MountRoot at the top of this script."
    exit 1
}

# Strip query string (e.g. ?reveal=true)
$linkNoQuery = $Link -replace '\?.*$', ''

# Extract the last path segment, which is the filename
$encodedName = $linkNoQuery.Substring($linkNoQuery.LastIndexOf('/') + 1)

# URL-decode it (%20 -> space, %2E -> ., etc.)
$decodedName = [System.Uri]::UnescapeDataString($encodedName)

Write-Host "Looking for: $decodedName"
Write-Host "Scanning:    $MountRoot"
Write-Host "(no index on LucidLink, so this may take a moment on a large archive)"
Write-Host ""

$result = Get-ChildItem -Path $MountRoot -Recurse -Filter $decodedName -ErrorAction SilentlyContinue | Select-Object -First 1

if (-not $result) {
    Write-Host "No match found for `"$decodedName`" under $MountRoot."
    exit 1
}

Write-Host "Found: $($result.FullName)"
explorer.exe /select, "$($result.FullName)"
