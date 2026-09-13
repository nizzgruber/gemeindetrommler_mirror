@echo off
setlocal enabledelayedexpansion

echo ========================================================
echo   Oggauer Gemeindetrommler - Android APK Builder
echo ========================================================
echo.

set FLUTTER=C:\src\flutter\bin\flutter.bat
if not exist "%FLUTTER%" (
    set FLUTTER=flutter
)

echo [1/4] Dependencies laden...
call %FLUTTER% pub get
if %ERRORLEVEL% NEQ 0 (
    echo [FEHLER] 'flutter pub get' fehlgeschlagen.
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo [2/4] Universelle Release APK bauen...
call %FLUTTER% build apk --release
if %ERRORLEVEL% NEQ 0 (
    echo [FEHLER] 'flutter build apk --release' fehlgeschlagen.
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo [3/4] Split-per-ABI APKs bauen (fuer schlankere Downloads)...
call %FLUTTER% build apk --release --split-per-abi

echo.
echo [4/4] APKs organisieren...
if not exist "release-apks" mkdir "release-apks"

if exist "build\app\outputs\flutter-apk\app-release.apk" (
    copy /Y "build\app\outputs\flutter-apk\app-release.apk" "release-apks\oggauer-gemeindetrommler-universal.apk" >nul
)
if exist "build\app\outputs\flutter-apk\app-arm64-v8a-release.apk" (
    copy /Y "build\app\outputs\flutter-apk\app-arm64-v8a-release.apk" "release-apks\oggauer-gemeindetrommler-arm64.apk" >nul
)
if exist "build\app\outputs\flutter-apk\app-armeabi-v7a-release.apk" (
    copy /Y "build\app\outputs\flutter-apk\app-armeabi-v7a-release.apk" "release-apks\oggauer-gemeindetrommler-armv7.apk" >nul
)
if exist "build\app\outputs\flutter-apk\app-x86_64-release.apk" (
    copy /Y "build\app\outputs\flutter-apk\app-x86_64-release.apk" "release-apks\oggauer-gemeindetrommler-x86_64.apk" >nul
)

echo.
echo ========================================================
echo   ERFOLG! Alle APKs befinden sich im Ordner:
echo   %CD%\release-apks\
echo ========================================================
echo.
explorer release-apks
pause
