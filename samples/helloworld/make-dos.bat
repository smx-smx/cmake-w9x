set CMAKE_MODULES=%CD%\..\..\cmake
if not exist build (mkdir build)
pushd build
del CMakeCache.txt & ^
cmake .. -G"MinGW Makefiles" ^
	-DCMAKE_TOOLCHAIN_FILE=%CMAKE_MODULES%\cl.cmake ^
	-DCMAKE_BUILD_TYPE=Debug ^
	-DCL_ROOT="H:/msvc20/MSVC15" ^
	-DMSVC_VER=1 ^
	-DCL_TARGET_OS=DOS &^
mingw32-make clean &^
mingw32-make
popd