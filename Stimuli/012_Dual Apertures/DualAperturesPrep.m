function critInput = dualAperturePrep(Parameters, ScreenData, StimSettings, NumSubframes)
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
P.bright1     = Parameters(2,:);
P.gamma2      = Parameters(3,:);
P.bright2     = Parameters(4,:);
P.width       = Parameters(5,:);
P.height      = Parameters(6,:);
P.xpos        = Parameters(7,:);
P.ypos        = Parameters(8,:);
P.width2      = Parameters(9,:);
P.height2     = Parameters(10,:);
P.xpos2       = Parameters(11,:);
P.ypos2       = Parameters(12,:);

aperture = zeros(1, C);


%Fly position should be the basis for position
%THIS MIGHT BE FLY HEIGHT AND NOT WHERE IT IS LOOKING
center = ScreenData.flyPos(1:2);



for k = 1:C
    
    %Midpoints for apertures calculated from fly pos
    mid1=[center(1)+P.xpos(k) center(2)+P.ypos(k)];
    mid2=[center(1)+P.xpos2(k) center(2)+P.ypos2(k)];
    
    
    objRect = [mid1(1)-P.width(k)/2     mid1(2)-P.height(k)/2   mid1(1)+ P.width(k)/2    mid1(2)+P.height(k)/2];
    objRect2 =[mid2(1)-P.width2(k)/2    mid2(2)-P.height2(k)/2  mid2(1)+P.width2(k)/2   mid2(2)+P.height2(k)/2];

    aperture(k) = Screen('OpenOffscreenwindow', ScreenData.wPtr, [P.bright1(k) P.bright1(k) P.bright1(k) P.gamma1(k)]);
    
    if StimSettings(k).box1{2} == 1
        Screen('FillRect', aperture(k), [P.bright2(k) P.bright2(k) P.bright2(k) P.gamma2(k)], objRect);
    else
        %red
        Screen('FillOval', aperture(k), [P.bright2(k) P.bright2(k) P.bright2(k) P.gamma2(k)], objRect);
    end
    
    if StimSettings(k).box2{2} == 1
        Screen('FillRect', aperture(k), [P.bright2(k) P.bright2(k) P.bright2(k) P.gamma2(k)], objRect2);
    else
        %yellow
        Screen('FillOval', aperture(k), [P.bright2(k) P.bright2(k) P.bright2(k) P.gamma2(k)], objRect2);
    end
    
end

critInput.aperture = aperture;