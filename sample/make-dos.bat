if not exist build (mkdir build)
pushd build
del CMakeCache.txt & ^
cmake .. -G"MinGW Makefiles" ^
	-DCL_ROOT="H:/msvc20/MSVC15" ^
	-DMSVC_VER=1 ^
	-DCL_TARGET_OS=DOS ^
	-DCMAKE_TOOLCHAIN_FILE=..\..\cmake\cl.cmake &^
mingw32-make clean &^
mingw32-make
popd