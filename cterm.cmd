@echo off
setlocal
set "REPO=%~dp0"
set "REPO=%REPO:~0,-1%"

if /i "%~1"=="--setup" (
  call :run_setup
  goto :end
)
if /i "%~1"=="setup" (
  call :run_setup
  goto :end
)

if not exist "%REPO%\cterm.local.cmd" (
  call :run_setup
  if not exist "%REPO%\cterm.local.cmd" exit /b 1
)

call "%REPO%\cterm.local.cmd"

set "CTERM_CWD=%CD%"

rem First positional arg is the agent name only if it doesn't start with `-`.
rem Otherwise use default agent and forward all args.
set "CTERM_AGENT="
set "_FIRST=%~1"
set "_LEAD="
if defined _FIRST set "_LEAD=%_FIRST:~0,1%"
if defined _FIRST if not "%_LEAD%"=="-" (
  set "CTERM_AGENT=%~1"
  shift
)
if "%CTERM_AGENT%"=="" set "CTERM_AGENT=%CTERM_DEFAULT_AGENT%"
if "%CTERM_AGENT%"=="" set "CTERM_AGENT=claude"

set "CTERM_EXTRAS_FILE=%REPO%\.claude\agent-extras.tmp"
type nul > "%CTERM_EXTRAS_FILE%"
:extras_loop
if "%~1"=="" goto extras_done
>>"%CTERM_EXTRAS_FILE%" echo(%~1
shift
goto extras_loop
:extras_done

set "CTERM_REPO=%REPO%"
set /a "_NVIM_PORT=6666 + %RANDOM% %% 1000"
set "CTERM_NVIM_ADDR=127.0.0.1:%_NVIM_PORT%"

if "%CTERM_USE_USER_NVIM%"=="1" (
  rem leave XDG_* alone -> user's normal nvim config is used
) else (
  set "XDG_CONFIG_HOME=%REPO%"
  set "XDG_DATA_HOME=%REPO%\.data"
  set "XDG_STATE_HOME=%REPO%\.state"
  set "XDG_CACHE_HOME=%REPO%\.cache"
)

wezterm --config-file "%REPO%\wezterm.lua" start --always-new-process
goto :end

:run_setup
call "%REPO%\scripts\setup.cmd"
exit /b

:end
endlocal
