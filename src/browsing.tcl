proc SetCurrent {type} {
	global view
	switch $type {
		chapter {set l $view(chapters)}
		section {set l $view(sections)}
		unit {set l $view(units)}
		default {set l $view(units)}
	}
	set i [$l index active]
	$l selection set $i
	$l itemconfigure $i -bg #bfdfff -fg black
	focus $l
}

proc SetList {id} {
	global view
puts <SETLIST 
	foreach l "$view(chapters) $view(sections) $view(units)" {
		$l selection clear [$l index active]
	}	
	if {[Deleted $id]} {return}
	set type [GetPage $id type]      
	switch $type {
		chapter {
			SetChapter $id ;  puts setchapter
		}
		section {
			SetChapter [GetChapter $id]; 
		 	SetSection $id ; 
		}
		unit {
			set s [GetSection $id]; 
			set c [GetChapter $s] ; 
			SetChapter $c;  
			SetSection $s;   
			SetUnit $id	;  
		}
	}	
	GetChapters;  
	GetSections;  
	if {![NoSections]} {GetUnits} ;  
	SetCurrent $type;  
puts "SETLIST> $id $type "
}

proc SetHeight {h} {
	global view 
	if [Editing] return
	set view(height) $h
	foreach l "$view(chapters) $view(sections) $view(units)" {
		$l configure -height $h
	}
	# wait a little for the windows 
	set x 0; after 100 {set x 1}; vwait x
	foreach l "$view(chapters) $view(sections) $view(units)" {
		$l yview [expr {[$l index active]-$view(height)/2}]
	}	 
}

proc IncrList {} {
	global view
	set h [expr {$view(height)+2}]; if {$h>30} {set h 30}
	SetHeight $h
	TextCodePanes [CurrentPage]
}

proc DecrList {} {
	global view
	set h [expr {$view(height)-2}]; if {$h<3} {set h 3}
	SetHeight $h
	TextCodePanes [CurrentPage]
}

proc DeleteChapter {} {
	if [NoChapters] {return}
	set chapter [Chapter]; set prev [PrevChapter]; set next [NextChapter]
	# move chapter to deleted chapters
	if {$prev==""} {
		SetBase list $next
	} else {
		SetPage $prev next $next 
	}
	SetPage $chapter next [GetBase delchapters] type deleted 
	SetBase delchapters $chapter
	# mark all items in the chapter as 'deleted'
	set s [Section]
	SetSection [FirstSection]
	while {[Section]!=[Chapter]} {
		SetUnitsType deleted
		SetPage [Section] type deleted
		SetSection [NextSection]
	}
	SetSection $s
	if [NoChapters] {ClearChapters; ClearPage; return}
	if {$next == ""} {SetChapter $prev} else {SetChapter $next}
	RefreshChapters
}

proc InsertChapter {chapter location} {
	if {[NoChapters]} {
		SetBase list $chapter
		SetPage $chapter next "" type chapter   
	} else {
		if {$location=="before"} {
			set prev [PrevChapter]	
	    		if {$prev==""} {
				SetBase list $chapter
	    		} else { 
		   		SetPage $prev next $chapter
			}
	    		SetPage $chapter next [Chapter] type chapter
	 	} else {	      	
			# insert after active chapter
     			set nextc [NextChapter]
     			SetPage [Chapter] next $chapter
     			SetPage $chapter next $nextc type chapter
     		} 
	}
	SetChapter $chapter
	set s [Section]
	SetSection [FirstSection]
	while {[Section]!=[Chapter]} {
		SetUnitsType unit
		SetPage [Section] type section
		SetSection [NextSection]
	}
	SetSection $s
	RefreshChapters
	WriteChapter	
}

proc InsertCDeleted {where} {
     set d [GetBase delchapters]
     if {$d == ""} {return}
     set n [Next $d]
     SetBase delchapters $n
     InsertChapter $d $where
}

proc NewChapter {} {
	set name "Chapter"
	set c [AppendPage name $name changes $::version date [clock seconds]]
	SetPage $c list $c
	InsertChapter $c 1
}

proc AddChapter {} {
	NewChapter; NewSection; NewUnit; FocusChapters
}

proc iActiveSection {} {
	global view
	return [$view(sections) index active]
}

proc iLastSection {} {
	global view
	return [expr {[$view(sections) index end] -1}]
}

proc SetUnitsType {t} {
	set u [Unit]
	SetUnit [FirstUnit]
	while {[Unit]!=[Section]} {
		SetPage [Unit] type $t
		SetUnit [NextUnit]
	}
	SetUnit $u
}

proc DeleteSection {} {
	if {[NoSections]} {return}
	set section [Section]; set prev [PrevSection]; set next [NextSection]
	if {$prev==[Chapter]} {
		SetPage [Chapter] list $next
	} else {
		SetPage $prev next $next 
	}
	SetPage $section next [GetBase delsections] type deleted; SetUnitsType deleted
	SetBase delsections $section     
	if {[NoSections]} {
		ClearSections; ClearPage; if [LinView] {StreamAll}
     		return
	}
	if {$next==[Chapter]} {SetSection $prev} else {SetSection $next}
	RefreshSections
	WriteChapter	
}

proc InsertSection {section location} {
	if {[NoSections]} {
		SetPage [Chapter] list $section
		SetPage $section next [Chapter] type section
	} else {
		if {$location=="before"} {
			set prev [PrevSection]
	    		if {$prev==[Chapter]} {
				SetPage [Chapter] list $section
	    		} else { 
		   		SetPage $prev next $section
			}
	    		SetPage $section next [Section] type section
	 	} else {	      	
			# insert after active section
		     set next [NextSection]
		     SetPage [Section] next $section
		     SetPage $section next $next type section
		}
	}     
	SetSection $section
	SetUnitsType unit
	RefreshSections 
	WriteChapter	
}

proc InsertSDeleted {l} {
	set d [GetBase delsections]
	if {$d == ""} {return}
	set n [Next $d]
	SetBase delsections $n
	InsertSection $d $l
}

proc NewSection {} {
	set s [AppendPage name "Section" changes $::version date [clock seconds]]
	SetPage $s list $s
	InsertSection $s 1
}

proc AddSection {} {
	NewSection; NewUnit; FocusSections
}

proc CopySection {} {
	# New section page
	pagevars [Section] name text
	set news [AppendPage name $name-copy text $text type section]
	if {[NoUnits]} {
		# Set section list empty
     		SetPage $news list $news
	} {
		# Link section to next item in db = new unit
		set inews $news; incr inews; SetPage $news list $inews 
		set u [FirstUnit]
		while {$u != [Section]} {
			pagevars $u name text source
			set newu [AppendPage name $name-copy text $text source $source type unit]
			# Link unit to next item in db = next unit
			set n $newu; incr n; SetPage $newu next $n
			set u [Next $u]
		}
		# Link last new unit to new section
		SetPage $newu next $news
	}
	# Insert new section
	set n [GetPage [Section] next];	SetPage [Section] next $news; SetPage $news next $n
	SetSection $news
	RefreshSections 
	WriteChapter	 
}

proc UpSection {} {
	# return if not at first section
	set s [Section]
	if {[iActiveSection]>0} {return 0}
	set c [PrevChapter]
	while {$c != ""} {
		SetChapter $c
		if {![NoSections]} {
			set s [LastSection]; break
		}
		set c [PrevChapter]
     }
	GotoSection $s
	return 1
}

proc DownSection {} { 
	# return if not at last section
	set s [Section]
	if {[iActiveSection]<[iLastSection]} {return 0}
	set c [NextChapter]
	while {$c != ""} {
		SetChapter $c
		if {![NoSections]} {
			set s [FirstSection]; break
		}
		set c [NextChapter]
     }
	# Here if no more sections in DB
	GotoSection $s
	return 1
}

proc HomeSection {} {
	if {[iActiveSection]==0} {
		UpSection
	} else {
		GotoSection [FirstSection]
	}
}

proc EndSection {} {
	if {[iActiveSection]==[iLastSection]} {
		DownSection
	} else {
		GotoSection [LastSection]
	}
}

proc GotoSection {s} {
	SetList $s
	UpdateSections
}

proc PgUpSections {} {
	global Sections 
	set i [iActiveSection]
	if {$i==0} {
		UpSection
	} else {
		incr i -4; if {$i<0} {set i 0}
		GotoSection [lindex $Sections $i]
	}
}

proc DeleteUnit {} {
	if {[NoUnits]} {return}
	set unit [Unit]; set prev [PrevUnit]; set next [NextUnit]; 
	# move unit to deleted units
	if {$prev!=[Section]} {
		SetPage $prev next $next 
	} else {
		SetPage [Section] list $next
	}
	SetPage $unit next [GetBase delunits] type deleted; SetBase delunits $unit
	if {[NoUnits]} {
		ClearUnits; ClearPage; if [LinView] {StreamAll}
		return
	}
	if {$next==[Section]} {SetUnit $prev} else {SetUnit $next}
	RefreshUnits
	WriteChapter	
}

proc InsertUnit {unit location} {
	if {[NoUnits]} {
		SetPage [Section] list $unit
		SetPage $unit next [Section] type unit
	} else {
		if {$location=="before"} {
			set prev [PrevUnit]
			if {$prev==[Section]} {
				SetPage [Section] list $unit
			} else { 
				SetPage $prev next $unit
			}
	    		SetPage $unit next [Unit] type unit
	 	} else {
			# insert after active unit
			set next [NextUnit]
	    		SetPage [Unit] next $unit
	    		SetPage $unit next $next type unit
		}	
	}     
	SetUnit $unit
	RefreshUnits
	WriteChapter	
}

proc InsertUDeleted {l} {
	set d [GetBase delunits]
	if {$d == ""} {return}
	set n [Next $d]
	SetBase delunits $n
	InsertUnit $d $l
}

proc NewUnit {} {
	set u [AppendPage name "Unit" date [clock seconds] ]
	InsertUnit $u 1
}

proc CopyUnit {} {
	if [Editing] {SaveIt}
	pagevars [Unit] name text source
	set u [AppendPage name $name-copy  text $text source $source]
	InsertUnit $u 1
}

proc UpUnit {} {
	# return if not at first unit
	if {[iActiveUnit]>0} {return 0}
	set u [Unit]
	set s [PrevSection] 
	set c [Chapter]
	set sameChapter true
	while {$c != ""} {
		SetChapter $c
		if {![NoSections]} {
			if {!$sameChapter} {set s [LastSection]}
			while {$s != $c} {
				SetSection $s
				if {![NoUnits]} {
					GotoUnit [LastUnit]
					return 1
				}
				set s [PrevSection]
			}
		}
		set c [PrevChapter]
		set sameChapter false 
    }
	GotoUnit $u
	return 1
}

proc DownUnit {} {
	# return if not at last unit
	if {[iActiveUnit]<[iLastUnit]} {return 0}
	set u [Unit]	
	set s [NextSection]
	set c [Chapter]
	set sameChapter true
	while {$c != ""} {
		SetChapter $c
		if {![NoSections]} {
			if {!$sameChapter} {set s [FirstSection]}
			while {$s != $c} {
				SetSection $s
				if {![NoUnits]} {
					GotoUnit [FirstUnit]
					return 1
				}
				set s [NextSection]
			}
		}
		set c [NextChapter]
		set sameChapter false 
     }
	# restore old unit, section and chapter
	GotoUnit $u
	return 1
}

proc PgUpUnits {} {
	global Units 
	set i [iActiveUnit]
	if {$i==0} {
		UpUnit
	} else {
		incr i -4; if {$i<0} {set i 0}
		GotoUnit [lindex $Units $i]
	}
}

proc PgDnUnits {} {
	global Units 
	set i [iActiveUnit]
	set j [iLastUnit]
	if {$i==$j} {
		DownUnit
	} else {
		incr i 4; if {$i>$j} {set i $j}
		GotoUnit [lindex $Units $i]
	}
}

proc HomeUnit {} {
	if {[iActiveUnit]==0} {
		UpUnit
	} else {	
		GotoUnit [FirstUnit]
	}
}

proc EndUnit {} {
	if {[iActiveUnit]==[iLastUnit]} {
		DownUnit
	} else {
		GotoUnit [LastUnit]
	}
}

proc GotoUnit {u} {
	SetList $u
	UpdateUnits	
}

proc LastProgramUnit {} {
	set endUnit [Unit]
	SetChapter [FirstChapter]
	while {[Chapter]!=""} {
		set s [Section]
		SetSection [FirstSection]
		while {[Section]!=[Chapter]} {
			set u [Unit]
			SetUnit [FirstUnit]
			while {[Unit]!=[Section]} {
				set endUnit [Unit]
				SetUnit [NextUnit]
			}
			SetUnit $u
			SetSection [NextSection]
		}
		SetSection $s
		SetChapter [NextChapter]
	}
	GotoUnit $endUnit
}

proc Delimiter {char} {
	switch [GetBase syntax] {
		Tcl {return	[regexp {[\s\[\]\{\}\(\)\"\$\:\;\,\.]} $char]}
		Forth {return	[regexp {\s} $char]}
		default {return	[regexp {[\s\[\]\{\}\(\)\"\$\:\;\,\.]} $char]}
	}
}

proc GetChar {pane i} {
	$pane get "current + $i char"
}

set markedWord ""

proc MarkIt {pane} {
	global markedWord
	if {[Editing]} return
	$pane tag remove marking 1.0 end 
	set markedWord ""
	set i 0; set j 0
	while {![Delimiter [GetChar $pane $i]]} {
			incr i -1;  if {$i<-20} {break}
	}
	incr i
	while {![Delimiter [GetChar $pane $j]]} {
		incr j;  if {$j>20} {break}
	}
	set name [$pane get "current + $i char" "current + $j char"]
    	if [GetUnit $name] {
		$pane tag add marking "current + $i char" "current + $j char"
		set markedWord $name
	} 
}

proc GetWord {pane} {
	set i 0; set j 0
	while {![Delimiter [GetChar $pane $i]]} {
			incr i -1;  if {$i<-20} {break}
	}
	incr i
	while {![Delimiter [GetChar $pane $j]]} {
		incr j;  if {$j>20} {break}
	}
	return [$pane get "current + $i char" "current + $j char"]
}

proc GotoWord {pane} {
	global markedWord
	if {$markedWord!=""} {
		set id [GetUnit $markedWord]
		if {[Editing]} {SaveText}
		ShowPage $id
	} {
		if {![Editing]} {EditIt}
	}
}

proc SearchWord {pane} {
	set selection [$pane tag ranges sel]
	if {$selection!=""} {
		Find [eval {$pane get} $selection ]
	} {
		Find [GetWord $pane]
	}
	clipboard clear; clipboard append $::findText
}

set back 1

proc GoBack {} {
	global back
	if [Editing] {SaveIt}
	if {$back>=[llength [PageStack]]} return
	while {[Deleted [lindex [PageStack] $back]]} {
		incr back
		if {$back>=[llength [PageStack]]} return
	}
	ShowPage [lindex [PageStack] $back]		
	update
	incr back
}

proc GoBackSpace {} {
	if {[focus]==".s.find"} return
	if {[focus]==".s.replace"} return
	GoBack
}

proc FoundColor {color} {
	.s.find config -bg $color 
	.s.replace config -bg $color
}

proc ShowFoundText {} {
	global view searchText found
	set found 1.0;   # für FoundInPage
	foreach pane "$view(title) $view(text) $view(code)" {
		$pane tag remove foundit 1.0 end
		$pane tag remove replaced 1.0 end
		if {$searchText==""} {continue}
		if {$pane==$view(title)} {
			$pane tag configure foundit -foreground brown
		} {
			$pane tag configure foundit -foreground brown -background #eeeeee
		}
		$pane tag bind foundit <Button-1> {ReplaceText %W}
		$pane tag bind foundit <Alt-Button-1> {CopyName; break} 
		set start [$pane search -count cnt -nocase -- $searchText 1.0 end]
		if {$start!=""} {$pane tag add foundit $start "$start +$cnt chars"}
		while {$start!=""} {
			set start [$pane search -count cnt -nocase -- \
				$searchText "$start +1 chars" end]
			if {$start!=""} {$pane tag add foundit $start "$start +$cnt chars"}
		}
	}
}

proc ShowFoundPages {rows} {
	global findText searchText 
	ShowFoundText
	ClearRevision
	RevisionTitle " Found: $findText\n"
	set count 0
	foreach i $rows {
		if {[string compare $findText $searchText] != 0} return
		pagevars $i date name type
		if {[Deleted $i]} {continue}
		InsertRevisionline $name normal $i
		update
   		incr count; # if {$count>60} return
   		set lcname [string tolower $name]
   		set stext [string tolower $findText]
   		if {$lcname==$stext&&[focus]==".s.find"} {
   			set id [GetUnit $lcname]
   			if $id {
				if {[Editing]} {SaveText}
				ShowPage $id
				focus .s.find
			}
		}
  	}
    	if {$count==0} {InsertRevisionline "(none)" normal 0}
	set ::infomode found  
}

proc ShowVisitedPages {} {
	global color
	ClearVisited
	FoundColor $color(info)
	InfoTitle "Visited\n"
#	InfoTitle "Back\n"
#	InfoTitle "History\n"
#	InfoTitle "Recent\n"
#	InfoTitle "Edited:\n"
	set count 0
	foreach i [PageStack] {
		pagevars $i name 
		if {[Deleted $i]} {continue}
		InsertInfo $name normal $i
		incr count; if ($count>$::maxPages) return
	}
	MarkInfoPages
}

proc ShowRevision {rev} {
	global view color findText searchText infomode
	$view(rev) configure -state normal; $view(rev) delete 1.0 end; 
	set findText ""; set searchText ""; ShowFoundText
	RevisionTitle " Revision $rev\n"
	update
	set count 0
	set rows [mk::select wdb.pages -rsort date -globnc changes *$rev*]
	foreach i $rows {
		pagevars $i date name type
		InsertRevisionline $name normal $i
   		incr count
	}
	if {$count == 0} {InsertInfo "(none)" normal 0}
	set infomode revision
}

proc ShowRevisions {} {
	global view 
	set count 0; set lastDay 0; set lastversion 0; array set pageDays {}
	$view(rev) configure -state normal; $view(rev) delete 1.0 end; 
	$view(rev) insert end " Revisions" title; $view(rev) configure -state disabled
	update
	foreach i [mk::select wdb.archive -rsort date] {
		lassign [mk::get wdb.archive!$i id date name version] id date name version
		# only report last change to a page on each day
		set day [expr {$date/86400}]; set dayversion $day$version
		if {[info exists pageDays($id)] && $dayversion==$pageDays($id)} continue
		set pageDays($id) $dayversion
		#insert a header for each new date and version
		incr count
		if {$day!=$lastDay || $version!=$lastversion} {
			# only cut off on day changes and if over 7 days reported
			# if {$count > 1000} {break}
			set lastDay $day; set lastversion $version
			InfoDate "\n $version - [clock format $date -gmt 1 -format {%b. %e, %Y}] "
			update 
		}
		InsertRevisionline $name normal $id
	}
	set ::infomode revisions
}

