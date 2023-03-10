##
## This CMake file is invoked as launcher for CL.EXE
## the goal is to convert the object path from long to short DOS
## 
## 

include(${CMAKE_CURRENT_LIST_DIR}/common.cmake)

# collects CL.exe arguments
set(CL_ARGLIST "")

math(EXPR CL_ARGS_END "${CMAKE_ARGC} - 1")

set(_found_arg_delim FALSE)

# cmake, -P, [this file], args...
#   0    1      2           3...
foreach(i RANGE 3 ${CL_ARGS_END})
	set(var "CMAKE_ARGV${i}")
	set(arg "${${var}}")

	# loop until arg delim
	if(NOT _found_arg_delim)
		if(arg STREQUAL "--")
			set(_found_arg_delim TRUE)
		endif()

		continue()
	endif()

	#message("${i} -> ${arg}")
	
	string(SUBSTRING "${arg}" 0 1 prefix1)
	if(prefix1 STREQUAL "/" OR prefix1 STREQUAL "-")
		string(SUBSTRING "${arg}" 0 3 prefix3)
		if(prefix3 STREQUAL "/Fo")
			string(LENGTH "${arg}" arg_len)
			math(EXPR arg_len "${arg_len} - 3")
			# skip x chars
			string(SUBSTRING "${arg}" 3 ${arg_len} rela_object_file)
			
			# the object file must exist for this call to work
			set(full_object_file "${ARG_BINDIR}/${object_file}")
			file(TOUCH ${full_object_file})

			get_short_path("${full_object_file}" object_shortpath)
			list(APPEND CL_ARGLIST "/Fo${object_shortpath}")
		else()
			list(APPEND CL_ARGLIST "${arg}")
		endif()
	else()
		get_short_path("${arg}" file_shortpath)
		list(APPEND CL_ARGLIST "${file_shortpath}")
	endif()
endforeach()



# INCLUDE and LIB variables must have backslashes
string(REPLACE "/" "\\" env $ENV{LIB})
set(ENV{LIB} ${env})
string(REPLACE "/" "\\" env $ENV{INCLUDE})
set(ENV{INCLUDE} ${env})

# run CL.EXE
message(${CL_ARGLIST})
execute_process(
	COMMAND ${CL_ARGLIST}
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
	COMMAND_ECHO STDOUT
	COMMAND_ERROR_IS_FATAL ANY
)