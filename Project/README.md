# User Projects

### 1. Install Tcl/Tk

Download and install Tcl/Tk via https://docs.activestate.com/activetcl/8.6/

### 2. Install HolonCode
Download Holoncode.zip, <br> 
or use HolonCode in GitHub Desktop

### Create a new Project  

A HolonCode project consists of a database that contains the program units and a browser for handling the program. 
IOW, HolonCode is a content management system for source code

To create a new project, say "MyProject", 

1. start with a new project folder MyProject and 
2. make HolonCode create a new database MyProject.hdb <br>with the following script: 

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
  
1. tclsh <br>starts the Tcl app     

2. holonCode\src\holoncode.tcl <br>loads and starts HolonCode, which opens the database

3. MyProject.hdb<br>and makes "MyProject" the name of the project.


### Programming

