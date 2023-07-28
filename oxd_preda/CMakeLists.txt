# CMakeList.txt: preda_preoject
#
cmake_minimum_required(VERSION 3.8)

# Enable Hot Reload for MSVC compilers if supported.
if(POLICY CMP0135)
    cmake_policy(SET CMP0135 NEW)
    set(CMAKE_MSVC_DEBUG_INFORMATION_FORMAT "$<IF:$<AND:$<C_COMPILER_ID:MSVC>,$<CXX_COMPILER_ID:MSVC>>,$<$<CONFIG:Debug,RelWithDebInfo>:EditAndContinue>,$<$<CONFIG:Debug,RelWithDebInfo>:ProgramDatabase>>")
endif()

include(CMake_rules.txt)
project("oxd_preda")

# # set golbal config for each platform
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif()

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CONFIGURATION_TYPES Release Debug)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/PREDA/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/PREDA/bin)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/PREDA/bin)
set(CMAKE_INSTALL_PREFIX ${CMAKE_BINARY_DIR})

if(WIN32)
    # Use the USERPROFILE environment variable to get the user's home directory on Windows
    execute_process(COMMAND cmd /c "echo %USERPROFILE%" OUTPUT_VARIABLE HOME_DIR OUTPUT_STRIP_TRAILING_WHITESPACE)
else()
    # For non-Windows platforms, use the HOME environment variable to get the user's home directory
    execute_process(COMMAND bash -c "echo $ENV{HOME}" OUTPUT_VARIABLE HOME_DIR OUTPUT_STRIP_TRAILING_WHITESPACE)
endif()

set(PROJECT_BUILD_DIR ${CMAKE_BINARY_DIR})
set(DOWNLOAD_DIR "${HOME_DIR}/.cmake")
file(MAKE_DIRECTORY ${DOWNLOAD_DIR})
option(DOWNLOAD_OPS "download 3rdParty packages" OFF)

if(DOWNLOAD_OPS)
    message(STATUS "DOWNLOAD_OPS is ${DOWNLOAD_OPS}")

    # # download wasmtime
    set(3rdParty ${CMAKE_CURRENT_SOURCE_DIR}/3rdParty)

    if(CMAKE_HOST_SYSTEM_NAME MATCHES "Windows")
        message("CMAKE_HOST_SYSTEM_NAME: ${CMAKE_HOST_SYSTEM_NAME}, begin download wasmtime package")
        set(URL "https://github.com/preda-devteam/preda/releases/download/wasmtime/wasmtime-x86_64-windows-c-api.7z")
        set(SHA256 "F6173B17D8848AC8CCDDB1E8F5CC7517AD9847A539856216CEBCE6D1E0CF651B")
        file(DOWNLOAD ${URL} ${DOWNLOAD_DIR}/wasmtime-x86_64-windows-c-api.7z SHOW_PROGRESS EXPECTED_HASH SHA256=${SHA256})
        file(ARCHIVE_EXTRACT INPUT ${DOWNLOAD_DIR}/wasmtime-x86_64-windows-c-api.7z DESTINATION ${DOWNLOAD_DIR})
        file(INSTALL ${DOWNLOAD_DIR}/wasmtime-dev-x86_64-windows-c-api/ DESTINATION ${3rdParty}/wasmtime FOLLOW_SYMLINK_CHAIN USE_SOURCE_PERMISSIONS)
    elseif(CMAKE_HOST_SYSTEM_NAME MATCHES "Linux")
        message("CMAKE_HOST_SYSTEM_NAME: ${CMAKE_HOST_SYSTEM_NAME}, begin download wasmtime package")
        set(URL "https://github.com/preda-devteam/preda/releases/download/wasmtime/wasmtime-x86_64-linux-c-api.7z")
        set(SHA256 "839899455A9E97FE82B61478F22619ED8877D4DCFC1AE7743026D6197825B80F")
        file(DOWNLOAD ${URL} ${DOWNLOAD_DIR}/wasmtime-x86_64-linux-c-api.7z SHOW_PROGRESS EXPECTED_HASH SHA256=${SHA256})
        file(ARCHIVE_EXTRACT INPUT ${DOWNLOAD_DIR}/wasmtime-x86_64-linux-c-api.7z DESTINATION ${DOWNLOAD_DIR})
        file(INSTALL ${DOWNLOAD_DIR}/wasmtime-dev-x86_64-linux-c-api/ DESTINATION ${3rdParty}/wasmtime FOLLOW_SYMLINK_CHAIN USE_SOURCE_PERMISSIONS)
    elseif(CMAKE_HOST_SYSTEM_NAME MATCHES "Darwin")
        message("CMAKE_HOST_SYSTEM_NAME: ${CMAKE_HOST_SYSTEM_NAME}, begin download wasmtime package")
        set(URL "https://github.com/preda-devteam/preda/releases/download/wasmtime/wasmtime-x86_64-macos-c-api.7z")
        set(SHA256 "D70C8BE5757AC1C45BBD8D1673EB2D5FD51BEE2A21BBFE060A9C880BA5A3DD10")
        file(DOWNLOAD ${URL} ${DOWNLOAD_DIR}/wasmtime-x86_64-macos-c-api.7z SHOW_PROGRESS EXPECTED_HASH SHA256=${SHA256})
        file(ARCHIVE_EXTRACT INPUT ${DOWNLOAD_DIR}/wasmtime-x86_64-macos-c-api.7z DESTINATION ${DOWNLOAD_DIR})
        file(INSTALL ${DOWNLOAD_DIR}/wasmtime-dev-x86_64-macos-c-api/ DESTINATION ${3rdParty}/wasmtime FOLLOW_SYMLINK_CHAIN USE_SOURCE_PERMISSIONS)
    else()
        message("current OS platform unkonw, download wasmtime latest failed.....")
    endif()

    # # download and install mingw64
    if(WIN32)
        message("CMAKE_HOST_SYSTEM_NAME: ${CMAKE_HOST_SYSTEM_NAME}, begin download mingw64 package")
        set(URL "https://github.com/preda-devteam/preda/releases/download/mingw64/x86_64-8.1.0-release-win32-seh-rt_v6-rev0.7z")
        set(SHA256 "73797B9A1D0B007DBDD6F010E6064DC0AA4DF835B042F6947F73A3BF9CC348C5")
        file(DOWNLOAD ${URL} ${DOWNLOAD_DIR}/x86_64-8.1.0-release-win32-seh-rt_v6-rev0.7z SHOW_PROGRESS EXPECTED_HASH SHA256=${SHA256})
        file(ARCHIVE_EXTRACT INPUT ${DOWNLOAD_DIR}/x86_64-8.1.0-release-win32-seh-rt_v6-rev0.7z DESTINATION ${CMAKE_CURRENT_SOURCE_DIR}/bin/)
    endif(WIN32)

    # # download emscripten
    set(ems_version "3.1.24")

    if(CMAKE_HOST_SYSTEM_NAME MATCHES "Windows")
        message("CMAKE_HOST_SYSTEM_NAME: ${CMAKE_HOST_SYSTEM_NAME}, begin download emscripten package")
        set(URL "https://github.com/preda-devteam/preda/releases/download/emscripten/emscripten-3.1.24-win-x64.7z")
        set(SHA256 "6497B23C41204C36FE3C332AC147B3176A5764D3D80F6E1C6DDEB7E38B2918FC")
        file(DOWNLOAD ${URL} ${DOWNLOAD_DIR}/emscripten-3.1.24-win-x64.7z SHOW_PROGRESS EXPECTED_HASH SHA256=${SHA256})
        file(ARCHIVE_EXTRACT INPUT ${DOWNLOAD_DIR}/emscripten-3.1.24-win-x64.7z DESTINATION ${CMAKE_CURRENT_SOURCE_DIR}/bin/emscripten/)
        file(REMOVE_RECURSE ${CMAKE_CURRENT_SOURCE_DIR}/bin/emscripten/${ems_version})
        file(RENAME ${CMAKE_CURRENT_SOURCE_DIR}/bin/emscripten/emscripten-3.1.24-win-x64 ${CMAKE_CURRENT_SOURCE_DIR}/bin/emscripten/${ems_version})
    elseif(CMAKE_HOST_SYSTEM_NAME MATCHES "Linux")
        message("CMAKE_HOST_SYSTEM_NAME: ${CMAKE_HOST_SYSTEM_NAME}, begin download emscripten package")
        set(URL "https://github.com/preda-devteam/preda/releases/download/emscripten/emscripten-3.1.24-linux-x64.7z")
        set(SHA256 "624C89303BC6A0D3D512A0D880BC10FFAB55C3FC040D45167211DE91183E585E")
        file(DOWNLOAD ${URL} ${DOWNLOAD_DIR}/emscripten-3.1.24-linux-x64.7z SHOW_PROGRESS EXPECTED_HASH SHA256=${SHA256})
        file(ARCHIVE_EXTRACT INPUT ${DOWNLOAD_DIR}/emscripten-3.1.24-linux-x64.7z DESTINATION ${CMAKE_CURRENT_SOURCE_DIR}/bin/emscripten/)
        file(REMOVE_RECURSE ${CMAKE_CURRENT_SOURCE_DIR}/bin/emscripten/${ems_version})
        file(RENAME ${CMAKE_CURRENT_SOURCE_DIR}/bin/emscripten/emscripten-3.1.24-linux-x64 ${CMAKE_CURRENT_SOURCE_DIR}/bin/emscripten/${ems_version})
    elseif(CMAKE_HOST_SYSTEM_NAME MATCHES "Darwin")
        message("CMAKE_HOST_SYSTEM_NAME: ${CMAKE_HOST_SYSTEM_NAME}, begin download emscripten package")
        set(URL "https://github.com/preda-devteam/preda/releases/download/emscripten/emscripten-3.1.24-mac-x64.7z")
        set(SHA256 "D9D7397F3A36AD4B57D848AE7ACA6D3C929E43850DDC9AFD7106453BD3AF886C")
        file(DOWNLOAD ${URL} ${DOWNLOAD_DIR}/emscripten-3.1.24-mac-x64.7z SHOW_PROGRESS EXPECTED_HASH SHA256=${SHA256})
        file(ARCHIVE_EXTRACT INPUT ${DOWNLOAD_DIR}/emscripten-3.1.24-mac-x64.7z DESTINATION ${CMAKE_CURRENT_SOURCE_DIR}/bin/emscripten/)
        file(REMOVE_RECURSE ${CMAKE_CURRENT_SOURCE_DIR}/bin/emscripten/${ems_version})
        file(RENAME ${CMAKE_CURRENT_SOURCE_DIR}/bin/emscripten/emscripten-3.1.24-mac-x64 ${CMAKE_CURRENT_SOURCE_DIR}/bin/emscripten/${ems_version})
    else()
        message("current OS platform unkonw, download wasmtime latest failed.....")
    endif()

    # # download solc
    set(SOLC_VERSION "v0.8.18")

    if(CMAKE_HOST_SYSTEM_NAME MATCHES "Windows")
        message("CMAKE_HOST_SYSTEM_NAME: ${CMAKE_HOST_SYSTEM_NAME}, begin download solc package")
        set(URL "https://github.com/ethereum/solidity/releases/download/${SOLC_VERSION}/solc-windows.exe")
        set(SHA256 "3413D777E5A08E7240C5DC7E6A61AFBC5FB78949BA0AA81CA3C9E9AD31D03490")
        file(DOWNLOAD ${URL} ${DOWNLOAD_DIR}/solc/solc-windows.exe SHOW_PROGRESS EXPECTED_HASH SHA256=${SHA256})
        file(INSTALL ${DOWNLOAD_DIR}/solc/solc-windows.exe DESTINATION ${CMAKE_CURRENT_SOURCE_DIR}/bin/solc FOLLOW_SYMLINK_CHAIN USE_SOURCE_PERMISSIONS)
    elseif(CMAKE_HOST_SYSTEM_NAME MATCHES "Linux")
        message("CMAKE_HOST_SYSTEM_NAME: ${CMAKE_HOST_SYSTEM_NAME}, begin download solc package")
        set(URL "https://github.com/ethereum/solidity/releases/download/${SOLC_VERSION}/solc-static-linux")
        set(SHA256 "95E6ED4949A63AD89AFB443ECBA1FB8302DD2860EE5E9BAACE3E674A0F48AA77")
        file(DOWNLOAD ${URL} ${DOWNLOAD_DIR}/solc-static-linux SHOW_PROGRESS EXPECTED_HASH SHA256=${SHA256})
        file(INSTALL ${DOWNLOAD_DIR}/solc-static-linux DESTINATION ${CMAKE_CURRENT_SOURCE_DIR}/bin/solc USE_SOURCE_PERMISSIONS)
    elseif(CMAKE_HOST_SYSTEM_NAME MATCHES "Darwin")
        message("CMAKE_HOST_SYSTEM_NAME: ${CMAKE_HOST_SYSTEM_NAME}, begin download solc package")
        set(URL "https://github.com/ethereum/solidity/releases/download/${SOLC_VERSION}/solc-macos")
        set(SHA256 "8F15287C799AD2B33F241D1252226ABDA5D4BC3EF6BE40B946923178FC57D397")
        file(DOWNLOAD ${URL} ${DOWNLOAD_DIR}/solc-macos SHOW_PROGRESS EXPECTED_HASH SHA256=${SHA256})
        file(INSTALL ${DOWNLOAD_DIR}/solc-macos DESTINATION ${CMAKE_CURRENT_SOURCE_DIR}/bin/solc FOLLOW_SYMLINK_CHAIN USE_SOURCE_PERMISSIONS)
    else()
        message("current OS platform unkonw,${CMAKE_HOST_SYSTEM_NAME} download solc latest failed.....")
    endif()
else()
    message(STATUS "DOWNLOAD_OPS is ${DOWNLOAD_OPS}")
    message("Download 3rdParty is off by default, please set -DDOWNLOAD_OPS=ON to download")
endif()

# ############### Determine if the oxd_libsec exists ####################
# if(NOT "$<CONFIG>" MATCHES "Release")
# set(OXD_LIBSEC_NAME oxd_libsec_d)
# else()
# set(OXD_LIBSEC_NAME oxd_libsec)
# endif()
if(WIN32)
    file(GLOB OXD_LIBSEC_NAME ../oxd_libsec/lib/oxd_libsec*.lib)
    file(GLOB IPP_LIB ../CPCF/libs/win/*.lib)
elseif(UNIX AND NOT APPLE)
    file(GLOB OXD_LIBSEC_NAME ../oxd_libsec/lib/liboxd_libsec*.a)
    file(GLOB IPP_LIB ../CPCF/libs/linux/*.a)
elseif(APPLE)
    file(GLOB OXD_LIBSEC_NAME ../oxd_libsec/lib/liboxd_libsec*.a)
    file(GLOB IPP_LIB ../CPCF/libs/mac/*.a)
endif()

if(OXD_LIBSEC_NAME STREQUAL "")
    message(WARNING "Can not find oxd_libsec library in ../oxd_libsec/lib, please build oxd_libsec first....")
endif()

message("oxd_libsec list ${OXD_LIBSEC_NAME}")

# ############### build autlr4 ##############################
if(WIN32)
    set(ANTLR4_DIR ./3rdParty/antlr4/runtime/Cpp)
    include_directories(
        ${ANTLR4_DIR}/runtime/src/support
        ${ANTLR4_DIR}/runtime/src/tree
        ${ANTLR4_DIR}/runtime/src/misc
        ${ANTLR4_DIR}/runtime/src/tree/pattern
        ${ANTLR4_DIR}/runtime/src/dfa
        ${ANTLR4_DIR}/runtime/src
        ${ANTLR4_DIR}/runtime/src/atn
        ${ANTLR4_DIR}/runtime/src/tree/xpath
    )

    file(GLOB_RECURSE ANTLR4_SOURCE
        ${ANTLR4_DIR}/runtime/src/*.cpp
        ${ANTLR4_DIR}/runtime/src/atn/*.cpp
        ${ANTLR4_DIR}/runtime/src/dfa/*.cpp
        ${ANTLR4_DIR}/runtime/src/misc/*.cpp
        ${ANTLR4_DIR}/runtime/src/support/*.cpp
        ${ANTLR4_DIR}/runtime/src/tree/*.cpp
        ${ANTLR4_DIR}/runtime/src/tree/pattern/*.cpp
        ${ANTLR4_DIR}/runtime/src/tree/xpath/*.cpp
    )
    add_library(antlr4-runtime STATIC
        ${ANTLR4_SOURCE}
    )
    target_compile_definitions(antlr4-runtime PRIVATE ANTLR4CPP_STATIC)
    set_target_properties(antlr4-runtime PROPERTIES
        OUTPUT_NAME "antlr4-runtime"
    )

elseif(UNIX OR APPLE)
    set(BUILD_SHARED_LIBS ON)
    set(CMAKE_BUILD_WITH_INSTALL_RPATH TRUE)
    set(CMAKE_MACOSX_RPATH TRUE)
    set(CMAKE_INSTALL_NAME_DIR "@rpath")
    add_subdirectory(./3rdParty/antlr4/runtime/Cpp)
endif()

# ########### build preda_engine ######################
add_subdirectory(engine)

# ############### build transpiler ###############
add_subdirectory(transpiler)

# ############## build chain_simulator #################
add_subdirectory(simulator)

# ############### add 3rParty target #######################
add_custom_target(3rdParty
    WORKING_DIRECTORY ${PROJECT_BUILD_DIR}
    COMMAND ${CMAKE_COMMAND} -E make_directory ${PROJECT_BUILD_DIR}/PREDA/bin
    COMMAND ${CMAKE_COMMAND} -E make_directory ${PROJECT_BUILD_DIR}/PREDA/examples
    COMMAND ${CMAKE_COMMAND} -E make_directory ${PROJECT_BUILD_DIR}/PREDA/solc
    COMMENT "Setting up 3rdParty"
)
add_dependencies(3rdParty preda_engine transpiler chain_simulator)
file(GLOB_RECURSE SOLC_FILE LIST_DIRECTORIES FALSE ./bin/solc/solc*)
add_custom_command(TARGET 3rdParty POST_BUILD
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMAND ${CMAKE_COMMAND} -E copy ${SOLC_FILE} ${PROJECT_BUILD_DIR}/PREDA/solc/
    COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_CURRENT_SOURCE_DIR}/bin/compile_env ${PROJECT_BUILD_DIR}/PREDA/compile_env
    COMMENT "Copying examples and emscripten to directory"
    COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_CURRENT_SOURCE_DIR}/simulator/contracts ${PROJECT_BUILD_DIR}/PREDA/examples
    COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_CURRENT_SOURCE_DIR}/bin/emscripten ${PROJECT_BUILD_DIR}/PREDA/emscripten
    COMMENT "Copying commond files for 3rdParty"
)

if(WIN32)
    add_custom_command(TARGET 3rdParty POST_BUILD
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        COMMENT "Copying mingw64 and scripts files to directory"
        COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/3rdParty/evmone/win/bin/evmone.dll ${PROJECT_BUILD_DIR}/PREDA/bin/
        COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/3rdParty/wasmtime/lib/wasmtime.dll ${PROJECT_BUILD_DIR}/PREDA/bin/
        COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_CURRENT_SOURCE_DIR}/bin/mingw64 ${PROJECT_BUILD_DIR}/PREDA/mingw64
    )
elseif(UNIX AND NOT APPLE)
    add_custom_command(TARGET 3rdParty POST_BUILD
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        COMMENT "Copying files for 3rdParty on Linux"
        COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/3rdParty/wasmtime/lib/libwasmtime.so ${PROJECT_BUILD_DIR}/PREDA/bin
        COMMAND ${CMAKE_COMMAND} -E chdir ./ cp -a ${CMAKE_CURRENT_SOURCE_DIR}/3rdParty/evmone/linux/lib/libevmone* ${PROJECT_BUILD_DIR}/PREDA/bin
		COMMAND ${CMAKE_COMMAND} -E chdir ./ cp -a ${CMAKE_BINARY_DIR}/lib/libantlr4-runtime.so* ${PROJECT_BUILD_DIR}/PREDA/bin
        COMMAND ${CMAKE_COMMAND} -E chdir ${PROJECT_BUILD_DIR}/PREDA/emscripten chmod -R 755 ./3.1.24
    )
elseif(APPLE)
    add_custom_command(TARGET 3rdParty POST_BUILD
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/3rdParty/wasmtime/lib/libwasmtime.dylib ${PROJECT_BUILD_DIR}/PREDA/bin
        COMMAND ${CMAKE_COMMAND} -E chdir ./ cp -a ${CMAKE_CURRENT_SOURCE_DIR}/3rdParty/evmone/darwin/lib/libevmone.* ${PROJECT_BUILD_DIR}/PREDA/bin
        COMMAND ${CMAKE_COMMAND} -E chdir ./ cp -a ${CMAKE_BINARY_DIR}/lib/libantlr4-*.dylib ${PROJECT_BUILD_DIR}/PREDA/bin
        COMMAND ${CMAKE_COMMAND} -E chdir ${PROJECT_BUILD_DIR}/PREDA/emscripten chmod -R 755 ./3.1.24
        COMMENT "Copying files for 3rdParty on macOS"
    )
endif()

set_target_properties(3rdParty PROPERTIES
    EXCLUDE_FROM_ALL true
    EXCLUDE_FROM_DEFAULT_BUILD true
)
