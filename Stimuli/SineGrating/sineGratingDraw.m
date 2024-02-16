function Parameters = sineGratingDraw(wPtr, n, k, ifi, Parameters)
%function out = sineGratingDraw(wPtr, n, k, Parameters, out)
%
% Draws a sine grating.
%

%--------------------------------------------------------------------------
% FlyFly v2
%
% Jonas Henriksson, 2010                                   info@flyfly.se
%--------------------------------------------------------------------------

offset = mod((n-1)*Parameters.pixelsPerFrame(k), Parameters.wavelength(k));

srcRect = Parameters.srcRect(:,k) + [ offset*cos(Parameters.angle(k)); offset*sin(Parameters.angle(k)); ...
                                      offset*cos(Parameters.angle(k)); offset*sin(Parameters.angle(k))];

Screen('DrawTexture', wPtr, Parameters.texture(Parameters.textureIndex(k)), srcRect, Parameters.dstRect(:,k));