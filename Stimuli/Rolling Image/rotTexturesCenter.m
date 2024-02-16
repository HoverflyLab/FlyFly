function textureRects = rotTexturesCenter(textureRects, angle)
%FUNCTION TEXTURERECTS = ROTTEXTURES(TEXTURERECTS, ANGLE)
%
%Rotates the dstRect(s) in textureRects by angle degrees around their
%center point.

%--------------------------------------------------------------------------
% FlyFly v2
%
% Jonas Henriksson, 2010                                   info@flyfly.se
%--------------------------------------------------------------------------


[tmp, C, tmp] = size(textureRects);

if C == 1
    
    dstRect = textureRects{2};
    
    offset = rect2center(dstRect);    
    dstRect = dstRect - offset; %set origin in center of dstRect
    
    [dstRect(1) dstRect(2)] = rotXY(dstRect(1), dstRect(2), angle);
    [dstRect(3) dstRect(4)] = rotXY(dstRect(3), dstRect(4), angle);
    
    dstRect = dstRect + offset;
    textureRects{2} = dstRect;
else
    
    dstRectL = textureRects{2, 1};
    dstRectR = textureRects{2, 2};
    
    %L
    %offsetL = rect2center(dstRectL);   
    offsetL  = [ [dstRectL(1)+dstRectL(3) dstRectL(2)+dstRectL(4)]/2 [dstRectL(1)+dstRectL(3) dstRectL(2)+dstRectL(4)]/2 ];
    
    dstRectL = dstRectL - offsetL; %set origin in center of dstRect
    
    [dstRectL(1) dstRectL(2)] = rotateXY(dstRectL(1), dstRectL(2), angle);
    [dstRectL(3) dstRectL(4)] = rotateXY(dstRectL(3), dstRectL(4), angle);
    
    dstRectL = dstRectL + offsetL;
    textureRects{2,1} = dstRectL;

    %R
    %offsetR = rect2center(dstRectR);
    offsetR  = [ [dstRectR(1)+dstRectR(3) dstRectR(2)+dstRectR(4)]/2 [dstRectR(1)+dstRectR(3) dstRectR(2)+dstRectR(4)]/2 ];
    
    dstRectR = dstRectR - offsetR; %set origin in center of dstRect
    
    [dstRectR(1) dstRectR(2)] = rotateXY(dstRectR(1), dstRectR(2), angle);
    [dstRectR(3) dstRectR(4)] = rotateXY(dstRectR(3), dstRectR(4), angle);
    
    dstRectR = dstRectR + offsetR;
    textureRects{2,2} = dstRectR;
    
end

function [x1,y] = rotateXY(x, y, angle)
% function [x1,y1] = rotateXY(x, y, angle)
% (local copy of rotXY() .. appears to be faster)
% rotates coordinate (x, y) angle degrees around origin

x1 = x*cos(angle) - y*sin(angle);
y  = y*cos(angle) + x*sin(angle);