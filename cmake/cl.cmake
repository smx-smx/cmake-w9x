## required for CMAKE_C_LINKER_LAUNCHER
## unless an alternative can be used
cmake_minimum_required(VERSION 3.21)

if(NOT DEFINED CL_ROOT)
	message(FATAL_ERROR "CL_ROOT not defined")
endif()

set(CMAKE_C_COMPILER ${CL_ROOT}/BIN/CL.EXE)
set(CMAKE_CXX_COMPILER ${CL_ROOT}/BIN/CL.EXE)

# force all compiler checks
set(CMAKE_C_COMPILER_ID MSVC)
set(CMAKE_C_COMPILER_ID_RUN TRUE)
set(CMAKE_C_COMPILER_FORCED TRUE)
set(CMAKE_C_COMPILER_WORKS TRUE)

set(CMAKE_CXX_COMPILER_ID MSVC)
set(CMAKE_CXX_COMPILER_ID_RUN TRUE)
set(CMAKE_CXX_COMPILER_FORCED TRUE)
set(CMAKE_CXX_COMPILER_WORKS TRUE)
# $TODO: detect it from CL.exe
set(MSVC_VERSION "8.00c")

##
## old CL has a PATH length limitation (probably max 256 chars)
## use a launcher to set a shorter PATH, as well as
## INCLUDE/LIB locations for standard headers and libraries
##
set(CL_LAUNCHER
	${CMAKE_COMMAND} -E env
		PATH=$ENV{WinDir}\\System32
		INCLUDE=${CL_ROOT}/INCLUDE
		LIB=${CL_ROOT}/LIB
)

set(CMAKE_C_COMPILER_LAUNCHER ${CL_LAUNCHER})
set(CMAKE_C_LINKER_LAUNCHER ${CL_LAUNCHER} ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_LIST_DIR}/link.cmake)

set(CMAKE_CXX_COMPILER_LAUNCHER ${CL_LAUNCHER})
set(CMAKE_CXX_LINKER_LAUNCHER ${CL_LAUNCHER} ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_LIST_DIR}/link.cmake)

# wipe defaults
set(CMAKE_C_STANDARD_LIBRARIES "")
set(CMAKE_C_FLAGS "")
set(CMAKE_C_FLAGS_DEBUG "")
set(CMAKE_C_FLAGS_RELEASE "")

set(CMAKE_CXX_STANDARD_LIBRARIES "")
set(CMAKE_CXX_FLAGS "")
set(CMAKE_CXX_FLAGS_DEBUG "")
set(CMAKE_CXX_FLAGS_RELEASE "")

# set new defaults and parse 9x specific flags
include(${CMAKE_CURRENT_LIST_DIR}/Windows.cmake)

# override platform flags and link commands
set(CMAKE_USER_MAKE_RULES_OVERRIDE ${CMAKE_CURRENT_LIST_DIR}/overrides.cmake)