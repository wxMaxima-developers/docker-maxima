#!/bin/sh
docker build -t maxima .
docker run maxima cat maxima-x86_64.AppImage > maxima-x86_64.AppImage
chmod +x maxima-x86_64.AppImage
