#! /bin/sh
export xmake=/Users/kaas/.local/bin/xmake
export PATH=/Users/kaas/.local/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Library/Apple/usr/bin
PATH=$PATH:$xmake
repo=/Users/kaas/Documents/preda_cmake
date=$(TZ=Asia/Shanghai date +%y%m%d%H%M)
cd ${repo}
for((i=1;i<=10;i++))
do
  git pull --rebase --autostash
  if [ $? -ne 0 ];then
    echo "git pull failed,will retry $i times...."
    git fetch --all
    git reset --hard origin/dev
    git pull
    git submodule update --init -f
    sleep 1
  else
    git submodule update --init -f
    echo "pull success..."
    break
  fi
done
if [[ "$?" -ne "0" ]];then
  echo "git pull failed.........."
  exit 1
fi
#### start build with xmake
rm -rf preda-*.vsix preda-*.pkg build
scp administrator@sftp:/kaasftp/preda_repo/preda-*.vsix .
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
if [ ${CONFIG} == "Debug" ] || [ ${CONFIG} == "debug" ];then
  libsec=liboxd_libsec_d.a
fi
echo "start cofigure cmake ........"
if [ -d ./build ];then
  rm -rf ./build
fi
#if [ ! -f ./oxd_libsec/lib/${libsec} ] || [ ! -d ./oxd_libsec/lib ];then
  cmake -S ./oxd_libsec -B ./build/oxd_libsec -G Xcode
  cmake --build ./build/oxd_libsec --config ${CONFIG}
  cmake --install ./build/oxd_libsec --config ${CONFIG}
  if [ $? -eq 0 ];then
	echo "####### oxd_libsec.lib install success"
  else
	echo "######### oxd_libsec install failed"
	exit 1
  fi
#fi
cmake -S./ -B./build -G Xcode -DDOWNLOAD_OPS=${DOWNLOAD_OPS} -DBUNDLE_OPS=${BUNDLE_OPS}
cmake --build ./build --config ${CONFIG} --target ALL_BUILD
cmake --install ./build --config ${CONFIG}
if [ ${BUNDLE_OPS} == "ON" ];then
  echo "bundle options is ${BUNDLE_OPS}......,will take few minutes to build packages"
  cmake --build ./build --config ${CONFIG} --target build_package
  if [ -f ./bundle/preda-toolchain.pkg ];then
  tmp=$(ls ./bundle/preda-toolchain.pkg)
  file=${tmp##*/}
  name=${file%.*}
  ext=${file##*.}
  mv ${tmp} ./bundle/${name}_${date}.${ext}
  fi
else
  echo "bundle options is ${BUNDLE_OPS}...., will copy 3rdpary to ./build/PREDA only"
  cmake --build ./build --config ${CONFIG} --target 3rdParty
fi
