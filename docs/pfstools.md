## pfstools

For handling high dynamic range image formats (.hdr), the [pfstools](http://pfstools.sourceforge.net/) is recommended. After careful compilation and debugging, the version 1.9.1 is recommended by myself.

To version 2.1.0 is the latest, but dependent on opencv2 with nonfree module. The command in the README indicates to install opencv-nonfree module from ppa repository ```xqms/opencv-nonfree```, which is currently 404. This version is build upon opencv2, and installation of opencv3 or opencv4 with contrib module would not help to solve the issue.

Therefore, stick to pfstools 1.9.1 please. (Pay attention to the virtual environment)

## how to compile and install

```
cd <pfstools_dir>
mkdir build
cd build
cmake ../
make
(sudo) make install
```

## how to view HDR image

[pfsglview](http://pfstools.sourceforge.net/man1/pfsglview.1.html) is a OpenGL/GLUT application for viewing high-dynamic range images. It expects pfs stream on the standard input and displays the frames in that stream one by one.

```
(sudo) pfsin xxxxxx.hdr | pfsglview
```

## how to output HDR image

```pfsout```: Read pfs frames from stdin and write them in the format determined by the extension of the file name. 

```
(sudo) pfsin xxxxxx.hdr | pfsout xxxxxx.jpg
```