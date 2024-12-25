
set(EXECUTABLE_NAME game)
set(TARGET_SOURCE "")
if (ANDROID)
	# The SDL java code is hardcoded to load libmain.so on android, so we need to change EXECUTABLE_NAME
	set(EXECUTABLE_NAME main)
	add_library(${EXECUTABLE_NAME} SHARED)
elseif(CMAKE_SYSTEM_NAME MATCHES Windows)
	add_executable(${EXECUTABLE_NAME} WIN32)
else()
	add_executable(${EXECUTABLE_NAME})
endif()


file(GLOB_RECURSE TARGET_SOURCE "${CMAKE_CURRENT_SOURCE_DIR}/*.cpp" "${CMAKE_CURRENT_SOURCE_DIR}/*.h")
list(FILTER TARGET_SOURCE EXCLUDE REGEX "${CMAKE_CURRENT_SOURCE_DIR}/Entry/*.*" )

# on Web targets, we need CMake to generate a HTML webpage. 
if(CMAKE_SYSTEM_NAME MATCHES Emscripten)
	set(CMAKE_EXECUTABLE_SUFFIX ".html" CACHE INTERNAL "")
	file(GLOB WASM_ENTRY  "${CMAKE_CURRENT_SOURCE_DIR}/Entry/Windows/main.cpp")
	list(APPEND TARGET_SOURCE ${WASM_ENTRY})
	target_link_options(${EXECUTABLE_NAME} PRIVATE -sEXPORTED_FUNCTIONS=_main)
    target_link_options(${EXECUTABLE_NAME} PRIVATE -sWASM=1)
	# File system support: https://emscripten.org/docs/api_reference/Filesystem-API.html#including-file-system-support
    target_link_options(${EXECUTABLE_NAME} PRIVATE -sWASMFS -sFORCE_FILESYSTEM -sEXPORTED_RUNTIME_METHODS=['ccall','cwrap','FS'])
    target_link_options(${EXECUTABLE_NAME} PRIVATE --shell-file "${CMAKE_CURRENT_SOURCE_DIR}/Entry/Wasm/main.html")
	target_link_options(${EXECUTABLE_NAME} PRIVATE  $<$<CONFIG:Debug>:"-sASSERTIONS=1">)
    # link with WebGL2
    target_link_options(${EXECUTABLE_NAME} PRIVATE -sUSE_WEBGL2=1  --bind -sALLOW_MEMORY_GROWTH=1 -sNO_EXIT_RUNTIME=1  ${EXTRA_FLAGS}  --preload-file ${PROJECT_SOURCE_DIR}/data@/ )
    # link with WebGPU 
    #-sASYNCIFY # Required by WebGPU-C++
    target_link_options(${EXECUTABLE_NAME} PRIVATE -sUSE_WEBGPU -sASYNCIFY)
    # WASM+JS size optimizations
    target_link_options(${EXECUTABLE_NAME} PRIVATE -sASSERTIONS=0 -sMALLOC=emmalloc --closure=1)
    if (GAME_WASM_SINGLE_FILE)
        message(STATUS "Embedding WASM inside .js")
		target_link_options(${EXECUTABLE_NAME} PRIVATE -sSINGLE_FILE=1)
    endif()
elseif(CMAKE_SYSTEM_NAME MATCHES Windows)
	file(GLOB WINDOWS_ENTRY  "${CMAKE_CURRENT_SOURCE_DIR}/Entry/Windows/main.cpp")
	list(APPEND TARGET_SOURCE ${WINDOWS_ENTRY})
	set_property(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY VS_STARTUP_PROJECT "${EXECUTABLE_NAME}")
endif()

source_group(TREE "${CMAKE_CURRENT_SOURCE_DIR}" FILES ${TARGET_SOURCE})

target_include_directories(${EXECUTABLE_NAME} PRIVATE "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/>" 
											PRIVATE "$<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/libs/mlpack/src>" )
set_property(TARGET ${EXECUTABLE_NAME} PROPERTY VS_DEBUGGER_WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/bin")
target_link_libraries(${EXECUTABLE_NAME} 
				PRIVATE ${OPENGL_LIBRARIES}
)

target_sources(${EXECUTABLE_NAME} PRIVATE "${TARGET_SOURCE}")


install(TARGETS ${EXECUTABLE_NAME})