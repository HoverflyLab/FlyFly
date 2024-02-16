function [x, y, z, sizes, clrs] = starSeed2(density, size, box_x, box_y, box_z, maxDistance)
%function [x y z] = starSeed(ThisCase, NDots, ViewDist)
%
% Returns randomly generated position vector [x y z].
% ThisCase: Set-up to use. 1=cube, 2=lines, 3=sphere
% density: Number of dots per cubic cm
% ViewDist: Spread of dots in space
%

%--------------------------------------------------------------------------
% FlyFly v3.1
%
% Jonas Henriksson, 2010                                   info@flyfly.se
%--------------------------------------------------------------------------

% first sample dots over a space that is UNIFORM in all 3 dimensions 
max_dim = max([box_x box_y box_z]);
numDots = floor(max_dim^3*density);

x = max_dim*(rand(1, numDots) -0.5);
y = max_dim*(rand(1, numDots) -0.5);
z = max_dim*(rand(1, numDots) -0.5);


% now crop out dots we'll never see (that are outside the boxes)
removables = find(abs(x) > box_x/2);
removables = union(removables, find(abs(y) > box_y/2));
removables = union(removables, find(abs(z) > box_z/2));

x(removables) = [];
y(removables) = [];
z(removables) = [];


sizes = ones(1, length(x)) * size;
clrs = rand(1, length(x));
end



