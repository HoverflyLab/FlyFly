function [x1 y1 x2 y2] = setFlyPos(ScreenSettings)
% function [x1 y1 x2 y2] = setFlyPos(ScreenSettings)
%
% lets the user mark two positions on the screen (x1, y1) and (x2, y2) and
% returns them.

%--------------------------------------------------------------------------
% FlyFly v2
%
% Jonas Henriksson, 2010                                   info@flyfly.se
%--------------------------------------------------------------------------

wPtr = ScreenSettings.wPtr;
rect = ScreenSettings.rect;
ifi  = ScreenSettings.ifi;

screenRes = get(0, 'ScreenSize');

numScreens = max(Screen('Screens'));

flyPos = 0;
oldButtons = [0 0 0];
numClicks = 0;
go = 1;

disp(' ');
disp('Welcome to the position calibration tool with Mr. Fly');
disp('Put marker in height with Mr. Fly');

vbl = Screen('Flip', wPtr);

while go
    
    [mX,mY, buttons] = GetMouse(0);
    
%Uncomment this if secondary screen is on the right of main screen.    
%640px is the width of stimuli screen. 
%     if numScreens > 0
%         %Dual screen set up
%         if mX > (screenRes(3) - 640)
%             HideCursor;
%         end
%         
%         %Assume screen with width 640px to right of normal screen
%         mX = mX - screenRes(3) + 640;
%     end
    
    if buttons(1) == 1 && oldButtons(1) == 0 %left click
        numClicks = numClicks+1;
        if numClicks == 1
            flyPos = [mX, mY];
            disp('Put marker where Mr. Fly is looking')
        elseif numClicks == 2
            flyMidline = [mX, mY];
            disp('Press left button to confirm, right button to restart');
        else
            disp('Mr. Fly says "Thank You!"')
            break;
        end
    elseif buttons(3) == 1 && oldButtons(3) == 0 %right click
        numClicks = 0;
    end
    
    if numClicks == 0 %case 1
        
        Screen('DrawLine', wPtr, [0 0 0], 0, mY, rect(3), mY); %horizontal
        Screen('DrawLine', wPtr, [0 0 0], mX, 0, mX, rect(4)); %vertical
        
    elseif numClicks == 1 %case 2
        Screen('DrawLine', wPtr, [200 200 200], 0, flyPos(2), rect(3), flyPos(2));
        Screen('DrawLine', wPtr, [200 200 200], flyPos(1), 0, flyPos(1), rect(4));
        Screen('FillOval', wPtr, [200 200 200], [flyPos(1)-3  flyPos(2)-3  flyPos(1)+3  flyPos(2)+3]); 
        
        Screen('DrawLine', wPtr, [0 0 0], 0, mY, rect(3), mY); %horizontal
        Screen('DrawLine', wPtr, [0 0 0], mX, 0, mX, rect(4)); %vertical
    elseif numClicks == 2 %case 3
        Screen('DrawLine', wPtr, [200 200 200], 0, flyPos(2), rect(3), flyPos(2));
        Screen('DrawLine', wPtr, [200 200 200], flyPos(1), 0, flyPos(1), rect(4));
        Screen('FillOval', wPtr, [200 200 200], [flyPos(1)-3  flyPos(2)-3  flyPos(1)+3  flyPos(2)+3]); 
        
        Screen('DrawLine', wPtr, [200 200 200], 0, flyMidline(2), rect(3), flyMidline(2));
        Screen('DrawLine', wPtr, [200 200 200], flyMidline(1), 0, flyMidline(1), rect(4));
        Screen('FillOval', wPtr, [200 200 200], [flyMidline(1)-3  flyMidline(2)-3  flyMidline(1)+3  flyMidline(2)+3]); 
    end
    
    Screen('Flip', wPtr, vbl+0.7*ifi);
    oldButtons = buttons;
end

disp(' ');
disp(['Fly height: ' num2str(flyPos(1)) 'x, ' num2str(flyPos(2)) 'y (px)']);
disp(['Fly eye focus: ' num2str(flyMidline(1)) 'x, ' num2str(flyMidline(2)) 'y (px)']);

x1 = flyPos(1);
y1 = flyPos(2);
x2 = flyMidline(1);
y2 = flyMidline(2);