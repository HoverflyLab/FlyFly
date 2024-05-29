function P = gridDraw(wPtr, n, k, ifi, P)%
%
%Draws a text string on the scren
%

%--------------------------------------------------------------------------
% FlyFly v2
%
% Jonas Henriksson, 2010                                   info@flyfly.se
%--------------------------------------------------------------------------

Screen('TextSize', wPtr, P.textSize(k));
Screen('DrawText', wPtr, P.textString{k}, P.xpos(k), P.ypos(k));