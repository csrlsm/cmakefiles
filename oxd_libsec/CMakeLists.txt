# CMakeList.txt: preda_preoject
#
cmake_minimum_required(VERSION 3.18)

# Enable Hot Reload for MSVC compilers if supported.
if(POLICY CMP0135)
    cmake_policy(SET CMP0135 NEW)
    set(CMAKE_MSVC_DEBUG_INFORMATION_FORMAT "$<IF:$<AND:$<C_COMPILER_ID:MSVC>,$<CXX_COMPILER_ID:MSVC>>,$<$<CONFIG:Debug,RelWithDebInfo>:EditAndContinue>,$<$<CONFIG:Debug,RelWithDebInfo>:ProgramDatabase>>")
endif()

project("oxd_libsec")
set(CMAKE_CONFIGURATION_TYPES Release Debug RelWithDebInfo MinSizeRel)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif()

if(CMAKE_HOST_SYSTEM_NAME MATCHES "Windows")
    add_definitions(-DUNICODE -D_UNICODE)
elseif(CMAKE_HOST_SYSTEM_NAME MATCHES "Darwin")
    set(CMAKE_OSX_DEPLOYMENT_TARGET 10.14)
endif()

function(win_sdk_rule target)
    if(MSVC)
        # Retrieve the necessary environment variables from the vcvars config
        # include("${CMAKE_CURRENT_LIST_DIR}/path/to/vcvars.cmake")  # Path to your vcvars file
        string(REPLACE "\\" "/" VC_TOOLS_DIR ${CMAKE_VS_PLATFORM_TOOLSET})
        set(vcvars_INCLUDE "${VC_TOOLS_DIR}/Include")
        set(vcvars_LIB "${VC_TOOLS_DIR}/Lib")

        if(vcvars_INCLUDE)
            target_include_directories(${target} SYSTEM PRIVATE ${vcvars_INCLUDE})
        endif()

        target_link_libraries(${target} PRIVATE
            kernel32 user32 gdi32 winspool comdlg32 advapi32 shell32 ole32
            oleaut32 uuid odbc32 odbccp32 comctl32 setupapi shlwapi
        )

        foreach(flags
            CMAKE_C_FLAGS CMAKE_C_FLAGS_DEBUG CMAKE_C_FLAGS_RELEASE
            CMAKE_C_FLAGS_MINSIZEREL CMAKE_C_FLAGS_RELWITHDEBINFO
            CMAKE_CXX_FLAGS CMAKE_CXX_FLAGS_DEBUG CMAKE_CXX_FLAGS_RELEASE
            CMAKE_CXX_FLAGS_MINSIZEREL CMAKE_CXX_FLAGS_RELWITHDEBINFO
        )
            if(${flags} MATCHES "/MD")
                string(REGEX REPLACE "/MD" "/MT" ${flags} "${${flags}}")
            endif()
        endforeach()

        if(NOT MINGW)
            target_link_libraries(${target} PRIVATE strsafe)
        endif()
    endif()
endfunction()

# ################ build oxd_libsec.lib##########################
include_directories(
    ../CPCF
    ../CPCF/core/ext/botan
    ../oxd_libsec/src
    ../oxd_libsec/src/libsodium/libsodium/src/libsodium/include/sodium
)

file(GLOB ESSENTIALS_SOURCES ../CPCF/essentials.cpp)
file(GLOB BOTAN_SOURCES ../CPCF/core/ext/botan/botan.cpp)
file(GLOB OXD_LIBSEC_SOURCES ../oxd_libsec/src/*.cpp)
file(GLOB LIBSODIUM_SOURCES ../oxd_libsec/src/libsodium/*.cpp)

# file(GLOB files_to_remove "${PROJECT_SOURCE_DIR}/lib/*")
# foreach(file ${files_to_remove})
# file(REMOVE ${file})
# endforeach()
add_library(oxd_libsec STATIC
    ${ESSENTIALS_SOURCES}
    ${BOTAN_SOURCES}
    ${OXD_LIBSEC_SOURCES}
    ${LIBSODIUM_SOURCES}
)

if(WIN32)
    file(GLOB WIN_IPP_LIBS ../CPCF/libs/win/*.lib)
    add_compile_definitions(_CONSOLE)
    target_link_directories(oxd_libsec PRIVATE ../CPCF/libs/win)
    target_link_libraries(oxd_libsec PRIVATE ${WIN_IPP_LIBS})
    win_sdk_rule(oxd_libsec)
elseif(UNIX AND NOT APPLE)
    # linux_link_ipp_rule(oxd_libsec)
    target_link_directories(oxd_libsec PRIVATE ../CPCF/libs/linux)
    file(GLOB LINUX_IPP_LIBS ../CPCF/libs/linux/*.a)
    target_link_libraries(oxd_libsec PRIVATE
        pthread dl X11
    )
    target_link_libraries(oxd_libsec PRIVATE ${LINUX_IPP_LIBS})
    add_compile_options(-fPIC -pthread -ldl -lX11)
elseif(APPLE)
    file(GLOB MAC_LIBS ../CPCF/libs/mac/*.a)
    target_link_directories(oxd_libsec PRIVATE ../CPCF/libs/mac)
    list(APPEND OXD_LIBSEC_SOURCES ../CPCF/core/os/objc_wrap.mm)
    target_link_libraries(oxd_libsec PRIVATE ${MAC_LIBS})
endif()

# set oxd_libsec name as oxd_libsec_d in debug mode
set_target_properties(oxd_libsec PROPERTIES DEBUG_POSTFIX "_d")
set_target_properties(oxd_libsec PROPERTIES OUTPUT_NAME "oxd_libsec")
set_target_properties(oxd_libsec PROPERTIES ENABLE_EXPORTS ON)
set_target_properties(oxd_libsec PROPERTIES POSITION_INDEPENDENT_CODE ON)
set_target_properties(oxd_libsec PROPERTIES
    ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}
    LIBRARY_OUTPUT_DIRECTORY ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}
)
install(TARGETS oxd_libsec
    ARCHIVE DESTINATION ${PROJECT_SOURCE_DIR}/lib
    LIBRARY DESTINATION ${PROJECT_SOURCE_DIR}/lib
    RUNTIME DESTINATION ${PROJECT_SOURCE_DIR}/lib

    # CONFIGURATIONS $<CONFIG:Debug>
)
