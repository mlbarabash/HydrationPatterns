% Lattice transforms
% Miraslau Barabash, Lancaster University, November 2020

% Please ensure MATLAB can access readpdb.m and writepdb.m from MDToolbox https://github.com/ymatsunaga/mdtoolbox

% Add the folder with transform functions to the path
addpath('./transforms','-begin');

%% INPUT ##################################################################

[pdb, ~] = readpdb('graphene_pore.pdb');

% Select the atoms of the lattice
latInds = pdb.serial(strncmp(cellstr(pdb.resname),'GRA',4));
lattice0 = pdb.xyz(latInds,:);


%% Transforms
interCarbon = 1.418; % [A]

% Skewing
val = -0.003; % Set the required value
lattice = skew(lattice0,val);

% Twisting along Y axis
val = +0.005; % Set the required value
lattice = twist(lattice,val);


%% OUTPUT: Writing the new PDB file #######################################
pdb.xyz(latInds,:) = lattice;
filename = 'graphene_pore_transformed.pdb';
writepdb(filename, pdb);