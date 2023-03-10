cmake_minimum_required(VERSION 3.21)
project(hellowin C)

add_executable(helloworld helloworld.c)

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