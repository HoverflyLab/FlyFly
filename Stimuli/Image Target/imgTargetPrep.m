function [critInput] = imgTargetPrep(Parameters, ScreenData, StimSettings, NumSubframes)
%
% Prepares input parameters for rectTargetDraw

%--------------------------------------------------------------------------
% FlyFly v3.1
%
% Richard Leibbrandt 2017    
%--------------------------------------------------------------------------

if nargin<4
    NumSubframes = 1;
end


P.height      = Parameters(1,:);
P.width       = Parameters(2,:);
P.xpos        = Parameters(3,:);
P.ypos        = Parameters(4,:);
P.velocity    = Parameters(5,:)/NumSubframes;
P.angle       = Parameters(6,:);
P.contrast  = Parameters(7,:);

numRuns = size(Parameters,2);

for k = 1:numRuns
    imagePath        = StimSettings(k).path1{2};
    [I, ~, alpha] = imread(imagePath);
    I = double(I);
    I = P.contrast(k)*(I-127) + 127;
    if ~isempty(alpha)
        I(:,:,4) = alpha;
    end

    
    texturePtr(k) = Screen('MakeTexture', ScreenData.wPtr, I);
    aratio = size(I,1)/size(I,2);
    P.srcRect = [0; 0; size(I,1); size(I,2)]
    if P.width(k) == 0
        if P.height(k) == 0
            P.height(k) = size(I, 1);
            P.width(k) = size(I, 2);
        else
            P.width(k) = P.height(k) / aratio;
        end
    else
        if P.height(k) == 0
            P.height(k) = P.width(k) * aratio;
        else
            P.height(k) = min(P.height(k), P.width(k) * aratio);
            P.width(k) = P.height(k) / aratio;
        end
    end;
end

% the x and y components of the movement vector
delta_x = cos(P.angle*pi/180);
delta_y = -sin(P.angle*pi/180);

critInput.RGB      = [0; 0; 0];

critInput.pos      = [P.xpos - P.width/2; P.ypos - P.height/2; ...
    P.xpos + P.width/2; P.ypos + P.height/2];

critInput.deltaPos = ScreenData.ifi*...
    [P.velocity.*delta_x; P.velocity.*delta_y; ...
    P.velocity.*delta_x; P.velocity.*delta_y];

critInput.srcRect = P.srcRect;
critInput.texturePtr      = texturePtr;

