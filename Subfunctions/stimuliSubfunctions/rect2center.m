function center = rect2center(rect)
%get center(x, y) coordinate from rect(x1, y1, x2, y2)

%--------------------------------------------------------------------------
% FlyFly v2
%
% Jonas Henriksson, 2010                                   info@flyfly.se
%--------------------------------------------------------------------------

center = [ rect(1)+rect(3) rect(2)+rect(4)]/2;
center = [center center];