# Example: applying sequentially skewing and twisting to a graphene nanopore
# Miraslau Barabash, Lancaster University, November 2020

# Load the functions
source ./transforms/stretch.tcl
source ./transforms/skew.tcl
source ./transforms/bend.tcl
source ./transforms/twist.tcl

# Load the nanopore's structure
mol load pdb graphene_pore.pdb

# Select the atoms to which the coordinate transform should be applied
set sel [atomselect top carbon]


# Apply the transforms
# Skew
set val -0.003	;# Set the required value 
skew $sel $val
# Twist
set val +0.005	
twist $sel $val


# Save the structure and the coordinates
$sel writepsf graphene_pore_transformed.psf
$sel writepdb graphene_pore_transformed.pdb