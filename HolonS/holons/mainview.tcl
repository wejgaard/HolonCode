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

proc CreateButton {name command} {
	global color buttonBar
	set lcname [string tolower $name]
	set ::$name [label $buttonBar.$lcname -text $name -bg $color(menu)	-font button \
		-height 1 -width 7 -relief flat -bd 1 ]
	set press "$buttonBar.$lcname configure -relief sunken; update; $command" 
	bind $buttonBar.$lcname <Button-1> $press
	set release "$buttonBar.$lcname configure -relief flat ;"
	bind $buttonBar.$lcname <ButtonRelease> $release
	set enter "$buttonBar.$lcname configure -relief flat -cursor arrow  ;"
	bind $buttonBar.$lcname <Enter> $enter
	set leave "$buttonBar.$lcname configure -relief flat -cursor xterm ;"
	bind $buttonBar.$lcname <Leave> $leave
 }

proc DoRun {} {
	if [Editing] {SaveIt}
	cd $::sourcedir; 
	eval exec [GetBase runcmd] &
	cd ..   ;# reset to project dir 
}

proc BrowserButtons {} {
	global color
	.b.new configure -text New -bg $color(button) ; bind .b.new <Button-1> NewPage 
	.b.edit configure -text Edit -bg $color(button) ; bind .b.edit <Button-1> EditIt 
	.b.load configure -bg $color(button)
}

proc EditorButtons {} {	
	.b.edit configure -text Save -bg #eeffff  ; 	bind .b.edit <Button-1> SaveIt
	.b.new configure -text Cancel -bg #ffeeff  ;	bind .b.new <Button-1> Cancel
	.b.load configure	-bg #eeffff 
}

proc CreateButtons {} {
	CreateButton Back GoBack   
	CreateButton New NewPage
	CreateButton View ChangeView
	CreateButton Edit EditIt
	CreateButton Load LoadUnit
	CreateButton Setup AskSetup
	CreateButton Run DoRun
	CreateButton Test LoadTest
	CreateButton Commit Commit
	CreateButton Print Print
	CreateButton Rev EditRevision
	CreateButton Clear ClearAll
	label .b.leer -text " |    " -bg $::color(menu)
	bind .b.rev <$::RightButton> ShowRevisions
	bind .b <$::RightButton> ClearAll
	bind .b <Button-1> ClearAll
	bind .b.load <$::RightButton> DoRun
}

proc FindReplace {} {
	global color findText replaceText 
	frame .s -bg $color(system) -padx 0 -pady 8 -relief flat -bd 0 
	label .s.ftext -text "   Find " -bg $color(system) -font button  
	entry .s.find -textvariable findText -font code -width 14 -highlightthickness 0 -bd 1
	bind .s.find <Return> EditIt
	bind .s.ftext <Button-1> ClearAll
	label .s.rtext -text "   Replace " -bg $color(system) -font button 
	entry .s.replace -textvariable replaceText -font code -width 14 -highlightthickness 0 -bd 1
	bind .s.replace <Return> {focus .}
	bind .s.rtext <Button-1> ClearAll
	label .s.leer -text " " -bg $color(menu)
	pack .s.leer -side right 
	pack .s.replace -side right -expand 0 -fill x 
	pack .s.rtext -side right -expand 0 
	pack .s.find -side right -expand 0 -fill x 
	pack .s.ftext -side right -expand 0
	return .s
}

proc PackButtons {} {
	pack $::Back $::View $::New $::Edit $::Load .b.leer $::Rev  -side left -padx 0 -pady 0 
	pack [FindReplace] -in .b -side right 
}

proc ButtonBar {} {
	global color buttonBar 
	set buttonBar .b
	frame $buttonBar -relief flat -bd 1 -bg $color(menu) -padx 5 -pady 6 -cursor xterm
	CreateButtons
	PackButtons
#	.b.rev config -text "Revision $::version"
	.b.rev config -text "Rev. $::version"
	.b.rev config -width 8
	return $buttonBar
}

proc CreateMenu {} {
	menu .menubar  
	. config -menu .menubar
	FileMenu 
	ViewMenu 
	ConfigurationMenu
	HolonMenu
}

proc FileMenu {} {
	global menu
	.menubar add cascade -label Project -menu .menubar.file -underline 0
	set menu(file) [menu .menubar.file -tearoff 0]
	$menu(file) add command -label "Import .fml" -command Import-fml
#	$menu(file) add command -label "Import .of" -command Import-of
	$menu(file) add command -label "Export .hml" -command ExportChapter
	$menu(file) add command -label "Import .hml" -command Import-hml
#	$menu(file) add command -label "Print Chapter" -command PrintChapter
#	$menu(file) add command -label "Print Section" -command PrintSection
#	$menu(file) add command -label "Print Unit" -command PrintUnit
#	$menu(file) add command -label "Export Project" -command ExportChapters
#	$menu(file) add command -label "Import Project" -command ImportChapters
	$menu(file) add command -label "Quit" -command EndSession  
}

proc ViewMenu {} {
	global menu
	.menubar add cascade -label View -menu .menubar.view -underline 0
	set menu(view) [menu .menubar.view -tearoff 0 ]
	$menu(view) add command -label "Lists View" -command {SetListView}
	$menu(view) add command -label "Tree View" -command {SetTreeView}
	$menu(view) add command -label "Linear View" \
		-command {LinearView; update idletasks; ShowLinPage [CurrentPage]}
	$menu(view) add command -label "Lists longer   (+)" -command {IncrList}
	$menu(view) add command -label "Lists shorter  (-)" -command {DecrList} 
}

proc ConfigurationMenu {} {
	global menu
	.menubar add cascade -label Configuration -menu .menubar.version -underline 0
	set menu(version) [menu .menubar.version -tearoff 0 ]
	$menu(version) add command -label "Preferences" -command AskSetup
	$menu(version) add command -label "About" -command AboutHolonCode
}

proc HolonMenu {} {
	global menu
	.menubar add cascade -label Holon -menu .menubar.holon -underline 0
	set menu(holon) [menu .menubar.holon -tearoff 0]
	$menu(holon) add command -label "Markup for Import" -command {Markup}
	$menu(holon) add command -label "New Project" -command {NewProject}
	$menu(holon) add command -label "License" -command {License}
}

proc AboutHolonCode {} {
	if [winfo exists .about] {return}
	toplevel .about
	wm title .about "About HolonCode"
	set abouttext [text .about.t -width 80 -height 27]
	pack $abouttext -side top -fill both
	AnzahlElemente
  	$abouttext insert 1.0 "
  HolonCode Version 1.0 
  Copyright 2008-20 Wolf Wejgaard
  All Rights Reserved
    
  Current # Elements:
  $::AboutElemente 
  
  "
}

set menu(chapters) ""
set menu(sections) ""
set menu(units) ""
set menu(tree) ""
set menu(text) ""
set menu(setup) ""
set menu(version) ""
set menu(view) ""
set menu(revision) ""

proc ChapterMenu {} {
	global menu view
	set menu(chapters) [menu $view(lists).cmenu -tearoff 0]
	$menu(chapters) add command -label "New chapter" -command AddChapter
	$menu(chapters) add command -label "Print chapter" -command PrintChapter	
}

proc SectionMenu {} {
	global menu view
	set menu(sections) [menu $view(lists).smenu -tearoff 0]
	$menu(sections) add command -label "New Section" -command AddSection
	$menu(sections) add command -label "Copy Section" -command CopySection
	$menu(sections) add command -label "Print Section" -command PrintSection
}

proc UnitMenu {} {
	global menu  view
	set menu(units) [menu $view(lists).umenu -tearoff 0]
	$menu(units) add command -label "New Unit" -command NewUnit
	$menu(units) add command -label "Copy Unit" -command CopyUnit
	$menu(units) add command -label "Print Page" -command PrintUnit
}

proc RevisionMenu {} {
	global menu
	set menu(revision) [menu .b.rev.menu -tearoff 0 ]
	$menu(revision) add command -label "Commit" -command {Commit}
	$menu(revision) add command -label "Revisions" -command ShowRevisions
#	ShowProject
}

proc LoadMenu {} {
	global menu
	set menu(load) [menu .b.load.menu -tearoff 0 ]
#	$menu(load) add command -label "Run" -command {DoRun}
#	ShowProject
}

proc ContextMenus {} {
	global view menu
	ChapterMenu
	bind $view(chapters) <$::RightButton> {tk_popup $menu(chapters) %X %Y}
	bind $view(chapters) <Control-Button-1> {tk_popup $menu(chapters) %X %Y}
	SectionMenu 
	bind $view(sections) <$::RightButton> {tk_popup $menu(sections) %X %Y}
	bind $view(sections) <Control-Button-1> {tk_popup $menu(sections) %X %Y}
	UnitMenu 
	bind $view(units) <$::RightButton> {tk_popup $menu(units) %X %Y}
	bind $view(units) <Control-Button-1> {tk_popup $menu(units) %X %Y}
	RevisionMenu
	bind $::Rev <$::RightButton> {tk_popup $menu(revision) %X %Y}
	bind $::Rev <Control-Button-1> {tk_popup $menu(revision) %X %Y}
	LoadMenu
	bind $::Load <$::RightButton> {tk_popup $menu(load) %X %Y}
	bind $::Load <Control-Button-1> {tk_popup $menu(load) %X %Y}
}

proc BindInfo {} {
	global view
	bind $view(info) <$::RightButton> {focus $view(info)}
}

proc InfoFrame {} {
	global color style
	eval labelframe .info $style(frame) 
	.info configure -text  "   Info" -fg #888
}

proc InfoPane {} {
	global color view 
	InfoFrame
	panedwindow .info.panes -orient vertical -borderwidth 0 \
		-sashrelief flat -opaqueresize 1 -sashwidth 3 -bg #f3f3f3
	set view(info) .info.panes.text
	if [osx] {set infosize 24} {set infosize 17}
	text $view(info) -width $infosize	-state disabled -wrap none -bg $color(menu) \
		-padx 8 -relief sunken -cursor arrow -bd 1 -highlightthickness 0 -pady 5 -spacing3 0
	BindInfo
	$view(info) tag configure normal -font infoNormal
	$view(info) tag configure bold -font infoBold
	$view(info) tag configure marking -foreground blue -font infoNormal
	$view(info) tag configure red -foreground brown -font infoNormal
	$view(info) tag configure title -font infoBold -spacing1 9 -spacing3 9 -foreground #666
	$view(info) tag raise marking
	set view(rev) .info.panes.revision
	text $view(rev) -width $infosize	-state disabled -wrap none -bg $color(menu) \
		-padx 8 -relief sunken -cursor arrow -bd 1 -highlightthickness 0 -pady 5 -spacing3 0
	$view(rev) tag configure normal -font infoNormal
	$view(rev) tag configure grey -font infoNormal -foreground #999
	$view(rev) tag configure date -font smallbold -foreground #666
	$view(rev) tag configure title -font infoBold -spacing1 9 -spacing3 9 -foreground #666
	.info.panes add $view(info)
	.info.panes add $view(rev)
	.info.panes sash place 0 0 163
	pack .info.panes -side top -fill both -expand 1
	return .info
}

set infomode ""

proc ClearVisited {} {
	global view 
	$view(info) configure -state normal
	$view(info) delete 1.0 end
	$view(info) configure -state disabled
}

proc ClearRevision {} {
	global view 
	$view(rev) configure -state normal
	$view(rev) delete 1.0 end
	$view(rev) configure -state disabled  
}

proc InfoTitle {name} {
	global view
	$view(info) configure -state normal 
	$view(info) insert end " $name" title
	$view(info) configure -state disabled
}

proc RevisionTitle {name} {
	global view
	$view(rev) configure -state normal 
	$view(rev) insert end "$name" title
	$view(rev) configure -state disabled
}

proc InsertInfo {name style id} {
	global view
	$view(info) configure -state normal  
	$view(info) tag bind goto$id <1> "GotoTree $id; break"
	# show name clashes red (two or more units with the same name)
	set n [llength [mk::select wdb.pages name $name type unit]]
	if {$n>1} {set style red}
	$view(info) insert end " $name\n" "goto$id $style"
	set style normal
	$view(info) configure -state disabled
}

proc InfoDate {name} {
	global view
	$view(rev) configure -state normal 
	$view(rev) insert end " $name\n" date
	$view(rev) configure -state disabled
}

proc InsertRevisionline {name style id} {
	global view
	$view(rev) configure -state normal 
	$view(rev) tag bind goto$id <1> "GotoTree $id; break"
	$view(rev) insert end " $name\n" "goto$id $style"
	set style normal
	$view(rev) configure -state disabled
}

proc MarkInfoPages {} {
	global view page 
	foreach pane {info rev} {
		# clear marks
		foreach name [$view($pane) tag names] {
			$view($pane) tag configure $name -foreground black
		}
		# mark current page
		foreach name [$view($pane) tag names] {
			if {$name=="goto$page"} {
				$view($pane) tag configure $name -foreground blue
			}
		}
	}
}

proc GetSashPositions {} {
	global view
	set view(sash0) [$view(panes) sash coord 0]
#	set view(sash1) [$view(panes) sash coord 1] 
}

proc WorkPane {} {
	global view
	frame $view(work)
	CreateLists 
	CreateTree 
	CreatePage
	if {[GetBase view]=="list"} {
		pack $view(lists) -side top -fill x
		pack $view(page) -side top -fill both -expand yes
	} else {
		pack $view(treeframe) -side left -fill y
		pack $view(page) -side left -fill both -expand yes
		place $view(lists) -x -2 -y -2
		$view(page) configure -text "  Page"  -fg #888
	}
	return $view(work)
}

proc CreateView {} {
	CreateMenu 
	ListStyles
	grid [ButtonBar] -row 0 -column 0 -columnspan 2 -sticky new  
	grid [InfoPane] -row 1 -column 1 -sticky news  
	grid [WorkPane] -row 1 -column 0 -sticky news
	grid columnconfigure . 0 -weight 1
	grid columnconfigure . 1 -weight 0
	grid rowconfigure . 0 -weight 0
	grid rowconfigure . 1 -weight 1 
	update  
}

proc SetListView {} {
	global view
	place forget $view(lists)
	pack forget $view(treeframe)
	pack forget $view(page)
	pack $view(lists) -side top -fill x
	pack $view(page) -side top -fill both -expand yes
	SetBase view list
	update
	after 100 {TextCodePanes [CurrentPage]}
	$view(page) configure -text ""
}

proc SetTreeView {} {
	global view
	pack forget $view(lists)
	pack forget $view(page)
	pack $view(treeframe) -side left -fill y
	pack $view(page) -side left -fill both -expand yes
	place $view(lists) -x -2 -y -2
	SetBase view tree
	after 100 {TextCodePanes [CurrentPage]}
	$view(page) configure -text "  Page"  -fg #888
}

proc ChangeView {} {
	if {[GetBase view]=="list"} {SetTreeView} {SetListView}
}

proc BindGlobal {} {
	bind . <Key-space> {if {![Editing]&&[focus]!=".s.find"&&[focus]!=".s.replace"} {StartFind}}
	bind . <Control-space> ClearAll
	bind . <Control-K> {console show}
	bind . <Control-s> SaveIt
	bind . <Control-n> {NewPage}
	if [osx] {
		bind . <Command-n> {NewPage}
		bind . <Command-m> {CopyUnit}
	}
}

proc BindHolon {} {
	ListboxSelection
	ListNavigation
	Plus&Minus
	Insert&Delete
	BindEditItem
	BindGlobal
}

proc InitHolon {} {
	global topwin 
	set topwin "."
	CreateFonts; 
	AdjustFontsize
	CreateColors
	CreateView
	ContextMenus
	BindHolon
}

proc InitSpecial {} { }

proc ShowHolon {} {
	global view
#	set ::page [lindex [PageStack] 0]
	set ::page 0
	ShowPage [CurrentPage]
	ShowVisitedPages 
	ShowRevision $::version
	after 300 {TextCodePanes [CurrentPage]}
}

proc DisableMotionEvents {} {
	global view
	bind $view(text) <Motion> {}
	bind $view(text) <Leave> {}
	bind $view(code) <Motion> {}
	bind $view(code) <Leave> {}
	bind $view(test) <Motion> {}
	bind $view(test) <Leave> {}
	bind $view(info) <Motion> {}
	bind $view(info) <Leave> {}
}

proc EndSession {} {
	DisableMotionEvents
	SetBase geometry 900x600+300+60   
	CloseDB
	destroy $::topwin 
	exit
}

proc RunHolon {}  {
	global topwin  
	InitHolon 
	InitSpecial
  	ShowHolon
  	FindLoop
	wm protocol $topwin WM_DELETE_WINDOW {EndSession}
	update idletasks
	after idle raise $topwin
	tkwait window $topwin
}

