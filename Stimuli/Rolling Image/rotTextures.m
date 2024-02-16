function textureRects = rotTextures(textureRects, angle)
%FUNCTION TEXTURERECTS = ROTTEXTURES(TEXTURERECTS, ANGLE)
%
%Rotates the dstRect(s) in 'textureRects' by 'angle' degrees relative to
%the origin (top left corner).

%--------------------------------------------------------------------------
% FlyFly v2
%
% Jonas Henriksson, 2010                                   info@flyfly.se
%--------------------------------------------------------------------------

[tmp, C, tmp] = size(textureRects);

if C == 1
    
    dstRect = textureRects{2};
    
    x1 = dstRect(1);
    y1 = dstRect(2);
    x2 = dstRect(3);
    y2 = dstRect(4);
    
    if angle ~= 0
        %[x3, y3] = rotateXY(x2, 0, angle);
        [x1, y1] = rotateXY(x1, y1, angle);
        [x2, y2] = rotateXY(x2, y2, angle);
    end
    
    dstRect = [x1 y1 x2 y2];
    textureRects{2} = dstRect;
    
else
    
    dstRectL = textureRects{2, 1};
    dstRectR = textureRects{2, 2};
    
    %L
    x11 = dstRectL(1);
    y11 = dstRectL(2);
    x21 = dstRectL(3);
    y21 = dstRectL(4);
    
    %R
    x12 = dstRectR(1);
    y12 = dstRectR(2);
    x22 = dstRectR(3);
    y22 = dstRectR(4);
    
    if angle ~= 0
        [x11, y11] = rotateXY(x11, y11, angle);
        [x21, y21] = rotateXY(x21, y21, angle);
        
        [x12, y12] = rotateXY(x12, y12, angle);
        [x22, y22] = rotateXY(x22, y22, angle);
    end
    
    textureRects{2,1} = [x11 y11 x21 y21];
    textureRects{2,2} = [x12 y12 x22 y22];
end

function [x1,y] = rotateXY(x, y, angle)
% function [x1,y1] = rotateXY(x, y, angle)
% (local copy of rotXY() .. appears to be faster)
% rotates coordinate (x, y) angle degrees around origin

x1 = x*cos(angle) - y*sin(angle);
y  = y*cos(angle) + x*sin(angle);