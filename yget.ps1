<#
.SYNOPSIS
    Downloads YouTube audio and applies DSP effects (sine pitch wobble, reverse, panning).
#>
[CmdletBinding()]
param(
    [Parameter(Position=0, Mandatory=$false)]
    [string]$Url,

    [Parameter(Position=1, Mandatory=$false)]
    [string]$Model = "qwen2.5-coder:14b",

    [Alias("w")]
    [switch]$Wobble,

    [Alias("r")]
    [switch]$Reverse,

    [Alias("p")]
    [switch]$Pulsate,

    [Alias("f")]
    [switch]$Funky
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# --- 1. Input Validation ---
if ([string]::IsNullOrWhiteSpace($Url)) {
    if ($args.Count -gt 0 -and -not [string]::IsNullOrWhiteSpace($args[0])) {
        $Url = $args[0]
    } else {
        Write-Host "Usage: yget <URL> [-Wobble] [-Reverse] [-Pulsate] [-Funky]" -ForegroundColor Yellow
        exit 1
    }
}

if ($Url -match '^https?://') {
    $Url = ($Url -split '&')[0]
}

# --- 2. Check Dependencies ---
foreach ($cmd in @("yt-dlp", "ffmpeg")) {
    if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
        Write-Error "Required dependency missing from PATH: $cmd"
        exit 1
    }
}

# --- 3. Extract Metadata ---
Write-Host "[*] Extracting metadata..." -ForegroundColor Cyan

# Pre-initialize under StrictMode
$title = "Unknown_Title"
$id    = "Unknown_ID"

try {
    $rawJson = yt-dlp --dump-json --no-warnings "$Url" 2>$null

    if ($null -eq $rawJson) {
        Write-Error "yt-dlp returned empty response."
        exit 1
    }

    $firstLine = if ($rawJson -is [array]) { 
        if ($rawJson.Length -eq 0) { Write-Error "yt-dlp output array was empty."; exit 1 }
        $rawJson[0] 
    } else { 
        $rawJson 
    }

    if ([string]::IsNullOrWhiteSpace($firstLine)) {
        Write-Error "yt-dlp output line was empty."
        exit 1
    }

    $meta = $firstLine | ConvertFrom-Json

    if ($null -ne $meta.PSObject.Properties['title'] -and -not [string]::IsNullOrWhiteSpace($meta.title)) {
        $title = $meta.title -replace '[\\/:*?"<>|]', '_'
    }
    if ($null -ne $meta.PSObject.Properties['id'] -and -not [string]::IsNullOrWhiteSpace($meta.id)) {
        $id = $meta.id
    }
} catch {
    Write-Error "Metadata extraction failed: $_"
    exit 1
}

Write-Host "[+] Target: $title [$id]" -ForegroundColor Green

# --- 4. Download Raw Audio to Temp File ---
$tempPath = [System.IO.Path]::GetTempPath()
$tempRaw  = [System.IO.Path]::Combine($tempPath, "yget_temp_$id.wav")

if (Test-Path $tempRaw) { 
    Remove-Item $tempRaw -Force 
}

Write-Host "[*] Downloading raw audio..." -ForegroundColor Cyan
yt-dlp -f "ba/b" -x --audio-format wav -o $tempRaw "$Url" --no-warnings

if (-not (Test-Path $tempRaw)) {
    Write-Error "Failed to download raw audio buffer."
    exit 1
}

# --- 5. Build FFmpeg Audio Filter Graph ---
$filters = [System.Collections.Generic.List[string]]::new()

if ($Funky) {
    $Wobble  = $true
    $Pulsate = $true
}

if ($Wobble) {
    $filters.Add("vibrato=f=3.5:d=0.5")
}

if ($Pulsate) {
    $filters.Add("apulsator=mode=sine:hz=0.3:amount=0.8")
}

if ($Reverse) {
    $filters.Add("areverse")
}

$tag = ""
if ($Funky)   { $tag += "_FUNKY" }
if ($Wobble  -and -not $Funky) { $tag += "_wobble" }
if ($Pulsate -and -not $Funky) { $tag += "_pulsate" }
if ($Reverse -and -not $Funky) { $tag += "_reverse" }
if ($tag -eq "") { $tag = "_clean" }

$outputFile = "$title [$id]$tag.mp3"

# --- 6. Process Audio with FFmpeg ---
if ($filters.Count -gt 0) {
    $filterGraph = $filters -join ","
    Write-Host "[*] Applying Audio DSP Filters: $filterGraph" -ForegroundColor Magenta
    ffmpeg -y -i $tempRaw -af $filterGraph -b:a 320k "$outputFile" -loglevel error
} else {
    Write-Host "[*] Saving clean audio..." -ForegroundColor Cyan
    ffmpeg -y -i $tempRaw -b:a 320k "$outputFile" -loglevel error
}

if (Test-Path $tempRaw) { 
    Remove-Item $tempRaw -Force 
}

Write-Host "[+] Processing complete: $outputFile" -ForegroundColor Green
