#!/bin/bash

curl -O https://nitosoft.com/checkra1n/deb/com.imore.tvosavplayer_1.0-2_appletvos-arm64.deb
mkdir -p com.imore.tvosavplayer_1.0-2_appletvos-arm64/Library/Frameworks/
dpkg-deb -x com.imore.tvosavplayer_1.0-2_appletvos-arm64.deb com.imore.tvosavplayer_1.0-2_appletvos-arm64/
