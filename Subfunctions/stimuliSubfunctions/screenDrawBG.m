function screenDrawBG(wPtr, texture, imRect, rect, offset, position)
%function screenDrawBG(wPtr, texture, imRect, rect, offset, position)
%
%draws 'texture' to 'wPtr'. imRect is the rectangle surrounding the image
%and rect is the rectangle surrounding the screen to draw to. offset
%shifts the image in pixels.
%
%No flipping!

%--------------------------------------------------------------------------
% FlyFly v2
%
% Jonas Henriksson, 2010                                   info@flyfly.se
%--------------------------------------------------------------------------

imOffset = OffsetRect(imRect, -offset, 0);
clip     = ClipRect(imOffset, rect);
diff     = RectWidth(rect) - RectWidth(clip);

%First check if offset image does cover full screen or not. If it do cover
%the full screen the width of clip will be equal to the width of rect
if diff == 0  
    
    srcRect = ([offset, imRect(2), rect(3)+offset, imRect(4)]);
    dstRect = ([0,      0,         rect(3),        imRect(4)]) + position;
    
    Screen('DrawTexture', wPtr, texture, srcRect, dstRect);    
    
else    
    if diff < rect(3)
        
        if offset > 0 %moving left
            srcRectR = ([imRect(1)+offset rect(2) imRect(3) rect(4)]);
            srcRectL = ([imRect(1) rect(2) imRect(1)+diff rect(4)]);
            
            dstRectL = (clip) + position;
            dstRectR = ([rect(3)-diff imRect(2) rect(3) imRect(4)]) + position;
        else          %moving right
            srcRectL = ([imRect(1) rect(2) imRect(1)+rect(3)-diff rect(4)]);
            srcRectR = ([imRect(3)+offset rect(2) imRect(3) rect(4)]);
            
            dstRectL = ([rect(1) imRect(2) rect(1)+diff imRect(4)]) + position;
            dstRectR = (clip) + position;
        end
        
        Screen('DrawTexture', wPtr, texture, srcRectL, dstRectR); %ok?
        Screen('DrawTexture', wPtr, texture, srcRectR, dstRectL);
        
    else %use from right
        srcRect = ([imRect(3)+offset rect(2) imRect(3)+offset+rect(3) rect(4)]);
        dstRect = ([0 0 rect(3) imRect(4)]) + position;
        
        Screen('DrawTexture', wPtr, texture, srcRect, dstRect);
    end
end

