@echo off
REM Wrapper to run OpenCode with MINIMAX_API_KEY from .scr\.env
REM Usage: run_opencode.bat "prompt text" [model]
REM Example: run_opencode.bat "What is 2+2?" minimax/MiniMax-M2.7

setlocal enabledelayedexpansion

REM Load MINIMAX_API_KEY from .scr\.env
for /f "usebackq tokens=1,2 delims==" %%a in ("%~dp0.scr\.env") do (
    if "%%a"=="MINIMAX_API_KEY" set MINIMAX_API_KEY=%%b
)

if "%MINIMAX_API_KEY%"=="" (
    echo ERROR: MINIMAX_API_KEY not found in %~dp0.scr\.env
    exit /b 1
)

set MODEL=%~2
if "%MODEL%"=="" set MODEL=minimax/MiniMax-M2.7

opencode run --model %MODEL% %1
