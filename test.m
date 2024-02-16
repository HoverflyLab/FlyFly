
v = -10000:200:10000;
xy = [v; v];
sz = 150*ones(1, length(v));
clrs = repmat([255;0;0], 1, length(v));
[windowPtr,rect]=Screen('OpenWindow',0,[], [100 100 200 200]);
rect = [0 0 10000 10000];
ptr = Screen('OpenOffScreenWindow', -1, [], rect);
Screen('DrawDots', ptr, xy, sz, clrs,[],1);
img = Screen('GetImage', ptr);
imwrite(img, 'kaboom.png');

figure; imshow(img);

Screen('Close', windowPtr);