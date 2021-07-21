function lattice = twist(lattice0,twistC)
% Twisting along Y axis of a 3D lattice
% Miraslau Barabash, Lancaster University, November 2020

interCarbon = 1.418; % [A] Carbon-carbon distance in an intact lattice
beta = twistC*2*pi/interCarbon*lattice0(:,2);
x1 = cos(beta).*lattice0(:,1) - sin(beta).*lattice0(:,3);
y1 = lattice0(:,2);
z1 = sin(beta).*lattice0(:,1) + cos(beta).*lattice0(:,3);
lattice = [x1,y1,z1];
end