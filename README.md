# PsYoutubeGet

A PowerShell script designed to download YouTube audio and apply creative DSP audio effects (sine pitch wobble, reverse, panning) using `yt-dlp` and `ffmpeg`.

## Features

* **Metadata Extraction**: Automatically fetches video titles and IDs via `yt-dlp` while sanitizing filenames for safe filesystem storage.
* **Creative DSP Effects**: 
  * `-Wobble` (`-w`): Applies a vibrato pitch modulation effect.
  * `-Pulsate` (`-p`): Applies a sine wave panning/amplitude pulse effect.
  * `-Reverse` (`-r`): Reverses the audio track.
  * `-Funky` (`-f`): Combines wobble and pulsating effects automatically.
* **High-Quality Output**: Downloads the best available audio stream and processes it out to a 320kbps MP3 file with descriptive tagging.

## Architecture & Workflow

The following diagram outlines the execution lifecycle of the script from URL input to final DSP processing:

```mermaid
flowchart TD
    A[Start: yget.ps1] --> B[Input Validation & URL Sanitization]
    B --> C{Check Dependencies<br>yt-dlp & ffmpeg}
    C -- Missing --> D[Error & Exit]
    C -- Present --> E[Extract Metadata<br>via yt-dlp --dump-json]
    E --> F[Download Raw Audio<br>to Temp WAV File]
    F --> G{Build DSP Filter Graph}
    G -->|Wobble / Pulsate / Reverse / Funky| H[Process with FFmpeg<br>Apply Audio Filters]
    G -->|Clean / Default| H
    H --> I[Cleanup Temp Files]
    I --> J[Done: Output 320kbps MP3]
