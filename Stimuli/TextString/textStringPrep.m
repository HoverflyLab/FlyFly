function P = textStringPrep(Parameters, ScreenData, StimSettings, NumSubframes)
%
% Prepares input parameters for textStringDraw

%--------------------------------------------------------------------------
% FlyFly v2
%
% Jonas Henriksson, 2010                                   info@flyfly.se
%--------------------------------------------------------------------------

if nargin<4
    NumSubframes = 1;
end

[R C] = size(Parameters);

for k = 1:C
    P.textString{k} = StimSettings(k).edit1{2};
end

P.textSize   = Parameters(1,:);
P.xpos       = Parameters(2,:);
P.ypos       = Parameters(3,:);

