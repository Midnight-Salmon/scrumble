#!/usr/bin/tclsh

# scrumble.tcl
# Copyright 2025 Midnight Salmon.

# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3 (or any later
# version) as published by the Free Software Foundation.

# This program is distributed without any warranty; without even the implied
# warranty of merchantability or fitness for a particular purpose. See the GNU
# General Public License for more details. 

proc md_meta {path} {
  set file [open $path]
  set data [read $file]
  close $file
  set lines [split $data \n]
  set title_block [lsearch -regex -all -inline $lines {^% .+}]
  set title [string range [lindex $title_block 0] 2 end]
  set author [string range [lindex $title_block 1] 2 end]
  set date [string range [lindex $title_block 2] 2 end]
  return [list $title $author $date]
}

proc md_title {path} {
  set meta [md_meta $path]
  return [lindex $meta 0]
}

proc md_author {path} {
  set meta [md_meta $path]
  return [lindex $meta 1]
}

proc md_date {path} {
  set meta [md_meta $path]
  return [lindex $meta 2]
}

proc insert_after_tag {source dest tag} {
  set tag_length [string length $tag]
  set tag_index [string last $tag $dest]
  set front [string range $dest 0 [expr "$tag_index + $tag_length - 1"]]
  set back [string range $dest [expr "$tag_index + $tag_length"] end]
  return [string cat $front $source $back]
}

proc post_table_row {date filename title} {
  set cell1 "<td>$date</td>"
  set cell2 "<td><a href=\"$filename\"><em>$title</em></a></td>"
  return [string cat \n <tr> $cell1 $cell2 </tr>]
}

if {$argc == 0} {
  puts "ERROR: no site title provided"
  exit
} else {
  set site_title [lindex $argv 0]
}

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
set num_posts [llength $post_paths]
set num_pages [llength $page_paths]
puts "found $num_posts posts and $num_pages pages"

file delete -force docs
file mkdir docs/blog

set header_file [open ./header.html]
set header [read $header_file]
close $header_file
set footer_file [open ./footer.html]
set footer [read $footer_file]
close $footer_file

set skeleton {<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<title></title>
<link rel="icon" href="/media/favicon.png" type="image/png">
<link rel="stylesheet" href="/style.css">
</head>
<body><main>
</main></body>
</html>}

set header [string cat \n $header]
set footer [string cat \n $footer]
set skeleton [insert_after_tag $header $skeleton <body>]
set skeleton [insert_after_tag $footer $skeleton </main>]

set nav "\n<ul>\n<li><a href=\"/index.html\">Blog</a></li>\n</ul>"

foreach page $page_paths {
  set key [file rootname [file tail $page]]
  set title [md_title $page]
  set filename $key.html
  set li "\n<li><a href=\"/$filename\">$title</a></li>"
  set nav [insert_after_tag $li $nav </li>]
}

set skeleton [insert_after_tag $nav $skeleton <nav>]

set post_table {<h1>Blog</h1>
<table>
<tr><th>Date</th><th>Title</th></tr>
</table>}

foreach post $post_paths {
  set key [file rootname [file tail $post]]
  set date [md_date $post]
  set title [md_title $post]
  set filename $key.html
  set html [exec pandoc -t html ./posts/$key.md]
  set output [insert_after_tag $html $skeleton <main>]
  set output [insert_after_tag "<p><time>$date</time></p>" $output <main>]
  set output [insert_after_tag "$title | $site_title" $output <title>]
  set file [open docs/blog/$filename w]
  puts $file $output
  close $file
  set row [post_table_row $date /blog/$filename $title]
  lappend post_rows $row
}

foreach page $page_paths {
  set key [file rootname [file tail $page]]
  set title [md_title $page]
  set filename $key.html
  set html [exec pandoc -t html ./pages/$key.md]
  set output [insert_after_tag $html $skeleton <main>]
  set output [insert_after_tag "$title | $site_title" $output <title>]
  set nav_off "<a href=\"/$filename\">$title</a>" 
  set output [string map [list $nav_off $title] $output]
  set file [open docs/$filename w]
  puts $file $output
  close $file
}

set post_rows [lsort -dictionary -decreasing $post_rows]
set post_rows [join $post_rows \n]
set post_table [insert_after_tag $post_rows $post_table </tr>]
set file [open docs/index.html w]
set output [insert_after_tag $post_table $skeleton <main>]
set output [insert_after_tag $site_title $output <title>]
set nav_off "<a href=\"/index.html\">Blog</a>" 
set output [string map [list $nav_off Blog] $output]
puts $file $output
close $file
file copy {*}[concat media style.css [glob {*.html}]] docs

puts "scrumbled!"
