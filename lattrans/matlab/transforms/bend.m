function lattice =  bend(lattice0,alpha)
% Bending around Y axis of a 3D lattice
% Miraslau Barabash, Lancaster University, November 2020

if alpha==0
    % Do nothing if alpha = 0
    warning('Bending factor = %f. Coordinates are left unchanged',alpha);
else
    interCarbon = 1.418; % [A] Carbon-carbon distance in an intact lattice
    R = interCarbon/alpha; % curvature radius
    phi = lattice0(:,1)/R; % bending angle for this lattice atom
    x1 = R*sin(phi);
    y1 = lattice0(:,2);
    z1 = lattice0(:,3) - R*(1 - cos(phi));
    lattice = [x1,y1,z1];
end
end