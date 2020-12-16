package require Mk4tcl
package require Tk

set dir [file dirname $argv0]
# if [namespace exists starkit] {set dir "."}

source $dir/model.tcl
source $dir/structureview.tcl
source $dir/pageview.tcl
source $dir/mainview.tcl
source $dir/browsing.tcl
source $dir/editing.tcl
source $dir/develop.tcl
source $dir/interfaces.tcl

proc ProjectDB {} {
	global argc argv appname 
	if [namespace exists starkit] {
		set dir [pwd]; if [osx] {set type app} {set type exe}
		set file [lindex [glob *.$type] 0]
		set db [lindex [split $file .] 0].hdb 
	} {
		if {$argc} {set db [lindex $argv 0]} {set db [tk appname].hdb}
	}
	set db "./$db"  
	set appname [file rootname [file tail $db]]
	set db [string tolower "./$db"]  
	return $db
}

proc OpenDB {} {
	global wdb db
	set db [ProjectDB]
	# open or create DB  
	set newdb [expr ![file exists $db]]
	mk::file open wdb $db -shared                 ;# wdb is handle of the db-file
	SetDBLayout
	if {$newdb} {CreateStructure}
	catch {
		if {[GetBase running]!="" && ([clock seconds]-[GetBase running])<90} {
			wm iconify .  ;# reduce window to icon, only message box is visible
			tk_messageBox -type ok -message "System is already running"
			exit
		}	
	}	UpdateRunning
}

proc ShowRevision {rev} {
	global view color findText searchText infomode
	$view(rev) configure -state normal; $view(rev) delete 1.0 end; 
	set findText ""; set searchText ""; ShowFoundText
	RevisionTitle " Found"
	update
	return
}

proc EndSession {} {
	DisableMotionEvents
#	SetBase geometry [wm geometry .]   
#	SetBase geometry 1280x678+0+22   
	SetBase geometry 1000x600+40+40   
	CloseDB
#	file delete $::runfile
	destroy $::topwin 
	exit
}

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

