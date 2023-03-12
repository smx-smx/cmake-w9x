cmake_minimum_required(VERSION 3.21)
project(hellowin C)

msvc_add_targets(
	WITHOUT_QUICKWIN
	TARGET_NAME helloworld
	SOURCES helloworld.c
	DEF_FILE ${CMAKE_SOURCE_DIR}/helloworld.def
)
