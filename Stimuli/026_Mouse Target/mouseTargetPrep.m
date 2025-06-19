function critInput = mouseTargetPrep(Parameters, ScreenData, StimSettings, NumSubframes)
%
% Prepares input parameters for mouseTargetDraw

%--------------------------------------------------------------------------
% FlyFly v2
%
% Jonas Henriksson, 2010                            info@flyfly.se
%--------------------------------------------------------------------------

if nargin<4
    NumSubframes = 1;
end

[tmp, numRuns] = size(Parameters); %R should equal 9

P.width     = Parameters(1,:);
P.height    = Parameters(2,:);
P.bright    = Parameters(3,:);


for k = 1:numRuns
    I          = P.bright(k)*ones(P.height(k), P.width(k));
    texture(k)  = Screen('MakeTexture', ScreenData.wPtr, I);
    srcRect{k} = [0, 0, P.width(k), P.height(k)];
end

dstRect = [0 0 0 0];

critInput.width  = P.width;
critInput.height = P.height;

critInput.oldButtonR = 0;
critInput.oldButtonL = 0;
critInput.drawAngle  = 0;

critInput.texture = texture;
critInput.srcRect = srcRect;



