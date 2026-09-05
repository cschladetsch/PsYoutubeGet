\# PsYoutubeGet



A PowerShell script designed to download YouTube audio and apply creative DSP audio effects (sine pitch wobble, reverse, panning) using `yt-dlp` and `ffmpeg`.



\## Features



\* \*\*Metadata Extraction\*\*: Automatically fetches video titles and IDs via `yt-dlp` while sanitizing filenames for safe filesystem storage.

\* \*\*Creative DSP Effects\*\*: 

&#x20; \* `-Wobble` (`-w`): Applies a vibrato pitch modulation effect.

&#x20; \* `-Pulsate` (`-p`): Applies a sine wave panning/amplitude pulse effect.

&#x20; \* `-Reverse` (`-r`): Reverses the audio track.

&#x20; \* `-Funky` (`-f`): Combines wobble and pulsating effects automatically\[cite: 1].

\* \*\*High-Quality Output\*\*: Downloads the best available audio stream and processes it out to a 320kbps MP3 file with descriptive tagging\[cite: 1].



\## Requirements



Ensure the following dependencies are installed and available in your system `PATH`\[cite: 1]:

\* \[PowerShell](https://github.com/PowerShell/PowerShell)

\* \[yt-dlp](https://github.com/yt-dlp/yt-dlp)

\* \[FFmpeg](https://ffmpeg.org/)



\## Usage



Run the script in PowerShell by passing a YouTube URL alongside any desired DSP effect flags:



```powershell

\# Download and save clean audio at 320kbps

.\\yget.ps1 "\[https://www.youtube.com/watch?v=](https://www.youtube.com/watch?v=)..."



\# Apply a sine pitch wobble effect

.\\yget.ps1 "\[https://www.youtube.com/watch?v=](https://www.youtube.com/watch?v=)..." -Wobble



\# Apply the funky preset (wobble + pulsate)

.\\yget.ps1 "\[https://www.youtube.com/watch?v=](https://www.youtube.com/watch?v=)..." -Funky



\# Reverse the audio track

.\\yget.ps1 "\[https://www.youtube.com/watch?v=](https://www.youtube.com/watch?v=)..." -Reverse

