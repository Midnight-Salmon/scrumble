#!/usr/bin/tclsh

# scrumble.tcl
# Copyright 2025 Midnight Salmon.

# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3 (or any later
# version) as published by the Free Software Foundation.

# This program is distributed without any warranty; without even the implied
# warranty of merchantability or fitness for a particular purpose. See the GNU
# General Public License for more details. 

# Contact: mail@midnightsalmon.boo

proc md_title {path} {
  set file [open $path]
  set data [read $file]
  close $file
  set lines [split $data \n]
  set title_line [lsearch -regex -inline $lines {^# .+}]
  return [string range $title_line 2 end]
}

set version 0.1

puts "scrumble version $version"
puts "scrumbling [pwd]..."

set missing 0

if {![file isdirectory {./posts}]} {
  puts "ERROR: no posts directory"
  incr missing
}

if {![file isdirectory {./pages}]} {
  puts "ERROR: no pages directory"
  incr missing
}

if {![file isdirectory {./media}]} {
  puts "ERROR: no media directory"
  incr missing
}

if {![file exist {./header.html}]} {
  puts "ERROR: no header.html"
  incr missing
}

if {![file exist {./footer.html}]} {
  puts "ERROR: no footer.html"
  incr missing
}

if {![file exist {./style.css}]} {
  puts "WARNING: no style.css"
}

if {![file exist {./media/favicon.png}]} {
  puts "WARNING: no favicon.png"
}

if {$missing > 0} {
  puts "are you scrumbling in the right place?"
  exit
}

set post_paths [glob {./posts/*.md}]
set page_paths [glob {./pages/*.md}]
set num_posts [llength post_paths]
set num_pages [llength page_paths]
puts "found $num_posts posts and $num_pages pages"

foreach post $post_paths {
  set key [file rootname [file tail $post]]
  set posts($key.date) [file mtime $post]
  set posts($key.title) [md_title $post]
  set posts($key.filename) $key.html
  exec pandoc -o $posts($key.filename) ./posts/$key.md
}

foreach page $page_paths {
  set key [file rootname [file tail $page]]
  set pages($key.title) [md_title $page]
  set pages($key.filename) $key.html
  exec pandoc -o $pages($key.filename) ./pages/$key.md
}

set header_file [open ./header.html]
set header [read $header_file]
close $header_file
set footer_file [open ./footer.html]
set footer [read $footer_file]
close $footer_file
