function drawTextures(wPtr, texture, textureRects, angle, offsetY)
%function drawTextures(wPtr, texture, textureRects, angle, offsetY)
%
% draws the texture(s) to screen

%--------------------------------------------------------------------------
% FlyFly v2
%
% Jonas Henriksson, 2010                                   info@flyfly.se
%--------------------------------------------------------------------------

[tmp, C, tmp] = size(textureRects);

if C == 1
    
    srcRect = textureRects{1};
    dstRect = textureRects{2} + offsetY;
    
    Screen('DrawTexture', wPtr, texture, srcRect, dstRect, angle);
else
    
    srcRectL = textureRects{1, 1};
    dstRectL = textureRects{2, 1} + offsetY;
    srcRectR = textureRects{1, 2};
    dstRectR = textureRects{2, 2} + offsetY;
    
%     Screen('DrawTexture', wPtr, texture, srcRectL, dstRectR, angle);
%     Screen('DrawTexture', wPtr, texture, srcRectR, dstRectL, angle);
     Screen('DrawTextures', wPtr, texture, [srcRectL' srcRectR'] , [dstRectR' dstRectL'], angle);
end