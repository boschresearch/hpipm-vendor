cmake_minimum_required(VERSION 3.3)

project(hpipm)

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif()

##############################
# MULTI-TARGET BUILD OPTIONS #
##############################

option(MULTI_X64_BUILD "Build HPIPM for multiple x64 targets." OFF)

# Specify paths where to install the different target builds
set(BLASFEO_INSTALL_PREFIX "/opt/blasfeo" CACHE STRING "Install prefix where blasfeo is installed.")
set(HPIPM_INSTALL_PREFIX "/opt/hpipm" CACHE STRING "Install prefixes: ${BLASFEO_INSTALL_PREFIX}/${TARGET}.")

# Define BLASFEO targets to build
list(APPEND MULTI_ARCH_X64_TARGETS
    X64_INTEL_HASWELL
    X64_INTEL_CORE
    X64_INTEL_SANDY_BRIDGE
    X64_AMD_BULLDOZER
    GENERIC
)

#########################
# DEFAULT CONFIGURATION #
#########################

set(HPIPM_FIND_BLASFEO                   ON              CACHE STRING "Options for hpipm.")
set(HPIPM_TESTING                        OFF             CACHE BOOL   "Options for hpipm.")
set(BUILD_SHARED_LIBS                    ON              CACHE BOOL   "Options for hpipm.")
set(TARGET                               GENERIC         CACHE STRING "Options for hpipm.")

###############
# BUILD LOGIC #
###############

if(NOT MULTI_X64_BUILD)
    add_subdirectory(external/hpipm)
else()
    include(ExternalProject)

    # Obtain path of CMAKE modules
    get_filename_component(MULTI_TARGET_BUILD_MODULES "${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules" ABSOLUTE)

    # Make paths absolute
    get_filename_component(BLASFEO_INSTALL_PREFIX_ABSOLUTE ${BLASFEO_INSTALL_PREFIX} ABSOLUTE)
    get_filename_component(HPIPM_INSTALL_PREFIX_ABSOLUTE ${HPIPM_INSTALL_PREFIX} ABSOLUTE)
    
    # Map BLASFEO target to HPIPM AVX targets
    list(APPEND HPIPM_AVX_TARGETS 
        X64_INTEL_HASWELL
        X64_INTEL_SANDY_BRIDGE
    )

    ###########################
    # BUILD AND INSTALL HPIPM #
    ###########################

    # Dummy target for bootstrapping dependencies, necessary for parallel build
    add_custom_target(dummy_target)
    list(APPEND BUILD_ORDER dummy_target)

    message(STATUS "############### hpipm targets ###############")
    foreach(BLASFEO_TARGET ${MULTI_ARCH_X64_TARGETS})
        # Build
        if (${BLASFEO_TARGET} IN_LIST HPIPM_AVX_TARGETS)
            set(HPIPM_TARGET "AVX" CACHE STRING "HPIPM Target." FORCE)
        else ()
            set(HPIPM_TARGET "GENERIC" CACHE STRING "HPIPM Target." FORCE)
        endif()
        message(STATUS "# ${BLASFEO_TARGET} blasfeo + ${HPIPM_TARGET} hpipm")
        ExternalProject_Add(hpipm_${BLASFEO_TARGET}
            DEPENDS ${BUILD_ORDER}
            SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/external/hpipm
            CMAKE_ARGS -DCMAKE_PREFIX_PATH=${BLASFEO_INSTALL_PREFIX_ABSOLUTE}/${BLASFEO_TARGET}
                       -DCMAKE_INSTALL_PREFIX=${CMAKE_CURRENT_BINARY_DIR}/hpipm_install/${BLASFEO_TARGET}
                       -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
                       -DTARGET=${HPIPM_TARGET}
                       -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
                       -DHPIPM_HEADERS_INSTALLATION_DIRECTORY=${HPIPM_HEADERS_INSTALLATION_DIRECTORY}
                       -DHPIPM_TESTING=${HPIPM_TESTING}
        )
        list(APPEND BUILD_ORDER hpipm_${BLASFEO_TARGET})
        list(REMOVE_AT BUILD_ORDER 0)

        # Install
        install(
            DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/hpipm_install/${BLASFEO_TARGET}/lib/
            DESTINATION ${HPIPM_INSTALL_PREFIX_ABSOLUTE}/${BLASFEO_TARGET}/lib
        )
        install(
            DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/hpipm_install/${BLASFEO_TARGET}/include/
            DESTINATION ${HPIPM_INSTALL_PREFIX_ABSOLUTE}/${BLASFEO_TARGET}/include
        )
        install(
            DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/hpipm_install/${BLASFEO_TARGET}/cmake/
            DESTINATION ${HPIPM_INSTALL_PREFIX_ABSOLUTE}/${BLASFEO_TARGET}/cmake
        )
    endforeach()
    message(STATUS "#############################################")

    ############################
    # CONFIGURE DEFAULT TARGET #
    ############################

    if (BUILD_SHARED_LIBS)
        set(LIBFILETYPE "so")
    else ()
        set(LIBFILETYPE "a")
    endif() 
    configure_file(cmake/modules/configure_default_target.cmake.in 
        ${CMAKE_CURRENT_BINARY_DIR}/configure_default_target.cmake
        @ONLY
    )
    install(DIRECTORY DESTINATION ${CMAKE_INSTALL_PREFIX}/lib)
    install(DIRECTORY DESTINATION ${CMAKE_INSTALL_PREFIX}/include)
    install(DIRECTORY DESTINATION ${CMAKE_INSTALL_PREFIX}/cmake)
    install(SCRIPT ${CMAKE_CURRENT_BINARY_DIR}/configure_default_target.cmake)
endif()
