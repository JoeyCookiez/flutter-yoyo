@echo off
echo 检查 Android SDK Platform 31 安装情况...
echo.

set SDK_DIR=F:\ad_sdk
set PLATFORM_DIR=%SDK_DIR%\platforms\android-31

echo SDK 目录: %SDK_DIR%
echo Platform 31 目录: %PLATFORM_DIR%
echo.

if exist "%PLATFORM_DIR%" (
    echo [√] Platform 31 目录存在
    if exist "%PLATFORM_DIR%\android.jar" (
        echo [√] android.jar 文件存在
        echo.
        echo Platform 31 已正确安装！
    ) else (
        echo [×] android.jar 文件不存在
        echo 请确保 Platform 31 完整安装
    )
) else (
    echo [×] Platform 31 目录不存在
    echo.
    echo 请将 Android SDK Platform 31 安装到: %PLATFORM_DIR%
    echo.
    echo 安装方法：
    echo 1. 使用 Android Studio SDK Manager
    echo 2. 或使用命令行: sdkmanager "platforms;android-31"
)

echo.
echo 检查 build-tools...
if exist "%SDK_DIR%\build-tools" (
    dir /b "%SDK_DIR%\build-tools"
) else (
    echo [×] build-tools 目录不存在
)

pause




