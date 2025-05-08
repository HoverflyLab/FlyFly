function Parameters = sineBackgroundDraw(wPtr, n, k, ~, Parameters)
%function out = sineGratingDraw(wPtr, n, k, Parameters, out)
%
% Fills window with a changing shade that matches a sinusoidal wave
%

%--------------------------------------------------------------------------
% FlyFly v2
%
% Jonas Henriksson, 2010                                   info@flyfly.se
%--------------------------------------------------------------------------

Screen('Fillrect', wPtr, Parameters.rgb{k}(n, :));