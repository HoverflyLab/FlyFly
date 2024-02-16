function critInput = gridPrep(Parameters, ScreenData, StimSettings, NumSubframes)
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

%objRect = CenterRect([P.xpos(k) P.ypos(k) P.xpos(k)+P.height(k) P.ypos(k)+P.width(k)], ScreenData.rect);

texture = Screen('OpenOffscreenwindow', ScreenData.wPtr, [0 0 0 0]);
rect    = ScreenData.rect;

k = 0;
while k < max(rect(4), rect(3)) %bright lines
    Screen('DrawLine', texture, [0 0 0 20], 0, k, rect(3), k);
    Screen('DrawLine', texture, [0 0 0 20], k, 0, k, rect(4));
    k = k + 10;
end

k = 0;
while k < max(rect(4), rect(3)) %bright lines
    Screen('DrawLine', texture, [0 0 0 40], 0, k, rect(3), k);
    Screen('DrawLine', texture, [0 0 0 40], k, 0, k, rect(4));
    k = k + 50;
end

k = 0;
while k < max(rect(4), rect(3)) %dark lines
    Screen('DrawLine', texture, [0 0 0], 0, k, rect(3), k);
    Screen('DrawLine', texture, [0 0 0], k, 0, k, rect(4));
    k = k + 100;
end

y = 0;
Screen('TextSize', texture, 7);
while y < rect(4) %rows
    
    x = 0;
    while x < rect(3) %cols
        Screen('DrawText', texture, ['(' num2str(x) ',' num2str(y) ')'], x, y);
        x = x + 100;
    end
    y = y + 100;
end

critInput.texture = texture;