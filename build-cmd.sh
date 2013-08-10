#!/bin/bash

cd "$(dirname "$0")"

# turn on verbose debugging output for parabuild logs.
set -x
# make errors fatal
set -e

if [ -z "$AUTOBUILD" ] ; then 
    fail
fi

if [ "$OSTYPE" = "cygwin" ] ; then
    export AUTOBUILD="$(cygpath -u $AUTOBUILD)"
fi

# load autobuild provided shell functions and variables
set +x
eval "$("$AUTOBUILD" source_environment)"
set -x

stage="$(pwd)/stage"

if [ -d "${stage}" ]
then
 rm -rf "${stage}/lib"
 rm -rf "${stage}/include"
fi

if [ ! -d "build-${AUTOBUILD_PLATFORM}-${AUTOBUILD_ARCH}" ]
then
  mkdir "build-${AUTOBUILD_PLATFORM}-${AUTOBUILD_ARCH}"
else
  rm -rf "build-${AUTOBUILD_PLATFORM}-${AUTOBUILD_ARCH}"
  mkdir "build-${AUTOBUILD_PLATFORM}-${AUTOBUILD_ARCH}"
fi

pushd "build-${AUTOBUILD_PLATFORM}-${AUTOBUILD_ARCH}"
    case "$AUTOBUILD_PLATFORM" in
        "windows")
            load_vsvars

            if [ "${AUTOBUILD_ARCH}" == "x64" ]
            then
              cmake .. -G "Visual Studio 10 Win64"
            
              build_sln "Project.sln" "Release|x64" "hacd"
              build_sln "Project.sln" "Release|x64" "nd_hacdConvexDecomposition"
              build_sln "Project.sln" "Release|x64" "nd_Pathing"

              build_sln "Project.sln" "Debug|x64" "hacd"
              build_sln "Project.sln" "Debug|x64" "nd_hacdConvexDecomposition"
              build_sln "Project.sln" "Debug|x64" "nd_Pathing"
            else
              cmake .. -G "Visual Studio 10"

              build_sln "Project.sln" "Release|Win32" "hacd"
              build_sln "Project.sln" "Release|Win32" "nd_hacdConvexDecomposition"
              build_sln "Project.sln" "Release|Win32" "nd_Pathing"

              build_sln "Project.sln" "Debug|Win32" "hacd"
              build_sln "Project.sln" "Debug|Win32" "nd_hacdConvexDecomposition"
              build_sln "Project.sln" "Debug|Win32" "nd_Pathing"
            fi

            mkdir -p "$stage/lib/debug"
            mkdir -p "$stage/lib/release"

			cp "Source/HACD_Lib/Debug/hacd.lib" "$stage/lib/debug"
			cp "Source/HACD_Lib/Release/hacd.lib" "$stage/lib/release"

			cp "Source/lib/Debug/nd_hacdConvexDecomposition.lib" "$stage/lib/debug"
			cp "Source/lib/Release/nd_hacdConvexDecomposition.lib" "$stage/lib/release"

			cp "Source/Pathing/Debug/nd_Pathing.lib" "$stage/lib/debug"
			cp "Source/Pathing/Release/nd_Pathing.lib" "$stage/lib/release"

        ;;
        "darwin")
        ;;            
			
        "linux")
        ;;
    esac
popd

mkdir -p "$stage/LICENSES"
cp ndPhysicsStub.txt "$stage/LICENSES"

mkdir -p "$stage/include"
cp Source/lib/LLConvexDecomposition.h "$stage/include/llconvexdecomposition.h"
cp Source/Pathing/llpathinglib.h "$stage/include"
cp Source/Pathing/llphysicsextensions.h "$stage/include"
cp Source/lib/ndConvexDecomposition.h "$stage/include"

