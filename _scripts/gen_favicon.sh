#!/bin/bash
#
# Author: Jason Graham
# http://jason.the-graham.com/about
#
# This script downloads my gravatar image and uses it to create the
# favicon for the website.

wget "http://www.gravatar.com/avatar/b2a0f795640bd199b6a00ba9fd4c4809?s=256" -O /tmp/favicon.jpg

convert /tmp/favicon.jpg ./favicon.png

# below is adapted from
# http://www.brennan.id.au/13-Apache_Web_Server.html#favicon
pngtopnm -mix ./favicon.png > tmp_logo.pnm

rm -f favicon.ico

pnmscale -xsize=32 -ysize=32 ./tmp_logo.pnm > tmp_logo32.ppm
pnmscale -xsize=16 -ysize=16 ./tmp_logo.pnm > tmp_logo16.ppm

pnmquant 256 tmp_logo32.ppm > tmp_logo32x32.ppm
pnmquant 256 tmp_logo16.ppm > tmp_logo16x16.ppm

ppmtowinicon -output ./favicon.ico tmp_logo16x16.ppm tmp_logo32x32.ppm

rm -f tmp_logo* favicon.png
