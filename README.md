# 终末地 注册表设置脚本

通过修改 Windows 注册表来调整《明日方舟：终末地》的游戏画面设置。**不删除任何游戏文件，不触发"资源初始化完成"弹窗。**

## 功能

| 设置项 | 可选值 |
|--------|--------|
| 显示模式 | 全屏 / 窗口 |
| 分辨率 | 1920x1080 / 2560x1440 / 3840x2160 / 1280x720 / 自定义 |
| 画质 | 极致 / 高 / 中 / 低 / 极低 |
| 帧率 | 120 / 60 / 30 |
| 语言 | 简中 / EN / 日本語 / 한국어 / 繁中 |
| 自动 HDR | 开启 / 关闭 |

## 文件说明

| 文件 | 用途 |
|------|------|
| `set_game_settings.bat` | 交互式菜单，逐项选择后写入注册表 |
| `force_registry.bat` | 一键执行预设参数，适合启动器联动 |
| `edit_force_registry.bat` | 修改 `force_registry.bat` 的预设参数 |
| `set_game_settings.ps1` | 核心引擎（被上面三个 bat 调用） |
| `edit_force_registry.ps1` | 配置编辑器逻辑 |
| `diag_registry.bat` | 诊断工具，查看当前注册表和配置文件状态 |

## 使用方法

### 手动修改

双击 `set_game_settings.bat`，按数字选择各项设置，选完后自动写入注册表。启动游戏即可生效。

### 配合 Xel-Launcher 联动

1. 双击 `edit_force_registry.bat`，设置你想要的参数，保存
2. 在 Xel-Launcher 的"自定义联动软件"中，添加 `force_registry.bat`
3. 之后每次通过 Xel-Launcher 启动游戏，脚本会自动执行，确保设置正确

### 命令行（高级）

```batch
set_game_settings.bat -Display Fullscreen -Resolution 1920x1080 -FPS 60 -Quality High
```

## 原理

游戏首次运行后，Unity 会在注册表 `HKCU\Software\Hypergryph\Endfield` 中创建设置键。脚本直接修改这些注册表值，游戏启动时读取。

## 系统要求

- Windows 10 / 11
- 终末地至少运行过一次（注册表键已创建）
- 不需要管理员权限

## 常见问题

**Q: 设置不生效？**  
A: 确保游戏至少运行过一次。可运行 `diag_registry.bat` 检查注册表状态。

**Q: 会触发"资源初始化完成"弹窗吗？**  
A: 不会。本脚本只修改注册表，不删除任何游戏文件。
