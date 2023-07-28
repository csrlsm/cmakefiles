#! bash
export PYTHONIOENCODING='utf-8'
cd $(dirname $0)
pwd
COMPILER="Visual Studio 16 2019"
DOWNLOAD_OPS=OFF
BUNDLE_OPS=OFF
CONFIG=Release
libsec=oxd_libsec.lib
if [ -n "$1" ]; then
  DOWNLOAD_OPS="$1"
fi
if [ -n "$2" ]; then
  BUNDLE_OPS="$2"
fi
if [ -n "$3" ]; then
  CONFIG="$3"
fi
if [ ${CONFIG} == "Debug" ] || [ ${CONFIG} == "debug" ];then
  libsec=oxd_libsec_d.lib
fi
echo $PATH

#git fetch --all
#git reset --hard origin/dev
git pull --autostash
git submodule update --init
echo build options is  -DDOWNLOAD_OPS=${DOWNLOAD_OPS} -DBUNDLE_OPS=${BUNDLE_OPS} --config ${CONFIG}

if [ -d ./build ];then
  echo "######################## clean cache ################################"
  rm -rf ./build
fi
#if [ ! -f ./oxd_libsec/lib/${libsec} ] || [ ! -d ./oxd_libsec/lib ];then
  if [ ${DOWNLOAD_OPS} == "ON" ];then
  cmake -S ./CPCF -B ./build/CPCF -G "${COMPILER}" -DDOWNLOAD_OPS=${DOWNLOAD_OPS}
  fi
  cmake -S ./oxd_libsec -B ./build/oxd_libsec -G "${COMPILER}" 
  cmake --build ./build/oxd_libsec --config ${CONFIG}
  cmake --install ./build/oxd_libsec --config ${CONFIG}
  if [ $? -eq 0 ];then
	echo "####### oxd_libsec.lib install success"
  else
	echo "######### oxd_libsec install failed"
	exit 1
  fi
#fi
cmake -S ./ -B ./build -G "${COMPILER}" -DDOWNLOAD_OPS=${DOWNLOAD_OPS} -DBUNDLE_OPS=${BUNDLE_OPS}
cmake --build ./build --config ${CONFIG} 
cmake --install ./build --config ${CONFIG}

if [ ${BUNDLE_OPS} == "OFF" ];then
  echo "########################bundle options is oFF, will not build package"
  cmake --build ./build --config ${CONFIG} --target 3rdParty
else
  echo "##################bundle options is on, will take a few minutes to build package"
  cmake --build ./build --parallel 10 --config ${CONFIG} --target build_package

  ###rename with date
  date=$(date +%y%m%d%H%M)
  pkg=$(ls -t ./bundle/preda-*.exe |head -n 1)
  tmp=${pkg##*/}
  name=${tmp%.*}
  ext=${tmp##*.}
  mv ${pkg} ./bundle/${name}_${date}.${ext}
fi