function Parameters = rollingImageDraw(wPtr, n, k, ifi, Parameters)
%function Parameters = rollingImageDraw(wPtr, n, k, t, Parameters)
%
% Draws an image that moves across the screen. Image may be angled and have
% custom contrast. The image is drawn "wrapped", meaning that when an a
% side exits the screen it will enter from the other side.

%--------------------------------------------------------------------------
% FlyFly v2
%
% Jonas Henriksson, 2010                                   info@flyfly.se
%--------------------------------------------------------------------------


if Parameters.keepOffset(k)
    offset = Parameters.out + Parameters.speedFrame(k);
else
    offset = Parameters.offset(k)+Parameters.speedFrame(k)*n;    
end

% Change to not have movement begin until the second frame of a trial
% if Parameters.keepOffset(k)
%     offset = Parameters.out;
% else
%     offset = Parameters.offset(k)+Parameters.speedFrame(k)*(n-1);
% end
Parameters.out = offset;

textureRects = splitTexture(Parameters.imRect(:,Parameters.textureIndex(k)), Parameters.rectAngled(:,k)', offset);

textureRects = rotTextures(textureRects, Parameters.angleRad(k));
textureRects = rotTexturesCenter(textureRects, -Parameters.angleRad(k));

drawTextures(wPtr, Parameters.texture(Parameters.textureIndex(k)), textureRects, Parameters.direction(k), Parameters.position(k,:));
%drawTextures(wPtr, Parameters.texture(Parameters.textureIndex(k)), textureRects, [], Parameters.position(k,:));
