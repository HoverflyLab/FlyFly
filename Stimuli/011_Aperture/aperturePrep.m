function critInput = aperturePrep(Parameters, ScreenData, StimSettings, NumSubframes)
%
% Prepares input parameters for apertureDraw

%--------------------------------------------------------------------------
% FlyFly v2
%
% Jonas Henriksson, 2010                                     info@flyfly.se
%--------------------------------------------------------------------------

if nargin<4
    NumSubframes = 1;
end

[R C] = size(Parameters);

P.gamma1      = Parameters(1,:);
P.gamma2      = Parameters(2,:);
P.height      = Parameters(3,:);
P.width       = Parameters(4,:);
P.xpos        = Parameters(5,:);
P.ypos        = Parameters(6,:);


aperture = zeros(1, C);

for k = 1:C
    
    objRect = [P.xpos(k)-P.width(k)/2; P.ypos(k)-P.height(k)/2;
        P.xpos(k)+P.width(k)/2; P.ypos(k)+P.height(k)/2];
    
    aperture(k) = Screen('OpenOffscreenwindow', ScreenData.wPtr, [0 0 0 P.gamma1(k)]);
    
    if StimSettings(k).box1{2} == 1
        Screen('FillRect', aperture(k), [255 255 255 P.gamma2(k)], objRect);
    else
        Screen('FillOval', aperture(k), [255 255 255 P.gamma2(k)], objRect);
    end
    
end

critInput.aperture = aperture;