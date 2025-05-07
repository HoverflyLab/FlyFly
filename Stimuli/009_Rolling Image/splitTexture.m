function texture = splitTexture(imRect, partial, offset)
%function splitTexture(imRect, partial, offset)
%
%return a cell array with the srcRect and dstrRct needed to draw a texture
%bounded by imRect to a screen bounded by partial. offset is a shift in
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

%clip = ClipRect(imOffset, partial);
clip = [0 0 0 0];
clip(2) = max( imOffset(2),partial(2) );
clip(4) = min( imOffset(4),partial(4) );
clip(1) = max( imOffset(1),partial(1) );
clip(3) = min( imOffset(3),partial(3) );

if (clip(3) - clip(1)) < 0 || (clip(4) - clip(2)) < 0
	clip = [0 0 0 0];
end

diff     = (partial(3) - partial(1)) - (clip(3) - clip(1)); % = width(partial) - width(clip)

%First check if offset image does cover full screen or not. If it do cover
%the full screen the width of clip will be equal to the width of partial
if diff == 0  
    
    srcRect = ([offset, imRect(2), partial(3)+offset, partial(4)]);
    dstRect = ([0,      0,         partial(3),        partial(4)]);
    
    texture = {srcRect ; dstRect};    
else    
    if diff < partial(3)
        
        if offset > 0 %moving left
            srcRectR = ([imRect(1)+offset partial(2) imRect(3) partial(4)]);
            srcRectL = ([imRect(1) partial(2) imRect(1)+diff partial(4)]);
            
            dstRectL = (clip);
            dstRectR = ([partial(3)-diff imRect(2) partial(3) partial(4)]);
        else          %moving right
            srcRectL = ([imRect(1) partial(2) imRect(1)+partial(3)-diff partial(4)]);
            srcRectR = ([imRect(3)+offset partial(2) imRect(3) partial(4)]);
            
            dstRectL = ([partial(1) imRect(2) partial(1)+diff partial(4)]);
            dstRectR = (clip);
        end
        
        texture = {srcRectL srcRectR; dstRectL dstRectR};
        
    else %use from right
        srcRect = ([imRect(3)+offset partial(2) imRect(3)+offset+partial(3) partial(4)]);
        dstRect = ([0 0 partial(3) partial(4)]);
        
        texture = {srcRect ; dstRect};
    end
end

