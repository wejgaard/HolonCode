proc CreateColors {} {
	global color
	set color(menu)    SystemButtonFace   
	set color(system)  SystemButtonFace
	set color(button)  SystemButtonFace
	set color(frame)   SystemButtonFace
	
	set color(pagebg)  white 
	set color(listbg)  white
	set color(treebg)  white
	set color(info)    white
	set color(setup)   white 
	
	set color(listfg)  black
	set color(editbg)  #f1ffff
	set color(testbg) orange
}

proc CreateFonts {} {
	set textfont Verdana 	 
	set codefont [GetBase codefont]
	set buttonfont Verdana
	set revisionfont Verdana
	
	font create text -family $textfont 
	font create underline -family $textfont -underline true
	font create bold -family $textfont -weight bold
	font create italic -family $textfont  -slant italic
	font create button -family $buttonfont 
	font create title -family $textfont 
	
	font create code       -family $codefont
	font create codebold -family $codefont -weight bold
	font create codeitalic -family $codefont -slant italic
	font create codelink  -family $codefont -underline true
	font create link -family $codefont  -underline true
	
	font create infoNormal -family $textfont 
	font create infoBold     -family $textfont -weight bold
	
	font create treeFont -family $textfont   
	font create treeBold -family $textfont -weight bold
	font create listFont -family $textfont   
	
	font create small -family $revisionfont 
	font create smallbold -family $revisionfont -weight bold
	font create smallitalic -family $revisionfont  -slant italic
	
	font create linearitalic -family $textfont -slant italic
	font create linearnormal -family $codefont


}

proc AdjustFontsize {} {
	set fontsize  [GetBase fontsize] 
	set codesize [GetBase codesize]
	font configure title -size [expr $fontsize+5]

	font configure button -size [expr $fontsize+1]

	foreach f "code codelink" {
		font configure $f -size [expr $codesize+1]
	}
	foreach f "text underline italic link " {
		font configure $f -size [expr $fontsize+1]
	}
	foreach f "bold treeBold" {
		font configure $f -size [expr $fontsize]
	}
	foreach f "listFont treeFont " {
		font configure $f -size [expr $fontsize+1]
	}
	foreach f "infoNormal infoBold " {
		font configure $f -size [expr $fontsize+1]
	}
	foreach f "small smallbold smallitalic" {
		font configure $f -size [expr $fontsize-2]
	}
}

proc ListStyles {} {
	global style 
	set style(frame) {-relief sunken -bd 0 -bg $color(frame) -fg $color(listfg) \
		-pady 2 -font text} 
	set style(listframe) {-relief sunken -bd 0 -bg $color(frame) -fg $color(listfg) \
		-pady 2 -font text} 
	set style(box) {-relief sunken -bd 1 -bg $color(listbg) -fg $color(listfg) \
		-font listFont -activestyle none}
}

set view(work)  .work             ;# Container for the selectable views
set view(page)  .work.page     ;# Container for title, comment and code 
set view(treeframe) .work.treeframe 
set view(tree)  .work.tree 	   ;# Container for tree text
set view(lists) .work.lists      ;# Container for chapters, sections and units lists

set view(chapters) ""	          ;# defined in ChapterList
set view(sections) ""
set view(units) ""
set view(upperpane) ""
set view(titleversion) ""
set view(title) ""
set view(version) ""
set view(text) ""
set view(code) ""
set view(info) ""
set view(test) ""
set view(treeactive) ""

set view(sash0) "0 50"     ;# Position of sash Text/Code
set view(sash1) "0 250"   ;# Position of sash Code/Test
set view(height) 7            ;# Number of elements visible in each list
set view(dragging) 0

proc ChapterList {} {  
	global view color style
	eval	labelframe $view(lists).cf $style(listframe) ;    
	pack $view(lists).cf -side left -fill both -expand 1
	$view(lists).cf configure -text "  Chapters" -fg #888
	set view(chapters) $view(lists).cf.chapters 
	set chapterScroll $view(lists).cf.cscroll
	eval listbox $view(chapters) $style(box) {-yscrollcommand "$chapterScroll set"}
	scrollbar $chapterScroll -orient vertical -command "$view(chapters) yview"
	pack $view(chapters) -side left -expand 1 -fill both   
	pack $chapterScroll -side left -fill y
}

proc SectionList {} {  
	global view color style
	eval	labelframe $view(lists).sf  $style(listframe) ;# -text {"  Sections"} -fg #888
	
	pack $view(lists).sf -side left -fill both  -expand 1
	$view(lists).sf configure -text "  Sections" -fg #888
	
	set view(sections) $view(lists).sf.sections 
	set sectionScroll $view(lists).sf.sscroll
	eval listbox $view(sections) $style(box) {-yscrollcommand "$sectionScroll set"}	
	scrollbar $sectionScroll -orient vertical -command "$view(sections) yview"
	pack $view(sections) -side left -expand 1 -fill both   
	pack $sectionScroll -side left -fill y
}

proc UnitList {} {  
	global view color	style
	eval	labelframe $view(lists).uf $style(listframe) ; # -text  {"  Units"} -fg #888

	pack $view(lists).uf -side left -fill both  -expand 1
	$view(lists).uf configure -text "  Units" -fg #888

	set view(units) $view(lists).uf.units
	set unitsScroll $view(lists).uf.uscroll
	eval listbox $view(units) $style(box) {-yscrollcommand "$unitsScroll set"}	
	scrollbar $unitsScroll -orient vertical -command "$view(units) yview"
	pack $view(units) -side left -expand 1 -fill both  
	pack $unitsScroll -side left -fill y


}

proc CreateLists {} {  
	global view
	frame $view(lists) 
	ChapterList
	SectionList
	UnitList
}

proc mark {w i} {
	global marked color 
	$w itemconfigure $i -fg #0000aa -bg #eeeeee
	set marked($w) $i
}

proc unmark {w} {
	global marked
	$w itemconfigure $marked($w) -fg black -bg white
}

proc Plus&Minus {} {
	global view
	bind Listbox <plus> {IncrList}
	bind Listbox <minus> {DecrList}
}

proc ListNavigation {} {
	global view
	bind $view(chapters) <Left> {FocusUnits} 
	bind $view(chapters) <Right> {FocusSections} 
	bind $view(chapters) <Alt-Left> {GoBack; break}   
	bind $view(sections) <Left> {FocusChapters} 
	bind $view(sections) <Right> {FocusUnits}
	bind $view(chapters) <Control-End> {LastProgramUnit}
	bind $view(sections) <Up> {if [UpSection] break} 
	bind $view(sections) <Down> {if [DownSection] break}
	bind $view(sections) <Home> {HomeSection; break}		
	bind $view(sections) <End> {EndSection; break}		
	bind $view(sections) <Control-End> {LastProgramUnit}
	bind $view(sections) <Prior> {PgUpSections; break}		;# PgUp  v50-6
	bind $view(sections) <Alt-Left> {GoBack; break}   
	bind $view(units) <Left> {FocusSections} 
	bind $view(units) <Right> {FocusChapters}
	bind $view(units) <Up> {if [UpUnit] break} 
	bind $view(units) <Down> {if [DownUnit] break} 
	bind $view(units) <Home> {HomeUnit; break}		
	bind $view(units) <End> {EndUnit; break}		
	bind $view(units) <Control-End> {LastProgramUnit}
	bind $view(units) <Prior> {PgUpUnits; break}		;# PgUp
	bind $view(units) <Next> {PgDnUnits; break}		 ;# PgDn
	bind $view(units) <Alt-Left> {GoBack; break}   
	bind . <Alt-Left> {GoBack; break}   
	bind . <BackSpace> {if ![Editing] GoBackSpace; break}   
}

proc ListboxSelection {} {	
	bind . <<ListboxSelect>> {
	     switch -glob -- %W {
	          *chapters {UpdateChapters}
	          *sections {UpdateSections}
	          *units    {UpdateUnits}
	     }
	}
	# No list item activation at release 
	# (tk script also contains "%w activate @%x,%y")
	bind Listbox <Enter> {tk::CancelRepeat}
}

set Chapters {}

proc iActiveChapter {} {
	global view
	return [$view(chapters) index active]
}

proc iLastChapter {} {
	global view
	return [expr {[$view(chapters) index end] -1}]
}

proc ChapterName {c} {
	set name [GetPage $c name]
	# Show name without extension?
	if {[GetBase extension]==0} {
		set n [string first {.} $name] 
		if {$n>0} {set name [string range $name 0 [expr $n-1]]}
	}
	return $name
}

proc AppendChapter {c} {
	global Chapters view
	lappend Chapters $c
	set name [ChapterName $c]
	$view(chapters) insert end "  $name"
	if {[Chapter]==$c} {
		set i [iLastChapter]
		$view(chapters) activate $i
		mark $view(chapters) $i
	}
}

proc GetChapters {} {
	global Chapters view 
	set Chapters {} 
	$view(chapters) delete 0 [$view(chapters) size]
	if {[NoChapters]} {return}
	set c [FirstChapter]
	while {$c != ""} {
		AppendChapter $c
		set c [Next $c]
	}
	$view(chapters) yview [expr {[iActiveChapter]-$view(height)/2}]
}

proc ClearChapters {} {
	global view
	$view(chapters) delete 0 [$view(chapters) size]
	ClearSections
}

proc RefreshChapters {} {
	global view
	GetChapters
	# needed for UpdateChapters
	$view(chapters) selection set [iActiveChapter] 
	if [LinView] {StreamAll}
	UpdateChapters
	focus $view(chapters)
}

proc GetSyntax {} {
	set filename [GetPage [Chapter] name]
	set dotpos [string first {.} $filename]; incr dotpos
	set extension [string range $filename $dotpos [string length $filename]]
	if {![string compare $extension "fth"] || ![string compare $extension "f"]} {
		SetBase syntax Forth
	} {
		SetBase syntax Tcl
	}
}

proc UpdateChapters {} {
	global Chapters view active
	if {[NoChapters]} {ClearChapters ; return}
	if {[Editing]} {SaveText}
	unmark $view(chapters)     
	set active [$view(chapters) curselection]
	mark $view(chapters) $active
	SetChapter [lindex $Chapters $active]
	GetSections
	if {![NoSections]} {GetUnits}
	ShowPage [Chapter]
#	GetSyntax
	focus $view(chapters)
	# keep active chapter in center of pane
	$view(chapters) yview [expr {$active-$view(height)/2}]
	after 500 {$view(chapters) activate $active}
}

proc FocusChapters {} {
	global view
	if [NoChapters] return
	ShowPage [Chapter]
	$view(chapters) selection set [$view(chapters) index active]
	focus $view(chapters)
}

set Sections {}

proc AppendSection {s} {
	global Sections view
	lappend Sections $s
	$view(sections) insert end "  [GetPage $s name]"
	if {[Section]==$s} {
		set i [expr [$view(sections) index end]-1]
		$view(sections) activate $i
		mark $view(sections) $i  
		$view(sections) see $i
	}
}

proc ClearSections {} {
	global view
	$view(sections) delete 0 [$view(sections) size]
	ClearUnits
}

proc GetSections {} {
	global Sections view
	set Sections {} 
	ClearSections
	ClearUnits
	if {[NoSections]} {return}
	set s [GetPage [Chapter] list]
	AppendSection $s
	while {[Next $s]!=[Chapter]} {
		set s [Next $s]
		AppendSection $s
	}
	$view(sections) yview [expr {[$view(sections) index active]-$view(height)/2}]
}

proc RefreshSections {} {
	global view
	GetSections
	if [LinView] {StreamAll}
	ShowPage [Section]
	GetUnits
	$view(sections) selection set [$view(sections) index active]
	focus $view(sections)
}

proc UpdateSections {} {
	global Sections view active
	if {[Editing]} {SaveText}
	focus $view(sections)  
	if {[NoSections]} {FocusSections; return}
	unmark $view(sections)      
	set active [$view(sections) curselection]
	mark $view(sections) $active 
	SetSection [lindex $Sections $active]
	ShowPage [Section]
	focus $view(sections)     
	GetUnits
	$view(sections) yview [expr {$active-$view(height)/2}]
	after 500 {$view(sections) activate $active}
}

proc FocusSections {} {
	global view
	focus $view(sections)
	if {[NoSections]} {
	 	$view(chapters) selection clear [$view(chapters) index active]
		mark $view(chapters) [$view(chapters) index active]
		ClearPage
		return
	}
	ShowPage [Section]
	$view(sections) selection set [$view(sections) index active]
}

set Units {}

proc iActiveUnit {} {
	return [$::view(units) index active]
}

proc iLastUnit {} {
	return [expr {[$::view(units) index end] -1}]
}

proc AppendUnit {u} {
	global Units view
	lappend Units $u
	$view(units) insert end "  [GetPage $u name]" 
	# show name clashes red (two or more units with the same name)
	set n [llength [mk::select wdb.pages name [GetPage $u name] type unit]]
	if {$n>1} {
		$view(units) itemconfigure [iLastUnit] -fg brown
	}
	if {[Unit]==$u} {
		set i [iLastUnit]
		$view(units) activate $i
		mark $view(units) $i  
	}
}

proc ClearUnits {} {
	global view Units
	set Units {} 
	$view(units) delete 0 [$view(units) size]
}

proc GetUnits {} {
	global Units view
	ClearUnits
	if {[NoUnits]} {return}
	set u [FirstUnit]
	while {$u != [Section]} {
		AppendUnit $u
		set u [Next $u]
	}
	$view(units) yview [expr {[iActiveUnit]-$view(height)/2}]
}

proc RefreshUnits {} {
	global view
	GetUnits
	if [LinView] {StreamAll}
	ShowPage [Unit]
	$view(units) selection set [iActiveUnit] 
	focus $view(units)
}

proc UpdateUnits {} {
	global Units view active
	if {[Editing]} {SaveText}
	if {[NoSections]} {return}
	focus $view(units) 
	if {[NoUnits]} {FocusUnits; return}
	unmark $view(units)
	set active [$view(units) curselection]
	mark $view(units) $active 
	SetUnit [lindex $Units $active]  
	Text&CodePanes; ShowPage [Unit]
	focus $view(units) 
	# show active unit in center of pane
	$view(units) yview [expr {$active-$view(height)/2}]
	after 500 {$view(units) activate $active}
}

proc FocusUnits {} {
	global view
	if {[NoSections]} {return}
	focus $view(units)
	if {[NoUnits]} {
		$view(sections) selection clear [$view(sections) index active]
		mark $view(sections) [$view(sections) index active]
		ClearPage
		return
	}
	$view(units) selection set [iActiveUnit]
	Text&CodePanes; ShowPage [Unit]
	focus $view(units)
}

proc TreeFrame {} {
	global view color style
	eval labelframe $view(treeframe) $style(frame) 
	$view(treeframe) configure -text "  Chapters" -fg #888
}

proc CreateTree {} {
	global view theType color
	TreeFrame
	text $view(tree) -pady 5 -padx 10 -wrap none  -highlightthickness 0 \
 		-bg $color(treebg) -width 20 -cursor arrow -font listFont -relief sunken -bd 1 -spacing3 0
 	pack $view(tree) -in $view(treeframe) -fill both -expand true
 	
	$view(tree) tag configure bold -foreground darkblue -font treeBold 
	$view(tree) tag configure normal -foreground black -font treeFont 
	$view(tree) tag configure title -font bold -foreground #666 -spacing1 5 -spacing3 9
	$view(tree) tag configure blue -foreground darkblue -font treeBold
	$view(tree) tag configure bluemarked -foreground darkblue -font treeBold -background #bfdfff
	$view(tree) tag configure marked -background #bfdfff -foreground black -font treeFont
	
	bind $view(tree) <ButtonRelease-1> {SetCurrent $theType}   ;# v51-2
	bind $view(tree) <$::RightButton> {focus $view(tree)}  ;# 064
	TreeMenu
}

proc ExpandTree {} {
	SetBase view treeexp
	if [Editing] SaveIt
	ShowPage [CurrentPage]
}

proc CompressTree {} {
	SetBase view tree
	if [Editing] SaveIt
	ShowPage [CurrentPage]
}

proc TreeCMenu {} {
	global view tree
	set tree(cmenu) [menu $view(tree).comenu -tearoff 0]
	$tree(cmenu) add command -label "New Chapter" -command AddChapter
	$tree(cmenu) add command -label "Print Chapter" -command PrintChapter
	$tree(cmenu) add command -label "Expand Tree" -command ExpandTree
	$tree(cmenu) add command -label "Compress Tree" -command CompressTree
}

proc TreeSMenu {} {
	global view tree
	set tree(smenu) [menu $view(tree).somenu -tearoff 0]
	$tree(smenu) add command -label "New Section" -command AddSection
	$tree(smenu) add command -label "Print Section" -command PrintSection
	$tree(smenu) add command -label "Expand Tree" -command ExpandTree
	$tree(smenu) add command -label "Compress Tree" -command CompressTree
}

proc TreeUMenu {} {
	global view tree
	set tree(umenu) [menu $view(tree).uomenu -tearoff 0]
	$tree(umenu) add command -label "New Unit" -command NewUnit
	$tree(umenu) add command -label "Copy Unit" -command CopyUnit
	$tree(umenu) add command -label "Print Page" -command PrintUnit
	$tree(umenu) add command -label "Expand Tree" -command ExpandTree
	$tree(umenu) add command -label "Compress Tree" -command CompressTree
}

proc SetTreeMenu {} {
	global view tree
	switch [GetPage [CurrentPage] type] {
		chapter {set tree(menu) $tree(cmenu)}
		section {set tree(menu) $tree(smenu)}
		unit {set tree(menu) $tree(umenu)}
	}	
}

proc SetTreePage {} {
	global view tree
	if {[GetBase view]=="tree"} {
		set Page "  [string totitle [GetPage [CurrentPage] type]]"
		$view(page) configure -text $Page -fg #888
	}
}

proc TreeMenu {} {
	global view tree
	TreeCMenu; TreeSMenu; TreeUMenu
	bind $view(tree) <$::RightButton> {SetTreeMenu; tk_popup $tree(menu) %X %Y}
	bind $view(tree) <Control-Button-1> {SetTreeMenu; tk_popup $tree(menu) %X %Y}
}

proc GotoTree {id} {
	if {[Editing]} {SaveText}
	ShowPage $id
}

proc TreeSections {} {
	global view 
	if [NoSections] {return}
	set current [Section]
	SetSection [FirstSection]
	while {[Section]!=[Chapter]} {
		set s [Section]
		$view(tree) tag bind tag$s <Button-1> "GotoTree	$s"	
		if {[Section]==$view(treeactive)} {
			$view(tree) insert end "  [GetPage [Section] name]\n" "marked normal tag$s"
			$view(tree) see end
		} else {
			if {[Section]==$current} {
				$view(tree) insert end "  [GetPage [Section] name]\n" "normal tag$s"
			} else {
				$view(tree) insert end "  [GetPage [Section] name]\n" "normal tag$s"
			}
		}
		if {[GetBase view]=="treeexp"} {
			TreeUnits
		} else {
			if {[Section]==$current} {TreeUnits} 
		}
		SetSection [NextSection]
	}
	SetSection $current
}

proc TreeUnits {} {
	global view 
	if [NoUnits] {return}
	set u [FirstUnit]
	while {$u!=[Section]} {
		$view(tree) tag bind tag$u <Button-1> "GotoTree $u"
		if {$u==$view(treeactive)} {
			$view(tree) insert end "      [GetPage $u name]\n" "normal marked tag$u"
			$view(tree) see end
		} else {
			$view(tree) insert end "      [GetPage $u name]\n" "normal tag$u"
		}
		set u [Next $u]
	}
}

proc ShowTreeList {} {
	global view color
	$view(tree) configure -state normal -bg $color(pagebg)
	$view(tree) delete 1.0 end
#	$view(tree) insert end "Chapters\n"	title 
	set current [Chapter]
	set c [FirstChapter]
	while {$c != ""} {
		$view(tree) tag bind tag$c <Button-1> "GotoTree	$c; break" 	;# v51-2
		if {$c==$view(treeactive)} {
			$view(tree) insert end "[ChapterName $c]\n"	"bold tag$c"
		} else {
			if {$c==$current} {
			$view(tree) insert end "[ChapterName $c]\n" "bold tag$c"
			} else {
			$view(tree) insert end "[ChapterName $c]\n" "normal tag$c"
			}
		}
		set c [Next $c]
	}
	$view(tree) insert end "________________\n\n"
	SetChapter $current
	if {$current==$view(treeactive)} {
			$view(tree) insert end "[ChapterName $current]\n" "bluemarked tag$current"
			} else {
			$view(tree) insert end "[ChapterName $current]\n" "blue tag$current"
			}
	TreeSections
	$view(tree) configure -state disabled
}

proc ShowTree {id} {
	global view
	if [NoChapters] {return}
	set view(treeactive) $id
	ShowTreeList 
}

proc StreamChapterTitle {id} {
	global ltext
	$ltext insert end "Chapter [GetPage $id name]\n" bold
}

proc StreamSectionTitle {id} {
	global ltext
	set t [GetPage $id name]
	$ltext insert end "Section  $t \n" bold
}

proc StreamUnitTitle {id} {
	global ltext
	set t [GetPage $id name]
	$ltext insert end "$t\n" bold
}

proc StreamText {u} {
	global ltext
	set text [GetPage $u text]
	if {$text==""} {return}
	$ltext insert end [RemoveTags $text]\n
}

proc StreamCode {u} {
	global ltext
	$ltext insert end [GetPage $u source]\n
}

proc StreamPage {id} {
	global ltext
	set type [GetPage $id type]
	# insert the page with a tag of its own
	set i1 [$ltext index current]
	if {$type=="chapter"} {StreamChapterTitle $id}
	if {$type=="section"} {StreamSectionTitle $id}
	if {$type=="unit"} {StreamUnitTitle $id}
	StreamText $id 
	set i2 [$ltext index current]
	$ltext tag add text $i1 $i2
	if {$type=="unit"} {StreamCode $id }
	set i3 [$ltext index current]
	$ltext tag add code $i2 $i3
	set ltag "tag$id"
	$ltext tag add $ltag $i1 $i3
	$ltext tag bind $ltag <Double-Button-1>	"ShowPage $id; focus .lin"
	$ltext insert end \n
}

proc StreamSection {} {
	global ltext 
	$ltext insert end "\n"  
	StreamPage [Section]
	$ltext insert end "\n"  
	if [NoUnits] {return}
	set u [FirstUnit]
	while {$u!=[Section]} {
		set i1 [$ltext index current]
		StreamPage $u
		set i2 [$ltext index current]
		set u [Next $u]
	}
}

proc StreamChapter {} {
	global ltext
	$ltext insert end "   \n" chapter  
	StreamPage [Chapter]
	if [NoSections] {return}
	set current [Section]
	SetSection [FirstSection]
	while {[Section] != [Chapter]} {
		StreamSection
		SetSection [NextSection]
	}
	SetSection $current
}

proc StreamAll {} {
	global ltext 
	if [NoChapters] {return}
	$ltext configure -state normal
	$ltext delete 1.0 end
	set current [Chapter]
	SetChapter [FirstChapter]
	while {[Chapter] != ""} {
		StreamChapter
		SetChapter [NextChapter]
	}
	$ltext configure -state disabled
	SetChapter $current
}

proc LinearView {} {
	global ltext color
	if [winfo exists .lin] {wm deiconify .lin; return}
	toplevel .lin
	wm geometry .lin 700x900+80+20
	wm title .lin "Linear Text View"
	set ltext [text .lin.text -yscrollcommand ".lin.scroll set" \
		-padx 20 -pady 20 -wrap word  -tabs {1c 2c 3c 4c 5c 6c} ]
	scrollbar .lin.scroll -orient vertical -command [list .lin.text yview]
	pack .lin.scroll -side right -fill y
	pack .lin.text -side left -fill both -expand true

	$ltext tag configure text  -font linearitalic
	$ltext tag configure code  -font linearnormal
	$ltext tag configure frame  -relief solid -borderwidth 0 -background #eff -lmargin1 3 -rmargin 5
	$ltext tag configure bold -font bold
	$ltext tag configure b -font bold
	$ltext tag configure section -background $color(pagebg)
	$ltext tag configure chapter -background $color(menu) -font bold
	$ltext tag configure textpage -background $color(pagebg)
	$ltext tag configure codepage -background $color(pagebg)	
	StreamAll
}

proc LinView {} {
	winfo exists .lin
}

proc RemoveFrames {} {
	global ltext
	set l [$ltext tag ranges frame]	
	if {$l!={}} {
		eval $ltext tag remove frame $l
	}
}

proc ShowLinPage {id} {
	global ltext
	if ![LinView] {return}
	RemoveFrames
	set pagerange [$ltext tag ranges "tag$id"]
	set pagestart [lindex $pagerange 0]
	set pageend [lindex $pagerange 1]
	$ltext tag add frame $pagestart $pageend
	# make page fully visible
	$ltext see $pageend
	$ltext see $pagestart
}

