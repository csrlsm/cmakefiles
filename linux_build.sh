#! /bin/bash
cd $(dirname $0)
pwd
COMPILER="Unix Makefiles"
DOWNLOAD_OPS=OFF
BUNDLE_OPS=OFF
CONFIG=Release
libsec=liboxd_libsec.a
if [ -n "$1" ]; then
  DOWNLOAD_OPS="$1"
fi
if [ -n "$2" ]; then
  BUNDLE_OPS="$2"
fi
if [ -n "$3" ]; then
  CONFIG="$3"
fi
if [ ${CONFIG} == "Debug" ]||[ ${CONFIG} == "debug" ];then
  libsec=liboxd_libsec_d.a
fi
echo $PATH
echo build options is  -DDOWNLOAD_OPS=${DOWNLOAD_OPS} -DBUNDLE_OPS=${BUNDLE_OPS} --config ${CONFIG}
if [ -d ./build ];then
  echo "############clean cache################"
  rm -rf ./build
fi
#if [ ! -f ./oxd_libsec/lib/${libsec} ] || [ ! -d ./oxd_libsec/lib ];then
  if [ ${DOWNLOAD_OPS} == "ON" ];then
  cmake -S ./CPCF -B ./build/CPCF -G "${COMPILER}" -DDOWNLOAD_OPS=${DOWNLOAD_OPS} -DCMAKE_BUILD_TYPE=${CONFIG}
  fi
  cmake -S ./oxd_libsec -B ./build/oxd_libsec -G "${COMPILER}" -DCMAKE_BUILD_TYPE=${CONFIG}
  cmake --build ./build/oxd_libsec 
  cmake --install ./build/oxd_libsec 
  if [ $? -eq 0 ];then
	echo "####### oxd_libsec.lib install success"
  else
	echo "######### oxd_libsec install failed"
	exit 1
  fi
#fi

cmake -S ./ -B ./build -G "${COMPILER}" -DDOWNLOAD_OPS=${DOWNLOAD_OPS} -DBUNDLE_OPS=${BUNDLE_OPS} -DCMAKE_BUILD_TYPE=${CONFIG}
cmake --build ./build 
cmake --install ./build

if [ ${BUNDLE_OPS} == "ON" ];then
  echo "bundle options is on, will take a few minutes to build package"
  cmake --build ./build --target build_package

  ###rename with date
  date=$(TZ=CST-8 date +%y%m%d%H%M)
  pkg=$(ls -t ./bundle/preda-*.deb |head -n 1)
  echo $pkg
  tmp=${pkg##*/}
  name=${tmp%.*}
  ext=${tmp##*.}
  mv ${pkg} ./bundle/${name}_${date}.${ext}
fi
