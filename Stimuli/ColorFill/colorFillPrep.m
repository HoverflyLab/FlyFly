function [critInput] = colorFillPrep(Parameters, ScreenData, StimSettings, NumSubframes)
%
% Prepares input parameters for colorFillDraw

%--------------------------------------------------------------------------
% FlyFly v2
%
% Jonas Henriksson, 2010                            info@flyfly.se
%--------------------------------------------------------------------------

if nargin<4
    NumSubframes = 1;
end

critInput.RGB = [Parameters(1,:) Parameters(1,:) Parameters(1,:)];