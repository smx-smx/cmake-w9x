#set(CMAKE_C_LINK_EXECUTABLE "<CMAKE_LINKER> ${CMAKE_CL_NOLOGO} <CMAKE_C_LINK_FLAGS> <LINK_FLAGS> <OBJECTS>,<TARGET>,<LINK_LIBRARIES>")

# disable MD/MDd logic in CMake
set(CMAKE_MSVC_RUNTIME_LIBRARY_DEFAULT ON)

if(MSVC_VER EQUAL 1)
	# ad-hoc LINK.exe command line for MSVC 1.x
	set(CMAKE_C_LINK_EXECUTABLE "<CMAKE_LINKER> ${CMAKE_CL_NOLOGO} <CMAKE_C_LINK_FLAGS> <LINK_FLAGS> <OBJECTS> ${CMAKE_START_TEMP_FILE} <TARGET>,,<LINK_LIBRARIES>,,${CMAKE_END_TEMP_FILE}")
endif()