cmake_minimum_required(VERSION 3.22)
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")
include(vcpkg_bootstrap)

bootstrap_vcpkg()
set(EXECUTABLE_NAME GCT2024)
project(${EXECUTABLE_NAME} C CXX)
set(CMAKE_C_STANDARD)
set(CMAKE_CXX_STANDARD 17)

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)
include(CheckIPOSupported)
include(CPack)
include(CMakeFindDependencyMacro)

find_package(Vulkan)
find_package(OpenGL)


set(CMAKE_CONFIGURATION_TYPES "Debug;Release")

if (CMAKE_SYSTEM_NAME STREQUAL Linux)
    set(THREADS_PREFER_PTHREAD_FLAG ON)
    find_package(Threads REQUIRED)
endif()

foreach( OUTPUTCONFIG ${CMAKE_CONFIGURATION_TYPES} )
    string( TOUPPER ${OUTPUTCONFIG} OUTPUTCONFIG )
    set( CMAKE_ARCHIVE_OUTPUT_DIRECTORY_${OUTPUTCONFIG} ${CMAKE_SOURCE_DIR}/bin )
    set( CMAKE_LIBRARY_OUTPUT_DIRECTORY_${OUTPUTCONFIG} ${CMAKE_SOURCE_DIR}/bin )
    set( CMAKE_RUNTIME_OUTPUT_DIRECTORY_${OUTPUTCONFIG} ${CMAKE_SOURCE_DIR}/bin )
	set( CMAKE_${OUTPUTCONFIG}_POSTFIX ${OUTPUTCONFIG})
endforeach( OUTPUTCONFIG CMAKE_CONFIGURATION_TYPES )

option(BUILD_TESTING "Build Testing" OFF)
# Define installation folder and the module path 
set(CMAKE_INSTALL_PREFIX ${CMAKE_BINARY_DIR}/install)

add_subdirectory(libs)
add_subdirectory(src)

# Define the source and destination paths
set(DATA_FOLDER "${CMAKE_SOURCE_DIR}/data")
set(OUTPUT_FOLDER "${CMAKE_SOURCE_DIR}/bin/data")

# Add a custom command to copy the folder
add_custom_command(
    OUTPUT "${OUTPUT_FOLDER}"
    COMMAND ${CMAKE_COMMAND} -E copy_directory "${DATA_FOLDER}" "${OUTPUT_FOLDER}"
    DEPENDS "${DATA_FOLDER}" # This ensures the folder is re-copied if it changes
    COMMENT "Copying data folder to ${OUTPUT_FOLDER}"
)

# Add a custom target to trigger the copy command
add_custom_target(copy_data ALL
    DEPENDS "${OUTPUT_FOLDER}"
)