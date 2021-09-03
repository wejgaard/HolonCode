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

set oldText ""
set oldCode ""
set oldTitle ""

proc VersionPane {} {
	global view color
	set view(version) $view(titleversion).version
	text $view(version) -width 300 -font small -pady 4 \
		-height 1 -state disabled	-bg $color(pagebg) -relief flat -padx 9 \
		-highlightthickness 0 -wrap none
	pack $view(version) -side right -fill x -fill y -expand true
	$view(version) tag configure right -justify right
	$view(version) tag configure bold -font smallbold
	$view(version) tag configure deleted -font title -justify right
 	return $view(version)
}

proc TitleTags {} {
	global view
	$view(title) tag configure title -font title 
}

proc TitleBindings {} {
	global view edit color
	bind $view(title) <Button-1> {EditIt}
#	bind $view(title) <Double-Button-1> {EditIt; }
	bind $view(title) <Return> {focus $view(text) ; break}
	bind $view(title) <Shift-Return> {if {[Editing]} {SaveIt}}
	bind $view(title) <Escape> {if {[Editing]} {SaveIt}}
	bind $view(title) <Down> {focus $view(text)}
	bind $view(title) <$::RightButton> {SearchWord $view(title); break} 
	bind $view(title) <Control-Button-1> {SearchWord $view(title); break} 

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

proc ShowTitle {id} {
	global view color oldTitle oldVersion
	$view(title) configure -state normal -font title -bg $color(pagebg)
	$view(title) delete 1.0 end
	if {$oldVersion} {
		set oldTitle [GetOldPage $id name]
	} {
		set oldTitle [GetPage $id name]
	}		
	$view(title) insert end $oldTitle  
	$view(title) tag add title 1.0 end  
	$view(title) configure -state disabled  
	

}

proc TextTags {} {
	global view
	$view(text) tag configure fixed -font code 
	$view(text) tag configure body  -font text 
	$view(text) tag configure code  -font code  
	$view(text) tag configure ul -font text 
	$view(text) tag configure ol -font text 
	$view(text) tag configure dt -font text 
	$view(text) tag configure dl -font text 
	$view(text) tag configure i -font italic
	$view(text) tag configure b -font bold
	$view(text) tag configure image -background #ccff99
	$view(text) tag configure marking -font underline 
	$view(text) tag configure selection -background lightblue  
#	$view(text) tag configure url -font text -foreground blue
#	$view(text) tag bind url <Button-1> {catch ShowURL}
}

proc TextKeyBindings  {} {
	global view
	bind $view(text) <Return> {TextReturn}
	bind $view(text) <Shift-Return> {if {[Editing]} {SaveIt}}
	bind $view(text) <Escape> {if {[Editing]} {SaveIt}}
	bind $view(text) <Control-Up> {focus $view(title); break}
	bind $view(text) <Control-Down> {focus $view(code); break}
	bind $view(text) <Control-F> {FindInPage $view(text)}
	bind $view(text) <Control-b> {TextBold; break}
	bind $view(text) <Control-i> {TextItalic; break}
	bind $view(text) <Control-space> {TextNormal; break}
	bind $view(text) <Command-b> {TextBold; break}
	bind $view(text) <Command-i> {TextItalic; break}
	bind $view(text) <Command-space> {TextNormal; break}
	bind $view(text) <Control-U> {CutLines $view(text)}
	bind $view(text) <Control-W> {Signatur $view(text)}
	bind Text <Control-a> {%W tag add sel 1.0 end}
	bind Text <Control-Right> { tk::TextSetCursor %W {insert display lineend}}
	bind Text <Control-Left> { tk::TextSetCursor %W {insert display linestart}}


}

proc TextButton3 {x y} {
	global tm view
	set range [$view(text) tag prevrange sel current]
	if {$range!="" && [Editing]} {
		tk_popup $tm $x $y
	} {
		SearchWord $view(text)
	}
}

proc TextMouseBindings  {} {
	global edit view
	bind $view(text) <Button-1> {Click $view(text)} 	
#	bind $view(text) <Double-Button-1> {Click $view(text); } 	
	bind $view(text) <B1-Motion> {if $view(dragging) break}
	bind $view(text) <ButtonRelease-1> {ButtonRelease $view(text)}
	bind $view(text) <Control-Button-1> {TextButton3 %X %Y; break}
	bind $view(text) <$::RightButton> {TextButton3 %X %Y; break}
	bind $view(text) <Alt-Button-1> {GotoWord $view(text); break} 
	bind $view(text) <Motion> {MarkIt $view(text)}		
	bind $view(text) <Leave> {$view(text) tag remove marking 1.0 end}
	bind $view(text) <<Selection>> {EditorButtons; EditIt}
}

proc TextPane {} {
	global view color
	set tf [frame $view(panes).t -relief sunken -bg $color(menu)]
	set view(text) $tf.text
	text $view(text) -width 72 -height 10 -state disabled -wrap word -font text \
		-relief sunken -bd 1 -bg $color(pagebg) \
		-yscrollcommand "$tf.scroll set" \
		-exportselection 1 -undo true -pady 5 -padx 10  -tabs {1c 2c 3c 4c 5c 6c} \
		-highlightthickness 0
	scrollbar $tf.scroll -orient vertical -command [list $view(text) yview] -bg $color(pagebg) 
	pack $tf.scroll  -side right -fill y
	pack $view(text) -side left -expand 1 -fill both
	TextTags
	TextKeyBindings  
	TextMouseBindings
	TextMenu
	return $tf
}

proc ShowText {id} {
	global color view oldText oldVersion theType 
	if {$oldVersion} {
		set text [GetOldPage $id text]
	} {
		set text [GetPage $id text]; set theType [GetPage $id type]
	}
	$view(text) configure -state normal -font text -bg $color(pagebg)
	$view(text) delete 1.0 end
	set current 1.0   ;# default 
	if {$text!={}} {
		foreach {key value index} $text {
			switch $key {
				text {$view(text) insert $index $value}
				mark {
					if {$value == "current"} { set current $index }
					$view(text) mark set $value $index
					}
				tagon {set tag($value) $index}
				tagoff {$view(text) tag add $value $tag($value) $index}
			}
		}
		$view(text) mark set current $current
	}
	set oldText [$view(text) get 1.0 end] 
	$view(text) configure -state disabled
	LoadImages
}

proc CodeTags {} {
	global view
	$view(code) tag configure marking -font codelink
	$view(code) tag configure selection -background lightblue
	$view(code) tag configure blue -foreground #2C5FA8
	$view(code) tag configure red -foreground red
	$view(code) tag configure green -foreground limegreen
	$view(code) tag configure purple -foreground purple
	$view(code) tag configure comment -font codeitalic -foreground gray40 
	$view(code) tag configure grey -foreground gray60 
	$view(code) tag configure bold -font codebold
	
	$view(code) tag configure name -foreground #CC642E 
	$view(code) tag configure keyword -foreground #8D5C47
	$view(code) tag configure string -foreground #007230

}

proc CodeKeyBindings  {} {
	global view
	bind $view(code) <Return> {CodeReturn}
	bind $view(code) <Shift-Return> {if {[Editing]} {SaveIt}}
	bind $view(code) <Escape> {if {[Editing]} {SaveIt}}
	bind $view(code) <Control-Up> {focus $view(text); break}
	bind $view(code) <Control-F> {FindInPage $view(code)}
	bind $view(code) <Control-U> {CutLines $view(code)}
	bind $view(code) <Control-W> {Signatur $view(code)}
	bind $view(code) <Control-a> {$view(code) tag add sel 1.0 end}
	bind $view(code) <Control-Right> {tk::TextSetCursor $view(code) {insert display lineend}}

}

proc CodeMouseBindings  {} {
	global edit view
	bind $view(code) <Button-1> {Click $view(code)} 	
#	bind $view(code) <Double-Button-1> {Click $view(code); } 	
	bind $view(code) <B1-Motion> {if $view(dragging) break}
	bind $view(code) <ButtonRelease-1> {ButtonRelease $view(code)}
	bind $view(code) <$::RightButton> {SearchWord $view(code); break}
	bind $view(code) <Control-Button-1> {SearchWord $view(code); break} 
	bind $view(code) <Motion> {MarkIt $view(code)}	
	bind $view(code) <Leave> {$view(code) tag remove marking 1.0 end}
	bind $view(code) <Alt-Button-1> {CopyName; break} 
	if [osx] {bind $view(code) <Command-Button-1> {CopyName; break}}
}

proc CodePane {} {
	global view color 
	set pf [frame $view(panes).c -bg $color(menu) -relief sunken ]
	set view(code) $pf.code
	text $view(code) -width 72 -height 20 -pady 10 -padx 10 -bd 1 -relief sunken \
		-highlightthickness 0 -bg $color(pagebg) -yscrollcommand "$pf.scroll set" \
		-font code -wrap word -spacing3 1 -undo true -tabs {1c 2c 3c 4c 5c 6c} \
		-state disabled -exportselection 1
	scrollbar $pf.scroll -orient vertical -command [list $view(code) yview]
	pack $pf.scroll -side right -fill y
	pack $view(code) -side left -expand 1 -fill both
	CodeTags
	CodeKeyBindings  
	CodeMouseBindings
	return $pf
}

proc ShowCode {id} {
	global view color oldCode oldVersion 
	$view(code) configure -state normal
	$view(code) delete 1.0 end
	if {$oldVersion} {
		set code [GetOldPage $id source]; set offset 1.0
	} {
		set code [GetPage $id source]; 	set offset [GetPage $id cursor]; if {$offset==""} {set offset 1.0}
	}
	$view(code) insert  end $code\n
	if [GetBase codecolor] ColorCode
	set oldCode $code
	$view(code) configure -state disabled -bg $color(pagebg)
	if {$offset<1.0} {$view(code) yview moveto $offset} 
	bind $view(code) <<Selection>> {EditorButtons; EditIt}
}

proc CodeReturn {} {
	global view
	set lineno [expr {int([$view(code) index insert])}]
	set line [$view(code) get $lineno.0 $lineno.end]
	regexp {^(\s*)} $line -> prefix
	if {[$view(code) index insert]!=[$view(code) index "insert linestart"]} {
		after 1 [list $view(code) insert insert $prefix]
	}
}

proc TestReturn {} {
	global view
	set lineno [expr {int([$view(test) index insert])}]
	set line [$view(test) get $lineno.0 $lineno.end]
	regexp {^(\s*)} $line -> prefix
	if {[$view(test) index insert]!=[$view(test) index "insert linestart"]} {
		after 1 [list $view(test) insert insert $prefix]
	}
}

proc TestTags {} {
	global view
	$view(test) tag configure marking -foreground blue -font link
	$view(test) tag configure selection -background lightblue
}

proc TestKeyBindings  {} {
	global view
	bind $view(test) <Return> {TestReturn}
	bind $view(test) <Shift-Return> {if {[Editing]} {SaveIt}}
	bind $view(test) <Escape> {if {[Editing]} {SaveIt}}
	bind $view(test) <Shift-Right> {continue}  ;# bypass CurRight	
	bind $view(test) <Shift-Left> {continue}
}

proc TestMouseBindings  {} {
	global edit view
	bind $view(test) <Button-1> {Click $view(test)} 	
	bind $view(test) <B1-Motion> {if $view(dragging) break}
	bind $view(test) <ButtonRelease-1> {ButtonRelease $view(test)}
	bind $view(test) <Control-Button-1> {SearchWord $view(test); break} 
	bind $view(test) <$::RightButton> {SearchWord $view(test); break}
	bind $view(test) <Motion> {MarkIt $view(test)}	
	bind $view(test) <Leave> {$view(test) tag remove marking 1.0 end}
}

proc TestPane {} {
	global view color
	set pt [frame $view(panes).x -relief sunken]
	set view(test) $pt.text
	set testScroll $pt.scroll
	text $view(test) -width 72 -height 10 -pady 5 -padx 10 -bd 1 -relief sunken \
		-highlightthickness 0 -bg bisque -yscrollcommand "$pt.scroll set" \
	 	-font code -wrap word -undo true  -tabs {1c 2c 3c 4c 5c 6c} \
		-state disabled -exportselection 1 
	scrollbar $testScroll -orient vertical -command [list $view(test) yview]
	pack $testScroll -side right -fill y
	pack $view(test) -side left -expand 1 -fill both
	TestTags
	TestKeyBindings ; TestMouseBindings
	return $pt
}

proc ShowTest {id} {
	global view color oldVersion 
	$view(test) configure -state normal
	$view(test) delete 1.0 end
	if {$oldVersion} {
		set test [GetOldPage $id test]
	} {
		set test [GetPage $id test] 	 
	}
	$view(test) insert end $test 
	$view(test) configure -state disabled -bg bisque

	if {[string length $test] > 1} {
		.b.test configure -text Test   ; 	bind .b.test <Button-1> LoadTest
	} {
		.b.test configure -text Test  ;	 bind .b.test <Button-1> LoadTest
	} 
}

proc SaveOldPage {id} {
	global version
	pagevars $id type text source changes old test name
	set v [lindex $changes end]
	if {$v==$version || $v==""} {return}
	set oldpage	[mk::row append wdb.oldpages 	text $text  source $source \
		link $old  type $type test $test name $name]
	SetPage $id old [mk::cursor position oldpage]
}

proc MarkVersion {j} {
	global view
	$view(version) tag remove bold 1.0 end
	set range [$view(version) tag ranges old$j]
	eval {$view(version) tag add bold} $range  
}

proc ShowOldPage {j} {
	global oldVersion
	if [Editing] {SaveIt}
	MarkVersion $j
	set id [CurrentPage]
	if {$j==0} {
		set oldVersion 0
		ShowPage $id
		return
	} 
	set oldVersion 1
	set id [GetPage $id old]
	for {set i 1} {$i<$j} {incr i} {
		set id [GetOldPage $id link]
		if {$id==""} return
	}
	ShowTitle $id
	ShowText $id;  $::view(text) configure -state normal 
	ShowCode $id; $::view(code) configure -state normal
	ShowTest $id
}

proc ShowVersions {id} {
	global view changelist color
	$view(version) configure -state normal 
	$view(version) delete 1.0 end
	set changelist [GetPage $id changes]
	if {$changelist==""} return
	set n [llength $changelist]
	for {set i 0} {$i<$n} {incr i} {
		set j [expr $n-$i-1]
		set v [lindex $changelist $i]
		$view(version) tag configure old$j
		$view(version) tag bind old$j <Button-1> "ShowOldPage $j; ShowRevision $v"
		$view(version) tag bind old$j <$::RightButton> "ShowRevision $v"
		$view(version) tag bind old$j <Control-Button-1> "ShowRevision $v"
		$view(version) tag bind old$j <Enter> {$view(version) config -cursor arrow}
		$view(version) tag bind old$j <Leave> {$view(version) config -cursor xterm}
		$view(version) insert end "$v " old$j
	}
	$view(version) tag add right 1.0 end
	$view(version) configure -state disabled 
}

proc PageFrame {} {
	global view color style
	eval labelframe $view(page) $style(frame) 
	bind $view(page) <Button-1> ClearAll
}

proc CreatePage {} {
	global view color
	PageFrame	
	# create paned window for text, code and test
	set view(panes) $view(page).panes
	panedwindow $view(panes) -orient vertical -borderwidth 0 \
		-sashrelief flat -opaqueresize 1 -sashwidth 3 -bg #f3f3f3
	$view(panes) add [TextPane]
	$view(panes) add [CodePane]
#	$view(panes) add [TestPane]
	TestPane  ;# exists but invisible
	# arrange title and panes in page	
	grid [TitlePane] -row 0  -sticky news
	grid $view(panes) -row 1  -sticky news  
	# configure
	grid rowconfigure $view(page) 0 -weight 0
	grid rowconfigure $view(page) 1 -weight 1 
	grid columnconfigure $view(page) 0 -weight 1  
	bind $view(panes) <ButtonRelease-1> {after 100 GetSashPositions}
}

proc SetPanes {} {
	global view
	eval $view(panes) sash place 0 $view(sash0)
}

proc Text&CodePanes {} {
	global view
	if {[Extension] =="txt"}	{
		NoCodePane
	} else {
		SetPanes 
	}
}

proc NoCodePane {} {
	global view
	$view(panes) sash place 0 0 2000
#	$view(panes) sash place 1 0 2000  -- no Testpane
}

proc TextCodePanes {id} {
	switch [GetPage $id type] {
		chapter {NoCodePane}
		section {NoCodePane}
		unit {Text&CodePanes}
	}
}

proc ClearPage {} {
	global view
	$view(title) configure -state normal
	$view(title) delete 1.0 end
	$view(title) configure -state disabled
	$view(text) configure -state normal
	$view(text) delete 1.0 end
	$view(text) configure -state disabled
	$view(code) configure -state normal
	$view(code) delete 1.0 end
	$view(code) configure -state disabled

}

proc ShowPage {id} {
	global view oldVersion page color
	set page $id
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
	foreach pane "$view(chapters) $view(sections) $view(units) $view(tree)" {
		$pane configure -bg $color(pagebg)
	}	
	TextCodePanes $id
	ShowLinPage $id
	ShowTree $id
	ShowFoundText 
	MarkInfoPages
	StartVisitTime
	SetTreePage
}

