# CMakeList.txt: preda_preoject
#
cmake_minimum_required(VERSION 3.18)

# set(CMAKE_CONFIGURATION_TYPES "Debug;Release;StaticLibDebug;StaticLibRelease" CACHE STRING "" FORCE)
# Enable Hot Reload for MSVC compilers if supported.
if(POLICY CMP0135)
    cmake_policy(SET CMP0135 NEW)
    set(CMAKE_MSVC_DEBUG_INFORMATION_FORMAT "$<IF:$<AND:$<C_COMPILER_ID:MSVC>,$<CXX_COMPILER_ID:MSVC>>,$<$<CONFIG:Debug,RelWithDebInfo>:EditAndContinue>,$<$<CONFIG:Debug,RelWithDebInfo>:ProgramDatabase>>")

    # set(CMAKE_MSVC_DEBUG_INFORMATION_FORMAT "$<IF:$<AND:$<C_COMPILER_ID:MSVC>,$<CXX_COMPILER_ID:MSVC>>,$<$<CONFIG:Debug,StaticLibDebug>:EditAndContinue>,$<$<CONFIG:Debug,StaticLibDebug>:ProgramDatabase>>")
endif()

set(CMAKE_CXX_FLAGS_DEBUG "/MTd")
set(CMAKE_CXX_FLAGS_RELEASE "/MT")

project("oxd_libsec")

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif()

set(CMAKE_CONFIGURATION_TYPES Release Debug)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

function(win_sdk_rule target)
    if(MSVC)
        # Retrieve the necessary environment variables from the vcvars config
        # include("${CMAKE_CURRENT_LIST_DIR}/path/to/vcvars.cmake")  # Path to your vcvars file
        string(REPLACE "\\" "/" VC_TOOLS_DIR ${CMAKE_VS_PLATFORM_TOOLSET})
        set(vcvars_INCLUDE "${VC_TOOLS_DIR}/Include")
        set(vcvars_LIB "${VC_TOOLS_DIR}/Lib")
        set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /MT")
        set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /MTd")

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
            CMAKE_C_FLAGS_StaticLibDebug CMAKE_C_FLAGS_StaticLibRelease
            CMAKE_CXX_FLAGS CMAKE_CXX_FLAGS_DEBUG CMAKE_CXX_FLAGS_RELEASE
            CMAKE_CXX_FLAGS_MINSIZEREL CMAKE_CXX_FLAGS_RELWITHDEBINFO
            CMAKE_CXX_FLAGS_StaticLibDebug CMAKE_CXX_FLAGS_StaticLibRelease
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
file(GLOB ESSENTIALS_SOURCES ../CPCF/essentials.*)
file(GLOB BOTAN_SOURCES ../CPCF/core/ext/botan/botan.*)
file(GLOB OXD_LIBSEC_SOURCES src/*.cpp)
file(GLOB LIBSODIUM_SOURCES src/libsodium/*.cpp)
file(GLOB OXD_LIBSEC_HEAD src/*.h)
set(GROUP_FILE ${OXD_LIBSEC_HEAD})
source_group("CPCF" FILES
    ${BOTAN_SOURCES}
    ${ESSENTIALS_SOURCES}
)

# source_group(TREE ${PROJECT_SOURCE_DIR} FILES ${LIBSODIUM_SOURCES} ${GROUP_FILE})
source_group(TREE ${PROJECT_SOURCE_DIR} FILES ${OXD_LIBSEC_SOURCES} ${GROUP_FILE} ${LIBSODIUM_SOURCES})
add_library(oxd_libsec STATIC
    ${ESSENTIALS_SOURCES}
    ${BOTAN_SOURCES}
    ${OXD_LIBSEC_SOURCES}
    ${LIBSODIUM_SOURCES}
)

if(WIN32)
    file(GLOB WIN_IPP_LIBS ../CPCF/libs/win/ipp*.lib)
    target_link_directories(oxd_libsec PRIVATE ../CPCF/libs/win)
    target_link_libraries(oxd_libsec PRIVATE ${WIN_IPP_LIBS})
    win_sdk_rule(oxd_libsec)
    set_target_properties(oxd_libsec PROPERTIES
        MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug,StaticLibDebug>:Debug>"

        # STATICLIBDEBUG_POSTFIX "_d"
    )
    target_compile_definitions(oxd_libsec PRIVATE -DUNICODE -D_UNICODE _CONSOLE)
    target_compile_options(oxd_libsec PRIVATE
        $<$<CONFIG:Debug,StaticLibDebug>:/ZI /JMC /W3 /sdl /RTC1 /permissive /Od /bigobj>
        $<$<CONFIG:Release,StaticLibRelease>:/Zi /W3 /sdl /Gy /permissive /O2 /Oi /GL>
    )

    # ##################### add libsec_test to build as exe ###################################
    add_executable(libsec_test
        ${ESSENTIALS_SOURCES}
        ${BOTAN_SOURCES}
        ${OXD_LIBSEC_SOURCES}
        ${LIBSODIUM_SOURCES}
    )
    target_sources(libsec_test PRIVATE
        test/sec_tests.cpp
        test/proj.win/main.cpp
    )
    target_link_directories(libsec_test PRIVATE ../CPCF/libs/win)
    target_link_libraries(libsec_test PRIVATE ${WIN_IPP_LIBS})
    win_sdk_rule(libsec_test)
    set_target_properties(libsec_test PROPERTIES
        MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug,StaticLibDebug>:Debug>"

        # STATICLIBDEBUG_POSTFIX "_d"
    )
    target_include_directories(libsec_test PRIVATE src/libsodium/libsodium/src/libsodium/include/sodium)
    target_compile_definitions(libsec_test PRIVATE -DUNICODE -D_UNICODE _CONSOLE)
    target_compile_options(libsec_test PRIVATE
        $<$<CONFIG:Debug,StaticLibDebug>:/ZI /JMC /W3 /sdl /RTC1 /permissive /Od /bigobj>
        $<$<CONFIG:Release,StaticLibRelease>:/Zi /W3 /sdl /Gy /permissive /O2 /Oi /GL>
    )
elseif(UNIX AND NOT APPLE)
    # linux_link_ipp_rule(oxd_libsec)
    target_link_directories(oxd_libsec PRIVATE ../CPCF/libs/linux)
    file(GLOB LINUX_IPP_LIBS ../CPCF/libs/linux/ipp*.a)
    target_link_libraries(oxd_libsec PRIVATE
        pthread dl X11
    )
    target_link_libraries(oxd_libsec PRIVATE ${LINUX_IPP_LIBS})
    add_compile_options(-fPIC -pthread -ldl -lX11)
elseif(APPLE)
    file(GLOB MAC_LIBS ../CPCF/libs/mac/ipp*.a)
    target_link_directories(oxd_libsec PRIVATE ../CPCF/libs/mac)
    list(APPEND OXD_LIBSEC_SOURCES ../CPCF/core/os/objc_wrap.mm)
    target_link_libraries(oxd_libsec PRIVATE ${MAC_LIBS})
    set(CMAKE_OSX_DEPLOYMENT_TARGET 10.14)
endif()

# set oxd_libsec name as oxd_libsec_d in debug mode
target_include_directories(oxd_libsec PRIVATE ./src/libsodium/libsodium/src/libsodium/include/sodium)
set_target_properties(oxd_libsec PROPERTIES DEBUG_POSTFIX "_d")
set_target_properties(oxd_libsec PROPERTIES OUTPUT_NAME "oxd_libsec")
set_target_properties(oxd_libsec PROPERTIES ENABLE_EXPORTS ON)
set_target_properties(oxd_libsec PROPERTIES POSITION_INDEPENDENT_CODE ON)
set_target_properties(oxd_libsec PROPERTIES
    ARCHIVE_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/lib/$<0:>
    LIBRARY_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/lib/$<0:>
)