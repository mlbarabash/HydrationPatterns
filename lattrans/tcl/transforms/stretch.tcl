proc stretch {sel val} {
  set newcoords {}
  foreach coord [$sel get {x y z}] {	
    lappend newcoords [vecscale [expr 1 + 2.0*$val] $coord]	;# Value 2.0 approximates the elongation-to-strain factor in [A. Smolyanitsky et al., Nanoscale, 2020,12, 10328-10334]
  }
$sel set {x y z} $newcoords
}
