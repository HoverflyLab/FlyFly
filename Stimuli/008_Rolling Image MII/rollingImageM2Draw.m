function P = rollingImageM2Draw(wPtr, n, k, ifi, P)
%function P = rollingImageDraw(wPtr, n, k, t, P)
%
% Draws an image that moves across the screen. Image may be angled and have
% custom contrast. The image is drawn "wrapped", meaning that when an a
% side exits the screen it will enter from the other side.

%--------------------------------------------------------------------------
% FlyFly v2
%
% Jonas Henriksson, 2010                                   info@flyfly.se
%--------------------------------------------------------------------------

pos = P.position(k,:);

if P.useX(k)
    if isnumeric(P.xOffset{k})
        xPos = P.xOffset{k}(n);
    else
        xPos = eval(P.xOffset{k});
    end
    pos = pos + [xPos 0 xPos 0];
end

if P.useY(k)
    if isnumeric(P.yOffset{k})
        yPos = P.yOffset{k}(n);
    else
        yPos = eval(P.yOffset{k});
    end
    pos = pos + [0 yPos 0 yPos];
end

if P.useOff(k)
    if isnumeric(P.offset{k})
        offset = P.offset{k}(n);
    else
        offset = eval(P.offset{k});
    end
else
    offset = 0;
end

textureRects = splitTexture(P.imRect(:,P.textureIndex(k)), P.rectAngled(:,k)', offset);
textureRects = rotTextures(textureRects, P.angleRad(k));
textureRects = rotTexturesCenter(textureRects, -P.angleRad(k));

drawTextures(wPtr, P.texture(P.textureIndex(k)), textureRects, P.direction(k), pos);

