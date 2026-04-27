@echo off
setlocal
set "REPO=%~dp0"
set "REPO=%REPO:~0,-1%"
set "XDG_CONFIG_HOME=%REPO%"
set "XDG_DATA_HOME=%REPO%\.data"
set "XDG_STATE_HOME=%REPO%\.state"
set "XDG_CACHE_HOME=%REPO%\.cache"
wezterm start --config-file "%REPO%\wezterm.lua" --always-new-process
endlocal
