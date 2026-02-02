@echo off
title Windows 11 Desktop wallpaper settings ~by anig.top
mode con cols=68 lines=15
color a
chcp 936 > nul
REM 提示1: 需要将该文件的编码格式改为ANSI
REM 提示2: 文件路径可能需要绝对路径

:menu
cls
echo.
echo ===============================
echo     Windows 11 背景切换
echo ===============================
echo 按 1 - 设为纯色背景（Metal blue）
echo 按 2 - 设为图片背景
echo 按 3 - 打开个性化设置
echo ===============================
echo.

choice /c 123 /n /m "请选择: "

if %errorlevel%==1 goto solid_color
if %errorlevel%==2 goto picture_bg
if %errorlevel%==3 goto open_settings

:solid_color
REM 设为纯色背景 - Metal blue
echo 设为纯色背景: Metal blue

REM 设置背景色为 Metal blue
reg add "HKCU\Control Panel\Colors" /v Background /t REG_SZ /d "0 102 204" /f

REM 设置壁纸为空以使用纯色背景
PowerShell -Command "Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name Wallpaper -Value ''"

REM 刷新设置
RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters

echo 纯色背景已设置为 Metal blue！
goto menu

:picture_bg
echo.
echo 正在设置图片背景...
echo.

REM 使用 PowerShell API 设置图片背景
if defined SAVED_WALLPAPER (
    echo 恢复保存的图片：%SAVED_WALLPAPER%
    
    powershell -Command "Add-Type -TypeDefinition 'using System; using System.Runtime.InteropServices; namespace Wallpaper { public class Setter { [DllImport(\"user32.dll\", CharSet = CharSet.Auto)] public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni); } }'; [Wallpaper.Setter]::SystemParametersInfo(0x0014, 0, '%SAVED_WALLPAPER%', 3)"
    
    reg add "HKCU\Control Panel\Desktop" /v Wallpaper /t REG_SZ /d "%SAVED_WALLPAPER%" /f
    reg add "HKCU\Control Panel\Desktop" /v WallpaperStyle /t REG_SZ /d "10" /f
    reg add "HKCU\Control Panel\Desktop" /v TileWallpaper /t REG_SZ /d "0" /f
    
    reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Wallpapers" /v BackgroundType /f 2>nul
    reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Wallpapers" /v BackgroundColor /f 2>nul
) else (
    echo 未找到保存的图片路径，使用Windows默认图片...
    
    powershell -Command "Add-Type -TypeDefinition 'using System; using System.Runtime.InteropServices; namespace Wallpaper { public class Setter { [DllImport(\"user32.dll\", CharSet = CharSet.Auto)] public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni); } }'; $defaultWallpaper = [Environment]::GetFolderPath('Windows') + '\web\wallpaper\Windows\img0.jpg'; [Wallpaper.Setter]::SystemParametersInfo(0x0014, 0, $defaultWallpaper, 3)"
)

REM 刷新设置
RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters

echo 图片背景设置完成！
echo.
timeout /t 2 >nul
goto menu

:open_settings
start ms-settings:personalization-background
goto menu
