# CMakeList.txt: preda_preoject
#
cmake_minimum_required(VERSION 3.8)

# Enable Hot Reload for MSVC compilers if supported.
if(POLICY CMP0135)
  cmake_policy(SET CMP0135 NEW)
  set(CMAKE_MSVC_DEBUG_INFORMATION_FORMAT "$<IF:$<AND:$<C_COMPILER_ID:MSVC>,$<CXX_COMPILER_ID:MSVC>>,$<$<CONFIG:Debug,RelWithDebInfo>:EditAndContinue>,$<$<CONFIG:Debug,RelWithDebInfo>:ProgramDatabase>>")
endif()

include(../CMake_rules.txt)
project("chain_simulator")

# ############## build chain_simulator #################
file(GLOB_RECURSE CHAIN_SIMULATOR_FILE
  ../native/*.cpp
  ../native/types/*.cpp
  ./*.cpp
  ../../CPCF/core/ext/bignum/*.cpp
)

add_executable(chain_simulator ${CHAIN_SIMULATOR_FILE})

# add_dependencies(chain_simulator oxd_libsec)
target_include_directories(chain_simulator PRIVATE
  ../../CPCF
  ../../CPCF/core/ext/exprtk
  ./native/abi
  ./simulator
)
target_sources(chain_simulator PRIVATE
  ../../CPCF/essentials.cpp
  ../../CPCF/core/ext/exprtk/exprtk.cpp
  ../../CPCF/core/ext/lib_inc.c
)

# target_link_libraries(chain_simulator PRIVATE oxd_libsec)
if(WIN32)
  target_sources(chain_simulator PRIVATE ../../CPCF/core/ext/bignum/ttmath/ttmathuint_x86_64_msvc.asm)
  target_compile_options(chain_simulator PRIVATE ${CMAKE_CXX_FLAGS} /bigobj)
  target_link_directories(chain_simulator PRIVATE ../../CPCF/libs/win)
  target_link_libraries(chain_simulator PRIVATE ${OXD_LIBSEC_NAME})
  win_sdk_rule(chain_simulator)
elseif(UNIX AND NOT APPLE)
  linux_link_ipp_rule(chain_simulator)
  target_link_directories(chain_simulator PRIVATE ../../CPCF/libs/linux)
  target_link_libraries(chain_simulator PRIVATE ${OXD_LIBSEC_NAME} ${IPP_LIB})
  target_compile_options(chain_simulator PRIVATE -fPIC -pthread)
elseif(APPLE)
  target_sources(chain_simulator PRIVATE ../../CPCF/core/os/objc_wrap.mm)
  target_link_libraries(chain_simulator
    PRIVATE
    ${IPP_LIB}
    ${OXD_LIBSEC_NAME}
  )
  mac_link_rule(chain_simulator)
endif()

target_compile_definitions(chain_simulator PRIVATE _VIZ)
set_target_properties(chain_simulator PROPERTIES OUTPUT_NAME "chsimu")
set_property(TARGET chain_simulator PROPERTY CXX_STANDARD 17)
set_target_properties(chain_simulator PROPERTIES LINK_FLAGS "${CMAKE_SHARED_LINKER_FLAGS}")
set_target_properties(chain_simulator PROPERTIES CMAKE_POLICY_DEFAULT_CMP0069 NEW)
install(TARGETS chain_simulator
  RUNTIME DESTINATION ${PROJECT_BUILD_DIR}/PREDA/bin
)

if(CMAKE_VERSION VERSION_GREATER 3.12)
  set_property(TARGET chain_simulator PROPERTY CXX_STANDARD 17)
  cmake_policy(SET CMP0057 NEW)
endif()
