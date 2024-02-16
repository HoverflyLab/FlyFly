function [critInput] = rollingImageM2Prep(Parameters, ScreenData, StimSettings, NumSubframes)
%
% Prepares the input parameters for rollingImageDraw
%

%--------------------------------------------------------------------------
% FlyFly v2
%
% Jonas Henriksson, 2010                                   info@flyfly.se
%--------------------------------------------------------------------------

if nargin<4
    NumSubframes = 1;
end

[tmp, numRuns] = size(Parameters);

P.direction   = -Parameters(1,:);   % counter-clockwise rotation
P.xpos        = Parameters(2,:);
P.ypos        = Parameters(3,:);
P.height      = Parameters(4,:);
P.width       = Parameters(5,:);
P.contrast    = Parameters(6,:);
P.time        = Parameters(7,:)*NumSubframes;

P.angleRad      = P.direction/180*pi; %rad

ifi = ScreenData.ifi;

% MAKE TEXTURE
usedTextures = {};
newTex       = 1;
index        = 1;
texture      = [];

for k = 1:numRuns
    
    if StimSettings(k).box4{2} && k==1
        % Generate bar image
        x = str2num(StimSettings(k).edit4{2});
        y = str2num(StimSettings(k).edit5{2});
        imRect(:,k) = [0 0 x y]';
        if ~StimSettings(k).box5{2}
            I = generateBarStimImage(x,y);
            critInput.images{k} = I(1,:);
        else
            I = generateBarStimImage(x,y,'horizontal');
            critInput.images{k} = I(:,1);
        end
        texture(end+1) = Screen('MakeTexture', ScreenData.wPtr, uint8(255*I));
        index = length(texture);
    else
        % Load image from file

        imPath        = StimSettings(k).path1{2};

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

            [I tmp alpha] = imread(imPath);
            if ~isempty(alpha)
                I(:,:,4) = alpha;
            end

            [y, x, tmp]   = size(I);
            imRect(:,k) = [0 0 x y]';

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

%custom functions
useOff = zeros(1, numRuns);
useX   = zeros(1, numRuns);
useY   = zeros(1, numRuns);

for k = 1:numRuns
    
    n=0;N=0;t=0;T=0;
    
    if StimSettings(k).box1{2} %use x function
        useOff(k) = 1;
        values = eval(StimSettings(k).edit1{2});
        if length(values)==1
            offset{k} = StimSettings(k).edit1{2};
        else
            repeats = ceil(P.time/length(values));
            list = repmat(values,repeats,1);
            offset{k} = cumsum(list(1:P.time));
        end
    else
        useOff(k) = 0;
        offset    = '1';
    end
    
    if StimSettings(k).box2{2} %use x function
        useX(k) = 1;
        values = eval(StimSettings(k).edit2{2});
        if length(values)==1
            xOffset{k} = StimSettings(k).edit2{2};
        else
            repeats = ceil(P.time/length(values));
            list = repmat(values,repeats,1);
            xOffset{k} = cumsum(list(1:P.time));
        end
    else
        useX(k) = 0;
        xOffset = '1';
    end

    if StimSettings(k).box3{2} %use y function
        useY(k) = 1;
        values = eval(StimSettings(k).edit3{2});
        if length(values)==1
            yOffset{k} = StimSettings(k).edit3{2};
        else
            repeats = ceil(P.time/length(values));
            list = repmat(values,repeats,1);
            yOffset{k} = cumsum(list(1:P.time));
        end
    else
        useY(k) = 0;
        yOffset = '1';
    end
end

%Export critical input
critInput.useOff = useOff;
critInput.useX   = useX;
critInput.useY   = useY;

critInput.offset  = offset;
critInput.xOffset = xOffset;
critInput.yOffset = yOffset;

critInput.angleRad   = P.angleRad;
critInput.direction  = P.direction;

critInput.rectAngled   = rectAngled;
critInput.imRect       = imRect;
critInput.position     = position;
critInput.texture      = texture;
critInput.textureIndex = textureIndex;

