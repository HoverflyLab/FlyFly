function [critInput] = sineGratingCylinderPrep(Parameters, ScreenData, StimSettings, NumSubframes)
%
%  Prepares input parameters for sineGratingDraw

%--------------------------------------------------------------------------
% FlyFly v2
%
% Jonas Henriksson, 2010                                   info@flyfly.se
%--------------------------------------------------------------------------

if nargin<4
    NumSubframes = 1;
end

[tmp, numRuns] = size(Parameters);

P.wavelength  = Parameters(1,:);
P.freq        = Parameters(2,:)/NumSubframes;   % temporal frequency
P.angle       = Parameters(3,:);
P.patchHeight = Parameters(4,:);
P.patchWidth  = Parameters(5,:);
P.patchXpos   = Parameters(6,:);
P.patchYpos   = Parameters(7,:);
P.contrast    = Parameters(8,:);

P.angle = flipAngleDeg(P.angle);

angleRad = P.angle*pi/180;         % deg orientation.
fRad     = 1./P.wavelength*2*pi;   % cycles/pixel

% TEXTURE
usedTextures = struct('contrast', [], 'wavelength', [], 'freq', [], 'angle', []);
texture = [];

newTex       = 1;

texX = P.patchWidth  / 2;
texY = P.patchHeight / 2;

xAdd = abs(P.wavelength.*cos(angleRad));
yAdd = abs(P.wavelength.*sin(angleRad));

white = WhiteIndex(ScreenData.screenNumber);
black = BlackIndex(ScreenData.screenNumber);
gray  = round((white+black)/2);
inc   = white - gray;

p = 1;

for k = 1:numRuns
    
    tmpTex.contrast   = P.contrast(k);
    tmpTex.wavelength = P.wavelength(k);
    tmpTex.freq       = P.freq(k);
    tmpTex.angle      = P.angle(k);
    
    for n = 1:length(usedTextures)
        if isequal(tmpTex, usedTextures(n))
            newTex = 0;
            index  = n;
            break;
        end
    end
    
    if newTex
        usedTextures(p) = tmpTex;
        
        %make grating
        [x,y]    = meshgrid(-(texX+xAdd(k)):texX+xAdd(k), -(texY+yAdd(k)):texY+yAdd(k) );
        
        a = cos(angleRad(k))*fRad(k);
        b = sin(angleRad(k))*fRad(k);
        
        grating = sin(a*x + b*y);
        grating = gray+inc*grating;
        grating = P.contrast(k)*(grating - gray) + gray;
        
        texture(p) = Screen('MakeTexture', ScreenData.wPtr, grating);
        
        index = length(texture);
        p = p +1;
    end
    textureIndex(k) = index;
    newTex = 1;
end

pixelsPerFrame = P.wavelength.*P.freq *ScreenData.ifi;

critInput.texture = texture;
critInput.dstRect = [P.patchXpos - texX;             P.patchYpos - texY; ...
    P.patchXpos + texX;  P.patchYpos + texY ];

critInput.srcRect = [xAdd; yAdd; xAdd+P.patchWidth; yAdd+P.patchHeight];

critInput.pixelsPerFrame = pixelsPerFrame;
critInput.wavelength     = P.wavelength;
critInput.angle          = angleRad;
critInput.textureIndex   = textureIndex;