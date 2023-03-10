function(get_short_path file output_var)
	get_filename_component(full_path "${file}" ABSOLUTE)
	string(REPLACE "/" "\\" full_path "${full_path}")
	execute_process(
		COMMAND cmd /C "for %A in (${full_path}) do @echo %~sA"
		OUTPUT_VARIABLE short_path
	)
	string(STRIP "${short_path}" short_path)
	set(${output_var} "${short_path}" PARENT_SCOPE)
endfunction()