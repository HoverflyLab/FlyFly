function Parameters = colorFillDraw(wPtr, n, k, ifi, Parameters)
%function tmp = colorFillDraw(wPtr, n, k, Parameters, tmp)
%
% Fills the screen with a single color

%--------------------------------------------------------------------------
% FlyFly v2
%
% Jonas Henriksson, 2010                            info@flyfly.se
%--------------------------------------------------------------------------

Screen('Fillrect', wPtr, Parameters.RGB(k));