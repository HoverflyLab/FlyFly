function [x1,y] = rotXY(x, y, angle)
% function [x1,y1] = rotXY(x, y, angle)
%
% rotates coordinate (x, y) angle degrees around origin

%--------------------------------------------------------------------------
% FlyFly v2
%
% Jonas Henriksson, 2010                                   info@flyfly.se
%--------------------------------------------------------------------------

x1 = x*cos(angle) - y*sin(angle);
y  = y*cos(angle) + x*sin(angle);