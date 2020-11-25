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

### Create a Project

A HolonCode project consists of a database that contains the program units and a browser for handling the program. IOW, a content management system for source code

To create a new project, say "MyProject", use the command  "tclsh holonCode\src\holoncode.tcl MyProject.hdb". 

#### Windows

```
tclsh holonCode\src\holoncode.tcl MyProject.hdb
````
#### macOS and Linux

````
#!/bin/bash
cd `dirname $0` 
tclsh holonCode/src/holoncode.tcl MyProject.hdb &
````

#### The command has three parts:

````
tclsh
````
1. starts the Tcl app     

`````
holonCode\src\holoncode.tcl 
`````
2. loads and starts HolonCode

`````
MyProject.hdb
`````
3. opens the database and makes "MyProject" the name of the project.




### Example Application HolonTF
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

