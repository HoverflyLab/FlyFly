function Parameters = sineGratingBackgroundDraw(wPtr, n, k, ~, Parameters)
%function out = sineGratingDraw(wPtr, n, k, Parameters, out)
%
% Fills window with a changing shade that matches a sinusoidal wave
%

%--------------------------------------------------------------------------
% FlyFly v2
%
% Jonas Henriksson, 2010                                   info@flyfly.se
%--------------------------------------------------------------------------

% n is current frame, k is current trial, Parameters is a struct generated
% from sineGratingTruePrep.m, wPtr is index to current PTB3 window.

% Grab the trials correct texture
currentTexture = Parameters.texture{Parameters.textureIndex(k)};
% Grab the correct shade for this texture, algorithm starts from currentTexture(1)
% and then loops over the texture in steps of 'pixelsPerFrame'
currentColour = currentTexture(mod(floor(Parameters.pixelsPerFrame*(n - 1)) + Parameters.wavelength, Parameters.wavelength) + 1);
% Put it into shade recogniseable by PTB3
currentShade = [currentColour currentColour currentColour];
% Display the shade on the screen.
Screen('Fillrect', wPtr, currentShade, Parameters.dstRect(:,k));