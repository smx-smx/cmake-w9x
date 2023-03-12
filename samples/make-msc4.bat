set CMAKE_MODULES=%CD%\..\..\cmake
if not exist build (mkdir build)
pushd build
set VERBOSE=1
del CMakeCache.txt & ^
cmake .. -G"MinGW Makefiles" ^
	-DCMAKE_MESSAGE_LOG_LEVEL=DEBUG ^
	-DCMAKE_TOOLCHAIN_FILE=%CMAKE_MODULES%\cl.cmake ^
	-DCMAKE_BUILD_TYPE=Debug ^
	-DCL_ROOT="H:/msc4" ^
	-DCL_CPU="80286" &^
mingw32-make clean &^
mingw32-make
popd