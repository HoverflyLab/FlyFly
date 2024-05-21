function screenDrawBG(wPtr, texture, imRect, partial, offset, position)
%function screenDrawBG(wPtr, texture, imRect, partial, offset, position)
%
%draws 'texture' to 'wPtr'. imRect is the rectangle surrounding the image
%and partial is the rectangle surrounding the screen to draw to. offset
%shifts the image in pixels.
%
%No flipping!

%--------------------------------------------------------------------------
% FlyFly v2
%
% Jonas Henriksson, 2010                                   info@flyfly.se
%--------------------------------------------------------------------------

imOffset = OffsetRect(imRect, -offset, 0);
clip     = ClipRect(imOffset, partial);
diff     = RectWidth(partial) - RectWidth(clip);

%First check if offset image does cover full screen or not. If it do cover
%the full screen the width of clip will be equal to the width of partial
if diff == 0  
    
    srcRect = ([offset, imRect(2), partial(3)+offset, imRect(4)]);
    dstRect = ([0,      0,         partial(3),        imRect(4)]) + position;
    
    Screen('DrawTexture', wPtr, texture, srcRect, dstRect);    
    
else    
    if diff < partial(3)
        
        if offset > 0 %moving left
            srcRectR = ([imRect(1)+offset partial(2) imRect(3) partial(4)]);
            srcRectL = ([imRect(1) partial(2) imRect(1)+diff partial(4)]);
            
            dstRectL = (clip) + position;
            dstRectR = ([partial(3)-diff imRect(2) partial(3) imRect(4)]) + position;
        else          %moving right
            srcRectL = ([imRect(1) partial(2) imRect(1)+partial(3)-diff partial(4)]);
            srcRectR = ([imRect(3)+offset partial(2) imRect(3) partial(4)]);
            
            dstRectL = ([partial(1) imRect(2) partial(1)+diff imRect(4)]) + position;
            dstRectR = (clip) + position;
        end
        
        Screen('DrawTexture', wPtr, texture, srcRectL, dstRectR); %ok?
        Screen('DrawTexture', wPtr, texture, srcRectR, dstRectL);
        
    else %use from right
        srcRect = ([imRect(3)+offset partial(2) imRect(3)+offset+partial(3) partial(4)]);
        dstRect = ([0 0 partial(3) imRect(4)]) + position;
        
        Screen('DrawTexture', wPtr, texture, srcRect, dstRect);
    end
end

