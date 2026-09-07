$ErrorActionPreference = "Continue"

$batFile = Join-Path $ScriptDir "force_registry.bat"
$paramLinePattern = 'Invoke-Expression'

# ============================================================
#  解析 force_registry.bat 中的当前参数
# ============================================================
function Parse-BatParams {
    param([string]$FilePath)
    if (-not (Test-Path $FilePath)) {
        Write-Host "[错误] force_registry.bat 未找到" -ForegroundColor Red
        return @{}
    }
    $content = Get-Content $FilePath -Raw
    if ($content -match $paramLinePattern) {
        $params = @{}
        $regex = [regex]'\$(\w+)=''([^'']*)'''
        foreach ($m in $regex.Matches($content)) {
            $name = $m.Groups[1].Value
            if ($name -in @("Display","Resolution","Quality","FPS","Language","AutoHDR")) {
                $params[$name] = $m.Groups[2].Value
            }
        }
        return $params
    }
    return @{}
}

# ============================================================
#  显示当前配置
# ============================================================
$current = Parse-BatParams -FilePath $batFile

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " force_registry.bat - 当前配置" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  显示模式   : " -NoNewline
Write-Host $current["Display"] -ForegroundColor Yellow
Write-Host "  分辨率     : " -NoNewline
Write-Host $current["Resolution"] -ForegroundColor Yellow
Write-Host "  画质       : " -NoNewline
Write-Host $current["Quality"] -ForegroundColor Yellow
Write-Host "  帧率       : " -NoNewline
Write-Host $current["FPS"] -ForegroundColor Yellow
Write-Host "  语言       : " -NoNewline
Write-Host $current["Language"] -ForegroundColor Yellow
Write-Host "  自动 HDR   : " -NoNewline
Write-Host $current["AutoHDR"] -ForegroundColor Yellow
Write-Host ""

# ============================================================
#  编辑菜单
# ============================================================
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " 修改设置" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "回车 = 保持不变  0 = 跳过此项"
Write-Host ""

$new = @{}

# ── 显示模式 ──
Write-Host ""
Write-Host "显示模式:" -ForegroundColor Yellow
Write-Host "  [1] Fullscreen (全屏)"
Write-Host "  [2] Window (窗口)"
Write-Host "  [0] 跳过"
$choice = Read-Host "选择 (当前: $($current["Display"]))"
$new["Display"] = switch ($choice) {
    "1" { "Fullscreen" }
    "2" { "Window" }
    "0" { "Unchanged" }
    default { $current["Display"] }
}

# ── 分辨率 ──
Write-Host ""
Write-Host "分辨率:" -ForegroundColor Yellow
Write-Host "  [1] 1920x1080"
Write-Host "  [2] 2560x1440 (2K)"
Write-Host "  [3] 3840x2160 (4K)"
Write-Host "  [4] 1280x720"
Write-Host "  [5] 手动输入"
Write-Host "  [0] 跳过"
$choice = Read-Host "选择 (当前: $($current["Resolution"]))"
$new["Resolution"] = switch ($choice) {
    "1" { "1920x1080" }
    "2" { "2560x1440" }
    "3" { "3840x2160" }
    "4" { "1280x720" }
    "5" { Read-Host "  输入 宽x高 (如 1920x1080)" }
    "0" { "Unchanged" }
    default { $current["Resolution"] }
}

# ── 画质 ──
Write-Host ""
Write-Host "画质:" -ForegroundColor Yellow
Write-Host "  [1] Ultra (极致)"
Write-Host "  [2] High (高)"
Write-Host "  [3] Medium (中)"
Write-Host "  [4] Low (低)"
Write-Host "  [5] VeryLow (极低)"
Write-Host "  [0] 跳过"
$choice = Read-Host "选择 (当前: $($current["Quality"]))"
$new["Quality"] = switch ($choice) {
    "1" { "Ultra" }
    "2" { "High" }
    "3" { "Medium" }
    "4" { "Low" }
    "5" { "VeryLow" }
    "0" { "Unchanged" }
    default { $current["Quality"] }
}

# ── 帧率 ──
Write-Host ""
Write-Host "帧率:" -ForegroundColor Yellow
Write-Host "  [1] 120 FPS"
Write-Host "  [2] 60 FPS"
Write-Host "  [3] 30 FPS"
Write-Host "  [0] 跳过"
$choice = Read-Host "选择 (当前: $($current["FPS"]))"
$new["FPS"] = switch ($choice) {
    "1" { "120" }
    "2" { "60" }
    "3" { "30" }
    "0" { "Unchanged" }
    default { $current["FPS"] }
}

# ── 语言 ──
Write-Host ""
Write-Host "语言:" -ForegroundColor Yellow
Write-Host "  [1] CN (简体中文)"
Write-Host "  [2] EN (English)"
Write-Host "  [3] JP (日本語)"
Write-Host "  [4] KR (한국어)"
Write-Host "  [5] TC (繁體中文)"
Write-Host "  [0] 跳过"
$choice = Read-Host "选择 (当前: $($current["Language"]))"
$new["Language"] = switch ($choice) {
    "1" { "CN" }
    "2" { "EN" }
    "3" { "JP" }
    "4" { "KR" }
    "5" { "TC" }
    "0" { "Unchanged" }
    default { $current["Language"] }
}

# ── 自动 HDR ──
Write-Host ""
Write-Host "自动 HDR:" -ForegroundColor Yellow
Write-Host "  [1] 开启"
Write-Host "  [2] 关闭"
Write-Host "  [0] 跳过"
$choice = Read-Host "选择 (当前: $($current["AutoHDR"]))"
$new["AutoHDR"] = switch ($choice) {
    "1" { "Enable" }
    "2" { "Disable" }
    "0" { "Unchanged" }
    default { $current["AutoHDR"] }
}

# ============================================================
#  确认
# ============================================================
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " 新配置" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  显示模式   : " -NoNewline
Write-Host $new["Display"] -ForegroundColor $(if ($new["Display"] -ne $current["Display"]) { "Green" } else { "Gray" })
Write-Host "  分辨率     : " -NoNewline
Write-Host $new["Resolution"] -ForegroundColor $(if ($new["Resolution"] -ne $current["Resolution"]) { "Green" } else { "Gray" })
Write-Host "  画质       : " -NoNewline
Write-Host $new["Quality"] -ForegroundColor $(if ($new["Quality"] -ne $current["Quality"]) { "Green" } else { "Gray" })
Write-Host "  帧率       : " -NoNewline
Write-Host $new["FPS"] -ForegroundColor $(if ($new["FPS"] -ne $current["FPS"]) { "Green" } else { "Gray" })
Write-Host "  语言       : " -NoNewline
Write-Host $new["Language"] -ForegroundColor $(if ($new["Language"] -ne $current["Language"]) { "Green" } else { "Gray" })
Write-Host "  自动 HDR   : " -NoNewline
Write-Host $new["AutoHDR"] -ForegroundColor $(if ($new["AutoHDR"] -ne $current["AutoHDR"]) { "Green" } else { "Gray" })
Write-Host ""

$confirm = Read-Host "保存到 force_registry.bat? [Y/n]"
if ($confirm -eq "n" -or $confirm -eq "N") {
    Write-Host "已取消。" -ForegroundColor DarkYellow
    pause
    exit 0
}

# ============================================================
#  写入 force_registry.bat
# ============================================================
$newContent = @"
@echo off
cd /d "%~dp0"

REM Quick force: $($new["Display"]), $($new["Resolution"]), $($new["FPS"])fps
powershell -ExecutionPolicy Bypass -NoProfile -Command "`$Display='$($new["Display"])'; `$Resolution='$($new["Resolution"])'; `$FPS='$($new["FPS"])'; `$Quality='$($new["Quality"])'; `$Language='$($new["Language"])'; `$AutoHDR='$($new["AutoHDR"])'; `$s=[System.IO.File]::ReadAllText('%~dp0set_game_settings.ps1',[System.Text.Encoding]::UTF8); Invoke-Expression `$s"
"@

Set-Content -Path $batFile -Value $newContent -Encoding ASCII

Write-Host ""
Write-Host "force_registry.bat 已更新。" -ForegroundColor Green
Write-Host ""

# 显示新文件内容
Write-Host "--- force_registry.bat ---" -ForegroundColor DarkGray
Get-Content $batFile | ForEach-Object { Write-Host $_ -ForegroundColor DarkGray }
Write-Host "--------------------------" -ForegroundColor DarkGray

pause
