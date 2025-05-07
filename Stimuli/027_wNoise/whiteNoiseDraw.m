function P = whiteNoiseDraw(wPtr, n, k, ifi, P)
%
%Draw a patch of white noise to wPtr
%

%--------------------------------------------------------------------------
% FlyFly v2
%
% Jonas Henriksson, 2010                                   info@flyfly.se
%--------------------------------------------------------------------------

srcRect = [];
dstRect = P.dstRect(:,k);

offset = [0 0 0 0];

if P.useX(k)
    offset([1 3]) = eval(P.xOffset{k});
end

if P.useY(k)
    offset([2 4]) = eval(P.yOffset{k});
end

dstRect = round(dstRect + offset');

%I = (50*randn(dstRect(3)-dstRect(1), dstRect(4)-dstRect(2)) + 128);

I = (255*rand(round((dstRect(4)-dstRect(2))/P.pixels(k)), round((dstRect(3)-dstRect(1))/P.pixels(k))));
I = P.contrast(k)*(I-127) + 127;

tex = Screen('MakeTexture', wPtr, I);
Screen('DrawTexture', wPtr, tex, [], dstRect, [], 0);
Screen('Close', tex);