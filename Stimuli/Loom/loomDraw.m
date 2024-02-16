function Parameters = loomDraw(wPtr, n, k, ifi, Parameters)

%--------------------------------------------------------------------------
% FlyFly v3.1
%
% Richard Leibbrandt 2017                               
%--------------------------------------------------------------------------


angle = 0;
texture = Parameters.texturePtr{k}{n};
dstRect = Parameters.pos{k}{n};
Screen('DrawTexture', wPtr, texture, [], dstRect, angle);
 
 