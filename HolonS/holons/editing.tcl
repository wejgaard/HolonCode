 # Copyright (c) 2008 - 2020 Wolf Wejgaard. All  Rights Reserved.
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
 # along with this program.  If not, see <http://www.gnu.org/licenses/>.

proc ?SafeDel {} {
	global replaceText
	if [GetBase safe] {
		set replaceText "Shift+Delete?"; 
		after 2000 {set replaceText ""}
		return -code break
	}
}

proc Insert&Delete {} {
	global view
	bind $view(chapters) <Shift-Delete> {DeleteChapter}
	bind $view(chapters) <Delete> {?SafeDel; DeleteChapter}
	bind $view(chapters) <Insert> {InsertCDeleted before} 
	bind $view(chapters) <F13> {InsertCDeleted before} 
	bind $view(chapters) <Shift-F13> {InsertCDeleted after} 
	if [osx] {bind $view(chapters) <Command-BackSpace> {InsertCDeleted before}}
	bind $view(chapters) <Shift-Insert> {InsertCDeleted after} 
	bind $view(chapters) <Shift-BackSpace> {InsertCDeleted after; break} 

	bind $view(sections) <Shift-Delete> {DeleteSection}
	bind $view(sections) <Delete> {?SafeDel; DeleteSection}
	bind $view(sections) <Insert> {InsertSDeleted before} 
	bind $view(sections) <F13> {InsertSDeleted before} 
	bind $view(sections) <Shift-F13> {InsertSDeleted after} 
	if [osx] {bind $view(sections) <Command-BackSpace> {InsertSDeleted before}}
	bind $view(sections) <Shift-Insert> {InsertSDeleted after} 
	bind $view(sections) <Shift-BackSpace> {InsertSDeleted after; break} 
	
	bind $view(units) <Shift-Delete> {DeleteUnit}
	bind $view(units) <Delete> {?SafeDel; DeleteUnit}
	bind $view(units) <Insert> {InsertUDeleted before} 
	bind $view(units) <F13> {InsertUDeleted before} 
	bind $view(units) <Shift-F13> {InsertUDeleted after} 
	if [osx] {bind $view(units) <Command-BackSpace> {InsertUDeleted before}}
	bind $view(units) <Shift-Insert> {InsertUDeleted after} 
	bind $view(units) <Shift-BackSpace> {InsertUDeleted after; break} 
}

proc NewPage {} { 
	if [Editing] {SaveIt}
	switch [GetPage [CurrentPage] type] {
		chapter {AddChapter}
		section {AddSection}
		unit {NewUnit}
	}
}

set edit(pane) ""
set edit(pos) ""

proc CopyName {} {
	global view
	if {![Editing]} {return}
	set i 0; set j 0
	while {![regexp {\s} [GetChar $view(code) $i]]} {
			incr i -1;  if {$i<-20} {break}
	}
	incr i
	while {![regexp {\s} [GetChar $view(code) $j]]} {
		incr j;  if {$j>20} {break}
	}
	set name [$view(code) get "current + $i char" "current + $j char"]
	$view(title) delete 1.0 end
	$view(title) insert 1.0 $name
}

proc Editing {} {
	global view 
	expr {[$view(text) cget -state]=="normal"}
}

proc TextChanged {} {
	global view oldTitle oldText oldCode  
	set newTitle [string trim [$view(title) get 1.0 1.end]]
	set newText [$view(text) get 1.0 end]
	set newCode [$view(code) get 1.0 end ]
	regsub -all {\s+} $oldText "" oldText
	regsub -all {\s+} $newText "" newText
	regsub -all {\s+} $oldCode "" oldCode
	regsub -all {\s+} $newCode "" newCode
	if {[string equal $oldTitle $newTitle] && [string equal $oldText $newText] \
			&& [string equal $oldCode $newCode]} {
		return 0
	} else {
		return 1
	}
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
	SavePage [CurrentPage] $text $code local $title $cursor 
}

proc SaveText {} {
	if {![Editing]} {return}
	set id [CurrentPage]
	StoreText
	WriteChapter	         
	BrowserButtons
	if [LinView] {StreamAll}
}

proc SkipLine {} {
	global comp 
	incr comp(i)
	set t1 $comp(i) 
	while {$comp(i)<$comp(imax)} {
		if {[GetAscii $comp(i)]==10} {
			incr comp(i) -1; break
		} {
			incr comp(i)
		}
	}
	incr comp(i)
}

proc SaveIt {} {
	SaveText
	ShowPage [CurrentPage]  
}

proc Cancel {} {
	if [Editing] {BrowserButtons; ShowPage [CurrentPage]}
}

proc EditPage {} {
	global edit type view oldVersion color 
	if {$oldVersion} {return}
	set id [CurrentPage] 
	EditorButtons
	pagevars $id name page cursor source type 
	foreach pane "$view(title) $view(text) $view(code)" {
		$pane configure -state normal  -bg $color(editbg)
		$pane edit reset
	}
	if {$edit(pane)==""} {
		set pane $view(title)
	} else {
		set pane $edit(pane); set edit(pane) "" ; set cursor $edit(pos)
	}
	$pane mark set anchor insert	   
	focus $pane
	RefreshColors
	ShowFoundText  
}

proc EditIt {} {
	if {![Editing]} {EditPage}
}

proc BindEditItem {} {
	global view 
	bind $view(chapters) <Return> {EditIt}
	bind $view(sections) <Return> {EditIt}
	bind $view(units) <Return> {EditIt}
}

proc Find {text} {
	set ::findText $text
}

set searchText ""

proc ResetText {pane} {
	variable findText
	if {![Editing]} return
	set range [$pane tag prevrange replaced current+1c]   
	set a [lindex $range 0] 
	set b [lindex $range 1]
	$pane delete $a $b
	$pane insert $a $findText
	$pane tag add foundit $a "$a + [string length $findText] chars" 
}

proc SearchList {} {
	global setup findText
	variable fields
	if {$findText == ""} {return ""}
	set fields name
	lappend fields text
	lappend fields source 
	# escape [ and ] search chars: replace by \[ and \]
	regsub -all {[][?*\\]} $findText \\\\& searchEscaped
	return [mk::select wdb.pages -rsort date -globnc $fields *${searchEscaped}*] 
}

proc ReplaceText  {pane} {
	global view replaceText
	if {![Editing]} return
	set range [$pane tag prevrange foundit current+1c]  
	set a [lindex $range 0] 
	set b [lindex $range 1]
	$pane delete $a $b
	$pane insert $a $replaceText
	if {$pane==$view(title)} {
		$pane tag configure replaced -foreground "sea green"
	} {
		$pane tag configure replaced -foreground "sea green" -background #eeeeee
	}
	$pane tag bind replaced <Button-1> {ResetText %W}
	$pane tag bind replaced <Alt-Button-1> {CopyName; break} 
	$pane tag add replaced $a "$a + [string length $replaceText] chars" 

}

proc FindLoop {} {
	global searchText findText infomode
	if {[string length $findText]<1} {
		if {$searchText!=""} {
			set searchText "" 
			ShowFoundText 
			ShowRevision $::version
		}
	} {
		if {[string compare $findText $searchText]!=0} {
			set searchText $findText
			ShowFoundPages 	[SearchList]
		}
	}
	after 200 FindLoop	
}

proc ClearAll {} {
	set ::findText ""
	set ::searchText ""
	set ::replaceText ""
	ShowFoundText
	ShowRevision $::version
	focus .
}

proc StartFind  {} {
	ClearAll
	.s.find config -bg white
	focus .s.find
}

proc FindInPage {page} {
	global found searchText
	if ![Editing] return
	set found [$page search $searchText [expr $found + 0.001]]
	$page see $found
	tk::TextSetCursor $page $found
}

proc Click {pane} {
	global view
	if {[Editing]} {
		if {[$pane tag ranges sel]==""} {return}
		if {[$pane compare [$pane index sel.last] >= [$pane index current]]\
			&& [$pane compare [$pane index sel.first] <= [$pane index current]]} {
			# Mousepointer in range, drag & drop
			set view(dragging) 1
			return -code break  ;# break, else selection is cleared
		} 
	} {
		set view(dragging) 0
		GotoWord $pane
	}
}

proc ButtonRelease {pane} {
	global view
	if $view(dragging) {DropSelection $pane}
}

proc DropSelection {pane} {
	global view
	set view(dragging) 0
	set selection [$pane get [$pane index sel.first] [$pane index sel.last]]
	if {[$pane compare [$pane index sel.first] <= [$pane index current]] &&\
		[$pane compare [$pane index sel.last] >= [$pane index current]]} {
		# if mouse is inside, clear selection
		$pane tag remove sel 1.0 end
	} {	
		$pane insert current $selection
		$pane delete [$pane index sel.first] [$pane index sel.last]
	}
}

proc ColorKeywords {} {
	foreach Symbol $::TclSyntax { 
		set Pattern \\m$Symbol\\M
		set start [$::view(code) search -regexp -count cnt -nocase -- $Pattern 1.0 end]
		if {$start!=""} {$::view(code) tag add blue $start "$start +$cnt chars"}
		while {$start!=""} {
			set start [$::view(code) search -regexp -count cnt -nocase -- \
						$Pattern "$start +1 chars" end]
			if {$start!=""} {$::view(code) tag add blue $start "$start +$cnt chars"}
		}
	}
}

proc ColorBrackets {} {
	foreach Symbol { \{ \} } {
		set start [$::view(code) search -count cnt -nocase -- $Symbol 1.0 end]
		if {$start!=""} {$::view(code) tag add purple $start "$start +$cnt chars"}
		while {$start!=""} {
			set start [$::view(code) search -count cnt -nocase -- $Symbol "$start +1 chars" end]
			if {$start!=""} {$::view(code) tag add purple $start "$start +$cnt chars"}
		}
	}
}

proc ColorStrings {} {
	set Pattern {"(.*?)"} 
	set start [$::view(code) search -regexp -count cnt -nocase -all -- $Pattern 1.0 end]
	if {$start!=""}	 {
		set n [llength $start]; set i 0
		while {$i<$n} {
			set s [lindex $start $i]; set c [lindex $cnt $i]
			$::view(code) tag add string $s "$s +$c chars"
			incr i
		}
	}
}

proc ColorComment {} {
	set Pattern {#\s(.*?)\n} 
	set start [$::view(code) search -regexp -count cnt -nocase -all -- $Pattern 1.0 end]
	if {$start!=""}	 {
		set n [llength $start]; set i 0
		while {$i<$n} {
			set s [lindex $start $i]; set c [lindex $cnt $i]
			$::view(code) tag add grey $s "$s +$c chars"
			incr i
		}
	}
}

proc ColorName {} {
	set name [GetPage [CurrentPage] name]
	set start [$::view(code) search -count cnt -nocase -- $name 1.0 end]
	if {$start!=""} {$::view(code) tag add name	$start "$start +$cnt chars"}
}

proc ColorCode {} {
	ColorKeywords
#	ColorBrackets
	ColorStrings
	ColorName
	ColorComment
}

set JavaSyntax {
	if while else global null this import class void int float \
	foreach boolean new super for case break }

set TclSyntax {
	if while else after append array binary break catch continue error eval exec exit expr flush format gets
	incr join lappend lindex linsert llength list load lrange lreplace lset namespace open package proc puts
	regexp regsub return set socket split string switch unset update uplevel upvar variable vwait 
	global source set 	foreach 	boolean  for 	
	bind bitmap button canvas checkbutton console destroy entry event focus font frame grab grid image label
	labelframe listbox lower menu menubutton message option pack panedwindow place radiobutton raise scale
	scrollbar selection send spinbox text winfo wm tkwait
	tag remove end configure itemconfigure index insert activate mark
}

set OforthSyntax {
	immediate const mutable impot assert test ifTrue  ifFalse ifNull ifNotNull ifZero ifEq 
	else self for loop step forEach native method virtual classVirtual classMethod new
	true false try when while doWhile return tvar
 	# func continue break
}

proc RefreshColors {} {
	if [GetBase codecolor] {
		foreach color {blue red green grey comment bold} {$::view(code) tag remove $color 1.0 end}
		ColorCode
		if [Editing] {after 1000 RefreshColors}
	}
}

proc ShowURL {} {
	global view URL-Windows
	if [Editing] return
	set webadr [eval {$view(text) get} [$view(text) tag prevrange url current]]
 	if [osx] {
		eval exec open $webadr &
	} {
		eval exec [auto_execok start] $webadr &
	} 
}

proc ShowHelp {} {
	set webadr "http://holonforth.com/holoncode/operation.html"
 	if [osx] {
		eval exec open $webadr &
	} {
		eval exec [auto_execok start] $webadr &
	} 
}

proc TextReturn {} {
	global view
	if {[$view(text) index "end-1c"]=="1.0"} {
		focus $view(code); tk::TextSetCursor $view(code) 1.0
	}
}

proc GetImage {filename} {
	global view
	set p [image create photo]
	$p read $filename
	$view(text) image create end -image $p
}

proc LoadImages {} {
	global view
	foreach {a b} [$view(text) tag ranges image] {
		GetImage [$view(text) get $a $b]
	}
}

proc TextBold {} {
	global view
	if {![Editing]} return
	set range [$view(text) tag range sel]
	if {$range==""} {return}
	set a [lindex $range 0] 
	set b [lindex $range 1]
	$view(text) tag add b $a $b
}

proc TextItalic {} {
	global view
	if {![Editing]} return
	set range [$view(text) tag range sel]
	if {$range==""} {return}
	set a [lindex $range 0] 
	set b [lindex $range 1]
	$view(text) tag add i $a $b
}

proc TextCode {} {
	global view
	if {![Editing]} return
	set range [$view(text) tag range sel]
	if {$range==""} {return}
	set a [lindex $range 0] 
	set b [lindex $range 1]
	$view(text) tag add code $a $b
}

proc TextNormal {} {
	global view
	if {![Editing]} return
	set range [$view(text) tag range sel]
	if {$range==""} {return}
	set a [lindex $range 0] 
	set b [lindex $range 1]
	$view(text) tag remove b $a $b
	$view(text) tag remove i $a $b
}

proc TextURL {} {
	global view
	set range [$view(text) tag range sel]
	if {$range==""} {return}
	set a [lindex $range 0] 
	set b [lindex $range 1]
	$view(text) tag add url $a $b
}

proc TextImage {} {
	global view
	set range [$view(text) tag range sel]
	if {$range==""} {return}
	set a [lindex $range 0] 
	set b [lindex $range 1]
	$view(text) tag add image $a $b
}

proc TextMenu {} {
	global tm view
	set tm [menu $view(text).menu -tearoff 0]
	$tm add command -label "normal" -command TextNormal
	$tm add command -label "bold" -command TextBold
	$tm add command -label "italic" -command TextItalic
#	$tm add command -label "source" -command TextCode
#	$tm add command -label "image" -command TextImage
	$tm add command -label "url" -command TextURL
}

