







ion}
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



c CopyName {} {
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

f {[Editing]} {
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

Editing]} {
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

ing]} {
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





















de) search -regexp -count cnt -nocase -- $Pattern 1.0 end]
		if {$start!=""} {$::view(code) tag add blue $start "$start +$cnt chars"}
		while {$start!=""} {
			set start [$::view(code) search -regexp -count cnt -nocase -- \
						$Pattern "$start +1 chars" end]
			if {$start!=""} {$::view(code) tag add blue $start "$start +$cnt chars"}
		}
	}
}

search -regexp -count cnt -nocase -- $Pattern 1.0 end]
		if {$start!=""} {$::view(code) tag add blue $start "$start +$cnt chars"}
		while {$start!=""} {
			set start [$::view(code) search -regexp -count cnt -nocase -- \
						$Pattern "$start +1 chars" end]
			if {$start!=""} {$::view(code) tag add blue $start "$start +$cnt chars"}
		}
	}
}













 string $s "$s +$c chars"
			incr i
		}
	}
}







ing $s "$s +$c chars"
			incr i
		}
	}
}

$s "$s +$c chars"
			incr i
		}
	}
}

ub return set socket split string switch unset update uplevel upvar variable vwait 
	global source set 	foreach 	boolean  for 	
	bind bitmap button canvas checkbutton console destroy entry event focus font frame grab grid image label
	labelframe listbox lower menu menubutton message option pack panedwindow place radiobutton raise scale
	scrollbar selection send spinbox text winfo wm tkwait
	tag remove end configure itemconfigure index insert activate mark
}

 [$view(text) tag prevrange url current]]
 	if [osx] {
		eval exec open $webadr &
	} {
		eval exec [auto_execok start] $webadr &
	} 
}

a [lindex $range 0] 
	set b [lindex $range 1]
	$view(text) tag add i $a $b
}

 
	set b [lindex $range 1]
	$view(text) tag add i $a $b
}

 revpage codefont codesize} 
	mk::view layout wdb.pages \
		{name page date:I who type next list active cursor source text \
		 changes old compcode test mode}
}

page codefont codesize} 
	mk::view layout wdb.pages \
		{name page date:I who type next list active cursor source text \
		 changes old compcode test mode}
}

 codefont codesize} 
	mk::view layout wdb.pages \
		{name page date:I who type next list active cursor source text \
		 changes old compcode test mode}
}

b argc argv appname db  newdb
	# get path of db and name of host=app=project
		if {$argc} {set db [lindex $argv 0]} else {set db [tk appname].hdb}
		set db "./source/$db"  
		set appname [file rootname [file tail $db]]
	# open or create DB  
		set newdb [expr ![file exists $db]]
		mk::file open wdb $db -shared        ;# wdb is handle of db-file
		SetDBLayout
		if {$newdb} {CreateStructure; return}
	# exit if app is already running
		if {[GetBase running]!="" && ([clock seconds]-[GetBase running])<60} {
			wm iconify .  
			tk_messageBox -type ok -message "This System is already running"
			exit
		}
	UpdateRunning
}

}



oc PrevChapter {} {
	set c [FirstChapter]
	if {$c==[Chapter]} {return ""}
	while {[Next $c]!=[Chapter]} {
		set c [Next $c]
	}
	return $c
}

revChapter {} {
	set c [FirstChapter]
	if {$c==[Chapter]} {return ""}
	while {[Next $c]!=[Chapter]} {
		set c [Next $c]
	}
	return $c
}

Unit]
}

	set name "thekeyfile"
	set f [open $name.key w]
 	fconfigure $f -encoding binary
	return $f
}

len} {incr i} {
		set char [string index $text $i]
 		set asc [ascii $char] 
		incr summe $asc
		append mtext	[char [Mumble $asc]]
	}
#	append mtext [char [expr $summe%128]]
	return $mtext
}

 {incr i} {
		set char [string index $text $i]
 		set asc [ascii $char] 
		incr summe $asc
		append mtext	[char [Mumble $asc]]
	}
#	append mtext [char [expr $summe%128]]
	return $mtext
}





n {} {
	global view
	return [$view(sections) index active]
}

