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

% Set the transformation scenario, i.e. the order of transformations and
% the corresponding parameters. For instance, {'Skew',+0.005,'Bend',0.03}
scenario = {'Skew',-0.003,...
            'Twist',+0.005,...
            'Bend',+0.01};
lattice = transforms(lattice0,scenario);

%% OUTPUT: Writing the new PDB file #######################################
pdb.xyz(latInds,:) = lattice;
filename = 'graphene_pore_transformed.pdb';
writepdb(filename, pdb);

%% FUNCTIONS
function lattice = transforms(lattice0,scenario) %% Transforms
        
    lattice = lattice0;
    
    for m=1:(size(scenario,2)/2) % Assumption: scenario is written in property-value pairs format
        trans = scenario{2*m-1};
        val = scenario{2*m};
        switch trans
            case 'Stretch'
                lattice = stretch(lattice,val);
            case 'Skew'
                lattice = skew(lattice,val);
            case 'Twist'
                lattice = twist(lattice,val);
            case 'Bend'
                lattice = bend(lattice,val);
            otherwise
                error('Unknown transform type.');
        end
        fprintf('%s: %.3f\n',trans,val);
    end     
end