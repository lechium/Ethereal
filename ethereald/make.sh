#!/bin/bash

set -e

xcrun -sdk appletvos clang -arch arm64 -Iinclude -F. -framework Foundation -mappletvos-version-min=9.0 -o ethereald ethereald.m

ldid2 -Sent.plist ethereald
sudo ldid2 -Sappent.plist layout/Applications/Ethereal.app/Ethereal
sudo cp ethereald ..layout/usr/bin/
sudo chown -R root:wheel layout/usr/bin/
sudo chown -R root:wheel layout/Library
dpkg-deb -b layout com.nito.ethereal_1.0-2-appletvos-arm64.deb
scp com.nito.ethereal_1.0-2-appletvos-arm64.deb twelve.local:~
ssh twelve.local "dpkg -i com.nito.ethereal_1.0-2-appletvos-arm64.deb"

