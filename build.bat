@echo off
chcp 65001 >nul
echo [1/3] Maven clean package...
call mvn clean package || (echo BUILD FAILED & exit /b 1)

echo [2/3] jpackage...
call mvn jpackage:jpackage || (echo JPACKAGE FAILED & exit /b 1)

echo [3/3] Copy drivers...
mkdir target\jpackage-output\sql-tool\drivers 2>nul
copy /Y "D:\develop\repository\com\h2database\h2\2.2.224\h2-2.2.224.jar" target\jpackage-output\sql-tool\drivers\ >nul
copy /Y "D:\develop\repository\com\mysql\mysql-connector-j\8.0.33\mysql-connector-j-8.0.33.jar" target\jpackage-output\sql-tool\drivers\ >nul
copy /Y "D:\develop\repository\org\postgresql\postgresql\42.6.0\postgresql-42.6.0.jar" target\jpackage-output\sql-tool\drivers\ >nul
echo Drivers copied successfully.

echo.
echo Done! Output: target\jpackage-output\sql-tool\
