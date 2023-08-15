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
file(GLOB_RECURSE TEST
  contracts/*.prdts
  contracts/*.prd
)
file(GLOB_RECURSE SIMULATOR
  *.cpp
  *.h
  proj.win/*.h
)
file(GLOB_RECURSE RVM ../native/abi/*.h)
file(GLOB_RECURSE types ../native/types/*.h)
source_group("test" FILES ${TEST})
source_group("simulator" FILES ${SIMULATOR})
source_group("rvm" FILES ${RVM})
source_group("rvm/types" FILES ${types})
source_group("main" FILES ${CHAIN_SIMULATOR_FILE})
source_group(TREE ${CMAKE_SOURCE_DIR}/native FILES ../native/abi/vm_address.h)
add_executable(chain_simulator ${CHAIN_SIMULATOR_FILE})

# add_dependencies(chain_simulator oxd_libsec)
# target_include_directories(chain_simulator PRIVATE
# ../../CPCF
# ../../CPCF/core/ext/exprtk
# ./native/abi
# ./simulator
# )
target_sources(chain_simulator PRIVATE
  ../../CPCF/essentials.cpp
  ../../CPCF/core/ext/exprtk/exprtk.cpp
  ../../CPCF/core/ext/lib_inc.c
)
target_link_directories(chain_simulator PRIVATE ../../oxd_libsec/lib)
target_link_libraries(chain_simulator PRIVATE "oxd_libsec$<$<CONFIG:Debug>:_d>")

if(WIN32)
  target_sources(chain_simulator PRIVATE ../../CPCF/core/ext/bignum/ttmath/ttmathuint_x86_64_msvc.asm)
  target_compile_options(chain_simulator PRIVATE ${CMAKE_CXX_FLAGS} /bigobj)
  target_link_directories(chain_simulator PRIVATE ../../CPCF/libs/win)
  target_link_libraries(chain_simulator PRIVATE ${IPP_LIB})
  win_sdk_rule(chain_simulator)

  if(MSVC)
    target_compile_options(chain_simulator PRIVATE
      $<$<CONFIG:Debug>:/ZI /JMC /W3 /MP /sdl /RTC1 /Od /GS /FC>
      $<$<CONFIG:Release>:/Zi /W3 /sdl /MP /Gy /O2 /Oi /GL /GS /FC>
    )

    # target_compile_options(preda_engine PRIVATE "/MT$<$<CONFIG:Debug>:d>")
  endif()
elseif(UNIX AND NOT APPLE)
  linux_link_ipp_rule(chain_simulator)
  target_link_directories(chain_simulator PRIVATE ../../CPCF/libs/linux)
  target_link_libraries(chain_simulator PRIVATE ${IPP_LIB})
  target_compile_options(chain_simulator PRIVATE -fPIC -pthread)
elseif(APPLE)
  target_sources(chain_simulator PRIVATE ../../CPCF/core/os/objc_wrap.mm)
  target_link_libraries(chain_simulator
    PRIVATE
    ${IPP_LIB}
  )
  mac_link_rule(chain_simulator)
endif()

target_compile_definitions(chain_simulator PRIVATE _VIZ _CONSOLE)
set_target_properties(chain_simulator PROPERTIES OUTPUT_NAME "chsimu")
set_property(TARGET chain_simulator PROPERTY CXX_STANDARD 17)
set_target_properties(chain_simulator PROPERTIES LINK_FLAGS "${CMAKE_SHARED_LINKER_FLAGS}")
set_target_properties(chain_simulator PROPERTIES CMAKE_POLICY_DEFAULT_CMP0069 NEW)
set_target_properties(chain_simulator PROPERTIES
  LIBRARY_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/bin/bin_$<CONFIG>/$<0:>
  RUNTIME_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/bin/bin_$<CONFIG>/$<0:>
  ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/bin/bin_$<CONFIG>/$<0:>
)

if(CMAKE_VERSION VERSION_GREATER 3.12)
  set_property(TARGET chain_simulator PROPERTY CXX_STANDARD 17)
  cmake_policy(SET CMP0057 NEW)
endif()
