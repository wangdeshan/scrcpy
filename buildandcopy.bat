call D:\tools\Open++\E\Xcmd.cmd
cd /d %~dp0
@chcp 65001
:ST
@echo.
@echo 1. Build
@echo 2. TestRun
@echo 3. CopyBin
@echo 9. Exit
@echo.
@choice /c:1239 /n /m ">"
@set SELECTED=%errorlevel%
@CLS
@if "%SELECTED%" equ "1" @CALL :BUILD
@if "%SELECTED%" equ "2" @CALL :BUILD
@if "%SELECTED%" equ "3" @CALL :BUILD
@if "%SELECTED%" equ "4" @exit /b
@goto :ST


:BUILD
@REM ADB
@REM wsl app/deps/adb_windows.sh
@REM @chcp 936
@REM @call gradlew  assembledebug

@REM @CALL :BUILDTEST
@REM @CALL :BUILDMAIN win32 cross static release
@REM @CALL :BUILDMAIN win32 cross shared release
@REM @CALL :BUILDMAIN win32 cross static debug
@REM @CALL :BUILDMAIN win32 cross shared debug
@CALL :BUILDMAIN win64 cross static release
@REM @CALL :BUILDMAIN win64 cross shared release
@REM @CALL :BUILDMAIN win64 cross static debug
@REM @CALL :BUILDMAIN win64 cross shared debug
@GOTO :END

:BUILDTEST
@SET "TEST_DIR=build/test"
@mkdir "%TEST_DIR%"
wsl meson setup "%TEST_DIR%" ^
	-Dcompile_server=false ^
	-Db_sanitize=address,undefined
wsl ninja -C "%TEST_DIR%" test
@GOTO :END

:BUILDMAIN
@SET TARGET_HOST=%1
@SET BUILD_TYPE=%2
@SET LINK_TYPE=%3
@SET DEBUG_TYPE=%4

@ECHO.
@ECHO.-------------------------------------------------------------------------------
@ECHO.-------------------------------------------------------------------------------
@ECHO.
@for /F %%i in ('git rev-parse --short HEAD') do ( @set COMMIT=%%i)


@SET "BP=%TARGET_HOST%-%BUILD_TYPE%-%LINK_TYPE%-%COMMIT%-%DEBUG_TYPE%"
@ECHO.BUILD %BP%

@SET "BUILD_DIR=build/%BP%"
@SET "DEPDIR=app/deps/work/install/%TARGET_HOST%-%BUILD_TYPE%-%LINK_TYPE%/"

@if "%SELECTED%" equ "2" @GOTO :TESTRUN
@if "%SELECTED%" equ "3" @GOTO :COPYBIN

@REM wsl app/deps/sdl.sh    %TARGET_HOST% %BUILD_TYPE% %LINK_TYPE%
@REM wsl app/deps/dav1d.sh  %TARGET_HOST% %BUILD_TYPE% %LINK_TYPE%
@REM wsl app/deps/ffmpeg.sh %TARGET_HOST% %BUILD_TYPE% %LINK_TYPE%
@REM wsl app/deps/libusb.sh %TARGET_HOST% %BUILD_TYPE% %LINK_TYPE%
@REM @GOTO :END

@mkdir "%BUILD_DIR%"

@wsl meson setup "%BUILD_DIR%" ^
	--pkg-config-path="%DEPDIR%/lib/pkgconfig" ^
	-Dc_args="-I%DEPDIR%/include" ^
	-Dc_link_args="-L%DEPDIR%/lib" ^
	-Dcompile_server=false ^
	-Dportable=true ^
	-Db_lto=true ^
	--cross-file=cross_%TARGET_HOST%.txt ^
	--buildtype=%DEBUG_TYPE%
	@REM --strip
	
@wsl ninja -C "%BUILD_DIR%"

@GOTO :END

:COPYBIN
@cls
@taskkill /f /im scrcpy.exe
@copy build\%BP%\app\scrcpy.exe ..\scrcpy-dev\scrcpy.exe  /Y /B
@GOTO :END

:TESTRUN
@cls
@SET OLDCWD=%CD%
@cd "build\%BP%\app"
@SET "SCRCPY_SERVER_PATH=..\..\..\server\build\outputs\apk\debug\server-debug.apk"
@del r:\Logs\ScreenRecoder\[*].mp4
@del r:\Logs\ScreenRecoder\[*].mkv
@scrcpy --list-display
@scrcpy --record-segment=30 --record=r:\Logs\ScreenRecoder\[%%03d].mp4 -m 640 --display-id=0
@cd %OLDCWD%
@GOTO :END

:END