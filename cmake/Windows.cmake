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

if(_platform STREQUAL "WIN16")
	add_definitions("/DCL_WIN16")
	set(CL_WIN16 TRUE)
	if(_quickwin)
		add_definitions("/DCL_QUICKWIN")
		set(CL_QUICKWIN TRUE)
	endif()
else()
	set(CL_WIN16 FALSE)
endif()

if(_platform STREQUAL "WIN32")
	add_definitions("/DCL_WIN32")
	set(CL_WIN32 TRUE)
else()
	set(CL_WIN32 FALSE)
endif()


if(_platform STREQUAL "DOS" OR _platform STREQUAL "WIN16")
	set(LIBC_NAME "LIBC")

	if(NOT DEFINED _mmodel)
		if(CL_TARGET_OS STREQUAL "WIN16")
			set(_mmodel "LARGE")
		else() # DOS
			set(_mmodel "SMALL")
		endif()
	endif()
	
	if(NOT DEFINED _fpuemu)
		set(_fpuemu "NO")
	endif()

	if(_fpuemu STREQUAL "ALT")
		# Alternate FPU package for FPU-less coprocessors
		set(_fpuemu_name "A")
		add_compile_options("/FPa")
	elseif(NOT _fpuemu)
		set(_fpuemu_name "7")
		add_compile_options("/FPi87")
	elseif(_fpuemu)
		set(_fpuemu_name "E")
		add_compile_options("/FPi")
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
			add_compile_options("/Mq")
		else()
			# protected-mode Win entry/exit code (A for Application)
			# $TODO: D for DLL
			add_compile_options("/GA")
		endif()
	endif()

	# set memory model
	add_compile_options("/A${_mmodel_name}")

	# compile only, don't link
	add_compile_options("/c")

	# we want to choose the LIBC variant ourselves
	add_link_options("/NOD")

	set(LIBC_LIBRARY "${_mmodel_name}${LIBC_NAME}${_fpuemu_name}${_platform_name}${_quickwin_name}")
	list(APPEND CMAKE_C_STANDARD_LIBRARIES ${LIBC_LIBRARY})

	if(CL_WIN16)
		list(APPEND CMAKE_C_STANDARD_LIBRARIES LIBW)
	endif()

	set(CMAKE_CXX_STANDARD_LIBRARIES ${CMAKE_C_STANDARD_LIBRARIES})
endif()

if(DEFINED CL_SUBSYSTEM)
	add_link_options("/subsystem:${CL_SUBSYSTEM}")
endif()

### toolchain-file related options