function lattice = skew(lattice0,skewness1)
% Skewing of a 3D lattice
% Miraslau Barabash, Lancaster University, November 2020

lattice(:,1) = lattice0(:,1) + skewness1*lattice0(:,2);
lattice(:,2) = lattice0(:,2) + skewness1*lattice0(:,1);
lattice(:,3) = lattice0(:,3);
end