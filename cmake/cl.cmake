## required for CMAKE_C_LINKER_LAUNCHER
## unless an alternative can be used
cmake_minimum_required(VERSION 3.21)

if(NOT DEFINED CL_ROOT)
	message(FATAL_ERROR "CL_ROOT not defined")
endif()

set(CMAKE_C_COMPILER ${CL_ROOT}/BIN/CL.EXE)
set(CMAKE_CXX_COMPILER ${CL_ROOT}/BIN/CL.EXE)
set(CMAKE_LINKER ${CL_ROOT}/BIN/LINK.EXE)

# force all compiler checks
set(CMAKE_C_COMPILER_ID MSVC)
set(CMAKE_C_COMPILER_ID_RUN TRUE)
set(CMAKE_C_COMPILER_FORCED TRUE)
set(CMAKE_C_COMPILER_WORKS TRUE)

set(CMAKE_CXX_COMPILER_ID MSVC)
set(CMAKE_CXX_COMPILER_ID_RUN TRUE)
set(CMAKE_CXX_COMPILER_FORCED TRUE)
set(CMAKE_CXX_COMPILER_WORKS TRUE)

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
if(CL_VERSION_MAJOR LESS 8)
	# use the wrapper
	set(CL_LAUNCHER
		${CL_LAUNCHER} ${CMAKE_COMMAND}
			# CMAKE_BINARY_DIR is reserved, so use our own
			-DARG_BINDIR=${CMAKE_BINARY_DIR}
			-P ${CMAKE_CURRENT_LIST_DIR}/compile.cmake
			--
	)
	
	set(CL_CHDIR_LAUNCHER
		${CMAKE_COMMAND} -E chdir
			${CL_ROOT}/BIN
	)

	# and run CL.exe from the BIN directory
	set(CL_LAUNCHER ${CL_CHDIR_LAUNCHER} ${CL_LAUNCHER})

	# by using ntvdm
	#set(CL_LAUNCHER ${CL_LAUNCHER} ntvdm)

	set(CL_LAUNCHER ${CL_LAUNCHER} $ENV{WinDir}\\System32\\cmd.exe /C)

	# final launcher: <chdir> <cmake> <ntvdm>
	# cmake runs ${CL_LAUNCHER} ${CMAKE_C_COMPILER}
endif()

function(cl_detect_version output_variable)
	string(REPLACE "/" "\\" cmd "${CMAKE_C_COMPILER}")
	execute_process(
		COMMAND ${CL_CHDIR_LAUNCHER} cmd /C "echo yyyyy | ${cmd} /help 2>&1 1>NUL"
		OUTPUT_VARIABLE cl_stdout
	)
	set(ver_regex "Microsoft.*Version (.*)")
	if(NOT cl_stdout MATCHES "${ver_regex}")
		message(FATAL_ERROR "Couldn't determine CL.exe version")
	endif()
	set(cl_version "${CMAKE_MATCH_1}")
	# limit to first line
	string(REGEX REPLACE "\r?\n.*" "" cl_version "${cl_version}")
	set(${output_variable} ${cl_version} PARENT_SCOPE)
endfunction()

cl_detect_version(MSVC_VERSION)
if(NOT MSVC_VERSION MATCHES "(\[0-9]+)\.(.*)")
	message(FATAL_ERROR "Unrecognized MSVC_VERSION: ${MSVC_VERSION}")
endif()

set(CL_VERSION_MAJOR ${CMAKE_MATCH_1})
set(CL_VERSION_MINOR ${CMAKE_MATCH_2})
message(STATUS "CL Version: ${CL_VERSION_MAJOR}.${CL_VERSION_MINOR}")


set(CMAKE_C_COMPILER_LAUNCHER ${CL_LAUNCHER})
set(CMAKE_C_LINKER_LAUNCHER
	${CL_LAUNCHER}
		${CMAKE_COMMAND}
			-DCL_VERSION_MAJOR=${CL_VERSION_MAJOR}
			-P ${CMAKE_CURRENT_LIST_DIR}/link.cmake
			--
)
set(CMAKE_CXX_LINKER_LAUNCHER
	${CL_LAUNCHER}
		${CMAKE_COMMAND}
			-DCL_VERSION_MAJOR=${CL_VERSION_MAJOR}
			-P ${CMAKE_CURRENT_LIST_DIR}/link.cmake
			--
)

set(CMAKE_CXX_COMPILER_LAUNCHER ${CL_LAUNCHER})

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

set(_target_cpu ${CL_CPU})
set(_common_flags "")

if(DEFINED _target_cpu)
	if(_target_cpu STREQUAL "8086")
		set(_cpu_gen 0)
	elseif(_target_cpu STREQUAL "80186")
		set(_cpu_gen 1)
	elseif(_target_cpu STREQUAL "80286")
		set(_cpu_gen 2)
	elseif(_target_cpu STREQUAL "80386")
		set(_cpu_gen 3)
	elseif(_target_cpu STREQUAL "80486")
		set(_cpu_gen 4)
	elseif(_target_cpu STREQUAL "pentium")
		set(_cpu_gen 5)
	else()
		message(FATAL_ERROR "Unsupported CPU ${_target_cpu}")
	endif()

	set(_common_flags "${_common_flags} /G${_cpu_gen}")
endif()

set(_debug_flags "${_common_flags} /Od /Zi")
if(CL_VERSION_MAJOR GREATER_EQUAL 8)
	set(_debug_flags "${_debug_flags} /Z7")
endif()

set(_release_flags "${_common_flags} /O2 /DNDEBUG")
if(CL_WIN32)
	set(_debug_flags "${_debug_flags} /MD")
endif()

set(CMAKE_C_FLAGS_DEBUG_INIT "${_debug_flags}")
set(CMAKE_CXX_FLAGS_DEBUG_INIT "${_debug_flags}")

set(CMAKE_C_FLAGS_RELEASE_INIT "${_release_flags}")
set(CMAKE_CXX_FLAGS_RELEASE_INIT "${_release_flags}")

set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG_INIT}")
set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE_INIT}")
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG_INIT}")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE_INIT}")

# override platform flags and link commands
set(CMAKE_USER_MAKE_RULES_OVERRIDE ${CMAKE_CURRENT_LIST_DIR}/overrides.cmake)