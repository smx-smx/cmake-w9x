function(get_short_path file output_var)
	string(REPLACE "/" "\\" path "${file}")

	execute_process(
		COMMAND cmd /C ${CMAKE_CURRENT_LIST_DIR}\\get_short_path.bat "${path}"
		OUTPUT_VARIABLE short_path
	)
	string(STRIP "${short_path}" short_path)
	set(${output_var} "${short_path}" PARENT_SCOPE)
endfunction()