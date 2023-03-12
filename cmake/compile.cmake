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

set(IS_MSC FALSE)
if(CL_VERSION_MAJOR LESS 8)
	set(IS_MSC TRUE)
endif()

set(_object_from "")
set(_object_to "")

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

	message("[DEBUG] in:arg ${i} -> ${arg}")

	if(IS_MSC)
		if(arg STREQUAL "/nologo"
		OR arg MATCHES "^/Fd.*")
			continue()
		endif()
	endif()

	string(TOUPPER "${arg}" arg_upper)
	set(out_arg "${arg}")

	# is it a switch?
	if(arg MATCHES "^[/-]")
		if(IS_MSC AND arg MATCHES "^/Fo")
			# change the /Fo flag to point to a temporary dir
			# the goal is to shorten the path so the command line will fit within 128 chars

			string(LENGTH "${arg}" arg_len)
			math(EXPR arg_len "${arg_len} - 3")
			string(SUBSTRING "${arg}" 3 ${arg_len} object_file)
			
			get_filename_component(fname "${object_file}" NAME)
			set(fpath "$ENV{TMP}\\${fname}")
			file(TOUCH ${fpath})
			message(DEBUG "[DEBUG] obj path: ${fpath}")

			set(_object_from "${object_file}")
			set(_object_to "${fpath}")

			get_short_path("${fpath}" object_shortpath)
			set(out_arg "/Fo${object_shortpath}")
		endif()
	# is it a file?
	elseif(IS_MSC 
		AND NOT arg MATCHES "^@"
		AND NOT arg_upper STREQUAL "NUL.MAP"
		# HACK to skip the link command chunks
		AND NOT arg MATCHES ","
		# skip libraries
		AND NOT arg_upper MATCHES ".LIB$"
	)
		get_short_path("${arg}" file_shortpath)
		set(out_arg "${file_shortpath}")
	endif()
	
	message("[DEBUG] out:arg ${i} -> ${out_arg}")

	if(NOT out_arg STREQUAL ",")
		list(APPEND CL_ARGLIST "${out_arg}")
	endif()
endforeach()

# run CL.EXE
message(DEBUG "[DEBUG]: CL ARGS")
list(JOIN CL_ARGLIST " " cl_args_string)
message(DEBUG "[DEBUG]: ${cl_args_string}")

execute_process(
	COMMAND ${CL_ARGLIST}
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
	COMMAND_ECHO STDOUT
	COMMAND_ERROR_IS_FATAL ANY
)

if(IS_MSC AND NOT _object_to STREQUAL "")
	# move the object file to the final location
	file(COPY_FILE "${_object_to}" "${_object_from}" ONLY_IF_DIFFERENT)
	file(REMOVE "${_object_to}")
endif()