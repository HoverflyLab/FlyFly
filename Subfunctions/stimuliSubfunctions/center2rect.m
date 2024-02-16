function rect = center2rect(center, rect)
%make rect(x1, y1, x2, y2) from center(x, y) and rect(0, 0, w, h)

%--------------------------------------------------------------------------
% FlyFly v2
%
% Jonas Henriksson, 2010                                   info@flyfly.se
%--------------------------------------------------------------------------

rect = rect + [center(1) center(2) center(1) center(2)];