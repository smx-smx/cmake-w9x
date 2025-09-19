# disable MD/MDd logic in CMake
set(CMAKE_MSVC_RUNTIME_LIBRARY_DEFAULT "")

set(CMAKE_VERBOSE_MAKEFILE ON)

set(CMAKE_C_CREATE_CONSOLE_EXE "")
set(CMAKE_CXX_CREATE_CONSOLE_EXE "")
set(CMAKE_CXX_CREATE_WIN32_EXE "")
set(CMAKE_C_CREATE_WIN32_EXE "")

if(CL_VERSION_MAJOR LESS 8)
	# needed for MSC 4. we will generate a flat .rsp ourselves
	# this is because CMake can only use response files for certain parts
	# of the linker commandline, while we want to use one for all switches
	set(CMAKE_C_USE_RESPONSE_FILE_FOR_LIBRARIES 0)
	set(CMAKE_CXX_USE_RESPONSE_FILE_FOR_LIBRARIES 0)
	set(CMAKE_C_USE_RESPONSE_FILE_FOR_OBJECTS 0)
	set(CMAKE_CXX_USE_RESPONSE_FILE_FOR_OBJECTS 0)
	set(CMAKE_C_USE_RESPONSE_FILE_FOR_INCLUDES 0)
	set(CMAKE_CXX_USE_RESPONSE_FILE_FOR_INCLUDES 0)
endif()

if(CL_VERSION_MAJOR LESS 9)
	# DOS/Win16 doesn't use subsystems
	# it uses separate LIBC libraries instead
	set(CMAKE_C_CREATE_WIN32_EXE "")
	set(CMAKE_C_CREATE_CONSOLE_EXE "")

	set(CMAKE_CXX_CREATE_WIN32_EXE "")
	set(CMAKE_CXX_CREATE_CONSOLE_EXE "")

	set(_linker_rule_pre "<CMAKE_LINKER> ${CMAKE_CL_NOLOGO}")
	set(_linker_rule_post "<LINK_FLAGS> <OBJECTS> ${CMAKE_START_TEMP_FILE}")

	# LINK
	# LINK @<response file>
	# LINK <objs>,<exefile>,<mapfile>,<libs>,<deffile>
	# NOTE: this command line is parsed by "link.cmake" to generate the RSP (hence the spaces)
	set(_linker_args_exe "<TARGET>,,<LINK_LIBRARIES>, <TARGET>.def ,${CMAKE_END_TEMP_FILE}")
	set(_linker_args_shlib "<TARGET>,,<LINK_LIBRARIES>, <TARGET>.def ,${CMAKE_END_TEMP_FILE}")
	
	if(CL_VERSION_MAJOR LESS 8)
		# add ListFile: NUL.MAP ($FIXME: make it configurable)
		# NOTE: this command line is parsed by "link.cmake" to generate the RSP (hence the spaces)
		set(_linker_args_exe "<TARGET> , NUL.MAP , <LINK_LIBRARIES> , <TARGET>.def , ${CMAKE_END_TEMP_FILE}")
	endif()

	# ad-hoc LINK.exe command line for MSVC 1.x
	set(CMAKE_C_LINK_EXECUTABLE "${_linker_rule_pre} <CMAKE_C_LINK_FLAGS> ${_linker_rule_post} ${_linker_args_exe}")
	set(CMAKE_CXX_LINK_EXECUTABLE "${_linker_rule_pre} <CMAKE_CXX_LINK_FLAGS> ${_linker_rule_post} ${_linker_args_exe}")

	set(CMAKE_C_CREATE_SHARED_LIBRARY "${_linker_rule_pre} ${_linker_rule_shlib} <CMAKE_C_LINK_FLAGS> ${_linker_rule_post} ${_linker_args_shlib}")
	set(CMAKE_CXX_CREATE_SHARED_LIBRARY "${_linker_rule_pre} ${_linker_rule_shlib} <CMAKE_CXX_LINK_FLAGS> ${_linker_rule_post} ${_linker_args_shlib}")
endif()