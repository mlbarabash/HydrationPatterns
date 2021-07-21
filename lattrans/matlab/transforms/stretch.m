function lattice = stretch(lattice0,strain)
% Homogeneous stretching of a 3D lattice
% Miraslau Barabash, Lancaster University, November 2020

stretch = 1 + 2.0*strain; % Value 2.0 approximates the elongation-to-strain factor in [A. Smolyanitsky et al., Nanoscale, 2020,12, 10328-10334]
lattice = stretch*lattice0; % Uniform
end
