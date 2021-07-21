function [hg_lat,hg_bond] = lattice_3D(lattice_xyz,atom_rep,bond_rep)
% Builds quickly a 3D graphene lattice to visualize it

Ang = 1; %
indsC = 1:size(lattice_xyz,1);
interCarbon = 1.418; % [A] Carbon-carbon distance in Angstroms


% choosing pairs with minimal distances
L = size(lattice_xyz,1);
pairInds = nchoosek(1:L,2); % unfolding = choosing pairs
pairDistances = lattice_xyz(pairInds(:,1),:) - lattice_xyz(pairInds(:,2),:); % column 1 - column 2
pairR = sqrt(sum(pairDistances.^2,2));
cond = (pairR>0.42*interCarbon & pairR<1.46*interCarbon); % choose the range of distances classified as "nearest"
pairInds = pairInds(cond,:);
L = length(pairInds);

latColor = 'k'; % lattice color

ax = gca;
%% Plotting
%% Atoms
if strcmp(atom_rep,'dot')
    scatter3(lattice_xyz(indsC,2),lattice_xyz(indsC,1),lattice_xyz(indsC,3),'k','filled'); hold on
elseif strcmp(atom_rep,'ball')
    Rs = 0.3*Ang; % radius of the atom/ion sphere
    [sX,sY,sZ] = sphere(20);
    hg_lat = hggroup;
        
    % Carbons
    s1 = surf(Rs*sY,Rs*sX,Rs*sZ,'LineStyle','none','FaceColor',latColor,'Parent',hg_lat); % Sphere at the origin
    s1.FaceColor = latColor;
    for m=1:length(indsC)
        ind = indsC(m);        
        sm = copyobj(s1,ax);
        sm.Parent = hg_lat;
        sm.XData = sm.XData + lattice_xyz(ind,2);
        sm.YData = sm.YData + lattice_xyz(ind,1);
        sm.ZData = sm.ZData + lattice_xyz(ind,3);
    end
    
    delete(s1); % delete the source surface at the origin
elseif strcmp(atom_rep,'hide')
    % do nothing, and nothing will be plotted. Useful for showing the background structure's skeleton
else
    error('Unknown representation for atoms')
end


%% Bonds
hold on;
if strcmp(bond_rep,'line')
    % One line broken by NaNs = lattice
    X = [lattice_xyz(pairInds(:,1),1),lattice_xyz(pairInds(:,2),1),NaN(L,1)]; X = reshape(X',3*L,1)';
    Y = [lattice_xyz(pairInds(:,1),2),lattice_xyz(pairInds(:,2),2),NaN(L,1)]; Y = reshape(Y',3*L,1)';
    Z = [lattice_xyz(pairInds(:,1),3),lattice_xyz(pairInds(:,2),3),NaN(L,1)]; Z = reshape(Z',3*L,1)';
    plot3(Y,X,Z,'k','LineWidth',3)
elseif strcmp(bond_rep,'cylinder')
    Rc = 0.1/2*Ang; % radius of the tube representing the bond
    hg_bond = hggroup;
    
    for m=1:size(pairInds,1)
        iFrom = pairInds(m,1);
        iTo = pairInds(m,2);    
        hold on;
        [cX,cY,cZ] = cylinder2P(Rc,10,lattice_xyz(iFrom,:),lattice_xyz(iTo,:));                  
        surf(cY,cX,cZ,'LineStyle','none','FaceColor',latColor,'Parent',hg_bond);        
    end
else
    error('Unknown representation for bonds')
end



end