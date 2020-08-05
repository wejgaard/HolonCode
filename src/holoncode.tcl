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

proc ProjectDB {} {
	global argv appname 
	set db [lindex $argv 0]
	set db "./$db"  
	set appname [file rootname [file tail $db]]
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
	}	
	UpdateRunning
}

proc CreateStructure {} {
		mk::row append wdb.base  monitor 0 view list	version 0.001 \
			geometry "1100x700+50+50" extension 1  \
			textcolor #ffffff codecolor 1 pages 2 comdel //  running 0 \
			runcmd "../tclkit ./main.tcl" syntax Tcl safe 0 \
			pagesize A4 start 0 codefont Verdana codesize 12 fontsize 12 revpage 1
		set c [AppendPage type chapter name "Revisions" mode source]
    		SetBase list $c active $c
    		SetPage $c next ""
    		set s [AppendPage type section name "Setup"]
    		SetPage $c list $s active $s
    		SetPage $s next $c
    		set u [AppendPage type unit name "0.001"]
    		SetPage $s list $u active $u
    		SetPage $u next $s
    		SetBase revpage $u
		mk::file commit wdb
}

proc AboutHolonCode {} {
	if [winfo exists .about] {return}
	toplevel .about
	wm title .about "About HolonCode"
	set abouttext [text .about.t -width 80 -height 27]
	pack $abouttext -side top -fill both
	AnzahlElemente
  	$abouttext insert 1.0 "
  HolonCode Version $::sourceversion 
  Copyright 2008-20 Wolf Wejgaard
  All Rights Reserved
    
  Contact/Support: 
  wejgaard@holonforth.com
       
  Current # Elements:
  $::AboutElemente 

"
}

proc License {} {
	global licensed keytext
	if [winfo exists .license] {return}
	toplevel .license
	wm title .license "HolonCode License"
	set lt [text .license.t -wrap word -height 40 -width 90 -padx 20 -pady 20]
	pack $lt -side top -fill both -expand true
	$lt insert 1.0 "Open Source License\n"
	$lt insert end $::LicenseText
	$lt configure -state disabled

}

proc LoadUnit {} {
	global view 
	if [NoUnits] return
	if [Editing] {SaveIt}
	set loadText [GetPage [Unit] source]
	if {[catch	{SendMonitor $loadText} result]} {
		tk_messageBox -type ok -message "Sorry, $result  "
	}	
}

proc AskSetup {} {
	global setup menu color
	set setup(win) .setup
	if [winfo exists $setup(win)] {raise $setup(win); return}
	toplevel $setup(win)
	wm title $setup(win) "Preferences"
	.setup config -bg $color(pagebg)
	SetupRevision
	SetupOperation
#	SetupPrinting
	SetupOK
	wm protocol $setup(win) WM_DELETE_WINDOW {EndSetup}
}

proc EndSetup {} {
	global setup view
	SetBase safe $setup(safe)
	SetBase fontsize $setup(size); SetBase codesize $setup(codesize); AdjustFontsize
	SetBase codecolor $setup(codecolor); if {![Editing]} {ShowCode [CurrentPage]}
	if {[GetBase extension]!=$setup(extension)} {
		SetBase extension $setup(extension); RefreshChapters
	}	
	if {[GetBase extension]==0} {
		$view(lists).cf configure -text "  Chapters" -fg #888
		$view(treeframe) configure -text "  Chapters" -fg #888
	} else {
		$view(lists).cf configure -text "  Chapters" -fg #888
		$view(treeframe) configure -text "  Chapters" -fg #888
	}
	destroy $setup(win)
}

proc ConfigurationMenu {} {
	global menu
	.menubar add cascade -label Configuration -menu .menubar.version -underline 0
	set menu(version) [menu .menubar.version -tearoff 0 ]
	$menu(version) add command -label "Preferences" -command AskSetup
	$menu(version) add command -label "Commit" -command Commit
	$menu(version) add command -label "About" -command AboutHolonCode
	$menu(version) add command -label "License" -command License
#    ShowProject
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

proc HolonMenu {} {
	global menu
	.menubar add cascade -label Holon -menu .menubar.holon -underline 0
	set menu(holon) [menu .menubar.holon -tearoff 0]
	$menu(holon) add command -label "Markup for Import" -command {Markup}
	$menu(holon) add command -label "New Project" -command {NewProject}
	$menu(holon) add command -label "License" -command {License}
}

proc CreateMenu {} {
	menu .menubar  
	. config -menu .menubar
	FileMenu 
	ViewMenu 
	ConfigurationMenu
	HolonMenu
}

proc TitlePane {} {
	global view color

	# the frame for title and version 
	set view(titleversion) [frame $view(page).tv -relief sunken -bd 1 -bg white]

	# the title space
	set view(title) $view(titleversion).title
	text $view(title) -width 40  -undo true	-font title -pady 7  \
		-height 1 -state disabled -relief flat -padx 9 -bg $color(menu) \
		-highlightthickness 0 -highlightcolor white
	pack $view(title) -side left -fill both 

	# the version space
	pack [VersionPane] -side right -fill x -fill y -expand true

	# configure
	TitleTags
	TitleBindings
 	return $view(titleversion)
}

proc Import-hml {} {
	set file [tk_getOpenFile -filetypes {{"" {".hml"}}} -initialdir . ]
	if {$file==""} {return}
	ImportChapter $file
}

proc StoreText {} {
	global view changed 
	# if text exists with no space at end, append space.
	if {[$view(text) get 1.0 end]!="\n" && [$view(text) get end-2char]!=" "} {
  		$view(text) insert end " "       ;# preserve tag at end
  	}
	tk::TextSetCursor $view(text) 1.0
	eval {$view(text) mark unset} {$view(text) mark names} 
	$view(text) tag remove foundit 1.0 end
	set title [string trim [$view(title) get 1.0 1.end]]
	set text [$view(text) dump 1.0 "end - 1 char"]
	set code [string trimright [$view(code) get 1.0 end ]]; 
	set cursor [lindex [$view(code) yview] 0] 
	set test " "; 	# set test [string trim [$view(test) get 1.0 end]]
	SavePage [CurrentPage] $text $code local $title $cursor $test $changed
}

proc SetPanes {} {
	global view
	eval $view(panes) sash place 0 $view(sash0)
}

proc ShowPage {id} {
	global view oldVersion color
	set ::page $id
	set oldVersion 0
	SetList $id
	ShowTitle $id
	ShowVersions $id; # ShowTest $id
	ShowText $id
	ShowCode $id
 	if {[Deleted $id]} {
		$view(version) configure -state normal 
		$view(version) delete 1.0 end
		$view(version) insert end "\[deleted\]" deleted
		$view(version) configure -state disabled 
	}
	foreach pane "$view(chapters) $view(sections) $view(units) $view(tree)" {$pane configure -bg $color(pagebg)}	
	TextCodePanes $id
	ShowLinPage $id
	ShowTree $id
	ShowFoundText 
	MarkInfoPages
	StartVisitTime
	SetTreePage
}

proc WriteSourceVersion {} {
}

proc EndSession {} {
	DisableMotionEvents
	SetBase geometry 1000x600+40+40   
	CloseDB
	destroy $::topwin 
	exit
}

# für OSX-App:
if [namespace exists starkit] {
	cd ../..
	if [osx] {cd ../../..}
}

Running?

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

WriteAllChapters
RunHolon  ; # stays here until the user ends the program

