@echo off

set currentdir=%~dp0

if not exist "%systemdrive%\Monitor" (
    mkdir %systemdrive%\Monitor
)

if not exist "%systemdrive%\output" (
    mkdir %systemdrive%\output
)

if exist "%currentdir%\app.exe" (
    copy /y %currentdir%\app.exe %systemdrive%\Monitor\
    copy /y %currentdir%\startup.cmd %systemdrive%\Monitor\
    copy /y %currentdir%\uninstall.cmd %systemdrive%\Monitor\
    REG ADD "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /V "Demo App" /t REG_SZ /F /D "%systemdrive%\Monitor\startup.cmd"
)

echo "installation complete"
