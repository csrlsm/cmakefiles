# CMakeList.txt: preda_preoject
#
cmake_minimum_required(VERSION 3.18)

# Enable Hot Reload for MSVC compilers if supported.
if(POLICY CMP0135)
  cmake_policy(SET CMP0135 NEW)
  set(CMAKE_MSVC_DEBUG_INFORMATION_FORMAT "$<IF:$<AND:$<C_COMPILER_ID:MSVC>,$<CXX_COMPILER_ID:MSVC>>,$<$<CONFIG:Debug,RelWithDebInfo>:EditAndContinue>,$<$<CONFIG:Debug,RelWithDebInfo>:ProgramDatabase>>")
endif()

include(../CMake_rules.txt)
project("preda_engine")
file(GLOB_RECURSE PREDA_ENGINE_FILES
  ./preda_engine/*.cpp
  ./evm_engine/*.cpp
)
add_library(preda_engine SHARED ${PREDA_ENGINE_FILES})
target_sources(preda_engine
  PRIVATE
  ../../CPCF/core/ext/bignum/big_num.cpp
  ../../CPCF/core/ext/bignum/precision_num.cpp
  ../../CPCF/core/ext/lib_inc.c
  ../../CPCF/core/ext/rocksdb/rocksdb.cpp
  ../../CPCF/essentials.cpp
  ../native/types/data_jsonifer.cpp
  ../native/types/blob.cpp
  ../native/types/data.cpp
)
target_include_directories(preda_engine
  PRIVATE
  ../3rdParty/wasmtime/include
  ../3rdParty/evmc/include
  ../../CPCF/core/ext/rocksdb
  ../native/abi
  ../engine/preda_engine
)

# target_link_libraries(preda_engine PRIVATE oxd_libsec)
set_target_properties(preda_engine PROPERTIES
  BUILD_WITH_INSTALL_RPATH TRUE
  INSTALL_RPATH "."
)

if(WIN32)
  target_include_directories(preda_engine
    PRIVATE
    ../3rdParty/evmone/win/include
  )
  target_link_directories(preda_engine
    PRIVATE
    ../3rdParty/evmone/win/lib
    ../3rdParty/wasmtime/lib
    ../../CPCF/libs/win
  )
  target_link_libraries(preda_engine
    PRIVATE
    wasmtime.dll.lib
    evmone
    ${OXD_LIBSEC_NAME}
    ${IPP_LIB}
  )
  target_compile_definitions(preda_engine PRIVATE _WINDLL)
  target_compile_options(preda_engine PRIVATE ${CMAKE_CXX_FLAGS} /bigobj)
  target_sources(preda_engine
    PRIVATE
    ../../CPCF/core/ext/bignum/ttmath/ttmathuint_x86_64_msvc.asm
  )

  win_sdk_rule(preda_engine)
  install(TARGETS preda_engine
    RUNTIME DESTINATION ${PROJECT_BUILD_DIR}/PREDA/bin
  )
elseif(UNIX AND NOT APPLE)
  linux_link_ipp_rule(preda_engine)
  target_include_directories(preda_engine
    PRIVATE
    ../3rdParty/evmone/linux/include
  )
  target_link_directories(preda_engine
    PRIVATE
    ../3rdParty/evmone/linux/lib
    ../3rdParty/wasmtime/lib
    ../../CPCF/libs/linux
  )

  target_compile_options(preda_engine
    PRIVATE
    -fPIC
    -pthread
  )
  target_link_libraries(preda_engine
    PRIVATE
    wasmtime
    evmone
    ${OXD_LIBSEC_NAME}
    ${IPP_LIB}
  )

  set_target_properties(preda_engine PROPERTIES
    PREFIX ""
    SUFFIX ".so"
  )
  install(TARGETS preda_engine
    LIBRARY DESTINATION ${PROJECT_BUILD_DIR}/PREDA/bin
  )
elseif(APPLE)
  set(BUILD_SHARED_LIBS ON)
  target_include_directories(preda_engine
    PRIVATE
    ../3rdParty/evmone/darwin/include
  )
  target_link_directories(preda_engine
    PRIVATE
    ../../CPCF/libs/mac
    ../3rdParty/evmone/darwin/lib
    ../3rdParty/wasmtime/lib
  )
  target_sources(preda_engine
    PRIVATE
    ../../CPCF/core/os/objc_wrap.mm
  )
  target_link_libraries(preda_engine
    PRIVATE
    wasmtime
    evmon
    ${IPP_LIB}
    ${OXD_LIBSEC_NAME}
  )
  mac_link_rule(preda_engine)
  set_target_properties(preda_engine PROPERTIES
    PREFIX ""
    SUFFIX ".dylib"
  )
  install(TARGETS preda_engine
    LIBRARY DESTINATION ${PROJECT_BUILD_DIR}/PREDA/bin
  )
endif()

# set_policy(CMP0069 NEW)
set_property(TARGET preda_engine PROPERTY CXX_STANDARD 17)
set_property(TARGET preda_engine PROPERTY CXX_STANDARD_REQUIRED ON)
set_property(TARGET preda_engine PROPERTY CXX_EXTENSIONS OFF)
