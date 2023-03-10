##
## This CMake file is invoked as launcher for LINK.EXE
## the goal is to patch the .rsp response file
## generated by CMake to have backslashes instead of forward slashes
## 
include(${CMAKE_CURRENT_LIST_DIR}/common.cmake)

# collects LINK.exe arguments
set(LINK_ARGLIST "")

set(_found_arg_delim FALSE)

math(EXPR LINK_ARGS_END "${CMAKE_ARGC} - 1")
# cmake, -P, [this file], args...
#   0    1      2           3...
foreach(i RANGE 3 ${LINK_ARGS_END})
	set(var "CMAKE_ARGV${i}")
	set(arg "${${var}}")


	# loop until arg delim
	if(NOT _found_arg_delim)
		if(arg STREQUAL "--")
			set(_found_arg_delim TRUE)
		endif()

		continue()
	endif()

	list(APPEND LINK_ARGLIST "${arg}")

	#message("${i} -> ${arg}")
	
	string(SUBSTRING "${arg}" 0 1 first_ch)
	# patch the RSP file to have backslashes
	if(first_ch STREQUAL "@")
		string(LENGTH "${arg}" arg_len)
		math(EXPR arg_len "${arg_len} - 1")
		string(SUBSTRING "${arg}" 1 ${arg_len} rsp_file)
		file(READ "${rsp_file}" rsp_data)
		string(REPLACE "/" "\\" rsp_data "${rsp_data}")
		file(WRITE "${rsp_file}" "${rsp_data}")
	endif()
endforeach()

# INCLUDE and LIB variables must have backslashes
string(REPLACE "/" "\\" env $ENV{LIB})
set(ENV{LIB} ${env})
string(REPLACE "/" "\\" env $ENV{INCLUDE})
set(ENV{INCLUDE} ${env})

# run LINK.EXE
execute_process(
	COMMAND ${LINK_ARGLIST}
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
	COMMAND_ECHO STDOUT
	COMMAND_ERROR_IS_FATAL ANY
)