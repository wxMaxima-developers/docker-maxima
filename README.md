Appimage build for Maxima
=========================

Building Appimage
-----------------

To build the Appimage, run the following command:

```
$ docker build -t maxima .
```

This will build all dependenecies and the Maxima application itself.
After the build has completed, run the following command to copy the
Appimage from the container:

```
$ docker run maxima cat maxima-x86_64.AppImage > maxima-x86_64.AppImage
```

Finally, set the executable flag so that the executable can be run:

```
$ chmod +x maxima-x86_64.AppImage
```

All of these commands have been combined to a shell script,

```
$ build.sh
```
