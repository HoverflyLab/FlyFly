function [critInput] = sineGratingBackgroundPrep(Parameters, ScreenData, ~, NumSubframes)
%
%  Prepares input parameters for sineGratingDraw

%--------------------------------------------------------------------------
% FlyFly v2
%
% Jonas Henriksson, 2010                                   info@flyfly.se
%--------------------------------------------------------------------------

% If we are missing length of trial, default to one frame.
if nargin<4
    NumSubframes = 1;
end

[~, numRuns] = size(Parameters);

P.wavelength  = Parameters(1,:);
P.freq        = Parameters(2,:)/NumSubframes;
P.patchHeight = Parameters(3,:);
P.patchWidth  = Parameters(4,:);
P.patchXpos   = Parameters(5,:);
P.patchYpos   = Parameters(6,:);
P.contrast    = Parameters(7,:);

% This is kept constant instead of a variable 
P.angle = flipAngleDeg(0);

angleRad = P.angle*pi/180;         % deg orientation.
fRad     = 1./P.wavelength*2*pi;   % cycles/pixel

% TEXTURE
usedTextures = struct('contrast', [], 'wavelength', [], 'freq', [], 'angle', []);
texture = cell(1, numRuns);

newTex       = 1;

texX = P.patchWidth  / 2;
texY = P.patchHeight / 2;


% xAdd and yAdd say how much extra needs to be added onto x and y dims
% to make it work
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
        
        % a and b do the rotation
        a = cos(angleRad(k))*fRad(k);
        b = sin(angleRad(k))*fRad(k);
        
        % We create the grating just like in sineGrating stimuli
        grating = sin(a*x + b*y);
        grating = gray+inc*grating;
        grating = P.contrast(k)*(grating - gray) + gray;
        % Then we grab only the changes to the shade
        texture{p} = grating(1, 1:P.wavelength(k));
        
        index = length(texture);
        p = p +1;
    end
    textureIndex(k) = index;
    newTex = 1;
    % Calculate what the position of the rectangle should be
    
end

pixelsPerFrame = P.wavelength.*P.freq *ScreenData.ifi;

critInput.texture        = texture;
critInput.dstRect        = [P.patchXpos - texX; P.patchYpos - texY; ...
                            P.patchXpos + texX; P.patchYpos + texY ];
critInput.pixelsPerFrame = pixelsPerFrame;
critInput.wavelength     = P.wavelength;
critInput.textureIndex   = textureIndex;
