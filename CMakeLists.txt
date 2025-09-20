cmake_minimum_required(VERSION 3.16.0)

set( CMAKE_PROJECT_NAME ndPhysicsStub )

if( PACKAGE_FOR_LL )
  set( ND_LIBDIR "lib/release")
else( PACKAGE_FOR_LL )
  set( ND_LIBDIR "lib/")
endif( PACKAGE_FOR_LL )

include_directories( Source/HACD_Lib/inc )

add_subdirectory(Source/lib)
add_subdirectory(Source/HACD_Lib)
add_subdirectory(Source/Pathing)

set(CPACK_INCLUDE_TOPLEVEL_DIRECTORY 0)
set(CPACK_GENERATOR "TBZ2")
set(CPACK_STRIP_FILES TRUE )
include(CPack)
