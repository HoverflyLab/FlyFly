function P = mouseTargetDraw(wPtr, n, k, ifi, P)
%
%Draw a rect in wPtr to current mouse position
%

%--------------------------------------------------------------------------
% FlyFly v2
%
% Jonas Henriksson, 2010                            info@flyfly.se
%--------------------------------------------------------------------------


[mX,mY, buttons] = GetMouse(0);

[keyIsDown, seconds, keyCode] = KbCheck;
keyIn = find(keyCode);


%MAC VERSION (79-82) || PC VERSION (37-40)
if ~isempty(keyIn)
    
    if any(keyIn == 80) || any(keyIn == 37) %left
        P.width(k) = (P.width(k) - 1)*(P.width(k) > 1) + (P.width(k) == 1);
    end
    if any(keyIn == 82)  || any(keyIn == 38)  %up
        P.height(k) = P.height(k) +1;
    end
    if any(keyIn == 79)  || any(keyIn == 39) %right
        P.width(k) = P.width(k) +1;
    end
    if any(keyIn == 81) || any(keyIn == 40) %down
        P.height(k) = (P.height(k) - 1)*(P.height(k) > 1) + (P.height(k) == 1);
    end
end

if buttons(3) == 1 && P.oldButtonR == 0
    P.drawAngle = P.drawAngle + 45/2;
    P.drawAngle = mod(P.drawAngle, 360);
elseif buttons(1) == 1 && P.oldButtonL == 0
    %break;
    disp('let me out!')
end

dstRect = [mX-P.width(k)/2 mY-P.height(k)/2 mX+P.width(k)/2 mY+P.height(k)/2];

Screen('DrawTexture', wPtr, P.texture(k), P.srcRect{k}, dstRect, P.drawAngle, 1); %draw target

P.oldButtonR = buttons(3);
P.oldButtonL = buttons(1);