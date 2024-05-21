function center = rect2center(partial)
%get center(x, y) coordinate from partial(x1, y1, x2, y2)

%--------------------------------------------------------------------------
% FlyFly v2
%
% Jonas Henriksson, 2010                                   info@flyfly.se
%--------------------------------------------------------------------------

center = [ partial(1)+partial(3) partial(2)+partial(4)]/2;
center = [center center];