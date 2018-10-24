@echo off
if exist "%systemdrive%\Monitor" (
    rmdir /q /s %systemdrive%\Monitor
)

if exist "%systemdrive%\output" (
    rmdir /q /s %systemdrive%\output
)

echo "uninstallation complete"
