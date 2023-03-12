cmake_minimum_required(VERSION 3.21)
project(hellowin C)

add_executable(helloworld helloworld.c)
target_link_options(helloworld PRIVATE "/MAP:${CMAKE_BINARY_DIR}/helloworld.map")

set_target_properties(helloworld PROPERTIES
	MSVC_DEFFILE ${CMAKE_SOURCE_DIR}/helloworld.def
)

if(CL_IS_MSC)
	set_target_properties(helloworld PROPERTIES
		MSVC_PLATFORM WIN16
		MSVC_OS WIN1
		MSVC_MMODEL SMALL
	)
endif()

if(CL_SUPPORTS_WIN16)
	set_target_properties(helloworld PROPERTIES
		MSVC_PLATFORM WIN16
		MSVC_MMODEL LARGE
	)
	
	add_executable(d_helloworld helloworld.c)
	set_target_properties(d_helloworld PROPERTIES
		MSVC_PLATFORM DOS
		MSVC_MMODEL SMALL
	)
	setup_msvc_target(d_helloworld)
else()
	set_target_properties(helloworld PROPERTIES
		MSVC_PLATFORM WIN32
		MSVC_SUBSYSTEM windows
	)
	target_link_libraries(helloworld user32)
endif()

if(CL_WIN32)
	# /subsystem:windows
	set_target_properties(helloworld
		PROPERTIES 
			WIN32_EXECUTABLE ON
			MSVC_PLATFORM WIN32
	)
	target_link_libraries(helloworld user32)
endif()

setup_msvc_target(helloworld)
