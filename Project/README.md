# User Projects

### 1. Install Tcl/Tk

Download and install Tcl/Tk via https://docs.activestate.com/activetcl/8.6/

### 2. Install HolonCode
Download Holoncode.zip, <br> 
or use HolonCode in GitHub Desktop

### Create a new Project

A HolonCode project consists of a database that contains the program units and a browser for handling the program. <br>IOW, a content management system for source code

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
tclsh  - starts the Tcl app     

holonCode\src\holoncode.tcl   - loads and starts HolonCode

MyProject.hdb  - opens the database and makes "MyProject" the name of the project.
````

## Programming

