
bind pub - !mode mode_pub
bind msg - !mode mode_msg

set modescsv "modes.csv"

proc mode_msg {nick uhand handle input} {
  if {[llength $input] == 0} {
       return "Usage: !mode <modename>\n       If your mode name contains a space, use quotation marks\n   eg: !mode \"digital sstv\" "
  }
  set mode [sanitize_string [string trim ${input}]]
  set mode [encoding convertfrom utf-8 ${mode}]
  putlog "mode msg: $nick $uhand $handle $mode"
  set output [getmode $mode]
  set output [split $output "\n"]

  foreach line $output {
      putmsg $nick [encoding convertto utf-8 "$line"]
    }
  }
}

proc mode_pub { nick host hand chan text } {
  if {[llength $text] == 0} {
       return "Usage: !mode <modename>\n       If your mode name contains a space, use quotation marks\n   eg: !mode \"digital sstv\" "
  }
  set mode [sanitize_string [string trim ${text}]]
  set mode [encoding convertfrom utf-8 ${mode}]
  putlog "mode pub: $nick $host $hand $chan $rig"
  set output [getmode $mode]
  set output [split $output "\n"]

  foreach line $output {
      putchan $chan [encoding convertto utf-8 "$line"]
    }
  }
}

proc getmode {mode} {
  global modescsv

  if { ![file exists $modescsv] } {
    return ""
  }

  set csvfile [open $modescsv r]
  while {![eof $csvfile]} {

    set line [gets $csvfile]

    if {[regexp -- {^#} $line]} {
      continue;
    }

    if {[regexp -- {^\s*$} $line]} {
      continue;
    }

    set fields [split $line ","]

    set rxp [lindex $fields 0]
    set modename [lindex $fields 1]
    set description [lindex $fields 2]
 
    set re {^[^,]*,[^,]*,[^,]*,[^,]*,[^,]*,\"([^\"]*)\"$}
    regexp $re $line -> desc

    if {[string match -nocase "*${mode}*" $modename]} {
      close $csvfile
      return "$modename: $desc"
    }

    if {[regexp -nocase -- $rxp $modename]} {
      close $csvfile
      return "$modename: $desc"
    }
  }
  close $csvfile
  if {[llength $text] > 0} { return "not found; pull requests accepted: https://github.com/vk3dan/modes/" }
}
