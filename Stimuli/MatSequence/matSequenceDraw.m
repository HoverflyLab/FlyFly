function Parameters = matSequenceDraw(wPtr, n, k, ifi, Parameters)
%function tmp = matSequenceDraw(wPtr, n, k, Parameters, tmp)
%
% Draws a sequence of images stored as a 3D matrix in .mat file. Format of
% matrix should be X:Y:Z, where each Z

%--------------------------------------------------------------------------
% FlyFly v2
%
% Jonas Henriksson, 2010                            info@flyfly.se
%--------------------------------------------------------------------------

srcRect = [];
dstRect = Parameters.dstRect(:,k);

Screen('DrawTexture', wPtr, Parameters.textures(Parameters.textureIndex(k), mod( ceil(Parameters.nSwitch(k)*n),Parameters.numFrames(k))+1), srcRect, dstRect);