function [x, y, z, sizes] = starSeedDebug(xmin, xmax, xspace, ymin, ymax, yspace, zmin, zmax, zspace, size)

% D = 18;
% D2 = 2.2;
% Z = -10;
% NUM = 2400;
% 
% angle = 2*pi*rand(1,NUM);
% dist = (D-D2)*rand(1,NUM)+D2;
% x = dist.*sin(angle);
% y = dist.*cos(angle);
% z = Z*ones(1, NUM);

xrange = xmin:xspace:xmax;
yrange = ymin:yspace:ymax;
zrange = zmin:zspace:zmax;

x = repmat(xrange, 1, numel(yrange));
y = repmat(yrange, numel(xrange), 1);
y = y(:)';

x = repmat(x, 1, numel(zrange));
y = repmat(y, 1, numel(zrange));
z = repmat(zrange, numel(xrange)*numel(yrange), 1);
z = z(:)';

numDots = numel(x);
sizes = ones(1, numDots) * size;

end



