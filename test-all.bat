@echo off
chcp 65001 >nul
setlocal

echo ============================================================
echo  SQL Tool - Full Database Test Suite
echo ============================================================
echo.

echo [H2] Starting H2 tests...
echo.
call test-h2.bat
echo.
echo [H2] H2 tests finished.
echo.
echo ============================================================
echo.

echo [MySQL] Starting MySQL tests...
echo.
call test-mysql.bat
echo.
echo [MySQL] MySQL tests finished.
echo.
echo ============================================================
echo.

echo [PostgreSQL] Starting PostgreSQL tests...
echo.
call test-postgres.bat
echo.
echo [PostgreSQL] PostgreSQL tests finished.
echo.
echo ============================================================
echo  ALL TESTS COMPLETE
echo ============================================================
endlocal
