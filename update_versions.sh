#!/bin/sh

maxima_build='tags\/5.46.0'

sed -i -e "s/ENV maxima_build .*/ENV maxima_build $maxima_build/" Dockerfile
