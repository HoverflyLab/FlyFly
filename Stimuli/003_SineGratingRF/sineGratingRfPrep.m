function [critInput] = sineGratingRfPrep(Parameters, ScreenData, StimSettings, NumSubframes)
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

sineGratingRfUserSetting; %DIST_ANGLE

[tmp, numRuns] = size(Parameters);

P.wavelength  = Parameters(1,:);
P.freq        = Parameters(2,:);
P.angle       = Parameters(3,:);
P.steps       = Parameters(4,:);
P.patchHeight = Parameters(5,:);
P.patchWidth  = Parameters(6,:);
P.patchXpos   = Parameters(7,:);
P.patchYpos   = Parameters(8,:);
P.contrast    = Parameters(9,:);
P.time        = Parameters(10,:);
%P.pause       = Parameters(11,:);
P.preTime     = Parameters(12,:);

P.angle = flipAngleDeg(P.angle);

angleRad = P.angle*pi/180;         % deg orientation.
fRad     = 1./P.wavelength*2*pi;   % cycles/pixel

maxSteps    = max(P.steps);
P.stepAngle = zeros(maxSteps, numRuns);

% TEXTURE
usedTextures = struct('contrast', [], 'wavelength', [], 'freq', [], 'angle', []);
texture = [];

newTex  = 1;

texX = P.patchWidth  / 2;
texY = P.patchHeight / 2;

xAdd = P.wavelength;
yAdd = P.wavelength;
    
white = WhiteIndex(ScreenData.screenNumber);
black = BlackIndex(ScreenData.screenNumber);
gray  = round((white+black)/2);
inc   = white - gray;

p = 0; %texture counter
for k = 1:numRuns

    steps = linspace(0, DIST_ANGLE*pi/180, P.steps(k)+1);
    steps = steps(1:end-1);
    if ~StimSettings(k).box1{2} %use clockwise
        tmp = angleRad(k) + steps;
    else
        tmp = angleRad(k) - steps;
    end
    
    P.stepAngle(1:length(tmp),k) = tmp;
    
    for j = 1:P.steps(k)
        
        tmpTex.contrast   = P.contrast(k);
        tmpTex.wavelength = P.wavelength(k);
        tmpTex.freq       = P.freq(k);
        tmpTex.angle      = P.stepAngle(j,k);
        
        for n = 1:length(usedTextures)
            if isequal(tmpTex, usedTextures(n))
                newTex = 0;
                index  = n;
                break;
            end
        end
        
        if newTex
            p = p +1;
            usedTextures(p) = tmpTex;
            
            %make grating
            [x,y] = meshgrid(-(texX+xAdd(k)):texX+xAdd(k), -(texY+yAdd(k)):texY+yAdd(k) );
            
            a = cos(P.stepAngle(j,k))*fRad(k);
            b = sin(P.stepAngle(j,k))*fRad(k);
            
            grating = sin(a*x + b*y);
            grating = gray+inc*grating;
            grating = P.contrast(k)*(grating - gray) + gray;
            
            texture(p) = Screen('MakeTexture', ScreenData.wPtr, grating);
            
            index = length(texture);

        end
        textureIndex(j,k) = index;
        newTex = 1;
        
    end
end

pixelsPerFrame = P.wavelength.*P.freq *ScreenData.ifi;

critInput.texture = texture;
critInput.dstRect = [P.patchXpos - texX;             P.patchYpos - texY; ...
    P.patchXpos + texX;  P.patchYpos + texY ];

critInput.srcRect = [xAdd; yAdd; xAdd+P.patchWidth; yAdd+P.patchHeight];

critInput.pixelsPerFrame = pixelsPerFrame;
critInput.wavelength     = P.wavelength;
critInput.angle          = P.stepAngle;
critInput.textureIndex   = textureIndex;
critInput.time           = P.time;
critInput.preTime        = P.preTime;
critInput.steps          = P.steps;
critInput.framesPerDir   = P.time./P.steps