call D:\tools\Open++\E\Xcmd.cmd
cd /d %~dp0
@chcp 65001
:ST
@echo.
@echo 1. Copy
@echo 2. Build
@echo 3. TestRun
@echo.
@choice /c:123 /n /m ">"
@set SELECTED=%errorlevel%
@CLS
@if "%SELECTED%" equ "1" @CALL :COPYBIN
@if "%SELECTED%" equ "2" @CALL :BUILD
@if "%SELECTED%" equ "3" @CALL :TESTRUN
@goto :ST


:BUILD
@REM ADB
@REM wsl app/deps/adb_windows.sh
@REM call gradlew  assembledebug

@REM @CALL :BUILDTEST
@CALL :BUILDMAIN win32 cross static release
@REM @CALL :BUILDMAIN win32 cross static debug
@REM @CALL :BUILDMAIN win32 cross shared
@REM @CALL :BUILDMAIN win64 cross static
@REM @CALL :BUILDMAIN win64 cross shared
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

@ECHO.BUILD %TARGET_HOST%-%BUILD_TYPE%-%LINK_TYPE%-%COMMIT%-%DEBUG_TYPE%

@SET "BUILD_DIR=build/%TARGET_HOST%-%BUILD_TYPE%-%LINK_TYPE%-%COMMIT%-%DEBUG_TYPE%"
@SET "DEPDIR=app/deps/work/install/%TARGET_HOST%-%BUILD_TYPE%-%LINK_TYPE%/"

@REM wsl app/deps/sdl.sh    %TARGET_HOST% %BUILD_TYPE% %LINK_TYPE%
@REM wsl app/deps/dav1d.sh %TARGET_HOST% %BUILD_TYPE% %LINK_TYPE%
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
@copy build\win32-cross-static-a34d9145-release\app\scrcpy.exe ..\scrcpy-dev\scrcpy.exe  /Y /B
@GOTO :END

:TESTRUN
@cls
@SET OLDCWD=%CD%
@cd build/win32-cross-static-a34d9145-release\app
@SET "SCRCPY_SERVER_PATH=..\..\..\server\build\outputs\apk\debug\server-debug.apk"
@del r:\Logs\ScreenRecoder[*].mp4
@del r:\Logs\ScreenRecoder[*].mkv
@scrcpy --list-display
@scrcpy --record-segment=30 --record=r:\Logs\ScreenRecoder[%%03d].mp4 -m 640 --display-id=0
@cd %OLDCWD%
@GOTO :END

:END