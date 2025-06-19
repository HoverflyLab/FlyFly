function Parameters = imgTargetDraw(wPtr, n, k, ifi, Parameters)

%--------------------------------------------------------------------------
% FlyFly v3.1
%
% Richard Leibbrandt 2017                               
%--------------------------------------------------------------------------


angle = 0;
dstRect = Parameters.pos(:,k) + (n-1)*Parameters.deltaPos(:,k);
Screen('DrawTexture', wPtr, Parameters.texturePtr(k), [], dstRect, angle);
 
 