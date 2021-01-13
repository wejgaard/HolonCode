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

set pageSize 61
set seite 0
set line 0

proc PrintHeader {} {
	global pf seite line appname version
	if {$line==1} return  ;# avoiding an empty page
	set line 0
	if {$seite>0} {puts -nonewline $pf \f}
	incr seite
#	set d [clock format [clock seconds] -format "%x"]
	set d [clock format [clock seconds] -format "%e.%b %Y"]
	set hAppname [string totitle $appname]
	set hChapter [ChapterName [Chapter]]
	set hSection [GetPage [Section] name] 
	set l "$hAppname/$hChapter/$hSection"
	set c [string length $l]
	puts -nonewline $pf $l
	while {$c<38} {puts -nonewline $pf " "; incr c}
	puts	$pf "$version / $d              Page $seite"
	puts $pf \n
}

proc IncrLine {} {
	global line pageSize
	incr line
	if {$line>$pageSize} {PrintHeader}
}

proc WriteLine {l} {
	global pf 
	regsub -all {\t} $l "    " l
	puts $pf $l 
	IncrLine
}

proc PrintTitle {type id} {
	set l "$type [GetPage $id name]"
	WriteLine $l
	set n [string length $l]
	set l [string repeat "=" $n]
	WriteLine $l
}

proc RemoveTags {t} {
	set text ""	
	foreach {key value index} $t {
		if {$key=="text"} {
			append text $value
		}
	}
	return [string trimright $text]
}

proc PrintTextLine {l r} {
	global pf
	set type [GetPage $r type]
	set length 78
	set delimiter [GetBase comdel]; if {$delimiter!=""} {set delimiter "$delimiter "}
	while {[string length $l] > $length} {
		set w [string wordstart $l $length]
		# if w points to first char of word, move to separator.
		set c [string index $l $w]
		if {[string match {[a-zA-Z0-9]} $c]} {incr w -1}
		# if separator is not space or dot, include in word.
		set c [string index $l $w]
		if {![string match {[ .]} $c]} {incr w -1}
		if {$type=="unit"} {puts -nonewline $pf $delimiter}
		WriteLine [string range $l 0 $w]
		set l [string replace $l 0 $w]
	}
	if {$type=="unit"} {puts -nonewline $pf $delimiter}
	WriteLine $l
}

proc PrintCodeLine {l r} {
	global pf
	set type [GetPage $r type]
	set length 78
	while {[string length $l] > $length} {
		set w [string wordstart $l $length]
		# if w points to first char of word, move to separator.
		set c [string index $l $w]
		if {[string match {[a-zA-Z0-9]} $c]} {incr w -1}
		# if separator is not space or dot, include in word.
		set c [string index $l $w]
		if {![string match {[ .]} $c]} {incr w -1}
		WriteLine [string range $l 0 $w]
		set l [string replace $l 0 $w]
	}
	WriteLine $l
}

proc UnitSize {r} {
	set t [RemoveTags [GetPage $r text]]
	set lines [split $t \n]
	set n [llength $lines]
	set t [GetPage $r source]
	set lines [split $t \n]
	incr n [llength $lines]
	return $n
}

proc PrintText {r} {
	global pf
	set t [RemoveTags [GetPage $r text]]
	set lines [split $t \n]
	set n [llength $lines]
	set i 0
	while {$i<$n} {
		PrintTextLine [lindex $lines $i] $r
		incr i
	}	
}

proc PrintCode {id} {
	set t [GetPage $id source]
	set lines [split $t \n]
	set n [llength $lines]
	set i 0
	while {$i<$n} {
		PrintCodeLine [lindex $lines $i] $id
		incr i
	}	
}

proc PrintPage {r} {
	global pageSize line
	if {[expr [UnitSize $r]+$line]>$pageSize} {PrintHeader}
	PrintText $r
	PrintCode $r
}

proc PrintSectionPages {} {
	PrintHeader
	PrintTitle "Section" [Section]
	PrintText [Section]
	WriteLine ""; WriteLine ""
	if {![NoUnits]} {
	     set u [FirstUnit]
	     PrintPage $u
	     while {[Next $u] != [Section]} {
			set u [Next $u]
			WriteLine ""; WriteLine ""
			PrintPage $u
	     }
	}
}

proc PrintSectionsList {}  {
	WriteLine "Sections"
	WriteLine "========"
 	set s [FirstSection]
	while {$s != [Chapter]} {
		WriteLine [GetPage $s name]
		set s [Next $s]
	 }
}

proc StartPrint {id} {
	global printfile pf seite 
	set name [GetPage $id name]; regsub -all { } $name {-} name
	# if chapter get rid of extension
	set n [string first {.} $name] 
	if {$n>0} {set name [string range $name 0 [expr $n-1]]}
	file mkdir [pwd]/text
	set printfile [pwd]/text/$name.txt
	set pf [open $printfile w]
	fconfigure $pf -encoding binary 
 	set seite 0
 	set line 1  ;# avoid empty pages in PrintHeader
 	if {[GetBase pagesize]!="A4"} {set pageSize 57} else {set pageSize 61}
}

proc EndPrint {} {
	global printfile pf
	close $pf
	 if [osx] {
		eval exec open $printfile &
	} {
		if [catch {eval exec wordpad.exe $printfile &}] {
			eval exec [auto_execok start] $printfile &
		}
	}
}

proc PrintUnit {} {
 	StartPrint [Unit]
	PrintHeader	
	PrintPage [Unit]
	EndPrint
}

proc PrintSection {} {
	StartPrint [Section]
	PrintSectionPages 
	EndPrint
}

proc PrintChapter {} {
	if {[NoSections]} {return}
	set current [Section]
	SetSection [FirstSection]
 	StartPrint [Chapter]
	PrintHeader
	PrintTitle "Chapter" [Chapter]
	PrintText [Chapter]
	WriteLine ""
	WriteLine ""
	PrintSectionsList
	while {[Section] != [Chapter]} {
		PrintSectionPages 
		SetSection [NextSection]
	}
	EndPrint
	SetSection $current
}

proc Print {} {
	switch -glob -- [focus] {
		*chapters {PrintChapter}
		*sections {PrintSection}
		*units {PrintUnit}
	}
}

proc OpenWriteFile {} {
	set dir $::sourcedir
	set name [string tolower [GetPage [Chapter] name]]
	set f [open $dir$name w]
 	fconfigure $f -encoding binary
	return $f
}

proc WriteSection {f} {
	set comdel [GetBase comdel]
	if {[NoUnits]} {return}
	set u [FirstUnit]
	while {$u != [Section]} {
		if {[Extension]=="txt"} {
			puts $f "\n  [GetPage $u name] \n"
			puts $f [GetPage $u text]\n
			puts $f [RemoveTags [GetPage $u text]]\n
		}
		puts $f [GetPage $u source]\n
		set u [Next $u]
	}
}

proc NoExtension {} {
	set name [GetPage [Chapter] name]
	return [expr [string first {.} $name]<0]
}

proc Extension {} {
	set name [GetPage [Chapter] name]
	set dot [string first {.} $name]
	if $dot>0 {
		set ext [string replace $name 0 $dot]
	} {
		set ext ""
	}
	return $ext
}

proc WriteChapter {} {
	global import
	if {$import} {return}                  
	if {[NoSections]} {return}
	if [NoExtension] return	
	set f [OpenWriteFile]
	set current [Section]
	SetSection [FirstSection]  
	while {[Section] != [Chapter]} {
		WriteSection $f 
		SetSection [NextSection]
	}
	SetSection $current
	close $f
}

proc WriteAllChapters {} {
	global import
	set import 0
	if {[NoChapters]} {return}
	set current [Chapter]    
	SetChapter [FirstChapter]
	while {[Chapter]!=""} {
          WriteChapter 
          SetChapter [NextChapter]
     }
	SetChapter $current
	WriteSourceVersion
}

proc OpenWriteDocFile {} {
	set dir $::sourcedir
	set name [string tolower [GetPage [Chapter] name]] 
	set f [open $dir$name.md w]
	fconfigure $f -encoding binary return $f
}

proc WriteChapterDoc {docfile chapter} {
	puts $docfile "\n\[Generated by Holon\]::\n"
	set name [ChapterName $chapter]
	puts $docfile "# $name\n"
	puts $docfile [RemoveTags [GetPage $chapter text]]\n
}

proc WriteSectionDoc {docfile section} {
	set name [GetPage $section name]
	puts $docfile "## $name\n"
	puts $docfile [RemoveTags [GetPage $section text]]\n
}

proc WriteUnitDoc {docfile unit} {
	set name [GetPage $unit name]
	puts $docfile "### $name\n"
	puts $docfile [RemoveTags [GetPage $unit text]]\n 
	set src [GetPage $unit source]
	if {$src!=""} {
		puts $docfile "\n```" 
		puts $docfile "$src\n" 
		puts $docfile "```\n"
	}
}

proc ExportDocFile {} {
	set f [OpenWriteDocFile]
	WriteChapterDoc $f [Chapter]
	if {[NoSections]} {return}
	set current [Section]
	SetSection [FirstSection]  
	while {[Section] != [Chapter]} {
		WriteSectionDoc $f [Section] 
		SetSection [NextSection]
	}
	SetSection $current
	close $f
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

proc OpenExportFile {} {
	set d $::sourcedir
	set n [GetPage [Chapter] name]
	set f [open $d$n.hml w]
 	fconfigure $f -encoding binary
	return $f
}

proc ExportRecord {r f} {
	puts $f "<Name> [GetPage $r name]"
	set t [GetPage $r text] ; if {$t!=""} {puts $f "<Comment> $t"}
	set s [GetPage $r source] ; if {$s!=""} {puts $f "<Source> $s"}
#	set v [lindex [GetPage $r changes] end] ; if {$v!=""} {puts $f "<Version> $v"}
}

proc ExportUnit {f} {
	puts $f "<Unit>"
	ExportRecord [Unit] $f
}

proc ExportSection {f} {
	puts $f "<Section>"
	ExportRecord [Section] $f
	if {[NoUnits]} {return}
	set current [Unit]
	SetUnit [FirstUnit]
	while {[Unit] != [Section]} {
		ExportUnit $f
		SetUnit [NextUnit]
	}
	SetUnit $current
}

proc ExportChapter {} {
	set f [OpenExportFile]
	puts $f "<Chapter>"
	ExportRecord [Chapter] $f
	if {[NoSections]} {return}
	set current [Section]
	SetSection [FirstSection]  
	while {[Section] != [Chapter]} {
		ExportSection $f 
		SetSection [NextSection]
	}
	SetSection $current
	close $f
}

text .importtext

proc TkText {text} {
	if {[regexp {^text \{} $text] || [regexp {^mark } $text]} {set tktext true} {set tktext false}
	return $tktext
}

proc AddCode {line} {
	global code 
	if {$code ne ""} {set code $code\n$line} else {set code $line}
}

proc PutCode {} {
	global item field code
	if {$code==""} {return}
	if {$field=="text" && ![TkText $code]} {
		.importtext delete 1.0 end
		.importtext insert 1.0 $code
		set code [.importtext dump 1.0 end-1char]
	}
	if {$field=="source"} {set code [string trimright $code]}
	SetPage $item $field $code
	set code ""
	update
}

set import 0

proc ImportChapter {file} {
	global item field code import version
	set f [open $file r]
 	fconfigure $f -encoding binary
	set code ""
	set import 1           ;# WriteChapter abschalten 
	while {[gets $f line] >= 0} {
		if {[regexp {^<(.+?)>} $line tag name]} {
			switch $tag {
				<Chapter> {NewChapter ; set item [Chapter]; set field text}
				<Module>  {NewChapter ; set item [Chapter]; set field text}
			 	<Section> {PutCode ; NewSection ; set item [Section]; set field text}
			 	<Unit>    {PutCode ; NewUnit ; set item [Unit]; set field source}
			 	<Name>    {SetPage $item name [string range $line 7 end]}
			 	<Text>    {set code [string range $line 7 end]; set field text}
			 	<Comment> {set code [string range $line 10 end]; set field text}
				<Source>  {PutCode ; set code [string range $line 9 end]; set field source}
				<Code>    {PutCode ; set code [string range $line 7 end]; set field source}
				<Version> {PutCode ; set code $version; set field changes}
				default 		{set code $code\n$line}
			}
		} { 
			set code $code\n$line	
		}	
	}
	PutCode
	close $f
	UpdateUnits
	set import 0; WriteChapter
	update idletasks
}

proc Import-hml {} {
	global appname
	set file [tk_getOpenFile -filetypes {{"" {".hml"}}} -initialdir ./$appname ]
	if {$file==""} {return}
	ImportChapter $file
}

proc ImportOforth {file} {
	global item field code import version
	set f [open $file r]; 	fconfigure $f -encoding binary 
	set field source;
	set code ""; 	set import 1   ;# WriteChapter abschalten 
	while {[gets $f line] >= 0} {
		if {[regexp {^\\ (<(.+?)>)} $line match tag]} {
			switch [string tolower $tag] {
				<file> {	set cname [string range $line 9 end]; 
			 	             NewChapter; SetPage [Chapter] name $cname;
						 NewSection; SetPage [Section] name $cname; 
						 NewUnit; SetPage [Unit] name $cname;	
						 set item [Unit];   # AddCode $line 
						 }
			 	<section> {PutCode; 
			 			set sname [string range $line 12 end]; 
			 	             NewSection; SetPage [Section] name $sname; 
					 	NewUnit;  SetPage [Unit] name $sname;	
						set item [Unit]; 	# AddCode $line 
						}	
			 	<unit>   {PutCode;
			 			NewUnit;	SetPage [Unit] name [string range $line 9 end]; 
						set item [Unit]; # AddCode $line 
						}	
				default 		{AddCode $line}
			}
		} { 
			AddCode $line	
		}	
	}
	PutCode; 	close $f
	UpdateUnits; set import 0; WriteChapter
	update idletasks
}

proc Import-of {} {
	set file [tk_getOpenFile -filetypes {{"" {".of"}}} -initialdir . ]
	if {$file==""} {return}
	ImportOforth $file
}

proc ImportSource {file} {
	global item field code import version
	set f [open $file r]; 	fconfigure $f -encoding binary 
	set field source;
	set code ""; 	set import 1   ;# WriteChapter abschalten 
	set mask "(<(.+?)>)" ; # set mask [string replace $mask  2 2 [GetBase comdel]]
	while {[gets $f line] >= 0} {
		if {[regexp $mask $line match tag]} {
			switch [string tolower $tag] {
				<file> {	set cname [string range $line 7 end]; 
			 	             NewChapter; SetPage [Chapter] name $cname;
						set item [Chapter]; set field "text"; #  AddCode $line; 
						 }
			 	<section> {PutCode; 
			 			set sname [string range $line 10 end]; 
			 	             NewSection; SetPage [Section] name $sname; 
					 	set item [Section];  set field "text"; # AddCode $line;
						}	
			 	<unit>   {PutCode;
			 			NewUnit;	SetPage [Unit] name [string range $line 7 end]; 
						set item [Unit]; set field "source"; # AddCode $line;
						}	
				default 		{AddCode $line}
			}
		} { 
			AddCode $line	
		}	
	}
	PutCode; 	close $f
	UpdateUnits; set import 0; WriteChapter
	update idletasks
}

proc Import-fml {} {
	set file [tk_getOpenFile -filetypes {{"" {".fml"}}} -initialdir . ]
#	set file [tk_getOpenFile -initialdir . ]
	if {$file==""} {return}
	ImportSource $file
}

if [osx] {
	set MonitorFile ../holon.mon
} {
	set MonitorFile ../holon.mon
}

proc LastAccess {} {
	global MonitorFile
	if {[file exists $MonitorFile]} {
		file stat $MonitorFile status
		return $status(mtime)
	} {
		return 0
	}
}

set LastRead 0

proc Monitor {} {
	global LastRead errorInfo
	if {$LastRead != [LastAccess]} {
		set LastRead [LastAccess]
		if {[catch DoIt result]} {
			puts "Error: $errorInfo"
		}
	}
	after 200 Monitor
}

proc DoIt {} {
	global MonitorFile
	set result [uplevel #0 {eval {source $MonitorFile}}]
	puts $result
	SendMonitor $result
}

proc SendMonitor {text} {
	set f [open $::MonitorFile w]
	fconfigure $f -encoding binary
	puts $f "$text\n"
	close $f
}

proc StartMonitor {} {
	global LastRead
	set LastRead [LastAccess]
	Monitor
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

