function partial = center2rect(center, partial)
%make partial(x1, y1, x2, y2) from center(x, y) and partial(0, 0, w, h)

%--------------------------------------------------------------------------
% FlyFly v2
%
% Jonas Henriksson, 2010                                   info@flyfly.se
%--------------------------------------------------------------------------

partial = partial + [center(1) center(2) center(1) center(2)];