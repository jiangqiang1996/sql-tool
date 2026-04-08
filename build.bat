@echo off
chcp 65001 >nul
echo [1/5] Maven clean package...
call mvn clean package || (echo BUILD FAILED & exit /b 1)

echo [2/5] jpackage...
call mvn jpackage:jpackage || (echo JPACKAGE FAILED & exit /b 1)

echo [3/5] Strip unnecessary runtime files...
del /q "target\jpackage-output\sql-tool\runtime\lib\jvm.lib" 2>nul
del /q "target\jpackage-output\sql-tool\runtime\lib\security\public_suffix_list.dat" 2>nul
rmdir /s /q "target\jpackage-output\sql-tool\runtime\legal" 2>nul
REM NOTE: Do NOT delete conf\security\policy — JCE crypto (used by PostgreSQL SCRAM auth) requires it
echo Stripped runtime files.

echo [4/5] Copy drivers README...
robocopy src\main\resources\drivers target\jpackage-output\sql-tool\drivers /e
echo README copied successfully.

echo [5/5] Copy to skills directory...
robocopy /purge target\jpackage-output\sql-tool .opencode\skills\sql-tool\script /e
echo Copied to .opencode\skills\sql-tool\ successfully.

echo.
echo Done! Output: target\jpackage-output\sql-tool\