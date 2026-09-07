# Endfield Settings Diagnostic
# Check registry, Persistent files, and StreamingAssets templates

$GameDir = "D:\Program Files\Endfield Game"
$PersistDir = "$GameDir\Endfield_Data\Persistent"
$StreamDir = "$GameDir\Endfield_Data\StreamingAssets"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Endfield Settings Diagnostic" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 1. Check Persistent files
Write-Host "=== Persistent Files ===" -ForegroundColor Yellow
if (Test-Path $PersistDir) {
    $files = Get-ChildItem $PersistDir -File -ErrorAction SilentlyContinue
    if ($files.Count -eq 0) {
        Write-Host "  (empty) - Registry mode should work" -ForegroundColor Green
    } else {
        foreach ($f in $files) {
            $sizeKB = [math]::Round($f.Length / 1024, 1)
            $marker = ""
            if ($f.Name -like "pref_*" -or $f.Name -like "index_initial*") {
                $marker = " [SETTINGS - will override registry!]"
                Write-Host "  [!] $($f.Name) ($sizeKB KB)$marker" -ForegroundColor Red
            } elseif ($f.Name -like "index_main*") {
                $marker = " [RESOURCE INDEX - OK to keep]"
                Write-Host "  [i] $($f.Name) ($sizeKB KB)$marker" -ForegroundColor Gray
            } else {
                Write-Host "  [?] $($f.Name) ($sizeKB KB)" -ForegroundColor DarkYellow
            }
        }
    }
} else {
    Write-Host "  Directory not found" -ForegroundColor DarkGray
}

Write-Host ""

# 2. Check StreamingAssets templates
Write-Host "=== StreamingAssets Templates ===" -ForegroundColor Yellow
if (Test-Path $StreamDir) {
    Get-ChildItem $StreamDir -File -ErrorAction SilentlyContinue | ForEach-Object {
        $sizeKB = [math]::Round($_.Length / 1024, 1)
        Write-Host "  $($_.Name) ($sizeKB KB)" -ForegroundColor Gray
    }
}

Write-Host ""

# 3. Check Registry (CN) - use _h prefix to match game keys
Write-Host "=== Registry (HKCU\Software\Hypergryph\Endfield) ===" -ForegroundColor Yellow
$prefixes = @(
    @("Screenmanager Fullscreen mode_h", "Fullscreen  "),
    @("video_full_screen_h", "VideoFS     "),
    @("Screenmanager Resolution Width_h", "ScrWidth    "),
    @("Screenmanager Resolution Height_h", "ScrHeight   "),
    @("video_resolution_width_h", "VidWidth    "),
    @("video_resolution_height_h", "VidHeight   "),
    @("video_frame_rate_8_h", "FrameRate   ")
)

try {
    $key = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey("Software\Hypergryph\Endfield")
    if ($null -eq $key) {
        Write-Host "  Registry key NOT FOUND" -ForegroundColor Red
    } else {
        $allNames = $key.GetValueNames()
        
        Write-Host "  Game keys (with _h suffix):" -ForegroundColor Cyan
        foreach ($item in $prefixes) {
            $prefix = $item[0]
            $label = $item[1]
            $matches = $allNames | Where-Object { $_.StartsWith($prefix) }
            if ($matches.Count -eq 0) {
                Write-Host "    [MISSING] $prefix" -ForegroundColor Red
            } else {
                foreach ($name in $matches) {
                    $val = $key.GetValue($name)
                    $kind = $key.GetValueKind($name)
                    Write-Host "    [$label] $name = $val ($kind)" -ForegroundColor Green
                }
            }
        }
        
        Write-Host ""
        Write-Host "  Default keys (may be ignored by game):" -ForegroundColor DarkGray
        foreach ($item in $prefixes) {
            $basePrefix = ($item[0] -replace '_h$', '')
            $label = $item[1]
            $matches = $allNames | Where-Object { $_.StartsWith($basePrefix) -and $_.Contains("Default") }
            foreach ($name in $matches) {
                $val = $key.GetValue($name)
                $kind = $key.GetValueKind($name)
                Write-Host "    [$label] $name = $val ($kind)" -ForegroundColor DarkGray
            }
        }
        
        $key.Close()
    }
} catch {
    Write-Host "  Error reading registry: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Summary ===" -ForegroundColor Cyan
Write-Host "Game reads:  pref_*.json + index_initial.json > registry" -ForegroundColor Yellow
Write-Host "Keep:        index_main.json (resource index, NOT settings)" -ForegroundColor Yellow
Write-Host "Run force_registry.bat to clear settings files and write registry." -ForegroundColor Yellow

pause
