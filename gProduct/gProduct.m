% This script computes the hydration pattern around the ion and the carbon
% nanopore, provided in the PDB file, according to Eq.(4) from paper
% "Origin and control of ionic hydration patterns in nanopores"
% Miraslau L. Barabash, William A. T. Gibby, Carlo Guardiani, Alex Smolyanitsky, Dmitry G. Luchinsky, Peter V. E. McClintock
% Commun Mater. 2, 65, 2021

% NOTES:
% Please ensure that this script can access the following files:
% -- readpdb.m function from MDToolbox https://github.com/ymatsunaga/mdtoolbox
% -- cylinder2P from https://www.mathworks.com/matlabcentral/mlc-downloads/downloads/submissions/5468/versions/1/previews/cylinder2P.m/index.html


clear all;

Ri = 1.33; % [A] radius of the K+ ion
iOn = false; % <true|false> decide whether to account for the presence of the ion


%% Create functions
fname = 'C-OH2.dat';
S = load(fname); fprintf('C-O: %s\n',fname); % figure; plot(S(:,1),S(:,2),'k','LineWidth',2);
gC_OW = @(r) interp1(S(:,1),S(:,2),abs(r),'pchip',1);

fname = 'POT-OH2.dat';
S = load(fname); fprintf('ion-water: %s\n',fname);
gK_OW = @(r) interp1(S(:,1),S(:,2),abs(r),'pchip',1);



%% Read lattice from the PDB file

[pdb, ~] = readpdb('fixed_grai.pdb');

latInds = pdb.serial(strncmp(cellstr(pdb.resname),'GRA',4)); % select carbon atoms

lattice = pdb.xyz(latInds,:);
offsetLat = mean(lattice,1);

iType = 'POT'; % select the potassium (POT) ion from teh PDB file
IonInd = pdb.serial(strncmp(cellstr(pdb.resname),iType,4)); warning('%s ion is clamped',iType);
if ~isempty(IonInd)
    offsetIon = pdb.xyz(IonInd,:); % XYZ coords of the fixed ion
    offset = [offsetIon(1),offsetIon(2),offsetLat(3)];
    xIon = offsetIon(1) - offset(1);
    yIon = offsetIon(2) - offset(2);
    zIon = offsetIon(3) - offset(3);
else
    offset = offsetLat;
end
% Offsetting the lattice and the ion
lattice = lattice - offset;
cenLattice = lattice; % assigning the centered coordinates

[sX,sY,sZ] = sphere(150);


%% 3D surfaces
Nx = 100; % Specify the resolution of the final 3D figure
Ny = 110;
Nz = 120;
x = linspace(-10,10,Nx); % Specify the XYZ dimensions of the domain to be analysed
y = linspace(-0,15,Ny);
z = linspace(-15,15,Nz);
warning('X and Y seem to be mixed');
[X,Y,Z] = meshgrid(x,y,z);

% Main multiplication loop
R = sqrt((X-xIon).^2 + (Y-yIon).^2 + (Z-zIon).^2);
if iOn
    density3D = gK_OW(R); % %
else
    density3D = ones(size(R)); warning('Ion''s effect is ignored.');
end

for n=1:size(cenLattice,1)
    R = sqrt((X - cenLattice(n,1)).^2 + (Y - cenLattice(n,2)).^2 + (Z - cenLattice(n,3)).^2);
    atomType = convertCharsToStrings(pdb.name(n,:)); % Atom name
    fprintf('atomType = %s\n',atomType); % controlling the atom type
    
    density3D = density3D.*gC_OW(R);
    
end

% Smoothing
density3D = smooth3(density3D,'box',3);

% Plotting
figure;
hold on; lattice_3D(cenLattice,'ball','cylinder');
if iOn
    hold on; surf(yIon + Ri*sX,xIon + Ri*sY,zIon + Ri*sZ,'LineStyle','none','FaceColor',[0.68 0.07 1])
end
isoSurfValue = 1.2; % isovalue
patch(isocaps(Y,X,Z,density3D,isoSurfValue),'FaceColor','interp','EdgeColor','none');
p = patch(isosurface(Y,X,Z,density3D,isoSurfValue),'FaceAlpha',0.95);
title('3D isosurface and slices')
p.FaceColor = 0.95*ones(1,3);
p.EdgeColor = 'none';
view([-60 10]);
colormap jet; colorbar; caxis([0 25]);
camlight headlight;
set(p,'FaceLighting','gouraud');
grid on;
box on; ax = gca; ax.BoxStyle = 'full';
rotate3d on;
axis equal
xlim([-6 +6])
ylim([-10 10])
set(gca, 'Projection','perspective');
material shiny
lighting gouraud
alphamap('rampdown')
