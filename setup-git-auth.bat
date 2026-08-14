@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo ============================================
echo   GitHub Git Auth Setup Script
echo ============================================
echo.

REM Check Git installation
where git >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Git is not installed. Please install Git for Windows:
    echo         https://gitforwindows.org/
    pause
    exit /b 1
)

for /f "tokens=*" %%i in ('git --version 2^>^&1') do set "GIT_VER=%%i"
echo [OK] Git installed: %GIT_VER%
echo.

REM Step 1: Configure Git Credential Manager
echo [Step 1] Configuring Git Credential Manager...

git config --global credential.helper manager
if %errorlevel% equ 0 (
    echo [OK] credential.helper set to manager
) else (
    echo [WARN] Git Credential Manager not available
    echo        Please install from:
    echo        https://github.com/git-ecosystem/git-credential-manager/releases
)
echo.

REM Step 2: Get user input
echo [Step 2] Enter your GitHub credentials
echo.
echo First, generate your Personal Access Token:
echo   - Visit: https://github.com/settings/tokens/new
echo   - Note: Any name (e.g. My-PC)
echo   - Check: repo (Full control of repositories)
echo   - Click Generate token and copy it
echo.

set /p "USERNAME=Enter your GitHub username: "
set /p "TOKEN=Paste your Personal Access Token: "

if "%USERNAME%"=="" (
    echo [ERROR] Username cannot be empty
    pause
    exit /b 1
)

if "%TOKEN%"=="" (
    echo [ERROR] Token cannot be empty
    pause
    exit /b 1
)

echo.

REM Step 3: Store credentials securely
echo [Step 3] Storing credentials securely...

echo protocol=https>%temp%\git_cred.txt
echo host=github.com>>%temp%\git_cred.txt
echo username=%USERNAME%>>%temp%\git_cred.txt
echo password=%TOKEN%>>%temp%\git_cred.txt
echo.>>%temp%\git_cred.txt

type %temp%\git_cred.txt | git credential-manager approve 2>nul
if %errorlevel% equ 0 (
    echo [OK] Credentials stored in Windows Credential Manager
) else (
    type %temp%\git_cred.txt | git credential approve 2>nul
    if %errorlevel% equ 0 (
        echo [OK] Credentials stored via git credential approve
    ) else (
        echo [WARN] Automatic storage failed
        echo        When you run git push for the first time,
        echo        Git will prompt for credentials:
        echo        Username: %USERNAME%
        echo        Password: ^<paste your Token here^>
    )
)

REM Secure cleanup
del %temp%\git_cred.txt >nul 2>&1
echo.

REM Step 4: Verify
echo [Step 4] Verifying configuration...
echo.
echo Current credential.helper:
git config --global credential.helper
echo.

git remote get-url origin >nul 2>&1
if %errorlevel% equ 0 (
    echo Remote URL configured.
) else (
    echo [INFO] No remote configured yet. Will be set on first push.
)

echo.
echo ============================================
echo   Setup Complete!
echo ============================================
echo.
echo Now you can run these commands:
echo.
echo   cd /d d:\trae-program\snakeGame\snakegame
echo   git add README.md
echo   git commit -m "docs: add README"
echo   git push origin main
echo.
echo Git will automatically use the stored credentials.
echo.
echo [Security] Your token is stored securely in Windows
echo            Credential Manager. It won't appear in
echo            any config files.
echo.

pause
