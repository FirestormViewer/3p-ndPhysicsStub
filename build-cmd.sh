#!/bin/bash

cd "$(dirname "$0")"

# turn on verbose debugging output for parabuild logs.
set -x
# make errors fatal
set -e

# Check autobuild is around or fail
if [ -z "$AUTOBUILD" ] ; then 
    fail
fi

if [ "$OSTYPE" = "cygwin" ] ; then
    export AUTOBUILD="$(cygpath -u $AUTOBUILD)"
fi

set +x
eval "$("$AUTOBUILD" source_environment)"
set -x

stage="$(pwd)/stage"

if [ -d "${stage}" ]
then
 rm -rf "${stage}/lib"
 rm -rf "${stage}/include"
fi

build=${AUTOBUILD_BUILD_ID:=0}
echo "1.${build}" > "${stage}/VERSION.txt"

mkdir -p "$stage/lib/debug"
mkdir -p "$stage/lib/release"

cp version.txt ${stage}/version.txt

if [ ! -d "build-${AUTOBUILD_PLATFORM}-${AUTOBUILD_WIN_VSPLATFORM}" ]
then
  mkdir "build-${AUTOBUILD_PLATFORM}-${AUTOBUILD_WIN_VSPLATFORM}"
else
  rm -rf "build-${AUTOBUILD_PLATFORM}-${AUTOBUILD_WIN_VSPLATFORM}"
  mkdir "build-${AUTOBUILD_PLATFORM}-${AUTOBUILD_WIN_VSPLATFORM}"
fi

pushd "build-${AUTOBUILD_PLATFORM}-${AUTOBUILD_WIN_VSPLATFORM}"
    case "${AUTOBUILD_PLATFORM}" in
        windows*)
            load_vsvars

            cmake .. -G "${AUTOBUILD_WIN_CMAKE_GEN}"
            build_sln "Project.sln" "Release|$AUTOBUILD_WIN_VSPLATFORM" "hacd"
            build_sln "Project.sln" "Release|$AUTOBUILD_WIN_VSPLATFORM" "nd_hacdConvexDecomposition"
            build_sln "Project.sln" "Release|$AUTOBUILD_WIN_VSPLATFORM" "nd_Pathing"

            build_sln "Project.sln" "Debug|$AUTOBUILD_WIN_VSPLATFORM" "hacd"
            build_sln "Project.sln" "Debug|$AUTOBUILD_WIN_VSPLATFORM" "nd_hacdConvexDecomposition"
            build_sln "Project.sln" "Debug|$AUTOBUILD_WIN_VSPLATFORM" "nd_Pathing"

            cp "Source/HACD_Lib/Debug/hacd.lib" "$stage/lib/debug"
            cp "Source/HACD_Lib/Release/hacd.lib" "$stage/lib/release"

            cp "Source/lib/Debug/nd_hacdConvexDecomposition.lib" "$stage/lib/debug"
            cp "Source/lib/Release/nd_hacdConvexDecomposition.lib" "$stage/lib/release"

            cp "Source/Pathing/Debug/nd_Pathing.lib" "$stage/lib/debug"
            cp "Source/Pathing/Release/nd_Pathing.lib" "$stage/lib/release"
        ;;

        darwin*)
        cmake "-DCMAKE_OSX_ARCHITECTURES=arm64;x86_64" \
            -DCMAKE_OSX_DEPLOYMENT_TARGET=11.0 \
            -DCMAKE_CXX_FLAGS="-std=c++14 -stdlib=libc++" \
            ../
        make

        # Copy the new libs
        cp "Source/lib/libnd_hacdConvexDecomposition.a" "$stage/lib/release/"
        cp "Source/Pathing/libnd_Pathing.a" "$stage/lib/release/"
        cp "Source/HACD_Lib/libhacd.a" "$stage/lib/release/"
        ;;
            
        linux*)
        cmake -DCMAKE_C_FLAGS:STRING="$LL_BUILD_RELEASE -m${AUTOBUILD_ADDRSIZE}" \
			  -DCMAKE_CXX_FLAGS:STRING="$LL_BUILD_RELEASE -m${AUTOBUILD_ADDRSIZE}" ..
        VERBOSE=1 make

        # Copy the new libs (just a guess)
        cp "Source/lib/libnd_hacdConvexDecomposition.a" "$stage/lib/release/"
        cp "Source/Pathing/libnd_Pathing.a" "$stage/lib/release/"
        cp "Source/HACD_Lib/libhacd.a" "$stage/lib/release/"
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

