#!/bin/bash

set -e
whoami=`whoami`
echo $whoami

LAYOUT="layout"
CONTROL_FILE=control
DPKG_DEBIAN_PATH="$LAYOUT"/DEBIAN

#you can quite likely comment this line out.
sudo xcode-select -s ~/Desktop/Xcode.app/Contents/Developer/
sudo rm -rf layout/Applications/
sudo chown -R $whoami:staff layout/
#rm -rf build

# build the Daemon
#echo -e "Building the daemon...\n"
#pushd ethereald
#FRAMEWORKS="-framework Foundation -framework Sharing -framework UIKit -framework MediaRemote -framework TVServices"
#xcrun -sdk appletvos clang -arch arm64 -Iinclude -I. -F. $FRAMEWORKS -mappletvos-version-min=9.0 -o ethereald ethereald.m -v
#echo -s "Signing the Daemon...\n"
#ldid2 -Sent.plist ethereald
#cp ethereald ../layout/usr/bin/
#popd

#echo -s "Making the Preference bundle...\n"
#make stage -C bundle
#echo -s "Making the Tweak...\n"
#make stage -C tweak

echo -s "Making the Application...\n"
/usr/bin/xcodebuild BUILD_ROOT=build | xcpretty
rm layout/Applications/*.app/embedded.mobileprovision

echo -s "Determing & updating package version...\n"
bash package_v.sh -c ${CONTROL_FILE} > "$DPKG_DEBIAN_PATH"/control
cat "$DPKG_DEBIAN_PATH"/control
currentversion=`bash get_version.sh -c ${CONTROL_FILE}`
echo "current version: $currentversion"

packagename="com.nito.ethereal_${currentversion}_appletvos-arm64.deb"

echo -s "Signing the package...\n"
sudo ldid2 -Sappent.plist layout/Applications/Ethereal.app/Ethereal

echo -s "Updating owners & permissions...\n"
sudo chown -R root:wheel layout/Applications
#sudo chown -R root:wheel layout/usr
#sudo chown -R root:wheel layout/Library
sudo rm -rf layout/Applications/*.app/_CodeSignature

echo -s "Creating deb...\n"
echo $packagename
dpkg-deb -b layout debs/$packagename

if [ "$#" == "1" ]; then
    echo -s "Installing package...\n"
    scp debs/$packagename root@$1:~
    ssh root@$1 "export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/bin/X11:/usr/games ; export SHELL=/bin/bash ;  dpkg -i $packagename"
    ssh root@$1 "killall -9 ethereald Ethereal"
    ssh root@$1 "lsdtrip launch com.nito.Ethereal"
    #ssh root@$1 "syslog -w"

fi




