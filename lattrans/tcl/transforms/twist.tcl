proc twist {sel val} {
  set newcoords {}
  set lambda 1.418	;#	Carbon-carbon distance in an intact graphene lattice
  set pi 3.1415926535897931
  foreach coord [$sel get {x y z}] {    	
	# Retrieve the original coordinates
	set x0 [lindex $coord 0]
	set y0 [lindex $coord 1]
	set z0 [lindex $coord 2]
	
	# Create new coordinates 
	set beta [expr $val*2*$pi/$lambda*$y0]
	set x1 [expr cos($beta)*$x0 - sin($beta)*$z0]
	set y1 $y0
	set z1 [expr sin($beta)*$x0 + cos($beta)*$z0]
		
	# Append the coordinates
	lappend newcoords [list $x1 $y1 $z1]	
  }
  # Write new coordinates
  $sel set {x y z} $newcoords
}
