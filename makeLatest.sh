#!/bin/bash

set -e
whoami=`whoami`
echo $whoami

DEVICE=""
PREFIX=""
SCHEME="Ethereal"
LAYOUT="layout"
CONTROL_FILE=control
DPKG_DEBIAN_PATH="$LAYOUT"/DEBIAN

usage() {
    echo "usage: $0 [-s|--sealed-target]"
    trap - INT TERM EXIT
    exit 0
}

while test $# -gt 0; do
    case "$1" in
        -h|--help)
            usage
            ;;
        -s|--sealed)
            SCHEME="EtherealSealed"
            PREFIX="fs/jb"
            LAYOUT="sealed"
            DPKG_DEBIAN_PATH="$LAYOUT"/DEBIAN
            shift
            ;;
        -t|--target-device)
            shift
            if test $# -gt 0; then
                DEVICE="$1"
            else
                echo "Error: No scp target given."
                trap - INT TERM EXIT
                exit 1
            fi
            shift
            ;;
        *)
            break
            ;;
    esac
done

export LAYOUT="$LAYOUT"
export PREFIX="$PREFIX"

rm -rf $LAYOUT/$PREFIX/Applications
#sudo chown -R $whoami:staff $LAYOUT

#rm -rf build

echo -s "Making the Application...\n"
/usr/bin/xcodebuild -scheme $SCHEME BUILD_ROOT=build | xcpretty
rm $LAYOUT/$PREFIX/Applications/*.app/embedded.mobileprovision

echo -s "Determing & updating package version...\n"
bash package_v.sh -c ${CONTROL_FILE} > "$DPKG_DEBIAN_PATH"/control
cat "$DPKG_DEBIAN_PATH"/control
currentversion=`bash get_version.sh -c ${CONTROL_FILE}`
echo "current version: $currentversion"

packagename="com.nito.ethereal_${currentversion}_appletvos-arm64.deb"

echo -s "Signing the package...\n"
#sudo ldid2 -Sappent.plist layout/Applications/Ethereal.app/Ethereal
ldid -Sappent.plist $LAYOUT/$PREFIX/Applications/Ethereal.app/Ethereal

echo -s "Updating owners & permissions...\n"
#sudo chown -R root:wheel layout/Applications
#sudo rm -rf layout/Applications/*.app/_CodeSignature
rm -rf $LAYOUT/$PREFIX/Applications/*.app/_CodeSignature

echo -s "Creating deb...\n"
echo $packagename
dpkg-deb -b $LAYOUT debs/$packagename

if [ -n "$DEVICE" ]; then
    echo -s "Installing package...\n"
    scp debs/$packagename root@$DEVICE:~
    ssh root@$DEVICE "export PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin:/binpack/usr/bin:/binpack/usr/sbin:/binpack/bin:/binpack/sbin:/fs/jb/usr/bin:/fs/jb/usr/libexec:/fs/jb/usr/sbin:/fs/jb/bin:/fs/jb/usr/local/bin ; export SHELL=/bin/bash ;  dpkg -i $packagename"
    ssh root@$DEVICE "killall -9 ethereald Ethereal"
    ssh root@$DEVICE "lsdtrip launch com.nito.Ethereal"
    #ssh root@$1 "syslog -w"
fi



