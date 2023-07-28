# CMakeList.txt: preda_preoject
#
cmake_minimum_required(VERSION 3.18)

# Enable Hot Reload for MSVC compilers if supported.
if(POLICY CMP0135)
  cmake_policy(SET CMP0135 NEW)
  set(CMAKE_MSVC_DEBUG_INFORMATION_FORMAT "$<IF:$<AND:$<C_COMPILER_ID:MSVC>,$<CXX_COMPILER_ID:MSVC>>,$<$<CONFIG:Debug,RelWithDebInfo>:EditAndContinue>,$<$<CONFIG:Debug,RelWithDebInfo>:ProgramDatabase>>")
endif()

include(../CMake_rules.txt)
project("transpiler")

# ############### build transpiler ###############
file(GLOB TRANSPILER_SOURCES
  ./*.cpp
  ./transpiler/*.cpp
  ./antlr_generated/*.cpp
)

add_library(transpiler SHARED ${TRANSPILER_SOURCES})

if(WIN32)
  add_dependencies(transpiler antlr4-runtime)
  target_include_directories(transpiler PRIVATE ../../CPCF/libs/win)
  target_link_libraries(transpiler PRIVATE
    antlr4-runtime
    ${OXD_LIBSEC_NAME}
  )

  add_compile_definitions(ANTLR4CPP_STATIC)
  win_sdk_rule(transpiler)
  install(TARGETS transpiler
    LIBRARY DESTINATION ${PROJECT_BUILD_DIR}/PREDA/bin
  )
elseif(UNIX AND NOT APPLE)
  add_dependencies(transpiler antlr4_shared)
  target_include_directories(transpiler PRIVATE ../../CPCF/libs/linux)
  target_compile_options(transpiler PRIVATE -fPIC -pthread -ldl -lX11)
  target_link_directories(transpiler PRIVATE ${CMAKE_BINARY_DIR}/PREDA/bin)
  target_link_libraries(transpiler PRIVATE
    antlr4-runtime
    ${OXD_LIBSEC_NAME}
    ${IPP_LIB}
  )
  set_target_properties(transpiler PROPERTIES
    PREFIX ""
    SUFFIX ".so"
  )
  install(TARGETS transpiler
    LIBRARY DESTINATION ${PROJECT_BUILD_DIR}/PREDA/bin
  )
elseif(APPLE)
  file(GLOB MAC_SOURCE_FILE ../../CPCF/libs/mac/*.a)
  add_dependencies(transpiler antlr4_shared)

  # target_link_directories(transpiler PRIVATE
  # ../../oxd_libsec/lib
  # ${CMAKE_BINARY_DIR}/PREDA/bin
  # ${CMAKE_HOME_DIRECTORY}/dist
  # )
  target_link_libraries(transpiler PRIVATE
    antlr4_shared
    ${MAC_SOURCE_FILE}

    # ${OXD_LIBSEC_NAME}
  )

  # target_sources(transpiler PRIVATE ${MAC_SOURCE_FILE})
  set_target_properties(transpiler PROPERTIES
    PREFIX ""
    SUFFIX ".dylib"
  )
  mac_link_rule(transpiler)
  install(TARGETS transpiler
    LIBRARY DESTINATION ${PROJECT_BUILD_DIR}/PREDA/bin
  )
endif()

target_include_directories(transpiler PRIVATE
  ../3rdParty/antlr4/runtime/Cpp/runtime/src
  ./
  ./transpiler
  ./antlr_generated
)

target_sources(transpiler PRIVATE ${TRANSPILER_SOURCES})

# target_link_libraries(transpiler PRIVATE antlr4-runtime)
set_property(TARGET transpiler PROPERTY CMAKE_POLICY_DEFAULT_CMP0079 NEW)
