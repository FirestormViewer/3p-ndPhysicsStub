cmake_minimum_required(VERSION 3.16.0)

if( MSVC )
  set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -D_SCL_SECURE_NO_WARNINGS=1" )
  set(CMAKE_CXX_FLAGS_RELWITHDEBINFO  "${CMAKE_CXX_FLAGS_RELWITHDEBINFO} -D_SECURE_STL=0" )
  set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -D_SECURE_STL=0 -D_HAS_ITERATOR_DEBUGGING=0 -D_SECURE_SCL=0" )
  add_definitions( "/Oy-" )
endif( MSVC )

set (SOURCE_FILES LLConvexDecomposition.cpp nd_hacdConvexDecomposition.cpp nd_hacdStructs.cpp nd_hacdUtils.cpp nd_EnterExitTracer.cpp nd_StructTracer.cpp )
file(GLOB HEADER_FILES *.h)

add_library( nd_hacdConvexDecomposition STATIC ${SOURCE_FILES} ${HEADER_FILES})

install( TARGETS nd_hacdConvexDecomposition DESTINATION ${ND_LIBDIR} )
install( FILES LLConvexDecomposition.h RENAME llconvexdecomposition.h DESTINATION include )
install( FILES ndConvexDecomposition.h DESTINATION include )
