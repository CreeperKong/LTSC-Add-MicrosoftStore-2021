@echo off
for /f "tokens=6 delims=[]. " %%G in ('ver') do if %%G lss 19041 goto :version
%windir%\system32\reg.exe query "HKU\S-1-5-19" 1>nul 2>nul || goto :uac
setlocal enableextensions

if /i "%PROCESSOR_ARCHITECTURE%" equ "AMD64" (set "arch=x64") else (set "arch=x86")
if /i "%PROCESSOR_ARCHITECTURE%" equ "ARM64" (set "arch=a64") else (set "arch=x86")

if /i %arch%==a64 (
for /f "tokens=6 delims=[]. " %%G in ('ver') do if %%G lss 22000 set "arch=a6432"
)

cd /d "%~dp0"
if not exist "*WindowsStore*.msixbundle" goto :nofiles
if not exist "*WindowsStore*.xml" goto :nofiles

for /f %%i in ('dir /b *WindowsStore*.Msixbundle 2^>nul') do set "Store=%%i"
for /f %%i in ('dir /b *NET.Native.Framework*2.2*.appx 2^>nul ^| find /i "x64"') do set "Framework6X64=%%i"
for /f %%i in ('dir /b *NET.Native.Framework*2.2*.appx 2^>nul ^| find /i "arm64"') do set "Framework6A64=%%i"
for /f %%i in ('dir /b *NET.Native.Framework*2.2*.appx 2^>nul ^| find /i "x86"') do set "Framework6X86=%%i"
for /f %%i in ('dir /b *NET.Native.Framework*2.2*.appx 2^>nul ^| find /i "arm_"') do set "Framework6A32=%%i"
for /f %%i in ('dir /b *NET.Native.Runtime*2.2*.appx 2^>nul ^| find /i "x64"') do set "Runtime6X64=%%i"
for /f %%i in ('dir /b *NET.Native.Runtime*2.2*.appx 2^>nul ^| find /i "arm64"') do set "Runtime6A64=%%i"
for /f %%i in ('dir /b *NET.Native.Runtime*2.2*.appx 2^>nul ^| find /i "x86"') do set "Runtime6X86=%%i"
for /f %%i in ('dir /b *NET.Native.Runtime*2.2*.appx 2^>nul ^| find /i "arm_"') do set "Runtime6A32=%%i"
for /f %%i in ('dir /b *VCLibs*140*.appx 2^>nul ^| find /i "x64"') do set "VCLibsX64=%%i"
for /f %%i in ('dir /b *VCLibs*140*.appx 2^>nul ^| find /i "arm64"') do set "VCLibsA64=%%i"
for /f %%i in ('dir /b *VCLibs*140*.appx 2^>nul ^| find /i "x86"') do set "VCLibsX86=%%i"
for /f %%i in ('dir /b *VCLibs*140*.appx 2^>nul ^| find /i "arm_"') do set "VCLibsA32=%%i"
for /f %%i in ('dir /b *WindowsAppRuntime.1.5*.msix 2^>nul ^| find /i "x64"') do set "RT15X64=%%i"
for /f %%i in ('dir /b *WindowsAppRuntime.1.5*.msix 2^>nul ^| find /i "arm64"') do set "RT15A64=%%i"
for /f %%i in ('dir /b *WindowsAppRuntime.1.5*.msix 2^>nul ^| find /i "x86"') do set "RT15X86=%%i"

if exist "*StorePurchaseApp*.appxbundle" if exist "*StorePurchaseApp*.xml" (
for /f %%i in ('dir /b *StorePurchaseApp*.appxbundle 2^>nul') do set "PurchaseApp=%%i"
)
if exist "*DesktopAppInstaller*.msixbundle" if exist "*DesktopAppInstaller*.xml" (
for /f %%i in ('dir /b *DesktopAppInstaller*.msixbundle 2^>nul') do set "AppInstaller=%%i"
)
if exist "*XboxIdentityProvider*.appxbundle" if exist "*XboxIdentityProvider*.xml" (
for /f %%i in ('dir /b *XboxIdentityProvider*.appxbundle 2^>nul') do set "XboxIdentity=%%i"
)

:ChoicePrompt
set "choice="
set /p choice="Do you want to install latest DesktopAppInstaller with winget included? This may take a while.(Y/N): "
set choice=%choice:~0,1%
if /i "%choice%"=="Y" (
    powershell -Command ^
        "try { Invoke-WebRequest -Uri 'https://aka.ms/getwinget' -OutFile '%~dp0\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle' -TimeoutSec 10; exit 0 } catch { exit 1 }"
    if %errorlevel% neq 0 (
        goto checkarch
    ) else (
        set "AppInstaller=Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
        goto checkarch
    )
) else if /i "%choice%"=="N" (
    goto checkarch
) else (
    goto ChoicePrompt
)

:checkarch
if /i %arch%==x64 (
set "DepStore=%VCLibsX64%,%VCLibsX86%,%Framework6X64%,%Framework6X86%,%Runtime6X64%,%Runtime6X86%"
set "DepPurchase=%VCLibsX64%,%VCLibsX86%,%Framework6X64%,%Framework6X86%,%Runtime6X64%,%Runtime6X86%"
set "DepXbox=%VCLibsX64%,%VCLibsX86%,%Framework6X64%,%Framework6X86%,%Runtime6X64%,%Runtime6X86%"
set "DepInstaller=%VCLibsX64%,%VCLibsX86%"
) else if /i %arch%==a6432 (
set "DepStore=%VCLibsX64%,%VCLibsX86%,%Framework6X64%,%Framework6X86%,%Runtime6X64%,%Runtime6X86%,%VCLibsA64%,%VCLibsA32%,%Framework6A64%,%Framework6A32%,%Runtime6A64%,%Runtime6A32%"
set "DepPurchase=%VCLibsX64%,%VCLibsX86%,%Framework6X64%,%Framework6X86%,%Runtime6X64%,%Runtime6X86%,%VCLibsA64%,%VCLibsA32%,%Framework6A64%,%Framework6A32%,%Runtime6A64%,%Runtime6A32%"
set "DepXbox=%VCLibsX64%,%VCLibsX86%,%Framework6X64%,%Framework6X86%,%Runtime6X64%,%Runtime6X86%,%VCLibsA64%,%VCLibsA32%,%Framework6A64%,%Framework6A32%,%Runtime6A64%,%Runtime6A32%"
set "DepInstaller=%VCLibsX64%,%VCLibsX86%,%VCLibsA64%,%VCLibsA32%"
) else if /i %arch%==a64 (
set "DepStore=%VCLibsX64%,%VCLibsX86%,%Framework6X64%,%Framework6X86%,%Runtime6X64%,%Runtime6X86%,%VCLibsA64%,%Framework6A64%,%Runtime6A64%"
set "DepPurchase=%VCLibsX64%,%VCLibsX86%,%Framework6X64%,%Framework6X86%,%Runtime6X64%,%Runtime6X86%,%VCLibsA64%,%Framework6A64%,%Runtime6A64%"
set "DepXbox=%VCLibsX64%,%VCLibsX86%,%Framework6X64%,%Framework6X86%,%Runtime6X64%,%Runtime6X86%,%VCLibsA64%,%Framework6A64%,%Runtime6A64%"
set "DepInstaller=%VCLibsX64%,%VCLibsX86%,%VCLibsA64%"
)
) else (
set "DepStore=%VCLibsX86%,%Framework6X86%,%Runtime6X86%"
set "DepPurchase=%VCLibsX86%,%Framework6X86%,%Runtime6X86%"
set "DepXbox=%VCLibsX86%,%Framework6X86%,%Runtime6X86%"
set "DepInstaller=%VCLibsX86%"
)

for %%i in (%DepStore%) do (
if not exist "%%i" goto :nofiles
)

set "PScommand=PowerShell -NoLogo -NoProfile -NonInteractive -InputFormat None -ExecutionPolicy Bypass"

echo.
echo ============================================================
echo Preparing Libraries
echo ============================================================
echo.
if /i %arch%==x64 (
%PScommand% Add-AppxPackage -Path %VCLibsX64%
%PScommand% Add-AppxPackage -Path %Runtime6X64%
%PScommand% Add-AppxPackage -Path %Framework6X64%
)
if /i %arch%==a64 (
%PScommand% Add-AppxPackage -Path %VCLibsX64%
%PScommand% Add-AppxPackage -Path %Runtime6X64%
%PScommand% Add-AppxPackage -Path %Framework6X64%
%PScommand% Add-AppxPackage -Path %VCLibsA64%
%PScommand% Add-AppxPackage -Path %Runtime6A64%
%PScommand% Add-AppxPackage -Path %Framework6A64%
)
if /i %arch%==a6432 (
%PScommand% Add-AppxPackage -Path %VCLibsX64%
%PScommand% Add-AppxPackage -Path %Runtime6X64%
%PScommand% Add-AppxPackage -Path %Framework6X64%
%PScommand% Add-AppxPackage -Path %VCLibsA64%
%PScommand% Add-AppxPackage -Path %Runtime6A64%
%PScommand% Add-AppxPackage -Path %Framework6A64%
%PScommand% Add-AppxPackage -Path %VCLibsA32%
%PScommand% Add-AppxPackage -Path %Runtime6A32%
%PScommand% Add-AppxPackage -Path %Framework6A32%
)
%PScommand% Add-AppxPackage -Path %VCLibsX86%
%PScommand% Add-AppxPackage -Path %Runtime6X86%
%PScommand% Add-AppxPackage -Path %Framework6X86%

echo.
echo ============================================================
echo Adding Microsoft Store
echo ============================================================
echo.
1>nul 2>nul %PScommand% Add-AppxProvisionedPackage -Online -PackagePath %Store% -DependencyPackagePath %DepStore% -LicensePath Microsoft.WindowsStore_8wekyb3d8bbwe.xml
for %%i in (%DepStore%) do (
%PScommand% Add-AppxPackage -Path %%i
)
%PScommand% Add-AppxPackage -Path %Store%

if defined PurchaseApp (
echo.
echo ============================================================
echo Adding Store Purchase App
echo ============================================================
echo.
1>nul 2>nul %PScommand% Add-AppxProvisionedPackage -Online -PackagePath %PurchaseApp% -DependencyPackagePath %DepPurchase% -LicensePath Microsoft.StorePurchaseApp_8wekyb3d8bbwe.xml
%PScommand% Add-AppxPackage -Path %PurchaseApp%
)
if defined AppInstaller (
echo.
echo ============================================================
echo Adding App Installer
echo ============================================================
echo.
1>nul 2>nul %PScommand% Add-AppxProvisionedPackage -Online -PackagePath %AppInstaller% -DependencyPackagePath %DepInstaller% -LicensePath Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.xml
%PScommand% Add-AppxPackage -Path %AppInstaller%
)
if defined XboxIdentity (
echo.
echo ============================================================
echo Adding Xbox Identity Provider
echo ============================================================
echo.
1>nul 2>nul %PScommand% Add-AppxProvisionedPackage -Online -PackagePath %XboxIdentity% -DependencyPackagePath %DepXbox% -LicensePath Microsoft.XboxIdentityProvider_8wekyb3d8bbwe.xml
%PScommand% Add-AppxPackage -Path %XboxIdentity%
)

for /f "tokens=6 delims=[]. " %%G in ('ver') do if %%G geq 22000 goto wt
:wtchoice
set "choice="
set /p choice="Do you want to install Windows Terminal?(Y/N): "
set choice=%choice:~0,1%
if /i "%choice%"=="Y" (
    goto wt
) else if /i "%choice%"=="N" (
    goto calcchoice
) else (
    goto wtchoice
)

:wt
for /f %%i in ('dir /b Microsoft.WindowsTerminal_*_8wekyb3d8bbwe.msixbundle_Windows10_PreinstallKit 2^>nul') do set "WTDIR=%%i"
for /f %%i in ('dir /b %WTDIR%\*.msixbundle 2^>nul') do set "WTFILE=%%i"
for /f %%i in ('dir /b %WTDIR%\*.xml 2^>nul') do set "WTLICFILE=%%i"

set WT=%WTDIR%\%WTFILE%
set WTLIC=%WTDIR%\%WTLICFILE%

echo.
echo ============================================================
echo Adding Windows Terminal
echo ============================================================
echo.
1>nul 2>nul %PScommand% Add-AppxProvisionedPackage -Online -PackagePath %WT% -LicensePath %WTLIC%
%PScommand% Add-AppxPackage -Path %WT%

:calcchoice
set "choice="
set /p choice="Do you want to install UWP Calculator?(Y/N): "
set choice=%choice:~0,1%
if /i "%choice%"=="Y" (
    goto calc
) else if /i "%choice%"=="N" (
    goto w11only
) else (
    goto calcchoice
)

:calc
for /f %%i in ('dir /b *WindowsCalculator*.Msixbundle 2^>nul') do set "Calc=%%i"
echo.
echo ============================================================
echo Adding UWP Calculator
echo ============================================================
echo.
1>nul 2>nul %PScommand% Add-AppxProvisionedPackage -Online -PackagePath %Calc% -SkipLicense
%PScommand% Add-AppxPackage -Path %Calc%

:w11only
for /f "tokens=6 delims=[]. " %%G in ('ver') do if %%G lss 22000 goto :fin
echo.
echo ============================================================
echo Adding APP Runtime 1.5
echo ============================================================
echo.
if /i %arch%==a64 (
1>nul 2>nul %PScommand% Add-AppxProvisionedPackage -Online -PackagePath %RT15A64% -SkipLicense
%PScommand% Add-AppxPackage -Path %RT15A64%
)
1>nul 2>nul %PScommand% Add-AppxProvisionedPackage -Online -PackagePath %RT15X64% -SkipLicense
%PScommand% Add-AppxPackage -Path %RT15X64%
1>nul 2>nul %PScommand% Add-AppxProvisionedPackage -Online -PackagePath %RT15X86% -SkipLicense
%PScommand% Add-AppxPackage -Path %RT15X86%

:paintchoice
set "choice="
set /p choice="Do you want to install UWP Paint?(Y/N): "
set choice=%choice:~0,1%
if /i "%choice%"=="Y" (
    goto paint
) else if /i "%choice%"=="N" (
    goto snipchoice
) else (
    goto paintchoice
)

:paint
for /f %%i in ('dir /b *Paint*.Msixbundle 2^>nul') do set "Paint=%%i"
echo.
echo ============================================================
echo Adding UWP Paint
echo ============================================================
echo.
1>nul 2>nul %PScommand% Add-AppxProvisionedPackage -Online -PackagePath %Paint% -SkipLicense
%PScommand% Add-AppxPackage -Path %Paint%

:snipchoice
set "choice="
set /p choice="Do you want to install UWP Snipping tool?(Y/N): "
set choice=%choice:~0,1%
if /i "%choice%"=="Y" (
    goto snip
) else if /i "%choice%"=="N" (
    goto notepadchoice
) else (
    goto snipchoice
)

:snip
for /f %%i in ('dir /b *ScreenSketch*.Msixbundle 2^>nul') do set "Snip=%%i"
echo.
echo ============================================================
echo Adding UWP Snipping tool
echo ============================================================
echo.
1>nul 2>nul %PScommand% Add-AppxProvisionedPackage -Online -PackagePath %Snip% -SkipLicense
%PScommand% Add-AppxPackage -Path %Snip%

:notepadchoice
set "choice="
set /p choice="Do you want to install UWP Notepad?(Y/N): "
set choice=%choice:~0,1%
if /i "%choice%"=="Y" (
    goto notepad
) else if /i "%choice%"=="N" (
    goto fin
) else (
    goto notepadchoice
)

:notepad
for /f %%i in ('dir /b *WindowsNotepad*.Msixbundle 2^>nul') do set "Notepad=%%i"
echo.
echo ============================================================
echo Adding UWP Notepad
echo ============================================================
echo.
1>nul 2>nul %PScommand% Add-AppxProvisionedPackage -Online -PackagePath %Notepad% -SkipLicense
%PScommand% Add-AppxPackage -Path %Notepad%

goto :fin
:uac
echo.
echo ============================================================
echo Error: Run the script as administrator
echo ============================================================
echo.
echo.
echo Press any key to Exit
pause >nul
exit

:nofiles
echo.
echo ============================================================
echo Error: Required files are missing in the current directory
echo ============================================================
echo.
echo.
echo Press any key to Exit
pause >nul
exit

:version
echo.
echo ============================================================
echo Error: This script is only for LTSC 2021 and later
echo ============================================================
echo.
echo.
echo Press any key to Exit
pause >nul
exit

:fin
echo.
echo ============================================================
echo Done
echo ============================================================
echo.
echo Press any Key to Exit.
pause >nul
exit
