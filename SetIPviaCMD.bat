@echo off
setlocal ENABLEDELAYEDEXPANSION
ECHO Checking Administrator rights
NET SESSION
IF %ERRORLEVEL% NEQ 0 GOTO ELEVATE
GOTO ADMINTASKS
:ELEVATE
CD /d %~dp0
MSHTA "javascript: var shell = new ActiveXObject('shell.application'); shell.ShellExecute('%~nx0', '', '', 'runas', 1);close();"
EXIT
:ADMINTASKS
@echo off
setlocal DisableDelayedExpansion
:loop
echo ----------------------
REM Last known adapter
::*** Start of dynamic code ***
;set interface=WiFi
::*** End of dynamic code ***
::
:StartHere
title Change your IP address via CMD
cls
echo Current IP address for %interface%
echo --------------------------------------
netsh interface ip show addresses "%interface%"
if %errorlevel% EQU 1 goto GetAdapters
echo --------------------------------------
echo Press x to switch network adapters or press [ENTER] for DHCP:
echo --------------------------------------
set input=DHCP
set /p input= New IP Address for "%interface%":
IF %input% EQU DHCP GOTO AutoDoDHCP
IF %input% EQU x GOTO GetAdapters
IF %input% EQU X GOTO GetAdapters
set "subnetmask=255.255.255.0"
set /p "subnetmask=Subnetmark or press [ENTER] for default [%subnetmask%]: "
set teststring=%input%
REM Figure out default gateway
  for /f "tokens=1-3 delims=. " %%a in ("%input%") do set ipfirst3octets=%%a.%%b.%%c.1
set /p "ipfirst3octets=Default Gateway or press [ENTER] for default [%ipfirst3octets%]: "
goto NetworkSetUp
:NetworkSetUp
echo running netsh interface ip set address "%interface%" static "%input%" "%subnetmask%" "%ipfirst3octets%"
netsh interface ip set address "%interface%" static "%input%" "%subnetmask%" "%ipfirst3octets%"
Goto Done
:AutoDoDHCP
Echo Trying DHCP....
netsh int ip set address name = "%interface%" source = dhcp && netsh int ip set dns name = "%interface%" source = dhcp && netsh int ip set wins name = "%interface%" source = dhcp
echo Note: Ignore "The parameter is incorrect." message
cls
Echo Waiting for DHCP && Timeout /T 3
Goto Done
:GetAdapters
CLS 
SET %errorlevel%=0
setlocal ENABLEDELAYEDEXPANSION
set c=0
set "choices="
echo Select Interface - (WARNING: Pressing ENTER will initiate DHCP)
for /f "skip=2 tokens=3*" %%A in ('netsh interface show interface') do (
    set /a c+=1
    set int!c!=%%B
    set choices=!choices!!c!
    echo [!c!] %%B
)
choice /c !choices! /m "Select Interface: " /n
set interface=!int%errorlevel%!
setlocal DISABLEDELAYEDEXPANSION
REM Make changes perminant
(
  call :changeBatch
  ==============================================================================
  ==============================================================================
)
================================================================================
================================================================================
goto :loop
:changeBatch
(
  for /f "usebackq delims=" %%a in ("%~f0") do (
    echo %%a
    if "%%a"=="::*** Start of dynamic code ***" (
	  setlocal DisableDelayedExpansion
      set /a newValue=%interface%
      echo ;set interface=%interface%
      endlocal
    )
  )
) >"%~f0.tmp"
::
::The 2 lines of equal signs amount to 164 bytes, including end of line chars.
::Putting the lines both within and after the parentheses allows for expansion
::or contraction by up to 164 bytes within the dynamic section of code.
(
  move /y "%~f0.tmp" "%~f0" > nul
  ==============================================================================
  ==============================================================================
)
================================================================================
================================================================================
cls
Goto StartHere
:Done
netsh interface ip show addresses "%interface%"
rem "%interface%" needs to be set to the name of the current %interface% adapter for the computer youre using
Echo Close window or press [ENTER] to start again
Pause
cls
Goto StartHere
