function angle = flipAngleDeg(angle)
%Flips the unit circle around the y axis. 0->180, 45->135, 90->90

%--------------------------------------------------------------------------
% FlyFly v2
%
% Jonas Henriksson, 2010                                   info@flyfly.se
%--------------------------------------------------------------------------

angle = angle + 135;
angle = mod(angle, 360);
angle = 315 - angle;