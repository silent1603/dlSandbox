# Function to bootstrap vcpkg
function(bootstrap_vcpkg)
    set(VCPKG_DIR "${CMAKE_SOURCE_DIR}/tools/vcpkg")
    # Set the toolchain file for vcpkg
    set(CMAKE_TOOLCHAIN_FILE "${VCPKG_DIR}/scripts/buildsystems/vcpkg.cmake" CACHE STRING "Vcpkg toolchain file")
    set(VCPKG_BINARY "")
 
    if(CMAKE_HOST_SYSTEM_NAME  MATCHES Windows)
        message(STATUS "Window")
        set(VCPKG_BINARY "${VCPKG_DIR}/vcpkg.exe")
        set(VCPKG_BOOTSTRAP "${VCPKG_DIR}/bootstrap-vcpkg.bat") 
    else()
        message(STATUS "Linux")
        set(VCPKG_BINARY "${VCPKG_DIR}/vcpkg")
        set(VCPKG_BOOTSTRAP "${VCPKG_DIR}/bootstrap-vcpkg.sh") 
    endif()

    if(NOT EXISTS "${VCPKG_BINARY}")
        message(STATUS "Bootstrapping vcpkg...")
        if(WIN32)
            execute_process(COMMAND cmd /c "${VCPKG_BOOTSTRAP_SCRIPT}"
                            WORKING_DIRECTORY "${VCPKG_DIR}"
                            RESULT_VARIABLE VCPKG_BOOTSTRAP_RESULT)
        else()
            execute_process(COMMAND bash "${VCPKG_BOOTSTRAP_SCRIPT}"
                            WORKING_DIRECTORY "${VCPKG_DIR}"
                            RESULT_VARIABLE VCPKG_BOOTSTRAP_RESULT)
        endif()

        if(NOT VCPKG_BOOTSTRAP_RESULT EQUAL 0)
            message(FATAL_ERROR "Failed to bootstrap vcpkg!")
        endif()
    else()
        message(STATUS "vcpkg is already bootstrapped.")
    endif()
endfunction()