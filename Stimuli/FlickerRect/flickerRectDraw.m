function Parameters = flickerRectDraw(wPtr, n, k, ifi, Parameters)
%Parameters: RGB1, RGB2, POSITION
%Draw a flickering rect in wPtr to position
%

%--------------------------------------------------------------------------
% FlyFly v2
%
% Jonas Henriksson, 2010                            info@flyfly.se
%--------------------------------------------------------------------------

tmpMod = mod(n-1, 2*Parameters.nFrame(k)); % [0, 2*nFrame-1]

if tmpMod < Parameters.nFrame(k)
    RGB = Parameters.RGB1(:,k);
else
    RGB = Parameters.RGB2(:,k);
end

offset = [0 0 0 0];

if Parameters.useX(k)
    xOffset = eval(Parameters.xOffset{k});
    offset([1 3]) = [xOffset xOffset];
end

if Parameters.useY(k)
    yOffset = eval(Parameters.yOffset{k});
    offset([2 4]) = [yOffset yOffset];
end

Screen('FillRect', wPtr, RGB , Parameters.pos(:,k)+offset');