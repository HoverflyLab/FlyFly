function [critInput] = rectTargetPrep(Parameters, ScreenData, StimSettings, NumSubframes)
%
% Prepares input parameters for rectTargetDraw

%--------------------------------------------------------------------------
% FlyFly v2
%
% Jonas Henriksson, 2010                                   info@flyfly.se
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
P.bright      = Parameters(7,:);

%how many fraction pixels target moves each frame
delta_x = cos(P.angle*pi/180);
delta_y = -sin(P.angle*pi/180);

critInput.RGB      = [P.bright; P.bright; P.bright];
critInput.pos      = [P.xpos - P.width/2; P.ypos - P.height/2; ...
    P.xpos + P.width/2; P.ypos + P.height/2];

critInput.deltaPos = ScreenData.ifi*...
    [P.velocity.*delta_x; P.velocity.*delta_y; ...
    P.velocity.*delta_x; P.velocity.*delta_y];
