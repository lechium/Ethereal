#!/bin/bash

set -e
whoami=`whoami`
echo $whoami

LAYOUT="layout"
CONTROL_FILE=control
DPKG_DEBIAN_PATH="$LAYOUT"/DEBIAN

sudo xcode-select -s ~/Desktop/Xcode.app/Contents/Developer/
sudo rm -rf layout/Applications/
sudo chown -R $whoami:staff layout/
#rm -rf build

pushd ethereald
FRAMEWORKS="-framework Foundation -framework Sharing -framework UIKit -framework MediaRemote -framework TVServices"
xcrun -sdk appletvos clang -arch arm64 -Iinclude -I. -F. $FRAMEWORKS -mappletvos-version-min=9.0 -o ethereald ethereald.m -v
ldid2 -Sent.plist ethereald
cp ethereald ../layout/usr/bin/
popd

make stage -C bundle
make stage -C tweak

/usr/bin/xcodebuild BUILD_ROOT=build | xcpretty
rm layout/Applications/*.app/embedded.mobileprovision

#install_name_tool -change @rpath/tvOSAVPlayerTouch.framework/tvOSAVPlayerTouch /Library/Frameworks/tvOSAVPlayerTouch.framework/tvOSAVPlayerTouch layout/Applications/Ethereal.app/Ethereal
#otool -L layout/Applications/Ethereal.app/Ethereal
#exit 0
bash package_v.sh -c ${CONTROL_FILE} > "$DPKG_DEBIAN_PATH"/control
cat "$DPKG_DEBIAN_PATH"/control
currentversion=`bash get_version.sh -c ${CONTROL_FILE}`
echo "current version: $currentversion"

packagename="com.nito.ethereal_${currentversion}_appletvos-arm64.deb"

sudo ldid2 -Sappent.plist layout/Applications/Ethereal.app/Ethereal
sudo chown -R root:wheel layout/Applications
sudo chown -R root:wheel layout/usr
sudo chown -R root:wheel layout/Library
sudo rm -rf layout/Applications/*.app/_CodeSignature

echo $packagename
dpkg-deb -b layout debs/$packagename

if [ "$#" == "1" ]; then

    scp debs/$packagename root@$1:~
    ssh root@$1 "export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/bin/X11:/usr/games ; export SHELL=/bin/bash ;  dpkg -i $packagename"
    ssh root@$1 "killall -9 ethereald Ethereal"
    ssh root@$1 "lsdtrip launch com.nito.Ethereal"
    #ssh root@$1 "syslog -w"

fi




