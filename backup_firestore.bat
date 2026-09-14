@echo off
echo ========================================================
echo   Oggauer Gemeindetrommler - Firestore Backup Tool
echo ========================================================
echo.
node scripts\backup_firestore.js
echo.
echo Backup abgeschlossen. Taste druecken zum Schliessen...
pause >nul
