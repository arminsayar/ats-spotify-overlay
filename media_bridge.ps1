# ============================================================
#  Media Session bridge for ETS2/ATS Spotify Overlay
#  Reads the Windows media session (Spotify desktop, browsers,
#  any media app) and reports it to the overlay app as JSON.
#  Also executes playback commands written to media_cmd.txt.
#  Works WITHOUT Spotify Premium / Web API.
# ============================================================
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Runtime.WindowsRuntime

$script:bridgeDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$script:statusFile = Join-Path $bridgeDir 'media_status.json'
$script:cmdFile    = Join-Path $bridgeDir 'media_cmd.txt'

$asTaskGeneric = [System.WindowsRuntimeSystemExtensions].GetMethods() | Where-Object { $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1' } | Select-Object -First 1

function Await($WinRtTask, $ResultType) {
    $asTask = $asTaskGeneric.MakeGenericMethod($ResultType)
    $netTask = $asTask.Invoke($null, @($WinRtTask))
    $netTask.Wait(-1) | Out-Null
    $netTask.Result
}

Add-Type '
using System;
using System.Runtime.InteropServices;
public static class MediaKeys {
    [DllImport("user32.dll")]
    public static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, UIntPtr dwExtraInfo);
    public const byte VK_MEDIA_PLAY_PAUSE = 0xB3;
    public const byte VK_MEDIA_NEXT_TRACK = 0xB0;
    public const byte VK_MEDIA_PREV_TRACK = 0xB1;
    public const byte VK_VOLUME_UP   = 0xAF;
    public const byte VK_VOLUME_DOWN = 0xAE;

    public static void Send(byte vk) {
        keybd_event(vk, 0, 0, UIntPtr.Zero);
        keybd_event(vk, 0, 2, UIntPtr.Zero);  // KEYEVENTF_KEYUP
    }
}
' -ReferencedAssemblies @('System', 'System.Runtime.InteropServices') | Out-Null

function Get-MediaInfo {
    try {
        $managers = [Windows.Media.Control.GlobalSystemMediaTransportControlsSessionManager, Windows.Media.Control, ContentType = WindowsRuntime]::RequestAsync()
        $mgr = Await $managers ([Windows.Media.Control.GlobalSystemMediaTransportControlsSessionManager])
        $session = $mgr.GetSessions() | Sort-Object { $_.SourceAppUserModelId -match 'Spotify' } -Descending | Select-Object -First 1
        if (-not $session) { return $null }

        $info = [ordered]@{
            source   = $session.SourceAppUserModelId
            title    = ''
            artist   = ''
            album    = ''
            playing  = $false
            position = 0
            duration = 0
            ok       = $true
        }

        $pt = Await $session.TryGetMediaPropertiesAsync() ([Windows.Media.Control.GlobalSystemMediaTransportControlsSessionMediaProperties])
        $info.title  = $pt.Title
        $info.artist = $pt.Artist
        $info.album  = $pt.AlbumTitle

        $info.playing  = ($session.GetPlaybackInfo().PlaybackStatus -eq [Windows.Media.Control.GlobalSystemMediaTransportControlsSessionPlaybackStatus]::Playing)
        $info.position = [int64]$session.GetTimelineProperties().Position.TotalMilliseconds
        $info.duration = [int64]$session.GetTimelineProperties().EndTime.TotalMilliseconds

        return $info
    } catch {
        return @{ ok = $false; error = $_.Exception.Message }
    }
}

function Send-Command([string]$cmd) {
    switch ($cmd) {
        'playpause' { [MediaKeys]::Send([MediaKeys]::VK_MEDIA_PLAY_PAUSE) }
        'next'      { [MediaKeys]::Send([MediaKeys]::VK_MEDIA_NEXT_TRACK) }
        'previous'  { [MediaKeys]::Send([MediaKeys]::VK_MEDIA_PREV_TRACK) }
        'volup'     { [MediaKeys]::Send([MediaKeys]::VK_VOLUME_UP) }
        'voldown'   { [MediaKeys]::Send([MediaKeys]::VK_VOLUME_DOWN) }
        default     { }
    }
}

Write-Host "Media bridge running. Status -> $script:statusFile"
$lastCmd = $null

while ($true) {
    try {
        $media = Get-MediaInfo
        if ($media) {
            $json = $media | ConvertTo-Json -Compress
            [IO.File]::WriteAllText($script:statusFile, $json)
        } else {
            [IO.File]::WriteAllText($script:statusFile, '{"ok":false,"playing":false,"title":"","artist":"","album":"","position":0,"duration":0}')
        }
    } catch {
        try { [IO.File]::WriteAllText($script:statusFile, '{"ok":false,"error":"bridge"}') } catch { }
    }

    if (Test-Path $script:cmdFile) {
        $raw = (Get-Content $script:cmdFile -Raw -ErrorAction SilentlyContinue)
        if ($raw) {
            $cmd = ($raw -split '\|')[0].Trim()   # payload is "action|nonce"
            if ($cmd -and $cmd -ne $lastCmd) {
                $lastCmd = $cmd
                Send-Command $cmd
            }
        }
    }

    Start-Sleep -Milliseconds 500
}
