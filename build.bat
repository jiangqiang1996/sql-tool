@echo off
chcp 65001 >nul
echo [1/4] Maven clean package...
call mvn clean package || (echo BUILD FAILED & exit /b 1)

echo [2/4] jpackage...
call mvn jpackage:jpackage || (echo JPACKAGE FAILED & exit /b 1)

echo [3/4] Copy drivers README...
robocopy src\main\resources\drivers target\jpackage-output\sql-tool\drivers /e
echo README copied successfully.

echo [4/4] Copy to skills directory...
robocopy  target\jpackage-output\sql-tool .opencode\skills\sql-tool\script /e
echo Copied to .opencode\skills\sql-tool\ successfully.

echo.
echo Done! Output: target\jpackage-output\sql-tool\