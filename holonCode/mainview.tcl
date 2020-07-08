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
	CreateButton Print Print
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
	pack $::Back $::View $::New $::Edit $::Load -side left -padx 0 -pady 0 
 	pack [FindReplace] -in .b -side right 
}

proc ButtonBar {} {
	global color buttonBar 
	set buttonBar .b
	frame $buttonBar -relief flat -bd 1 -bg $color(menu) -padx 5 -pady 6 -cursor xterm
	CreateButtons
	PackButtons
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

proc ConfigurationMenu {} {
	global menu
	.menubar add cascade -label Configuration -menu .menubar.version -underline 0
	set menu(version) [menu .menubar.version -tearoff 0 ]
	$menu(version) add command -label "Preferences" -command AskSetup
	$menu(version) add command -label "About" -command AboutHolonCode
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
	if [osx] {set infosize 24} {set infosize 17}
	
	set view(visited) .info.panes.visited
	text $view(visited) -width $infosize	-state disabled -wrap none -bg $color(menu) \
		-padx 8 -relief sunken -cursor arrow -bd 1 -highlightthickness 0 -pady 5 -spacing3 0
		
	BindInfo
	
	$view(visited) tag configure normal -font infoNormal
	$view(visited) tag configure bold -font infoBold
	$view(visited) tag configure marking -foreground blue -font infoNormal
	$view(visited) tag configure red -foreground brown -font infoNormal
	$view(visited) tag configure title -font infoBold -spacing1 9 -spacing3 9 -foreground #666
	$view(visited) tag raise marking
	
	set view(found) .info.panes.found
	text $view(found) -width $infosize	-state disabled -wrap none -bg $color(menu) \
		-padx 8 -relief sunken -cursor arrow -bd 1 -highlightthickness 0 -pady 5 -spacing3 0
		
	$view(found) tag configure normal -font infoNormal
	$view(found) tag configure grey -font infoNormal -foreground #999
	$view(found) tag configure date -font smallbold -foreground #666
	$view(found) tag configure title -font infoBold -spacing1 9 -spacing3 9 -foreground #666
	
	.info.panes add $view(visited)
	.info.panes add $view(found)
	.info.panes sash place 0 0 163
	pack .info.panes -side top -fill both -expand 1
	return .info
}

proc ClearVisited {} {
	global view 
	$view(visited) configure -state normal
	$view(visited) delete 1.0 end
	$view(visited) configure -state disabled
}

proc ClearFound {} {
	global view 
	$view(found) configure -state normal
	$view(found) delete 1.0 end
	$view(found) configure -state disabled  
}

proc VisitedTitle {name} {
	global view
	$view(visited) configure -state normal 
	$view(visited) insert end " $name" title
	$view(visited) configure -state disabled
}

proc FoundTitle {name} {
	global view
	$view(found) configure -state normal 
	$view(found) insert end "$name" title
	$view(found) configure -state disabled
}

proc InsertVisited {name style id} {
	global view
	$view(visited) configure -state normal  
	$view(visited) tag bind goto$id <1> "GotoTree $id; break"
	# show name clashes red (two or more units with the same name)
	set n [llength [mk::select wdb.pages name $name type unit]]
	if {$n>1} {set style red}
	$view(visited) insert end " $name\n" "goto$id $style"
	set style normal
	$view(visited) configure -state disabled
}

proc InsertFound {name style id} {
	global view
	$view(found) configure -state normal 
	$view(found) tag bind goto$id <1> "GotoTree $id; break"
	$view(found) insert end " $name\n" "goto$id $style"
	set style normal
	$view(found) configure -state disabled
}

proc MarkInfoPages {} {
	global view page 
	foreach pane {visited found} {
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
	set ::page [lindex [PageStack] 0]
	ShowPage [CurrentPage]
	ShowVisitedPages; 
	ShowFound
	after 300 {TextCodePanes [CurrentPage]}
}

proc DisableMotionEvents {} {
	global view
	bind $view(text) <Motion> {}
	bind $view(text) <Leave> {}
	bind $view(code) <Motion> {}
	bind $view(code) <Leave> {}
	bind $view(info) <Motion> {}
	bind $view(info) <Leave> {}
}

proc EndSession {} {
	DisableMotionEvents
	SetBase geometry 1000x600+40+40   
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

