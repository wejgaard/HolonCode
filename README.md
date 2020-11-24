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

### Installation

#### Tcl/Tk
Download and install Tcl/Tk via https://docs.activestate.com/activetcl/8.6/

#### HolonCode
Download Holoncode.zip 
or access HolonCode in GitHub Desktop


### Example Application HolonTF
My Holoncode project that created TclForth

![HolonTF](https://www.holonforth.com/images/holontf2.png)


### Run HolonTF

#### Windows

```
tclsh holonCode\src\holoncode.tcl holontf.hdb
````
#### macOS and Linux

````
#!/bin/bash
cd `dirname $0` 
tclsh holonCode/src/holoncode.tcl holontf.hdb &
```
