function texture = splitTexture(imRect, rect, offset)
%function splitTexture(imRect, rect, offset)
%
%return a cell array with the srcRect and dstrRct needed to draw a texture
%bounded by imRect to a screen bounded by rect. offset is a shift in
%pixels.
%Depending on the image size and offset one or two srcRect/dstRect is
%needed.
%

%--------------------------------------------------------------------------
% FlyFly v2
%
% Jonas Henriksson, 2010                                   info@flyfly.se
%--------------------------------------------------------------------------

offset  = mod(offset, imRect(3));
imOffset  = imRect' - [offset 0 offset 0]; %same as OffsetRect(imRect', -offset, 0) but faster

%clip = ClipRect(imOffset, rect);
clip = [0 0 0 0];
clip(2) = max( imOffset(2),rect(2) );
clip(4) = min( imOffset(4),rect(4) );
clip(1) = max( imOffset(1),rect(1) );
clip(3) = min( imOffset(3),rect(3) );

if (clip(3) - clip(1)) < 0 || (clip(4) - clip(2)) < 0
	clip = [0 0 0 0];
end

diff     = (rect(3) - rect(1)) - (clip(3) - clip(1)); % = width(rect) - width(clip)

%First check if offset image does cover full screen or not. If it do cover
%the full screen the width of clip will be equal to the width of rect
if diff == 0  
    
    srcRect = ([offset, imRect(2), rect(3)+offset, rect(4)]);
    dstRect = ([0,      0,         rect(3),        rect(4)]);
    
    texture = {srcRect ; dstRect};    
else    
    if diff < rect(3)
        
        if offset > 0 %moving left
            srcRectR = ([imRect(1)+offset rect(2) imRect(3) rect(4)]);
            srcRectL = ([imRect(1) rect(2) imRect(1)+diff rect(4)]);
            
            dstRectL = (clip);
            dstRectR = ([rect(3)-diff imRect(2) rect(3) rect(4)]);
        else          %moving right
            srcRectL = ([imRect(1) rect(2) imRect(1)+rect(3)-diff rect(4)]);
            srcRectR = ([imRect(3)+offset rect(2) imRect(3) rect(4)]);
            
            dstRectL = ([rect(1) imRect(2) rect(1)+diff rect(4)]);
            dstRectR = (clip);
        end
        
        texture = {srcRectL srcRectR; dstRectL dstRectR};
        
    else %use from right
        srcRect = ([imRect(3)+offset rect(2) imRect(3)+offset+rect(3) rect(4)]);
        dstRect = ([0 0 rect(3) rect(4)]);
        
        texture = {srcRect ; dstRect};
    end
end

