@echo off
setlocal enabledelayedexpansion

:: Set the path to your XexTool executable here
set "EXE_PATH=D:\Program Files\Xbox 360 Make Trainers\XexTool-windows-x64\XexTool.exe"

:: Check if XexTool exists before running
if not exist "%EXE_PATH%" (
    echo ===================================================
    echo ERROR: Could not find XexTool.exe at:
    echo %EXE_PATH%
    echo ===================================================
    echo Please check if the path is correct.
    echo.
    pause
    exit /b
)

:main_menu
cls
echo ===================================================
echo             XexTool Batch Processor
echo ===================================================
echo.
echo Full XexTool Options Reference:
echo   -l               : Print extended info (DEFAULT)
echo   -p ^<xexp^>        : Patch with a title update
echo   -b ^<file^>        : Dump the basefile
echo   -i ^<file^>        : Dump basefile info to an IDC script
echo   -d ^<dir^>         : Dump all resources (. is allowed)
echo   -o ^<xex^>         : Write a new file instead of altering input
echo   -a ^<path^>        : Add a bounding path
echo   -u               : Fix a patched xex so it no longer needs patch file
echo   -s ^<flags^>       : Title-specific patches (0 lists them, -1 does all)
echo   -r ^<flags^>       : Remove limitations (e.g., -r a for all)
echo   -m d^|r          : Force devkit (d) or retail (r)
echo   -c u^|c^|b         : Force uncompressed, compressed, or binary
echo   -e u^|e          : Force unencrypted or encrypted
echo   -x ^<flags^>       : Extract metadata as XML
echo   -z g^|s ^<file^>     : Get or set xex info
echo.
echo ---------------------------------------------------
echo Type your desired option(s) below and press Enter.
echo Press Enter with no input to use default: -l
set "USER_OPTS="
set /p "USER_OPTS=Options [-l]: "

:: If user presses Enter without typing, default to -l
if "%USER_OPTS%"=="" set "USER_OPTS=-l"

echo.
echo ---------------------------------------------------
echo Log Output Mode:
echo   [1] Combined Master File (Single report in folder) [DEFAULT]
echo   [2] Separate Text Files (Individual report per XEX in folder)
echo ---------------------------------------------------
set "LOG_MODE="
set /p "LOG_MODE=Choice [1]: "
if "%LOG_MODE%"=="" set "LOG_MODE=1"

echo.
echo ===================================================
echo   Searching for .xex files and running XexTool...
echo ===================================================
echo.

:: Automatically check Desktop for existing report folders and find the next unique number
set "FOLDER_NUM=1"
:find_next_folder
set "TARGET_DIR=%USERPROFILE%\Desktop\XexTool_Report_!FOLDER_NUM!"
if exist "!TARGET_DIR!" (
    set /a "FOLDER_NUM+=1"
    goto find_next_folder
)

:: Create the unique report directory on Desktop
mkdir "!TARGET_DIR!"

set "FOUND=0"

:: MODE 1: COMBINED SINGLE REPORT
if "%LOG_MODE%"=="1" (
    set "LOG_FILE=!TARGET_DIR!\XexTool_Report_!FOLDER_NUM!.txt"

    :: Initialize the master report file inside the new folder
    echo XexTool Batch Processing Report - %DATE% %TIME% > "!LOG_FILE!"
    echo Options Used: !USER_OPTS! >> "!LOG_FILE!"
    echo =================================================== >> "!LOG_FILE!"

    for /r %%i in (*.xex) do (
        set "FOUND=1"
        
        echo ---------------------------------------------------
        echo Processing: "%%i"
        echo ---------------------------------------------------
        
        :: Append to single master report
        echo File: "%%i" >> "!LOG_FILE!"
        echo --------------------------------------------------- >> "!LOG_FILE!"
        "%EXE_PATH%" !USER_OPTS! "%%i" >> "!LOG_FILE!" 2>&1
        echo. >> "!LOG_FILE!"
        echo =================================================== >> "!LOG_FILE!"
        
        :: Live console output
        "%EXE_PATH%" !USER_OPTS! "%%i"
        echo.
    )

    if "!FOUND!"=="0" (
        echo No .xex files were found. >> "!LOG_FILE!"
    ) else (
        echo ===================================================
        echo All .xex files processed!
        echo Master report saved inside folder: XexTool_Report_!FOLDER_NUM!
        echo File: XexTool_Report_!FOLDER_NUM!.txt
        echo ===================================================
    )
)

:: MODE 2: SEPARATE INDIVIDUAL REPORTS
if "%LOG_MODE%"=="2" (
    set "INDIV_NUM=1"

    for /r %%i in (*.xex) do (
        set "FOUND=1"

        set "LOG_FILE=!TARGET_DIR!\XexTool_Report_!INDIV_NUM!.txt"

        echo ---------------------------------------------------
        echo Processing: "%%i"
        echo Saving Log: XexTool_Report_!INDIV_NUM!.txt
        echo ---------------------------------------------------

        :: Initialize individual report inside the new folder
        echo XexTool Processing Report - %DATE% %TIME% > "!LOG_FILE!"
        echo Options Used: !USER_OPTS! >> "!LOG_FILE!"
        echo File: "%%i" >> "!LOG_FILE!"
        echo =================================================== >> "!LOG_FILE!"
        "%EXE_PATH%" !USER_OPTS! "%%i" >> "!LOG_FILE!" 2>&1

        :: Live console output
        "%EXE_PATH%" !USER_OPTS! "%%i"
        echo.

        set /a "INDIV_NUM+=1"
    )

    if "!FOUND!"=="1" (
        echo ===================================================
        echo All .xex files processed!
        echo Separate reports saved inside folder: XexTool_Report_!FOLDER_NUM!
        echo ===================================================
    )
)

if "!FOUND!"=="0" (
    echo ===================================================
    echo No .xex files were found in this directory or its subfolders.
    echo ===================================================
)

echo.
echo ---------------------------------------------------
echo Would you like to run another operation?
echo ---------------------------------------------------
set /p "REPEAT=Type 'Y' to run again, or press Enter to exit: "
if /i "!REPEAT!"=="Y" goto main_menu

endlocal
exit /b