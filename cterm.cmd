@echo off
setlocal
set "REPO=%~dp0"
set "REPO=%REPO:~0,-1%"
set "CTERM_CWD=%CD%"
set "CTERM_AGENT=%~1"
if "%CTERM_AGENT%"=="" set "CTERM_AGENT=claude"
set "CTERM_REPO=%REPO%"
set "XDG_CONFIG_HOME=%REPO%"
set "XDG_DATA_HOME=%REPO%\.data"
set "XDG_STATE_HOME=%REPO%\.state"
set "XDG_CACHE_HOME=%REPO%\.cache"
wezterm --config-file "%REPO%\wezterm.lua" start --always-new-process
endlocal
