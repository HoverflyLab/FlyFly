function [critInput] = rollingImagePrep(Parameters, ScreenData, StimSettings, NumSubframes)
%
% Prepares the input parameters for rollingImageDraw
%

%--------------------------------------------------------------------------
% FlyFly v2
%
% Jonas Henriksson, 2010                                 info@flyfly.se
%--------------------------------------------------------------------------

if nargin<4
    NumSubframes = 1;
end

[tmp, numRuns] = size(Parameters);

P.speed       = Parameters(1,:)/NumSubframes;
P.direction   = -Parameters(2,:);   % counter-clockwise rotation
P.xpos        = Parameters(3,:);
P.ypos        = Parameters(4,:);
P.height      = Parameters(5,:);
P.width       = Parameters(6,:);
P.offset      = -Parameters(7,:);
P.contrast    = Parameters(8,:);

P.angleRad      = P.direction/180*pi; %rad
P.speedFrame    = -P.speed * ScreenData.ifi;

% MAKE TEXTURE
usedTextures = {};
newTex       = 1;
index        = 1;
texture      = [];

critInput.images = [];

for k = 1:numRuns
    
    imPath        = StimSettings(k).path1{2};
    keepOffset(k) = StimSettings(k).box1{2};
    
    if StimSettings(k).box3{2} && k==1
        % Generate bar image
        x = str2num(StimSettings(k).edit3{2});
        y = str2num(StimSettings(k).edit4{2});
        imRect(:,k) = [0 0 x y]';
        if ~StimSettings(k).box4{2}
            I = generateBarStimImage(x,y);
            critInput.images{k} = I(1,:);
        else
            I = generateBarStimImage(x,y,'horizontal');
            critInput.images{k} = I(:,1);
        end
        texture(end+1) = Screen('MakeTexture', ScreenData.wPtr, uint8(255*I));
        index = length(texture);
    else
    
        for n = 1:length(usedTextures)
            if strcmp([imPath num2str(P.contrast(k))], usedTextures{n})
                newTex = 0;
                index  = n;
                break;
            end
        end

        if newTex
            %concate path and contrast
            usedTextures{end+1} = [imPath num2str(P.contrast(k))];

            [I, tmp, alpha] = imread(imPath);
            if ~isempty(alpha)
                I(:,:,4) = alpha;
            end

            [y, x, z]     = size(I);
            imRect(:,k)   = [0 0 x y]';

            I2 = double(I);
            I2 = P.contrast(k)*(I2-127) + 127;

            %uncommenting below  might improve performance?
            %optimizedDrawAngle = P.direction(k);
            %texture(end+1) = Screen('MakeTexture', ScreenData.wPtr, uint8(I2), optimizedDrawAngle);
            texture(end+1) = Screen('MakeTexture', ScreenData.wPtr, uint8(I2));

            index = length(texture);
            newTex = 1;
        end
    end
    
    textureIndex(k) = index;
end

xx = P.xpos-P.width/2;
yy = P.ypos-P.height/2;

position   = [xx' yy' xx' yy'];

angleBound = atan( (ScreenData.rect(4) - P.ypos) /x); %angle of screen diagonal

if P.angleRad > angleBound
    L = ScreenData.rect(4)./sin(P.angleRad);
elseif P.angleRad < angleBound
    L = ScreenData.rect(3)./cos(P.angleRad) + y*tan(P.angleRad);
else
    L = ScreenData.rect(3)./cos(P.angleRad);
end

%each trial in a column
for k = 1:numRuns
    tmp(1:4,k) = min(imRect(:,textureIndex(k)), [0; 0; P.width(k); P.height(k)]);
end

rectAngled = min([zeros(1, numRuns); zeros(1, numRuns); L; y*ones(1, numRuns)], tmp);

%Export critical input
critInput.offset     = P.offset; %changes dynamically if keepOffset is true for a trial
critInput.angleRad   = P.angleRad;
critInput.direction  = P.direction;
critInput.speedFrame = P.speedFrame;

critInput.rectAngled   = rectAngled;
critInput.imRect       = imRect;
critInput.position     = position;
critInput.texture      = texture;
critInput.textureIndex = textureIndex;

critInput.keepOffset   = keepOffset;
critInput.out          = P.offset(1);

