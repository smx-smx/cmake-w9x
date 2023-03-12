set(_mmodel ${CL_MMODEL})
set(_platform ${CL_TARGET_OS})
set(_fpuemu ${CL_FPUEMU})
set(_quickwin ${CL_QUICKWIN})

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
	get_target_property(_os ${target} MSVC_OS)

	if(_os STREQUAL "_os-NOTFOUND")
		set(_os "WIN32")
	endif()
	if(_quickwin STREQUAL "_quickwin-NOTFOUND")
		set(_quickwin ${CL_QUICKWIN})
	endif()
	if(_platform STREQUAL "_platform-NOTFOUND")
		set(_platform ${CL_TARGET_OS})
	endif()

	if(_target_type STREQUAL "EXECUTABLE")
		set(_is_library FALSE)
		set(_def_suffix ".exe.def")
	else()
		set(_is_library TRUE)
		set(_def_suffix ".dll.def")
	endif()

	set(_deftarget ${CMAKE_BINARY_DIR}/${target}${_def_suffix})
	
	if(_defsource)
		add_custom_command(
			OUTPUT ${_deftarget}
			COMMAND ${CMAKE_COMMAND} -E copy ${_defsource} ${_deftarget}
		)
	else()
		add_custom_command(
			OUTPUT ${_deftarget}
			COMMAND ${CMAKE_COMMAND} -E echo "NAME ${target}" > ${_deftarget}
		)
	endif()
	
	add_custom_target(${target}_def DEPENDS ${_deftarget})
	add_dependencies(${target} ${target}_def)

	set(_target_dos FALSE)
	set(_target_win16 FALSE)
	set(_target_win32 FALSE)

	set(_target_win1 FALSE)

	if(_platform STREQUAL "DOS")
		set(_target_dos TRUE)
	elseif(_platform STREQUAL "WIN16")
		set(_target_win16 TRUE)
		if(_os STREQUAL "WIN1")
			set(_target_win1 TRUE)
		endif()
	elseif(_platform STREQUAL "WIN32")
		set(_target_win32 TRUE)
	endif()

	if(_is_library)
		set(_libc_name "DLLC")
	else()
		set(_libc_name "LIBC")
	endif()

	if(NOT CL_IS_MSC)
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
	endif()

	if(NOT _target_win32)
		if(_mmodel STREQUAL "SMALL" OR NOT _mmodel)
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
	endif()

	if(_target_dos)
		# empty
	elseif((_target_win16 OR _target_win32) AND NOT _target_win1)
		set(_platform_name "W")
		if(_quickwin)
			set(_quickwin_name "Q")
			target_compile_options(${target} PRIVATE "/Mq")
		else()
			# protected-mode Win entry/exit code (A for Application, D for DLL)
			if(_is_library)
				target_compile_options(${target} PRIVATE "/GD")
			else()
				target_compile_options(${target} PRIVATE "/GA")
			endif()
		endif()
	endif()

	# set memory model
	target_compile_options(${target} PRIVATE "/A${_mmodel_name}")

	# compile only, don't link
	target_compile_options(${target} PRIVATE "/c")

	if(NOT _target_win32)
		if(NOT _target_win1 AND NOT CL_IS_MSC)
			# we want to choose the LIBC variant ourselves
			target_link_options(${target} PRIVATE "/NOD")
		endif()

		# [S|M|L|C]LIBC[A|7|E][W][Q]
		set(_libc_library "${_mmodel_name}${_libc_name}${_fpuemu_name}${_platform_name}${_quickwin_name}")

		if(NOT EXISTS ${CL_ROOT}/LIB/${_libc_library}.LIB)
			message(FATAL_ERROR "Invalid configuration, library ${_libc_library}.LIB does not exist")
		endif()

		if(_target_win1)
			target_link_libraries(${target} ${_mmodel_name}LIBW)
			#${_mmodel_name}WINLIBC
		elseif(_target_win16)
			target_link_libraries(${target} LIBW)
		endif()

		target_link_libraries(${target} ${_libc_library})
	endif()

	if(_target_win1)
		target_link_libraries(${target} LIBH)
	endif()
	

	if(_subsystem)
		target_link_options(${target} PRIVATE "/subsystem:${_subsystem}")
	endif()

	# this workaround keeps command line short
	# $FIXME: better alternative
	if(_target_dos)
		target_compile_definitions(${target} PRIVATE "T0")
	elseif(_target_win16 OR _target_win32)
		if(_target_win16)
			target_compile_definitions(${target} PRIVATE "T1")
		elseif(_quickwin)
			target_compile_definitions(${target} PRIVATE "T2")
		endif()
		if(_target_win32)
			target_compile_definitions(${target} PRIVATE "T3")
		endif()
	endif()
	#configure_file(${CMAKE_CURRENT_FUNCTION_LIST_DIR}/config.h.in ${CMAKE_BINARY_DIR}/config.h)
endfunction()
