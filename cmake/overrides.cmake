#set(CMAKE_C_LINK_EXECUTABLE "<CMAKE_LINKER> ${CMAKE_CL_NOLOGO} <CMAKE_C_LINK_FLAGS> <LINK_FLAGS> <OBJECTS>,<TARGET>,<LINK_LIBRARIES>")

# disable MD/MDd logic in CMake
set(CMAKE_MSVC_RUNTIME_LIBRARY_DEFAULT "")


if(CL_VERSION_MAJOR LESS 8)
	#set(CMAKE_C_COMPILE_OBJECT "<CMAKE_C_COMPILER> ${CMAKE_START_TEMP_FILE} ${_COMPILE_C} <DEFINES> <INCLUDES> <FLAGS> /Fo<OBJECT> /Fd<TARGET_COMPILE_PDB>${_FS_C} -c <SOURCE>${CMAKE_END_TEMP_FILE}")
	set(CMAKE_C_COMPILE_OBJECT "<CMAKE_C_COMPILER> ${CMAKE_START_TEMP_FILE} ${_COMPILE_C} <DEFINES> <INCLUDES> <FLAGS> /Fo<OBJECT> -c <SOURCE>${CMAKE_END_TEMP_FILE}")
elseif(CL_VERSION_MAJOR LESS 9)
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
	set(_linker_args_exe "<TARGET>,,<LINK_LIBRARIES>,,${CMAKE_END_TEMP_FILE}")
	set(_linker_args_shlib "<TARGET>,,<LINK_LIBRARIES>,<TARGET>.def,${CMAKE_END_TEMP_FILE}")

	# ad-hoc LINK.exe command line for MSVC 1.x
	set(CMAKE_C_LINK_EXECUTABLE "${_linker_rule_pre} <CMAKE_C_LINK_FLAGS> ${_linker_rule_post} ${_linker_args_exe}")
	set(CMAKE_CXX_LINK_EXECUTABLE "${_linker_rule_pre} <CMAKE_CXX_LINK_FLAGS> ${_linker_rule_post} ${_linker_args_exe}")

	set(CMAKE_C_CREATE_SHARED_LIBRARY "${_linker_rule_pre} ${_linker_rule_shlib} <CMAKE_C_LINK_FLAGS> ${_linker_rule_post} ${_linker_args_shlib}")
	set(CMAKE_CXX_CREATE_SHARED_LIBRARY "${_linker_rule_pre} ${_linker_rule_shlib} <CMAKE_CXX_LINK_FLAGS> ${_linker_rule_post} ${_linker_args_shlib}")
endif()