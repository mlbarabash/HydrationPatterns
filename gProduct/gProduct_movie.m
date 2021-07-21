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

Nx = 100; % Specify the resolution of the final 3D figure. Higher values correspond to higher quality but slower computation
Ny = 110;
Nz = 220; % set a larger value when Z span is double that of X and Y
x = linspace(-0,15,Nx); % Specify the XYZ dimensions of the domain to be analysed
y = linspace(-10,10,Ny);
z = linspace(-15,15,Nz);
warning('X and Y seem to be mixed');
[X,Y,Z] = meshgrid(x,y,z);

isoSurfValue = 1.1; % isovalue

% Main multiplication loop
R = sqrt((X-xIon).^2 + (Y-yIon).^2 + (Z-zIon).^2);

density3D_lat = ones(size(R)); % Density due to the lattice
% Hydration pattern due to the lattice
for n=1:size(cenLattice,1)
    R = sqrt((X - cenLattice(n,1)).^2 + (Y - cenLattice(n,2)).^2 + (Z - cenLattice(n,3)).^2);
    atomType = convertCharsToStrings(pdb.name(n,:)); % Atom name
    fprintf('atomType = %s\n',atomType); % controlling the atom type
    
    density3D_lat = density3D_lat.*gC_OW(R);
    
end

% Plotting
fig1 = figure;
set(fig1,'Position',[400 100 735 900]);
hold on; lattice_3D(cenLattice,'ball','cylinder');
hold on; hi = surf(yIon + Ri*sX,xIon + Ri*sY,zIon + Ri*sZ,'LineStyle','none','FaceColor',[0.68 0.07 1]);
view([-60 10]);
colormap jet; colorbar; caxis([0 20]);
camlight headlight; 
camlight left;
grid on;
box on; ax = gca; ax.BoxStyle = 'full';
rotate3d on;
axis equal
xlim([-6 +10])
ylim([-10 10])
zlim([min(z)-Ri, max(z)+Ri]); % clamping the Z axis limits of the figure
set(gca, 'Projection','perspective');
material shiny
lighting gouraud
alphamap('rampdown')
title('3D isosurfaces')


%% Creating frames
movieName = 'Hydration_Patterns_movie.avi';
imgFolder = 'movie_frames';
mkdir(imgFolder);
video = VideoWriter(movieName); %create the video object
video.FrameRate = 3; % set the frame rate
open(video); %open the file for writing

% Trajectory of motion, as discussed in Section 2.4 of the Supplementary Information of the above paper
nPoints = 31;
zTraj = linspace(-15,15,nPoints);
xTraj = zeros(1,nPoints);
yTraj = 0.03*sign(zTraj).*zTraj.^2;
plot3(xTraj',yTraj',zTraj','--k'); % Plot the trajectory


for m=1:nPoints
    fprintf('Frame %03d/%03d\n',m,nPoints);
    % Ion's contribution
    R = sqrt((X - xTraj(m)).^2 + (Y - yTraj(m)).^2 + (Z - zTraj(m)).^2);
    density3D = density3D_lat.*gK_OW(R);
    
    % Smoothing
    density3D = smooth3(density3D,'box',3);
    
    % Drawing
    hp1 = patch(isocaps(X,Y,Z,density3D,isoSurfValue),'FaceColor','interp','EdgeColor','none');
    hp2 = patch(isosurface(X,Y,Z,density3D,isoSurfValue),'FaceAlpha',0.95);
    hp2.FaceColor = 0.95*ones(1,3);
    hp2.EdgeColor = 'none';
    set(hp2,'FaceLighting','gouraud');
    
    % Update the ion's coordinates
    hi.XData = Ri*sX + xTraj(m);
    hi.YData = Ri*sY + yTraj(m);
    hi.ZData = Ri*sZ + zTraj(m);
    
    writeVideo(video,getframe(fig1)); %write the image to the file
    saveas(gcf,[imgFolder,'/','Frame_',sprintf('%03d',m),'.png']);
        
    delete(hp1);
    delete(hp2);    
    
end

close(video); %close the file
close(fig1);

