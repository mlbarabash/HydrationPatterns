proc skew {sel val} {
  set newcoords {}
  foreach coord [$sel get {x y z}] {    	
	# Retrieve the original coordinates
	set x0 [lindex $coord 0]
	set y0 [lindex $coord 1]
	set z0 [lindex $coord 2]
	
	# Create new coordinates 
	set x1 [expr {$x0 + $val*$y0}]
	set y1 [expr {$y0 + $val*$x0}]
	set z1 $z0	;# leave unchanged	
	
	# Append the coordinates
	lappend newcoords [list $x1 $y1 $z1]	
  }
  # Write new coordinates
  $sel set {x y z} $newcoords
}
