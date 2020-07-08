package require Mk4tcl
package require Tk

set dir [file dirname $argv0]

source $dir/model.tcl
source $dir/structureview.tcl
source $dir/pageview.tcl
source $dir/mainview.tcl
source $dir/browsing.tcl
source $dir/editing.tcl
source $dir/develop.tcl
source $dir/interfaces.tcl

OpenDB
set sysdir [pwd]
set sourcedir [string tolower $sysdir/$appname/]
file mkdir $sourcedir

if {[GetBase monitor]} {StartMonitor}
if {[GetBase syntax]==""} {SetBase syntax Tcl}
if {[GetBase safe]==""} {SetBase safe 1}
if {[GetBase fontsize]==""} {if [osx] {SetBase fontsize 13} {SetBase fontsize 11}}
SetBase comdel \\
set version [GetBase version]

wm title . "[string toupper $appname 0 0]"   
wm geometry . [GetBase geometry]  
wm minsize . 700 400

WriteAllChapters
RunHolon  ; # stays here until the user ends the program

