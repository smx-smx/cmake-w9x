## required for CMAKE_C_LINKER_LAUNCHER
## unless an alternative can be used
cmake_minimum_required(VERSION 3.21)

if(NOT DEFINED CL_ROOT)
	message(FATAL_ERROR "CL_ROOT not defined")
endif()

# NOTE: CMake wants forward paths here
# otherwise you'll get:
# Invalid character escape '\m'.

if(NOT DEFINED CL_EXECUTABLE)
	set(CL_EXECUTABLE ${CL_ROOT}/BIN/CL.EXE)
endif()
if(NOT DEFINED LINK_EXECUTABLE)
	set(LINK_EXECUTABLE ${CL_ROOT}/BIN/LINK.EXE)
endif()

set(CMAKE_C_COMPILER ${CL_EXECUTABLE})
set(CMAKE_CXX_COMPILER ${CL_EXECUTABLE})
set(CMAKE_LINKER ${LINK_EXECUTABLE})

# force all compiler checks
set(CMAKE_C_COMPILER_ID MSVC)
set(CMAKE_C_COMPILER_ID_RUN TRUE)
set(CMAKE_C_COMPILER_FORCED TRUE)
set(CMAKE_C_COMPILER_WORKS TRUE)

set(CMAKE_CXX_COMPILER_ID MSVC)
set(CMAKE_CXX_COMPILER_ID_RUN TRUE)
set(CMAKE_CXX_COMPILER_FORCED TRUE)
set(CMAKE_CXX_COMPILER_WORKS TRUE)

string(REPLACE "/" "\\" cl_root_var ${CL_ROOT})

##
## old CL has a PATH length limitation (probably max 256 chars)
## use a launcher to set a shorter PATH, as well as
## INCLUDE/LIB locations for standard headers and libraries
##
set(CL_PATH_LIST "")
list(APPEND CL_PATH_LIST
	${cl_root_var}\\BIN
	$ENV{WinDir}\\System32
)
list(JOIN CL_PATH_LIST "\\\;" CL_PATH_VAR)

set(CL_INCLUDE_DIRS_LIST "")
list(APPEND CL_INCLUDE_DIRS_LIST
	"${cl_root_var}\\INCLUDE"
	# **WARNING**: this assumes the Working directory is CMAKE_BINARY_DIR, where "config.h" is located
	"."
)
list(JOIN CL_INCLUDE_DIRS_LIST "\\\;" CL_INCLUDE_DIRS_VAR)

set(CL_LIB_DIRS_LIST "")
list(APPEND CL_LIB_DIRS_LIST
	"${cl_root_var}\\LIB"
)
list(JOIN CL_LIB_DIRS_LIST "\\\;" CL_LIB_DIRS_VAR)

set(CL_ENV_VARS "")
list(APPEND CL_ENV_VARS
	"PATH=${CL_PATH_VAR}"
	"TMP=$ENV{WinDir}\\TEMP"
)
if(NOT CL_NO_DEFAULT_INCLUDES)
	list(APPEND CL_ENV_VARS	"INCLUDE=${CL_INCLUDE_DIRS_VAR}")
endif()
if(NOT CL_NO_DEFAULT_LIBS)
	list(APPEND CL_ENV_VARS	"LIB=${CL_LIB_DIRS_VAR}")
endif()

set(CL_LAUNCHER_SETENV ${CMAKE_COMMAND} -E env "${CL_ENV_VARS}")
set(CL_LAUNCHER ${CL_LAUNCHER_SETENV})

function(cl_detect_version output_variable)
	string(REPLACE "/" "\\" compiler_cmd ${CMAKE_C_COMPILER})
	execute_process(
		COMMAND ${CL_LAUNCHER} cmd /C "echo yyyyy | ${compiler_cmd} /help 2>&1 1>NUL"
		OUTPUT_VARIABLE cl_stdout
		ECHO_OUTPUT_VARIABLE
		ECHO_ERROR_VARIABLE
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

# double-escape path separator
string(REPLACE ";" "\\\;" CL_LAUNCHER_SETENV "${CL_LAUNCHER_SETENV}")
set(CL_LAUNCHER ${CL_LAUNCHER_SETENV})

set(CL_VERSION_MAJOR ${CMAKE_MATCH_1})
set(CL_VERSION_MINOR ${CMAKE_MATCH_2})
message(STATUS "CL Version: ${CL_VERSION_MAJOR}.${CL_VERSION_MINOR}")

set(CL_IS_MSC FALSE)
set(CL_SUPPORTS_WIN16 TRUE)

if(CL_VERSION_MAJOR GREATER 8)
	set(CL_SUPPORTS_WIN16 FALSE)
endif()

if(CL_VERSION_MAJOR LESS 8)
	set(CL_IS_MSC TRUE)

	# use the wrapper
	set(CL_LAUNCHER
		${CL_LAUNCHER} ${CMAKE_LAUNCHER}
			# CMAKE_BINARY_DIR is reserved, so use our own
			-DARG_BINDIR=${CMAKE_BINARY_DIR}
			-DCL_VERSION_MAJOR=${CL_VERSION_MAJOR}
			-P ${CMAKE_CURRENT_LIST_DIR}/compile.cmake
			--
	)
endif()

set(CMAKE_LAUNCHER ${CMAKE_COMMAND})
if(CMAKE_MESSAGE_LOG_LEVEL)
	list(APPEND CMAKE_LAUNCHER --log-level=${CMAKE_MESSAGE_LOG_LEVEL})
endif()

set(CMAKE_C_COMPILER_LAUNCHER ${CL_LAUNCHER})
set(CMAKE_C_LINKER_LAUNCHER
	${CL_LAUNCHER}
		${CMAKE_LAUNCHER}
			-DCL_ROOT=${CL_ROOT}
			-DCL_VERSION_MAJOR=${CL_VERSION_MAJOR}
			-P ${CMAKE_CURRENT_LIST_DIR}/link.cmake
			--
)
set(CMAKE_CXX_LINKER_LAUNCHER
	${CL_LAUNCHER}
		${CMAKE_LAUNCHER}
			-DCL_ROOT=${CL_ROOT}
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

set(_debug_flags "${_common_flags} /Od")
if(DEFINED CMAKE_MSVC_DEBUG_INFORMATION_FORMAT)
	if(CMAKE_MSVC_DEBUG_INFORMATION_FORMAT STREQUAL Embedded)
		if(CL_VERSION_MAJOR GREATER_EQUAL 8)
			set(_debug_flags "${_debug_flags} /Z7")
		endif()
	elseif(CMAKE_MSVC_DEBUG_INFORMATION_FORMAT STREQUAL ProgramDatabase)
		set(_debug_flags "${_debug_flags} /Zi")
	else()
		message(FATAL_ERROR "Unsupported CMAKE_MSVC_DEBUG_INFORMATION_FORMAT ${CMAKE_MSVC_DEBUG_INFORMATION_FORMAT}")
	endif()
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