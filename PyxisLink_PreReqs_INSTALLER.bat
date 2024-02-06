@ECHO off
mode con:cols=106 lines=35
::Built by Caleb Mortensen
title CareFusion - PyxisLink Pre-Reqs _ Built 9/28/15 - Validated on 2008/R2-2012/R2
:: Installs in the following order
:: 1. Mongo (3.0.4)
:: 2. ERlang OTP 18 (7.0)
:: 3. Microsoft Visual C++ 2010 x64 Redistributable - 10.0.30319 (Installed by Erlang OTP installer ONLY IF THERE IS NO PRE-EXISTING VERSION)
:: 4. RabbitMQ (3.5.3)
:: 5. IISURLRewriteModule2 
:: 6. NodeJS
:: 7. IISNodeforiis7xfull
:: 8. Windows6.1-KB2731284-v3-x64.msu (HOTFIX for MONGO - will Zero-Out Data Files -2008 Server ONLY)
:: 9. Microsoft Web Platform Installer 3.0 (3.0.5)
:: 10. Microsoft Web Deploy 2.0 (2.0.1070)
:: 11. Microsoft Web Farm Framework Version 2.2 (2.2.1341)
:: 12. Microsoft External Cache Version 1 for IIS 7 (1.1.0490) (2008 Server ONLY)
:: 13. Microsoft Application Request Routing 3.0 (3.0.1750)
:: 14. Enable WebSocket Protocol ROLE (2012 Server ONLY)
:: 15. Windows6.0-KB2506146-x64.msu - Windows Management Framework 3.0 (Support for PowerShell - 2008 Server SP2 ONLY)
:: 16. Windows6.1-KB2819745-x64-MultiPkg.msu - Windows Management Framework 4.0 (Support for PowerShell - 2008R2 Server SP1 ONLY)
:: 17. iis7psprov_x64.msi - PowerShell WEb Administration Module (2008 Server ONLY)
:: 18. CareFusionServicesSSL.PFX Certificate
 
setlocal enableDelayedExpansion

Echo.WELCOME TO THE CAREFUSION PYXISLINK PREREQS INSTALLER
Echo.
Echo ********************************************************************************************
Echo Note 1: MongoDB requires 1 Gigabyte of free space for INSTALLATION on the selected partition
Echo Note 2: MongoDB requires 3 Gigabytes of free space for the SERVICE on the selected partition
Echo               = Total of 4 Gigabytes of free space REQUIRED
Echo ********************************************************************************************
Echo.

wmic OS get Caption,CSDVersion,OSArchitecture,Version

::Echo Note: MongoDB Service will not start unless at least 4 GigaBytes are free on the installation partition
::Echo       and other install dependencies will FAIL as a result

::ECHO.
wmic logicaldisk where drivetype=3 get name,Freespace
ECHO.

:: The Choice variable will contain the user selected drive letter, upper or lower case
:choice
SET /P choice=Select drive letter where MongoDB will install (one letter only, a-z):
if not "%choice:~1,1%"=="" goto choice
if "%choice%" lss "A" goto choice
if "%choice%" gtr "Z" goto choice
if NOT EXIST "%choice%": echo.PLEASE CHOOSE A DIFFERENT DRIVE LETTER && goto choice

set drive=%choice%

:: n1 <MIN SIZE REQUIRED is 4 gig>
set n1=4000000000
::echo %n1% (THIS IS HOW MUCH SPACE IS REQUIRED)

for /f "skip=1" %%a in ('wmic logicaldisk where "DeviceID='%choice%:'" get FreeSpace') do if not defined var set var=%%a
::echo %var% (THIS IS HOW MUCH SPACE IS AVAILABLE)
echo.
set n2=%var%

call :padNum n1
:padNum
setlocal enableDelayedExpansion
set "n=000000000000000!%~1!"
set "n=!n:~-15!"
endlocal & set "%~1=%n%"

call :padNum2 n2
:padNum2
setlocal enableDelayedExpansion
set "n=000000000000000!%~1!"
set "n=!n:~-15!"
endlocal & set "%~1=%n%"

::echo.%n1%
::echo.%n2%

if "%n2%" LSS "%n1%" echo SERVICE REQUIRES A MINIMUM OF 4 GigaBytes. Please free up some space on %choice%: && pause && goto :exit
if "%n2%" EQU "%n1%" echo SERVICE REQUIRES A MINIMUM OF 4 GigaBytes. Please free up some space on %choice%: && pause && goto :exit
if "%n2%" GTR "%n1%" goto :next

:: If this is an UPGRADE, stopping and removing service and directories (without prompting)
:next
net stop MongoDB >nul 2>nul
%choice%:\mongodb\bin\mongod.exe --remove >nul 2>nul
sc delete MongoDB >nul 2>nul
:: ADDED MSI Uninstall SCRIPTS 18SEPT2015
::For Mongo 2008 (2008 Server considered Legacy)
::MsiExec.exe /x {0CB0B0A7-9A8B-4669-B5C0-A727C429D014} /qb /log "%temp%\Mongo_Uninstall.log" >nul 2>nul
::MongoPlus
::MsiExec.exe /x {25A8BD90-DD6F-4626-9BDB-DF85A881A99A} /qb /log "%temp%\Mongo_Uninstall.log" >nul 2>nul
RMDIR %choice%:\mongodb /s /q >nul 2>nul

:: Beginning of Installation
echo.
echo Making Directories %choice%:\mongodb\data\db
echo.
ping localhost -n 3 >nul
md %choice%:\mongodb\data\db

echo.
echo Making Directories %choice%:\mongodb\log
echo.
ping localhost -n 3 >nul
md %choice%:\mongodb\log

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: 31OCTOBER2014 - ADDED OS VERSION CHECK for 2008 and R2
:: 04DECEMBER2014 - ADDED OS VERSION CHECK for 2012R2
set ver=Unknown

::systeminfo | findstr /B /C:"OS Version" >nul 2>nul
wmic OS get Version >nul 2>nul

:2008check
ver | find "6.0.6002" >nul 2>nul
if %ERRORLEVEL% == 0 set ver= 2008 && goto StandardMongo
if %ERRORLEVEL% == 1 goto 2008R2check

:2008R2check
ver | find "6.1.7601" >nul 2>nul
if %ERRORLEVEL% == 0 set ver=2008R2 && goto PlusMongo
if %ERRORLEVEL% == 1 goto 2012check

:2012check
ver | find "6.2.9200" >nul 2>nul
if %ERRORLEVEL% == 0 set ver= 2012 && goto PlusMongo
if %ERRORLEVEL% == 1 goto 2012R2check

:2012R2check
ver | find "6.3.9600" >nul 2>nul
if %ERRORLEVEL% == 0 set ver= 2012R2 && goto PlusMongo
if %ERRORLEVEL% == 1 goto UnSupportedOS

:StandardMongo
goto mongodb-win32-x86_64

:PlusMongo 
goto mongodb-win32-x86_64-2008plus

:UnSupportedOS
echo This is an NOT a supported Operating System && Pause && Exit

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

echo.
echo XCopy contents from this Mongo Install folder to %choice%:\mongodb
echo.
ping localhost -n 3 >nul

:: Note - This is the path for Mongo x64 2008R2
:mongodb-win32-x86_64-2008plus
xcopy /E /H /C /I /K /Y .\mongodb-win32-x86_64-2008plus\*.* %choice%:\mongodb\ >nul 2>nul

:: Note - This is the path for Mongo x64 2008 Standard
:mongodb-win32-x86_64
xcopy /E /H /C /I /K /Y .\mongodb-win32-x86_64\*.* %choice%:\mongodb\ >nul 2>nul


:: 20MAY2014 - added " " around logpath AND added dbpath to config
:: 11AUG2014 - Made Auth False and will Enable after service stop and start

:: 20MAY2014 - " --dbpath %choice%:\mongodb\data\db" has been added to Config and removed from Service Create
:: 19MAY2014 - Changed Service Script for Mongo 2.6.3 below for 2008R2
:: 11AUG2014 - Changed Service Script for Mongo 2.6.4 below for 2008R2
:: 30MARCH2015 - Changed Service Script for Mongo 3.0.1 below for 2008R2
:: 28APRIL2015 - Changed Service Script for Mongo 3.0.2 below for 2008R2
:: 18MAY2015 - Changed Service Script for Mongo 3.0.3 below for 2008R2

echo.
echo Creating Mongod config file (Remote Authentication DISABLED)
echo.
ping localhost -n 3 >nul

echo logpath=%choice%:\mongodb\log\mongo.log > "%choice%:\mongodb\mongod.cfg"
echo dbpath=%choice%:\mongodb\data\db>> "%choice%:\mongodb\mongod.cfg"
echo auth=false >> "%choice%:\mongodb\mongod.cfg"

echo.
echo Creating MongoDB service
echo.
ping localhost -n 3 >nul

sc.exe create MongoDB binPath= "\"%choice%:\mongodb\bin\mongod.exe\" --service --config=\"%choice%:\mongodb\mongod.cfg\"" DisplayName= "MongoDB 3.0.4" start= "auto" >nul 2>nul

:: Check if service was installed
:MongoServiceQuery
sc query MongoDB > NUL
IF ERRORLEVEL 1060 GOTO ServiceMissing

:: NOTE: System error 1067 has occured. (Occurs if there is NOT 4 GB free on installation drive and service cannot start)

:: STARTING SERVICE
net start MongoDB >nul 2>nul
for /F "tokens=3 delims=: " %%H in ('sc query "MongoDB" ^| findstr "        STATE"') do (if /I "%%H" NEQ "RUNNING" (
   Echo THE MongoDB SERVICE COULD NOT BE STARTED
   Echo.
   Echo PLEASE CHECK %choice%:\ DRIVE 
   Echo MINIMUM OF 4 GB OF FREE SPACE REQUIRED TO RUN SERVICE
   Echo CHECK AND RETRY INSTALLATION SCRIPT && Pause && Exit
  )
)

:: 08AUGUST2014 - Created a wait time of 10 seconds to allow local.0 and local.ns db build
Echo.
ECHO Service building local.0 and local.ns
ping localhost -n 10 >nul

:: The following should be created upon initial start of MongoDB
:: _tmp, Journal, local.0, local.ns, Mongod.lock
IF EXIST %choice%:\mongodb\data\db\local.ns GOTO Continue
IF NOT EXIST %choice%:\mongodb\data\db\local.ns GOTO Retry

:Retry
net stop MongoDB
net start MongoDB

IF NOT EXIST %choice%:\mongodb\data\db\local.ns ECHO FAILED DEFAULT DB INSTALLATION && Pause && Exit

:: 20MAY2014 - ExTENDED ping to 10 after Mongo DATABASE and cfnmongo Account file created
:: ADDING "pyxislink-api-cache" Mongo DATABASE and User Account in Java Script file

:Continue
echo.
echo Adding pyxislink-api-cache Mongo DATABASE and cfnmongo SERVICE ACCOUNT
Start "Mongo.exe" /wait "%choice%:\mongodb\bin\mongo.exe" ".\AddCFNMongoAccount.js"
ping localhost -n 5 >nul

::11AUG2014 Stopping Service after Pyxislink DB creation plus delete mongo cfg and also creating new one with auth TRUE


:: IN %choice%:\mongodb\data\db - pyxislink-api-cache.0, pyxislink-api-cache.1, pyxislink-api-cache.ns are created
IF EXIST %choice%:\mongodb\data\db\pyxislink-api-cache.ns GOTO AuthEnabled
IF NOT EXIST %choice%:\mongodb\data\db\pyxislink-api-cache.ns GOTO FailedDBCreation1


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:FailedDBCreation1
Echo FAILED TO BUILD %choice%:\mongodb\data\db\pyxislink-api-cache.ns && Pause && Exit


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: 31March2015
:: The following deletes the Auth Disabled Config file and replaces it with Auth Enabled Config file

:AuthEnabled

:: STOP Mongod Service
net stop MongoDB >nul 2>nul

echo.
echo Creating Mongod config file (Remote Authentication ENABLED)
echo.
:: Delete old Mongod Config
del /F /Q "%choice%:\mongodb\mongod.cfg"

echo logpath=%choice%:\mongodb\log\mongo.log > "%choice%:\mongodb\mongod.cfg"
echo dbpath=%choice%:\mongodb\data\db>> "%choice%:\mongodb\mongod.cfg"
echo auth=true >> "%choice%:\mongodb\mongod.cfg"

:: START Mongod Service
net start MongoDB >nul 2>nul

GOTO VerifyIISRoleRegPath

:VerifyIISRoleRegPath
echo.
echo --Checking ROLE: Web Server (IIS) Registry Path--
reg query HKEY_LOCAL_MACHINE\Software\Microsoft\InetStp\ /v PathWWWRoot >nul 2>nul
if !ERRORLEVEL! EQU 0 (goto EXEinstalls )
if !ERRORLEVEL! EQU 1 (goto IISinstall)

:IISinstall
echo.
echo In order for the following to be installed: IISURLRewriteModule2, NodeJS, and IISNodeforiis7xfull
echo PLEASE INSTALL THE PREREQUISITE WEB SERVER (IIS) ROLE AND RERUN MongoInstaller.bat && Pause && Exit
ping localhost -n 5 >nul

:: Script to Install IIS Role on 2008R2 - http://technet.microsoft.com/en-us/library/cc771209.aspx

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: UPDATED EXEinstalls on 10/02/14

:: NOTE - Order of precedence - Uninstall of BOTH RabbitMQ AND Erlang occurs first, then proceeeds to Install both

:EXEinstalls
echo.
echo BEGINNING INSTALLATION OF 2 EXE INSTALLERS (Erlang OTP and RabbitMQ)
echo.
echo NOTE: Erlang installer will also install (Microsoft Visual C++ 2010 x64 Redistributable - 10.0.30319)
echo.

:RabbitMQUninstall
echo.
echo.RabbitMQ Server
net stop RabbitMQ >nul 2>nul
taskkill /F /IM epmd.exe >nul 2>nul
sc delete RabbitMQ >nul 2>nul
"%systemdrive%\Program Files (x86)\RabbitMQ Server\Uninstall.exe" /S >nul 2>nul
RMDIR "%systemdrive%\Program Files (x86)\RabbitMQ Server" /s /q >nul 2>nul
RMDIR "%systemdrive%\Users\%USERNAME%\AppData\Roaming\RabbitMQ" /s /q >nul 2>nul
Echo.Uninstall of RabbitMQ COMPLETE && time /t

:: DELETE REGISTRY ENTRIES

REG DELETE HKEY_LOCAL_MACHINE\SOFTWARE\Ericsson\Erlang\ErlSrv\1.1\RabbitMQ /v Args /F >nul 2>nul
REG DELETE HKEY_LOCAL_MACHINE\SOFTWARE\Ericsson\Erlang\ErlSrv\1.1\RabbitMQ /v Comment /F >nul 2>nul
REG DELETE HKEY_LOCAL_MACHINE\SOFTWARE\Ericsson\Erlang\ErlSrv\1.1\RabbitMQ /v Machine /F >nul 2>nul
REG DELETE HKEY_LOCAL_MACHINE\SOFTWARE\Ericsson\Erlang\ErlSrv\1.1\RabbitMQ /v DebugType /F >nul 2>nul
REG DELETE HKEY_LOCAL_MACHINE\SOFTWARE\Ericsson\Erlang\ErlSrv\1.1\RabbitMQ /v Env /F >nul 2>nul
REG DELETE HKEY_LOCAL_MACHINE\SOFTWARE\Ericsson\Erlang\ErlSrv\1.1\RabbitMQ /v InternalServiceName /F >nul 2>nul
REG DELETE HKEY_LOCAL_MACHINE\SOFTWARE\Ericsson\Erlang\ErlSrv\1.1\RabbitMQ /v Name /F >nul 2>nul
REG DELETE HKEY_LOCAL_MACHINE\SOFTWARE\Ericsson\Erlang\ErlSrv\1.1\RabbitMQ /v OnFail /F >nul 2>nul
REG DELETE HKEY_LOCAL_MACHINE\SOFTWARE\Ericsson\Erlang\ErlSrv\1.1\RabbitMQ /v Priority /F >nul 2>nul
REG DELETE HKEY_LOCAL_MACHINE\SOFTWARE\Ericsson\Erlang\ErlSrv\1.1\RabbitMQ /v SName /F >nul 2>nul
REG DELETE HKEY_LOCAL_MACHINE\SOFTWARE\Ericsson\Erlang\ErlSrv\1.1\RabbitMQ /v StopAction /F >nul 2>nul
REG DELETE HKEY_LOCAL_MACHINE\SOFTWARE\Ericsson\Erlang\ErlSrv\1.1\RabbitMQ /v WorkDir /F >nul 2>nul && ping localhost -n 10 >nul && goto ErlangUninstall

:: 29JUNE2015 - NEW REGISTRY PATH for ERLANG OTP 18 (7.0) - The native uninstall will delete the Registry Entry
:: HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Erlang\7.0

:: 14JAN2015 - ADDED STOP AND START OF RSSEventAgent and CFNEventForwarding (Deprecated)

:ErlangUninstall
echo.
echo.Erlang OTP

net stop RSSEventAgent >nul 2>nul
net stop CFNEventForwarding >nul 2>nul

taskkill /F /IM epmd.exe >nul 2>nul
taskkill /F /IM erl.exe >nul 2>nul

"%systemdrive%\Program Files\erl6.0\Uninstall.exe" /S >nul 2>nul
"%systemdrive%\Program Files\erl6.1\Uninstall.exe" /S >nul 2>nul
"%systemdrive%\Program Files\erl6.2\Uninstall.exe" /S >nul 2>nul
"%systemdrive%\Program Files\erl6.3\Uninstall.exe" /S >nul 2>nul
"%systemdrive%\Program Files\erl6.4\Uninstall.exe" /S >nul 2>nul
"%systemdrive%\Program Files\erl7.0\Uninstall.exe" /S >nul 2>nul


RMDIR "%systemdrive%\Program Files\erl6.0" /s /q >nul 2>nul
RMDIR "%systemdrive%\Program Files\erl6.1" /s /q >nul 2>nul
RMDIR "%systemdrive%\Program Files\erl6.2" /s /q >nul 2>nul
RMDIR "%systemdrive%\Program Files\erl6.3" /s /q >nul 2>nul
RMDIR "%systemdrive%\Program Files\erl6.4" /s /q >nul 2>nul
RMDIR "%systemdrive%\Program Files\erl7.0" /s /q >nul 2>nul

ping localhost -n 5 >nul

net start RSSEventAgent >nul 2>nul
net start CFNEventForwarding >nul 2>nul

Echo.Uninstall of Erlang OTP COMPLETE && time /t && echo. && goto ErlangInstall18X

:ErlangInstall18X
echo.
echo Erlang OTP is NOT Installed. Beginning SILENT Installation - This may take a few minutes
time /t
start /wait .\otp_win64_18.0.exe /w /S
:: NOTE Installer Adds SYSTEM VARIABLE for ERLANG -"%systemdrive%\Program Files\erl6.4" /M
echo Erlang Installation COMPLETE. Proceeding to next installation
goto RabbitMQNOTInstalled

:RabbitMQNOTInstalled
echo.
echo RabbitMQ is NOT INSTALLED. Beginning Installation of NEW BUILD
time /t
start /wait .\rabbitmq-server-3.5.3.exe /w /S
echo Proceeding to check status of service

:: Check RabbitMQ Service is RUNNING
ping localhost -n 5 >nul 2>nul
net start RabbitMQ >nul 2>nul
ping localhost -n 5 >nul 2>nul
for /F "tokens=3 delims=: " %%H in ('sc query "RabbitMQ" ^| findstr "        STATE"') do (if /I "%%H" NEQ "RUNNING" (
   Echo THE RabbitMQ SERVICE COULD NOT BE STARTED - Please execute the MongoUninstaller.bat and rerun Installation && Pause && Exit
  )
)


:: Built the Copy and Delete below 08/25/14
:: Silently performed BEFORE MSI Installs
:: NOTE - %SystemDrive:\Users\%UserName%\AppData\Roaming\RabbitMQ is NOT DELETED upon UNINSTALL and contains CONFIG files

:CopyRabbitMQFiles

xcopy /y /c /k ".\RabbitMQ Management Dashboard.url" "%SystemDrive%\Program Files (x86)\RabbitMQ Server" >nul 2>nul
xcopy /y /c /k ".\rabbitmqctl.bat" "%SystemDrive%\Program Files (x86)\RabbitMQ Server\rabbitmq_server-3.5.3\sbin" >nul 2>nul
xcopy /y /c /k ".\rabbitmq-plugins.bat" "%SystemDrive%\Program Files (x86)\RabbitMQ Server\rabbitmq_server-3.5.3\sbin" >nul 2>nul
xcopy /y /c /k ".\rabbitmq-server.bat" "%SystemDrive%\Program Files (x86)\RabbitMQ Server\rabbitmq_server-3.5.3\sbin" >nul 2>nul
xcopy /y /c /k ".\rabbitmq-service.bat" "%SystemDrive%\Program Files (x86)\RabbitMQ Server\rabbitmq_server-3.5.3\sbin" >nul 2>nul

del /F /Q %choice%:\mongodb\"RabbitMQ Management Dashboard.url" >nul 2>nul
del /F /Q %choice%:\mongodb\rabbitmqctl.bat >nul 2>nul
del /F /Q %choice%:\mongodb\rabbitmq-plugins.bat >nul 2>nul

:: Environmental Variable
:: setx ERLANG_HOME "%systemdrive%\Program Files\erl6.4" /M

:: SUBROUTINE RabbitMQ_Management deletes and installs user accounts

CALL .\RabbitMQ_Management.bat
::CALL %SystemDrive%\Users\%USERNAME%\Desktop\RabbitMQ_Management.bat
::del %SystemDrive%\Users\%USERNAME%\Desktop\RabbitMQ_Management.bat

echo RabbitMQ Installation COMPLETE. Proceeding to next installation

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: MSI INSTALLERS (IISURLRewriteModule2, NodeJS, IISNodeforiis7xfull)

:MSIinstalls
echo.
echo BEGINNING INSTALLATION OF 3 MSI INSTALLERS (IISURLRewriteModule2, NodeJS, IISNodeforiis7xfull)
echo.

:IISURLRewriteModule2
echo.
echo --Checking IIS URL Rewrite Module 2 for REGISTRY KEY--
reg query HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall\{EB675D0A-2C95-405B-BEE8-B42A65D23E11} /v Version >nul 2>nul
if !ERRORLEVEL! EQU 0 (goto IISURLRewriteModule2Installed)
if !ERRORLEVEL! EQU 1 (goto IISURLRewriteModule2NOTInstalled)

 
:IISURLRewriteModule2Installed
echo IIS URL Rewrite Module 2 is already installed. Proceeding to next installation
echo.
goto NodeJS

:IISURLRewriteModule2NOTInstalled
echo IIS URL Rewrite Module 2 is NOT Installed. Proceeding with Installation
msiexec /i rewrite_2.0_rtw_x64.msi /log %systemdrive%/iisrewrite.log /passive
echo IIS URL Rewrite Module 2 installation COMPLETE
echo.
goto NodeJS


:NodeJS
echo --Checking Node.js DIRECTORY PATH--
:: Not using Reg Query as Uninstall reference because Registry Entry is NOT removed during Uninstall
::reg query HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall\{60DDC0F7-E419-4230-B787-ECE31B3C550B} /v Version >nul 2>nul

IF EXIST "%systemdrive%\Program Files\nodejs" GOTO NodeJSINstalled >nul 2>nul
IF NOT EXIST "%systemdrive%\Program Files\nodejs" GOTO NodeJSNOTInstalled >nul 2>nul

:NodeJSINstalled
echo Node.js is already installed. Proceeding to next installation
echo.
goto IISNodeforiis7xfull

:NodeJSNOTInstalled
echo Node.js is NOT Installed. Proceeding with installation.
msiexec /i node-v0.10.10-x64.msi /log %systemdrive%/Nodejs.log /passive
echo Node.js installation is COMPLETE
echo.
goto IISNodeforiis7xfull


:IISNodeforiis7xfull
echo --Checking IISNode for iis 7.x(x64) full for REGISTRY KEY--
reg query HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall\{6F74A39F-1AF6-4A97-B987-40DDFBFBDCE4} /v Version >nul 2>nul
if !ERRORLEVEL! EQU 0 (goto IISNodeforiis7xfullINstalled)
if !ERRORLEVEL! EQU 1 (goto IISNodeforiis7xfullNOTInstalled)


:IISNodeforiis7xfullINstalled
echo IISNode for iis 7.x(x64) full is already installed
echo.
goto StopServices


:IISNodeforiis7xfullNOTInstalled
echo IISNode for iis 7.x(x64) full is NOT Installed. Proceeding with installation.
msiexec /i iisnode-full-iis7-v0.2.6-x64.msi /log %systemdrive%/IISNode.log /passive
echo IISNode for iis 7.x(x64) full installation COMPLETE
echo.
goto StopServices

::::::::::::::::::::::::::::::::::::::::::::::::::
:: MOBILE DOCK PREREQS built 08JUNE2015
::::::::::::::::::::::::::::::::::::::::::::::::::

:: Stopping Windows Process Activation Service (WAS)
:: Stops the following services

:: Stops World Wide Web Publishing Service (W3SVC)
:: Stops Net.Tcp Listener Adapter (NetTcpActivator)
:: Stops Net.Pipe Listener Adapter (NetPipeActivator)

:: Web Management Service is STOPPED with additional Script (WMSVC - 2008/R2 ONLY)

:StopServices
net stop was /y

:: Stopping Web Management Service (WMSVC)

:: Note - 2008/R2 ONLY
:StopWMSVC
net stop wmsvc /y >nul 2>nul

:WebPlatformInstaller
reg query HKEY_LOCAL_MACHINE\Software\Microsoft\WebPlatformInstaller\3 /v Version 2>&1 | find "7.1.1070.01" >nul
if !ERRORLEVEL! EQU 0 (goto WebPlatformInstallerInstalled)
if !ERRORLEVEL! EQU 1 (goto WebPlatformInstallerNOTInstalled)

:WebPlatformInstallerInstalled
echo Web Platform Installer 3.0.5 is already installed
goto WebDeployInstaller

:WebPlatformInstallerNOTInstalled
echo Web Platform is NOT installed. Proceeding with installation...
msiexec /i WebPlatformInstaller_3_10_amd64_en-US.msi /log %systemdrive%/WebPlatformInstaller.log /passive >nul
echo WebPlatformInstaller installation COMPLETE
goto WebDeployInstaller

:WebDeployInstaller
reg query HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Installer\Products\A53B4315955B2674494ADF9481799735 /v ProductName 2>&1 | find "Microsoft Web Deploy 2.0" >nul
if !ERRORLEVEL! EQU 0 (goto WebDeployInstallerInstalled)
if !ERRORLEVEL! EQU 1 (goto WebDeployInstallerNOTInstalled)

:WebDeployInstallerInstalled
echo Web Deploy 2.0 is already installed
goto WebFarmInstaller

:WebDeployInstallerNOTInstalled
echo Web Deploy is NOT installed. Proceeding with installation...
msiexec /i WebDeploy_2_10_amd64_en-US.msi /log %systemdrive%/WebDeploy.log /passive >nul 2>nul
echo WebDeploy installation COMPLETE
goto WebFarmInstaller

:WebFarmInstaller
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\IIS Extensions\WebFarm Framework" /v Version 2>&1 | find "7.1.1341.0" >nul
if !ERRORLEVEL! EQU 0 (goto WebFarmInstallerInstalled)
if !ERRORLEVEL! EQU 1 (goto WebFarmInstallerNOTInstalled)

:WebFarmInstallerInstalled
echo Web Farm Framework is already installed
goto IISVersionCHECK08

:WebFarmInstallerNOTInstalled
echo Web Farm is NOT installed. Proceeding with installation...
msiexec /i WebFarm2_x64.msi /log %systemdrive%/WebFarm2_x64.log /passive >nul 2>nul
echo WebFarm installation COMPLETE
goto IISVersionCHECK08

:: This is a IIS check on 2008 Server for Major Version 7
:IISVersionCHECK08
reg query HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\InetStp /v MajorVersion 2>&1 | find "7" >nul
if !ERRORLEVEL! EQU 0 (goto ExternalDiskCacheInstaller08)
if !ERRORLEVEL! EQU 1 (goto IISVersionCHECK12)

:: This is a IIS check on 2012 Server for Major Version 8
:IISVersionCHECK12
reg query HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\InetStp /v MajorVersion 2>&1 | find "8" >nul
if !ERRORLEVEL! EQU 0 (goto RequestRouterInstaller)
if !ERRORLEVEL! EQU 1 (goto UnsupportedIISVersion)

:UnsupportedIISVersion
Echo Unsupported IIS Version && Pause && Exit

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: ONLY 2008 server with IIS7 has an External Disk Cache Installer - currently

:ExternalDiskCacheInstaller08
reg query HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Installer\Products\E65611F4168979A42B42FC2F9996896C /v Version 2>&1 | find "10101ea" >nul
if !ERRORLEVEL! EQU 0 (goto ExternalDiskCacheInstalled08)
if !ERRORLEVEL! EQU 1 (goto ExternalDiskCacheNOTInstalled08)

:ExternalDiskCacheInstalled08
echo Microsoft External Cache Version 1 is already installed
goto RequestRouterInstaller

:ExternalDiskCacheNOTInstalled08
echo External Disk Cache is NOT installed. Proceeding with installation...
msiexec /i ExternalDiskCache_amd64_en-US.msi /norestart /log %systemdrive%/ExternalDiskCache.log /passive >nul 2>nul
echo ExternalDiskCache installation COMPLETE
goto RequestRouterInstaller

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:RequestRouterInstaller
reg query HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Products\2A62DF874129DC84FA17F7331D7A8829\InstallProperties /v DisplayName 2>&1 | find "Microsoft Application Request Routing 3.0" >nul
if !ERRORLEVEL! EQU 0 (goto RequestRouterInstalled)
if !ERRORLEVEL! EQU 1 (goto RequestRouterNOTInstalled)

:RequestRouterInstalled
echo Application Request Routing is already installed
goto SRVRSTR

:RequestRouterNOTInstalled
echo Application Request Routing is NOT installed. Proceeding with installation...
msiexec /i requestRouter_x64.msi /norestart /log %systemdrive%/RequestRouter.log /passive >nul 2>nul
echo RequestRouter installation COMPLETE

:SRVRSTR
:: Starting Windows Process Activation Service (WAS)
echo.
echo Starting Windows Process Activation Service
net start was /y >nul 2>nul

:: Starting World Wide Web Publishing Service (W3SVC)
echo Starting World Wide Web Publishing Service
net start W3SVC >nul 2>nul

:: Starting Web Management Service (WMSVC 2008/R2 ONLY)
net start WMSVC >nul 2>nul

:: Starting Net.Tcp Listener Adapter (NetTcpActivator)
echo Starting Net.Tcp Listener Adapter
net start NetTcpActivator >nul 2>nul

:: Starting Net.Pipe Listener Adapter (NetPipeActivator)
echo Starting Net.Pipe Listener Adapter
net start NetPipeActivator >nul 2>nul
echo.

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:: Hotfix for Mongo 3.0 - Added 06MAY2015 - ONLY APPLICABLE TO 2008R2 Server - NOT 08 and 12

:: Perform 2008R2 Version Check - Added 07MAY2015

:2008R2checkOS
ver | find "6.1.7601" >nul 2>nul
if %ERRORLEVEL% == 0 set ver=2008R2 && goto Windows6.1-KB2731284-v3-x64
if %ERRORLEVEL% == 1 goto WMF

:Windows6.1-KB2731284-v3-x64
@echo off
echo.
for /f %%A in ('dir /b Windows6.1-KB2731284-v3-x64.msu') do (
echo Installing Updates "%%A" ...
start /wait %%A /quiet /norestart > nul
)
echo.
echo Installation of Windows6.1-KB2731284-v3-x64.msu COMPLETE
echo.

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: The following was added 18SEPT2015 - Version check of 2008sp2 (WMF3.0)and 2008R2sp1 (WMF4.0)
:: Note - 2012R2 already is at Version 4

:WMF
wmic OS get Version >nul 2>nul

:WMF32008
ver | find "6.0.6002" >nul 2>nul
if %ERRORLEVEL% == 0 set ver= 2008 && goto CheckWMF3
if %ERRORLEVEL% == 1 goto WMF42008R2

:WMF42008R2
ver | find "6.1.7601" >nul 2>nul
if %ERRORLEVEL% == 0 set ver=2008R2 && goto CheckWMF4
if %ERRORLEVEL% == 1 goto WSPcheck

:CheckWMF3
reg query HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PowerShell\3\PowerShellEngine /v PowerShellVersion 2>&1 | find "3.0" >nul
if !ERRORLEVEL! EQU 0 (goto WSPcheck)
if !ERRORLEVEL! EQU 1 (goto InstallWMF3)

:CheckWMF4
reg query HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PowerShell\3\PowerShellEngine /v PowerShellVersion 2>&1 | find "4.0" >nul
if !ERRORLEVEL! EQU 0 (goto WSPcheck)
if !ERRORLEVEL! EQU 1 (goto InstallWMF4)

:InstallWMF3
@echo off
echo.
for /f %%A in ('dir /b Windows6.0-KB2506146-x64.msu') do (
echo Installing Updates "%%A" ...
start /wait %%A /quiet /norestart > nul
)
echo.
echo Installation of Windows6.0-KB2506146-x64.msu COMPLETE && goto 2008STDCheck

:InstallWMF4

echo.
for /f %%A in ('dir /b Windows6.1-KB2819745-x64-MultiPkg.msu') do (
echo Installing Updates "%%A" ...
start /wait %%A /quiet /norestart > nul
)
echo.
echo Installation of Windows6.1-KB2819745-x64-MultiPkg.msu COMPLETE && goto 2008STDCheck


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Powershell Web Administration (2008 Server ONLY)


:2008STDCheck
wmic OS get Version >nul 2>nul
ver | find "6.0.6002" >nul 2>nul
if %ERRORLEVEL% == 0 set ver= 2008 && goto PWACheck
if %ERRORLEVEL% == 1 goto WSPcheck


:PWACheck
reg query HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Installer\Products\2CB755C34CF93924E9636F5F70E9E3C0 /v ProductName 2>&1 | find "Microsoft Windows PowerShell snap-in for IIS 7.0" >nul
if !ERRORLEVEL! EQU 0 (goto WPScheck)
if !ERRORLEVEL! EQU 1 (goto PWAInstall)


:PWAInstall
echo.
echo Powershell Web Administration NOT Installed. Proceeding with Installation
msiexec /i iis7psprov_x64.msi /log %systemdrive%/iis7prov-PWA.log /passive
echo Powershell Web Administration installation COMPLETE && goto WSPcheck

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: The following version check is for 2012 and 2012R2 to install WebSocket Protocol in IIS

:WSPcheck

wmic OS get Version >nul 2>nul

:2012OSversion
ver | find "6.2.9200" >nul 2>nul
if %ERRORLEVEL% == 0 set ver= 2012 && goto WebSocketProtocol
if %ERRORLEVEL% == 1 goto 2012R2OSversion

:2012R2OSversion
ver | find "6.3.9600" >nul 2>nul
if %ERRORLEVEL% == 0 set ver= 2012R2 && goto WebSocketProtocol
if %ERRORLEVEL% == 1 goto END


:: Note - If WebSocket Protocol is already installed, the below script will briefly flash only
:WebSocketProtocol
start /wait %SystemRoot%\system32\dism.exe /online /enable-feature /featurename:IIS-WebSockets
echo Installing WebSocket Protocol COMPLETE
goto END


:END
:: 28SEPT2015 - INSTALL CareFusionServices Certificate
echo.Installing CarefusionServicesSSL Certificate

CERTUTIL -f -v -p Godaddy3750 -importPFX CareFusionServicesSSL.pfx NoExport >nul 2>nul

echo.
ECHO MongoDB installed to %choice%:\mongodb and service is running
ECHO END OF SUCCESSFUL INSTALLATION
ECHO. 
ECHO. ****** PLEASE RESTART SERVER TO APPLY POWERSHELL UPDATES ON 2008/R2 ******
pause

:exit
exit

:ServiceMissing
echo.
ECHO MONGO DB SERVICE WAS NOT INSTALLED. 
ECHO PLEASE VERIFY INSTALLATION IS NOT RUN FROM WITHIN A ZIPPED FOLDER && Pause && Exit