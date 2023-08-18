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
  preda_engine/ContractData*
  preda_engine/PredaCompiledContracts.*
  preda_engine/SymbolDBForTranspiler.*
)
file(GLOB_RECURSE ROCKSDB
  ../../CPCF/core/ext/rocksdb/rocksdb.*
)
source_group("CPCF" FILES
  ../../CPCF/core/ext/bignum/big_num.cpp
  ../../CPCF/core/ext/bignum/precision_num.cpp
  ../../CPCF/core/ext/lib_inc.c
  ../../CPCF/essentials.cpp
)
file(GLOB_RECURSE EVMEngine
  evm_engine/*
)
file(GLOB COMPILE_ENV ../bin/compile_env/contract_template.cpp)
file(GLOB_RECURSE native ../native/*)
file(GLOB_RECURSE PREDA_ENGINE_FILES_RVM
  preda_engine/RvmAssetDelegate.*
  preda_engine/RvmContractDelegate.*
)
file(GLOB_RECURSE ExecutionEngine
  preda_engine/ContractRuntime*
  preda_engine/ExecutionEngine.*
  preda_engine/WASMRuntime.*
)
file(GLOB_RECURSE RuntimeInterface
  preda_engine/bigint.*
  preda_engine/runtime_interface.h
  preda_engine/RuntimeInterfaceImpl.*
)
file(GLOB main preda_engine/main.cpp ../../CPCF/core/ext/bignum/ttmath/ttmathuint_x86_64_msvc.asm)
source_group("compile_environment" FILES ${COMPILE_ENV})
source_group(TREE ${CMAKE_CURRENT_SOURCE_DIR}/evm_engine PREFIX "EVMEngine" FILES ${EVMEngine})
source_group(TREE ${CMAKE_CURRENT_SOURCE_DIR}/../native PREFIX "native" FILES ${native})
source_group("PredaEngine/ContractDatabase/RvmDelegate" FILES ${PREDA_ENGINE_FILES_RVM})
source_group("PredaEngine/ContractDatabase" FILES ${PREDA_ENGINE_FILES})
source_group("PredaEngine/ExecutionEngine/RuntimeInterface" FILES ${RuntimeInterface})
source_group("PredaEngine/ExecutionEngine" FILES ${ExecutionEngine})
source_group("rocksdb" FILES ${ROCKSDB})
source_group("Source Files" FILES "${main}")
add_library(preda_engine SHARED ${main} ${PREDA_ENGINE_FILES} ${PREDA_ENGINE_FILES_RVM} ${EVMEngine} ${native} ${ExecutionEngine} ${RuntimeInterface} ${ROCKSDB})
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
)

set_target_properties(preda_engine PROPERTIES
  BUILD_WITH_INSTALL_RPATH TRUE
  INSTALL_RPATH "."
)
target_link_directories(preda_engine PRIVATE
  ../3rdParty/wasmtime/lib
  ../../oxd_libsec/lib
)
target_link_libraries(preda_engine PRIVATE "oxd_libsec$<$<CONFIG:Debug>:_d>")

if(WIN32)
  target_include_directories(preda_engine
    PRIVATE
    ../3rdParty/evmone/win/include
  )
  target_link_directories(preda_engine
    PRIVATE
    ../3rdParty/evmone/win/lib
    ../../CPCF/libs/win
  )
  target_link_libraries(preda_engine
    PRIVATE
    wasmtime.dll.lib
    evmone
    ${IPP_LIB}
  )

  target_compile_definitions(preda_engine PRIVATE _WINDLL)

  # target_link_options(preda_engine PRIVATE /INCREMENTAL /DEGUB:FULL)
  target_compile_options(preda_engine PRIVATE ${CMAKE_CXX_FLAGS} /bigobj)
  target_sources(preda_engine
    PRIVATE
    ../../CPCF/core/ext/bignum/ttmath/ttmathuint_x86_64_msvc.asm
  )

  if(MSVC)
    set(CMAKE_SHARED_LINKER_FLAGS_DEBUG "${CMAKE_SHARED_LINKER_FLAGS_DEBUG} /DEBUG:FULL /INCREMENTAL")
    set(CMAKE_SHARED_LINKER_FLAGS_RELEASE "${CMAKE_SHARED_LINKER_FLAGS_RELEASE_INIT} /DEBUG:FULL /OPT:REF /OPT:ICF /LTCG:incremental")
    target_compile_options(preda_engine PRIVATE
      $<$<CONFIG:Debug>:/ZI /JMC /W3 /MP /sdl /RTC1 /Od /GS /FC>
      $<$<CONFIG:Release>:/Zi /W3 /MP /sdl /Gy /O2 /Oi /GL /GS /FC>
    )

    # target_compile_options(preda_engine PRIVATE "/MT$<$<CONFIG:Debug>:d>")
  endif()

  win_sdk_rule(preda_engine)
elseif(UNIX AND NOT APPLE)
  linux_link_ipp_rule(preda_engine)
  target_include_directories(preda_engine
    PRIVATE
    ../3rdParty/evmone/linux/include
  )
  target_link_directories(preda_engine
    PRIVATE
    ../3rdParty/evmone/linux/lib
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
    ${IPP_LIB}
  )
  set_target_properties(preda_engine PROPERTIES
    PREFIX ""
    SUFFIX ".so"
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
  )
  mac_link_rule(preda_engine)
  set_target_properties(preda_engine PROPERTIES
    PREFIX ""
    SUFFIX ".dylib"
  )
endif()

set_target_properties(preda_engine PROPERTIES
  LIBRARY_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/bin/bin_$<LOWER_CASE:$<CONFIG>>/$<0:>
  RUNTIME_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/bin/bin_$<LOWER_CASE:$<CONFIG>>/$<0:>
  ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/bin/bin_$<LOWER_CASE:$<CONFIG>>/$<0:>
)

# set_policy(CMP0069 NEW)
set_property(TARGET preda_engine PROPERTY CXX_STANDARD 17)
set_property(TARGET preda_engine PROPERTY CXX_STANDARD_REQUIRED ON)
set_property(TARGET preda_engine PROPERTY CXX_EXTENSIONS ON)
set_property(GLOBAL PROPERTY USE_FOLDERS ON)