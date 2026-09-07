if (-not (Test-Path variable:Display))    { $Display = "" }
if (-not (Test-Path variable:Resolution)) { $Resolution = "" }
if (-not (Test-Path variable:Quality))    { $Quality = "" }
if (-not (Test-Path variable:FPS))        { $FPS = "" }
if (-not (Test-Path variable:Language))   { $Language = "" }
if (-not (Test-Path variable:AutoHDR))    { $AutoHDR = "" }

$ErrorActionPreference = "Continue"

$regPath = "Software\Hypergryph\Endfield"

# ============================================================
#  Interactive mode
# ============================================================
function Show-Menu {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host " Endfield Game Settings Editor" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""

    if ($Display -eq "") {
        Write-Host ""
        Write-Host "Display Mode:" -ForegroundColor Yellow
        Write-Host "  [1] Fullscreen (全屏)"
        Write-Host "  [2] Window (窗口)"
        Write-Host "  [3] Unchanged (不修改)"
        $choice = Read-Host "Select (1-3)"
        $script:Display = switch ($choice) { "1" { "Fullscreen" } "2" { "Window" } default { "Unchanged" } }
    }

    if ($Resolution -eq "") {
        Write-Host ""
        Write-Host "Resolution:" -ForegroundColor Yellow
        Write-Host "  [1] 1920x1080"
        Write-Host "  [2] 2560x1440 (2K)"
        Write-Host "  [3] 3840x2160 (4K)"
        Write-Host "  [4] 1280x720"
        Write-Host "  [5] Custom (手动输入)"
        Write-Host "  [6] Unchanged (不修改)"
        $choice = Read-Host "Select (1-6)"
        $script:Resolution = switch ($choice) {
            "1" { "1920x1080" }
            "2" { "2560x1440" }
            "3" { "3840x2160" }
            "4" { "1280x720" }
            "5" { Read-Host "Enter WIDTHxHEIGHT (e.g. 1920x1080)" }
            default { "Unchanged" }
        }
    }

    if ($Quality -eq "") {
        Write-Host ""
        Write-Host "Graphics Quality:" -ForegroundColor Yellow
        Write-Host "  [1] Ultra (极致)"
        Write-Host "  [2] High (高)"
        Write-Host "  [3] Medium (中)"
        Write-Host "  [4] Low (低)"
        Write-Host "  [5] VeryLow (极低)"
        Write-Host "  [6] Unchanged (不修改)"
        $choice = Read-Host "Select (1-6)"
        $script:Quality = switch ($choice) {
            "1" { "Ultra" } "2" { "High" } "3" { "Medium" }
            "4" { "Low" } "5" { "VeryLow" } default { "Unchanged" }
        }
    }

    if ($FPS -eq "") {
        Write-Host ""
        Write-Host "Frame Rate:" -ForegroundColor Yellow
        Write-Host "  [1] 120 FPS"
        Write-Host "  [2] 60 FPS"
        Write-Host "  [3] 30 FPS"
        Write-Host "  [4] Unchanged (不修改)"
        $choice = Read-Host "Select (1-4)"
        $script:FPS = switch ($choice) { "1" { "120" } "2" { "60" } "3" { "30" } default { "Unchanged" } }
    }

    if ($Language -eq "") {
        Write-Host ""
        Write-Host "Text Language:" -ForegroundColor Yellow
        Write-Host "  [1] CN (简体中文)"
        Write-Host "  [2] EN (English)"
        Write-Host "  [3] JP (日本語)"
        Write-Host "  [4] KR (한국어)"
        Write-Host "  [5] TC (繁體中文)"
        Write-Host "  [6] Unchanged (不修改)"
        $choice = Read-Host "Select (1-6)"
        $script:Language = switch ($choice) {
            "1" { "CN" } "2" { "EN" } "3" { "JP" }
            "4" { "KR" } "5" { "TC" } default { "Unchanged" }
        }
    }

    if ($AutoHDR -eq "") {
        Write-Host ""
        Write-Host "Auto HDR:" -ForegroundColor Yellow
        Write-Host "  [1] Enable (开启)"
        Write-Host "  [2] Disable (关闭)"
        Write-Host "  [3] Unchanged (不修改)"
        $choice = Read-Host "Select (1-3)"
        $script:AutoHDR = switch ($choice) { "1" { "Enable" } "2" { "Disable" } default { "Unchanged" } }
    }
}

# ============================================================
#  Value mappings (matching MAA)
# ============================================================
$qualityMap = @{
    "Ultra"    = 1
    "High"     = 2
    "Medium"   = 3
    "Low"      = 4
    "VeryLow"  = 5
}

$fpsMap = @{
    "120" = 1000
    "60"  = 2000
    "30"  = 3000
}

$languageMap = @{
    "CN" = 0;  "EN" = 1;  "JP" = 2;  "KR" = 3
    "TC" = 4;  "MX" = 5;  "BR" = 6;  "FR" = 7
    "DE" = 8;  "RU" = 9;  "IT" = 10; "ID" = 11
    "TH" = 12; "VN" = 13
}

# ============================================================
#  Registry helpers
# ============================================================
function Set-RegDWord {
    param([string]$Path, [string]$Prefix, [int]$Value)
    try {
        $key = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey($Path, $true)
        if ($null -eq $key) { Write-Host "  [WARN] Cannot open HKCU\$Path" -ForegroundColor DarkYellow; return }
        $names = $key.GetValueNames() | Where-Object { $_.StartsWith($Prefix) }
        if ($names.Count -eq 0) {
            Write-Host "  [MISS] $Prefix (no key found)" -ForegroundColor DarkYellow
        } else {
            foreach ($n in $names) {
                $key.SetValue($n, $Value, [Microsoft.Win32.RegistryValueKind]::DWord)
                Write-Host "  [OK] $n = $Value" -ForegroundColor Green
            }
        }
        $key.Close()
    } catch {
        Write-Host "  [FAIL] $Prefix : $_" -ForegroundColor Red
    }
}

# ============================================================
#  Main
# ============================================================
if ($Display -eq "" -and $Resolution -eq "" -and
    $Quality -eq "" -and $FPS -eq "" -and $Language -eq "" -and $AutoHDR -eq "") {
    Show-Menu
}

# Defaults
if ($Display -eq "")    { $Display = "Fullscreen" }
if ($Resolution -eq "") { $Resolution = "1920x1080" }
if ($Quality -eq "")    { $Quality = "Unchanged" }
if ($FPS -eq "")        { $FPS = "60" }
if ($Language -eq "")   { $Language = "Unchanged" }
if ($AutoHDR -eq "")    { $AutoHDR = "Unchanged" }

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Applying Settings" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Display    : $Display" -ForegroundColor Yellow
Write-Host "  Resolution : $Resolution" -ForegroundColor Yellow
Write-Host "  Quality    : $Quality" -ForegroundColor Yellow
Write-Host "  FPS        : $FPS" -ForegroundColor Yellow
Write-Host "  Language   : $Language" -ForegroundColor Yellow
Write-Host "  Auto HDR   : $AutoHDR" -ForegroundColor Yellow
Write-Host ""

# --- Display mode ---
if ($Display -ne "Unchanged") {
    Write-Host "[Display]" -ForegroundColor Cyan
    $isFullscreen = ($Display -eq "Fullscreen")
    Set-RegDWord -Path $regPath -Prefix "Screenmanager Fullscreen mode_h" -Value $(if ($isFullscreen) { 1 } else { 3 })
    Set-RegDWord -Path $regPath -Prefix "video_full_screen_h"           -Value $(if ($isFullscreen) { 1 } else { 0 })
}

# --- Resolution ---
if ($Resolution -ne "Unchanged") {
    $parts = $Resolution -split "x"
    if ($parts.Count -eq 2) {
        $w = [int]$parts[0]; $h = [int]$parts[1]
        Write-Host "[Resolution]" -ForegroundColor Cyan
        Set-RegDWord -Path $regPath -Prefix "Screenmanager Resolution Width_h"  -Value $w
        Set-RegDWord -Path $regPath -Prefix "Screenmanager Resolution Height_h" -Value $h
        Set-RegDWord -Path $regPath -Prefix "video_resolution_width_h"           -Value $w
        Set-RegDWord -Path $regPath -Prefix "video_resolution_height_h"          -Value $h
    } else {
        Write-Host "[FAIL] Invalid resolution: $Resolution (use WIDTHxHEIGHT)" -ForegroundColor Red
    }
}

# --- Graphics quality ---
if ($Quality -ne "Unchanged") {
    if ($qualityMap.ContainsKey($Quality)) {
        Write-Host "[Quality]" -ForegroundColor Cyan
        Set-RegDWord -Path $regPath -Prefix "video_quality_main_h" -Value $qualityMap[$Quality]
    } else {
        Write-Host "[FAIL] Unknown quality: $Quality" -ForegroundColor Red
    }
}

# --- Frame rate ---
if ($FPS -ne "Unchanged") {
    if ($fpsMap.ContainsKey($FPS)) {
        Write-Host "[Frame Rate]" -ForegroundColor Cyan
        Set-RegDWord -Path $regPath -Prefix "video_frame_rate_8_h" -Value $fpsMap[$FPS]
    } else {
        Write-Host "[FAIL] Unknown FPS: $FPS" -ForegroundColor Red
    }
}

# --- Language ---
if ($Language -ne "Unchanged") {
    if ($languageMap.ContainsKey($Language)) {
        Write-Host "[Language]" -ForegroundColor Cyan
        Set-RegDWord -Path $regPath -Prefix "language_text_change_h" -Value $languageMap[$Language]
    } else {
        Write-Host "[FAIL] Unknown language: $Language" -ForegroundColor Red
    }
}

# --- Auto HDR (separate registry path) ---
if ($AutoHDR -ne "Unchanged") {
    Write-Host "[Auto HDR]" -ForegroundColor Cyan
    $hdrPath = "Software\Microsoft\DirectX\UserGpuPreferences"
    $hdrValue = if ($AutoHDR -eq "Enable") { "2097" } else { "2096" }
    try {
        $key = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey($hdrPath, $true)
        if ($null -eq $key) {
            Write-Host "  [WARN] No UserGpuPreferences key" -ForegroundColor DarkYellow
        } else {
            $names = $key.GetValueNames() | Where-Object { $_ -like "*Endfield*" }
            if ($names.Count -eq 0) {
                Write-Host "  [MISS] No Endfield.exe entry in UserGpuPreferences" -ForegroundColor DarkYellow
            } else {
                foreach ($n in $names) {
                    # Value format: "GpuPreference=2;AutoHDREnable=2096;"
                    $old = $key.GetValue($n, "")
                    $new = $old -replace "AutoHDREnable=\d+", "AutoHDREnable=$hdrValue"
                    if ($new -ne $old) {
                        $key.SetValue($n, $new, [Microsoft.Win32.RegistryValueKind]::String)
                        Write-Host "  [OK] $n AutoHDR=$hdrValue" -ForegroundColor Green
                    } else {
                        Write-Host "  [OK] $n (already AutoHDR=$hdrValue)" -ForegroundColor Green
                    }
                }
            }
        }
        $key.Close()
    } catch {
        Write-Host "  [FAIL] Auto HDR: $_" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Done. No files were touched." -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan

if ($Display -eq "" -and $Resolution -eq "" -and
    $Quality -eq "" -and $FPS -eq "" -and $Language -eq "" -and $AutoHDR -eq "") {
    pause
}
