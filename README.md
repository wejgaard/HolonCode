# HolonCode

### Overview
HolonCode handles program units in a structure of sections and chapters. 
Like a book. 


### Features
* Clear presentation of the program code.
* Chapters are files. 
* The files are instantly updated.
* Internal version control.
* Works in Windows, macOS and Linux, wherever Tcl/Tk runs.









### Create a Project

[User Project](https://github.com/wejgaard/HolonCode/tree/master/Project)





## Example Project HolonTF
The HolonCode project that created TclForth.

![HolonTF](https://www.holonforth.com/images/holontf2.png)


### Run HolonTF

#### Windows

```
tclsh holonCode\src\holoncode.tcl HolonTF.hdb
````
#### macOS and Linux

````
#!/bin/bash
cd `dirname $0` 
tclsh holonCode/src/holoncode.tcl HolonTF.hdb &

