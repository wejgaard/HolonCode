# Copyright (c) 2008 - 2021 Wolf Wejgaard. All  Rights Reserved.
#  
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

proc SetupRevision {} {
	global setup frev color
	set frev [labelframe $setup(win).frev -text "Revision" \
		-borderwidth 1 -padx 10 -pady 5 \
		-relief solid -bg $color(setup)]
	grid $frev -sticky we
	grid configure $frev -padx 20 -pady 5

	set setup(version) $::version
	label $frev.vl -text "Version: " -bg $color(setup) 
	entry $frev.ve -textvariable setup(version) -width 8 -font code 
	grid $frev.vl $frev.ve -sticky w -pady 2
}

proc SetupOperation {} {
	global setup color
	set fops [labelframe $setup(win).fops -text "Operation" -borderwidth 1 -padx 10 -pady 5 \
		-relief solid -bg $color(setup)]
	grid $fops  -sticky we
	grid configure $fops -padx 20 -pady 5
	
	set setup(safe) [GetBase safe]
	label $fops.dl -text "Delete items with key:  " -bg $color(setup)
	radiobutton $fops.db1 -text "<Delete>" -variable setup(safe) -value 0 -bg $color(setup)
	radiobutton $fops.db2 -text "<Shift+Delete>" -variable setup(safe) -value 1 -bg $color(setup)
	grid $fops.dl $fops.db1 $fops.db2 -sticky w -pady 2
 
	set setup(extension) [GetBase extension]	
	label $fops.xl -text "Show chapter:" -bg $color(setup)
	radiobutton $fops.xon -variable setup(extension) -text "With filetype" -value 1 -bg $color(setup)
	radiobutton $fops.xoff -variable setup(extension) -text "Without filetype" -value 0 -bg $color(setup)
	grid $fops.xl $fops.xon $fops.xoff -sticky w -pady 2
	
	set setup(size) [GetBase fontsize]
	label $fops.fsl -text "Font size: " -bg $color(setup) 
	entry $fops.fse -textvariable setup(size) -width 3 -font code
	grid $fops.fsl $fops.fse -sticky w -pady 2

	set setup(codesize) [GetBase codesize]
	label $fops.fcsl -text "Code size: " -bg $color(setup)
	entry $fops.fcse -textvariable setup(codesize) -width 3 -font code
	grid $fops.fcsl $fops.fcse -sticky w -pady 2

	set setup(codecolor) [GetBase codecolor]	
	label $fops.ccl -text "Syntax highlighting:" -bg $color(setup)
	radiobutton $fops.ccon -variable setup(codecolor) -text "on" -value 1 -bg $color(setup)
	radiobutton $fops.ccoff -variable setup(codecolor) -text "off" -value 0 -bg $color(setup)
	grid $fops.ccl $fops.ccon $fops.ccoff -sticky w -pady 2	

}

proc SetupPrinting {} {
	global setup color
	set fpnt [labelframe $setup(win).fpnt -text "Printing" -borderwidth 1 -padx 10 -pady 5 \
		-relief solid -bg $color(setup)]
	grid $fpnt -sticky we
	grid configure $fpnt -padx 20 -pady 5

	set setup(comdel) [GetBase comdel]
	label $fpnt.cl -text "Comment line delimiter:  " -bg $color(setup)
	entry $fpnt.ce -textvariable setup(comdel) -width 4 -font code 
	grid $fpnt.cl $fpnt.ce  -sticky w -pady 2

	set setup(pagesize) [GetBase pagesize]
	label $fpnt.sl -text "Page size:               " -bg $color(setup)
	radiobutton $fpnt.sb1 -variable setup(pagesize) -text "US Letter      " -value "letter" -bg $color(setup)
	radiobutton $fpnt.sb2 -variable setup(pagesize) -text "A4"	-value "A4" -bg $color(setup)
	grid $fpnt.sl $fpnt.sb1 $fpnt.sb2   -sticky w -pady 2
}

proc SetupOK {} {
	global setup color setOK
	set setOK 0
	set fok [frame $setup(win).fok -borderwidth 20 -bg $color(setup) ]
	grid $fok 
	button $fok.ok -text OK -command {set setOK 9} -padx 25 -pady 5 \
		-relief raised -border 2 -bg $color(setup)
	pack $fok.ok  -pady 5
	bind $setup(win) <Return> {EndSetup}
}

proc EndSetup {} {
	global setup view 
	SaveSetupVersion	$setup(version); .b.rev config -text "Rev. $setup(version)"
	SetBase safe $setup(safe)
	SetBase fontsize $setup(size); 
	SetBase codesize $setup(codesize); AdjustFontsize
	SetBase codecolor $setup(codecolor); if {![Editing]} {ShowCode [CurrentPage]}
	if {[GetBase extension]!=$setup(extension)} {
		SetBase extension $setup(extension); RefreshChapters
	}
}

proc AskSetup {} {
	global setup color setOK
	set setup(win) .setup
	toplevel $setup(win)
	wm title $setup(win) "Preferences"
	.setup config -bg $color(pagebg)
	SetupRevision
	SetupOperation
	SetupOK
	vwait setOK
	destroy $setup(win)
	EndSetup
}

set AboutElemente ""

proc AnzahlElemente {} {
	set CC 0; set SS 0; set UU 0
	set endUnit [Unit]
	SetChapter [FirstChapter]
	while {[Chapter]!=""} {
		incr CC
		set s [Section]
		SetSection [FirstSection]
		while {[Section]!=[Chapter]} {
			incr SS
			set u [Unit]
			SetUnit [FirstUnit]
			while {[Unit]!=[Section]} {
				incr UU
				set endUnit [Unit]
				SetUnit [NextUnit]
			}
			SetUnit $u
			SetSection [NextSection]
		}
		SetSection $s
		SetChapter [NextChapter]
	}
	set ::AboutElemente "$CC Chapters,  $SS Sections, $UU Units"
	GotoUnit $endUnit
}

proc IncrVersion {} {
	global version
	set v1 [split $version .]         
	if {$v1==$version} {
		set v2 $v1                
	} {
		set v2 [lindex $v1 end] 
	} 
	set n [string length $v2]
	incr n -1		                          ;# length of changenumber
	set v3 [join "1 $v2" ""]       ;# avoid leading zeros = octal
	incr v3
	set v2 [string range $v3 end-$n end]
	if {$v1==$version} {
		set version $v2
	} {
		set v1 [lreplace $v1 end end $v2]
		set version [join $v1 .]
	}
}

proc ShowProject {} {
	wm title . "$::appname  "
}

proc Commit {} {
	global version  
	set revpage  [GetBase revpage]
	if {$revpage==""} return
	GotoTree [GetBase revpage]; update
	IncrVersion
	SetVersion $version
	WriteSourceVersion
	AddLogPage
}

proc SaveSetupVersion {v} {
	if {$v==$::version} {return}
	SetVersion $v
	WriteSourceVersion
#	ShowProject
	focus .
}

proc WriteSourceVersion {} {
	set version [GetBase version]
	set f [open $::sourcedir/sourceversion.tcl w]
	puts $f "set sourceversion $version"
	close $f
}

proc UpdateChangelist {id} {
	global version changelist
	if {$version==[lindex $changelist end]} {return}
	lappend changelist $version
	SetPage $id changes $changelist 
	
}

proc GotoLogPage {} {
	set u [GetBase revpage]
	if $u {GotoUnit $u}
}

proc AddLogPage {} {
	if [Editing] SaveIt
	global version 
	LastProgramUnit
	set u [AppendPage name "$version" changes $version date [clock seconds] ]
	InsertUnit $u after
	SetBase revpage $u
	.b.rev config -text "Rev. $version"
}

proc EditRevision {} {
	set ::findText ""
	set ::searchText ""
	set ::replaceText ""
	ShowRevision $::version
	GotoTree [GetBase revpage]
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
  
  2. In a terminal/console enter:
 	
      Windows:
 	
         tclsh HolonCode\\src\\holoncode.tcl MyProject.hdb

      Mac and Linux:
     
        #!/bin/bash
        cd `dirname \$0` 
        tclsh HolonCode/src/holoncode.tcl MyProject.hdb &
  
 
  The new project creates the database MyProject.hdb
  and the folder myproject/  for source files
  that are generated in the project.
 
  You are ready to go.
"
}

proc CreateImportScript {} {
	global Chapters VersionButton
	set d ./source/
	set f [open ${d}project.imp w]
	set version [GetBase version]
	puts $f "SetVersion $version"
	foreach c $Chapters {puts $f [list ImportChapter $d[GetPage $c name].hml]}
	puts $f "SetPageStack 3"
	close $f
}

proc ExportChapters {} {
	global Chapters 
	CreateImportScript
	set current [Chapter]
	foreach c $Chapters {
		SetChapter $c
		FocusChapters; update idletasks
		ExportChapter
	}
	SetChapter $current	
}

proc ImportChapters {} {
	source ./source/project.imp
}

set LicenseText {
GNU General Public License v3.0
Copyright 2008-2020 Wolf Wejgaard

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

--

CREDITS
HolonCode is programmed in TclTk and uses the Metakit database.
License for TclTK:  http://www.tcl.tk/software/tcltk/license.html
License for Metakit:  http://equi4.com/metakit/license.html

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

