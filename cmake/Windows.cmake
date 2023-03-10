set(_mmodel ${CL_MMODEL})
set(_platform ${CL_TARGET_OS})
set(_fpuemu ${CL_FPUEMU})
set(_quickwin ${CL_QUICKWIN})

if(_platform STREQUAL "DOS")
	add_definitions("/DCL_DOS")
	set(CL_DOS TRUE)
else()
	set(CL_DOS FALSE)
endif()

define_property(
	TARGET
	PROPERTY MSVC_QUICKWIN
)
define_property(
	TARGET
	PROPERTY MSVC_PLATFORM
)
define_property(
	TARGET
	PROPERTY MSVC_MMODEL
)
define_property(
	TARGET
	PROPERTY MSVC_FPUEMU
)
define_property(
	TARGET
	PROPERTY MSVC_SUBSYSTEM 
)
define_property(
	TARGET
	PROPERTY MSVC_DEFFILE
)

function(setup_msvc_target target)
	get_target_property(_quickwin ${target} MSVC_QUICKWIN)
	get_target_property(_platform ${target} MSVC_PLATFORM)
	get_target_property(_mmodel ${target} MSVC_MMODEL)
	get_target_property(_fpuemu ${target} MSVC_FPUEMU)
	get_target_property(_subsystem ${target} MSVC_SUBSYSTEM)
	get_target_property(_defsource ${target} MSVC_DEFFILE)
	get_target_property(_target_type ${target} TYPE)

	set(_is_library FALSE)
	if(NOT _target_type STREQUAL "EXECUTABLE")
		set(_is_library TRUE)
	endif()

	if(_defsource)
		set(_deftarget ${CMAKE_BINARY_DIR}/${target}.dll.def)
		add_custom_command(
			OUTPUT ${_deftarget}
			COMMAND ${CMAKE_COMMAND} -E copy ${_defsource} ${_deftarget}
		)
		add_custom_target(${target}_def DEPENDS ${_deftarget})
		add_dependencies(${target} ${target}_def)
	endif()

	set(_target_win16 FALSE)
	set(_target_win32 FALSE)

	if(_platform STREQUAL "WIN16")
		target_compile_definitions(${target} PRIVATE "/DCL_WIN16")
		set(_target_win16 TRUE)
		if(_quickwin)
			target_compile_definitions(${target} PRIVATE "/DCL_QUICKWIN")
		endif()
	endif()

	if(_platform STREQUAL "WIN32")
		target_compile_definitions(${target} PRIVATE "/DCL_WIN32")
		set(_target_win32 TRUE)
	endif()


	if(_platform STREQUAL "DOS" OR _platform STREQUAL "WIN16")
		if(_is_library)
			set(_libc_name "DLLC")
		else()
			set(_libc_name "LIBC")
		endif()

		if(NOT _mmodel)
			if(CL_TARGET_OS STREQUAL "WIN16")
				set(_mmodel "LARGE")
			else() # DOS
				set(_mmodel "SMALL")
			endif()
		endif()
		
		if(_fpuemu STREQUAL "ALT")
			# Alternate FPU package for FPU-less coprocessors
			set(_fpuemu_name "A")
			target_compile_options(${target} PRIVATE "/FPa")
		elseif(NOT _fpuemu AND NOT _fpuemu STREQUAL "_fpuemu-NOTFOUND")
			# emulator explicitly disabled, real FPU
			set(_fpuemu_name "7")
			target_compile_options(${target} PRIVATE "/FPi87")
		else() # default, use emulator
			set(_fpuemu_name "E")
			target_compile_options(${target} PRIVATE "/FPi")
		endif()

		if(_mmodel STREQUAL "SMALL")
			set(_mmodel_name "S")
		elseif(_mmodel STREQUAL "MEDIUM")
			set(_mmodel_name "M")
		elseif(_mmodel STREQUAL "LARGE")
			set(_mmodel_name "L")
		elseif(_mmodel STREQUAL "HUGE")
			set(_mmodel_name "H")
		elseif(_mmodel STREQUAL "TINY")
			set(_mmodel_name "T")
		elseif(_mmodel STREQUAL "COMPACT")
			set(_mmodel_name "C")
		endif()

		if(_platform STREQUAL "DOS")
		elseif(_platform STREQUAL "WIN16")
			set(_platform_name "W")
			if(_quickwin)
				set(_quickwin_name "Q")
				target_compile_options(${target} PRIVATE "/Mq")
			else()
				# protected-mode Win entry/exit code (A for Application)
				# $TODO: D for DLL
				target_compile_options(${target} PRIVATE "/GA")
			endif()
		endif()

		# set memory model
		target_compile_options(${target} PRIVATE "/A${_mmodel_name}")

		# compile only, don't link
		target_compile_options(${target} PRIVATE "/c")

		# we want to choose the LIBC variant ourselves
		target_link_options(${target} PRIVATE "/NOD")

		set(_libc_library "${_mmodel_name}${_libc_name}${_fpuemu_name}${_platform_name}${_quickwin_name}")

		if(NOT EXISTS ${CL_ROOT}/LIB/${_libc_library}.LIB)
			message(FATAL_ERROR "Invalid configuration, library ${_libc_library}.LIB does not exist")
		endif()

		target_link_libraries(${target} ${_libc_library})

		if(_target_win16)
			target_link_libraries(${target} LIBW)
		endif()
	endif()

	if(_subsystem)
		target_link_options(${target} PRIVATE "/subsystem:${_subsystem}")
	endif()
endfunction()

### toolchain-file related options