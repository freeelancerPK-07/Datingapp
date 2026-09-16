@echo off
echo Creating MySQL database 'trylo' on localhost:3307...
echo.

REM Try common MySQL installation paths
set MYSQL_PATH=""

if exist "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" set MYSQL_PATH="C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"
if exist "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" set MYSQL_PATH="C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"
if exist "C:\Program Files (x86)\MySQL\MySQL Server 8.0\bin\mysql.exe" set MYSQL_PATH="C:\Program Files (x86)\MySQL\MySQL Server 8.0\bin\mysql.exe"
if exist "C:\xampp\mysql\bin\mysql.exe" set MYSQL_PATH="C:\xampp\mysql\bin\mysql.exe"
if exist "C:\wamp64\bin\mysql\mysql8.0.31\bin\mysql.exe" set MYSQL_PATH="C:\wamp64\bin\mysql\mysql8.0.31\bin\mysql.exe"

if "%MYSQL_PATH%"=="" (
    echo ERROR: mysql.exe not found in common locations.
    echo Please run manually:
    echo   mysql -h localhost -P 3307 -u root -ppassword < database_setup.sql
    pause
    exit /b 1
)

echo Using: %MYSQL_PATH%
%MYSQL_PATH% -h localhost -P 3307 -u root -ppassword < database_setup.sql

if %ERRORLEVEL% EQU 0 (
    echo.
    echo SUCCESS: Database 'trylo' and table 'users' created!
) else (
    echo.
    echo ERROR: Failed to create database. Check if MySQL is running on port 3307.
)

pause