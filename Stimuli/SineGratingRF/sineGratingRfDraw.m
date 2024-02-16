function P = sineGratingRfDraw(wPtr, n, k, ifi, P)
%function P = sineGratingRfDraw(wPtr, n, k, t, P)
%
% Draws a sine grating with angles distributed over range of 360 degrees each trial.
% Range can be changed in user setttings.
%

%--------------------------------------------------------------------------
% FlyFly v2
%
% Jonas Henriksson, 2010                                   info@flyfly.se
%--------------------------------------------------------------------------

p      = ceil(n/P.framesPerDir(k));
offset = mod((n-1)*P.pixelsPerFrame(k), P.wavelength(k));

srcRect = P.srcRect(:,k) + [ offset*cos(P.angle(p,k)); offset*sin(P.angle(p,k)); ...
    offset*cos(P.angle(p,k)); offset*sin(P.angle(p,k))];

Screen('DrawTexture', wPtr, P.texture(P.textureIndex(p,k)), srcRect, P.dstRect(:,k));