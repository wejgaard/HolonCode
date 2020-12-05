# HolonS

### Overview

[HolonS](https://holonforth.com/holons.html) handles program units in a structure of sections and chapters. 
Like a book. 



![HolonTF](https://www.holonforth.com/images/holontest.png)





### Features

see [HolonS](https://holonforth.com/holons.html) 

- Internal Revision Control
- Saves state of a page when edited under a new version - after a commit
- version control of DB items.
- 
- GitHub works on files - not on DB - a datastructure other than text
- Holonfiles are rewritten from DB at a new session
- 
- HolonS creates Mastersource for Holoncode
- Copy holons/ to src/ to make changes valid for the  HolonCode Projects
- HolonS, HolonTF and Projects

* Works in Windows, macOS and Linux, wherever Tcl/Tk runs.



### Run HolonS

#### Windows

```
tclsh holonCode\src\holoncode.tcl HolonS.hdb
````
#### macOS and Linux

````
#!/bin/bash
cd `dirname $0` 
tclsh holonCode/src/holoncode.tcl HolonS.hdb &


````



# 

müsste files vergleichen