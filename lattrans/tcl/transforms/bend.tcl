proc bend {sel val} {  
	if { $val == 0 } {
		# Do nothing if val=0
		puts "Bending factor = $val. Coordinates are left unchanged"		
	} else {
		# Apply the transform
		set newcoords {}
		set lambda 1.418	;# Carbon-carbon distance in an intact lattice		
  		
		foreach coord [$sel get {x y z}] {    	
			# Retrieve the original coordinates
			set x0 [lindex $coord 0]
			set y0 [lindex $coord 1]
			set z0 [lindex $coord 2]
	
			# Create useful variables
			set R [expr $lambda/$val]	;# val is assumed to be non-negative
			set phi [expr $x0/$R] 	
		
			# Create new coordinates 
			set x1  [expr $R*sin($phi)];
			set y1  $y0		
			set z1  [expr $z0 - $R*(1.0 - cos($phi))];
		
			# Append the coordinates
			lappend newcoords [list $x1 $y1 $z1]	
		}
		# Write new coordinates
		$sel set {x y z} $newcoords
	}
}
