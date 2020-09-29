package require Mk4tcl
package require Tk

set dir [file dirname $argv0]
if [namespace exists starkit] {set dir "."}

source $dir/model.tcl
source $dir/structureview.tcl
source $dir/pageview.tcl
source $dir/mainview.tcl
source $dir/browsing.tcl
source $dir/editing.tcl
source $dir/develop.tcl
source $dir/interfaces.tcl
source $dir/sourceversion.tcl

proc ListboxSelection {} {	
	bind . <<ListboxSelect>> {
	     switch -glob -- %W {
	          *chapters {UpdateChapters}
	          *sections {UpdateSections}
	          *units    {UpdateUnits}
	     }
	}
}

# proc Section {} {
# 	return [lindex [GetPage [Chapter] active] 0]
# }

proc LoadUnit {} {
	global view 
	if [NoUnits] return
	if [Editing] {SaveIt}
	set loadText [GetPage [Unit] source]
	if {[catch	{SendMonitor $loadText} result]} {
		tk_messageBox -type ok -message "Sorry, $result  "
	}	
}

proc Markup {} {
	if [winfo exists .markup] {return}
	toplevel .markup
	wm title .markup "Markup for Import"
	set markuptext [text .markup.t -width 80 -height 30]
	pack $markuptext -side top -fill both
	$markuptext insert 1.0 "
  IMPORTING .fml FILES  (Legacy Files Markup Language)
	
  <File> File=Chapter name
  (text)
  <Section> Section name
  (text)
  <Unit> Unit name
  code
  <Section> name 
  (text)
  <Unit> name
  code
 
  --
  Tag names are case insensitive
  Unit comments are imported with the code. 
  Text and code are delimited by the following tag. 
   
  -----------------------------------------------------------------
   
  IMPORTING .hml FILES  (Holon Markup Language)
  (export a chapter for an example)
  
  <Chapter>
  <Name> Name of Chapter
  <Comment> text
  <Section>
  <Name> Get prime numbers
  <Comment> text
  <Unit>
  <Name> Name of unit
  <Comment> text
  <Source> text
  <Unit>
  <Name> Name of unit
  <Source> text
  <Section>
  <Name> Name of section
  <Comment> text
  
  --
  Comments and source are delimited by the following tag. 
  Exported <Comment> text contains Tcl Editor markup.
 
"
}

proc NewProject {} {
	if [winfo exists .project] {return}
	toplevel .project
	wm title .project "Holon Projects"
	set projecttext [text .project.t -width 80 -height 30]
	pack $projecttext -side top -fill both
	$projecttext insert 1.0 " 
  CREATING A NEW PROJECT
	
  1. Create a project folder, say, 'MyProject'
  2. Insert a COPY of HolonTalk.app and rename it 'MyProject.app' -- or .exe 
  3. Run the App. 
  
  The new project App creates the database MyProject.hdb and the folder 
  myproject/  for source files that are generated in the project.
  
  You are ready to go.
   
"
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
wm minsize . 870 450
tk_focusFollowsMouse

WriteAllChapters
RunHolon  ; # stays here until the user ends the program

