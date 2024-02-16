function output = background2DPrep(Parameters, ScreenData, StimSettings, NumSubframes)

%--------------------------------------------------------------------------
% FlyFly v3.1
%
% Richard Leibbrandt, 2017
%--------------------------------------------------------------------------

if nargin<4
    NumSubframes = 1;
end

[~, numRuns] = size(Parameters);

SIZE =1000;
DEPTH = 200;
WIDTH = 8600;
HEIGHT = 8600;
% v = -SIZE:200:SIZE;
% xy = [v; v];
% sz = 150*ones(1, length(v));
% clrs = repmat([0;0;0], 1, length(v));


StarfieldParameters = zeros(14, numRuns);
StarfieldParameters(1:2, :) = Parameters(1:2, :);  % size, density
StarfieldParameters(end-3, :) = ones(1, numRuns); % time

starfieldOutput = starfieldPrep(StarfieldParameters, ScreenData, StimSettings, NumSubframes);

for k = 1:numRuns
    dotsize = StarfieldParameters(1, k);
    density = StarfieldParameters(2, k);
    [x, y, z, sizes] = starSeed2(density, dotsize, WIDTH, HEIGHT, DEPTH, DEPTH);
    xy = [x + WIDTH/2; y+HEIGHT/2];
    fprintf('x has length %d\n', numel(x));
    sz = max(min(63, sizes./z),1);
    clrs = repmat(255*z/DEPTH, 3, 1);
   rect = [0 0 WIDTH HEIGHT];
    %rect = [0 0 650 500];
    ptr = Screen('OpenOffScreenWindow', -1, [], rect);
    Screen('DrawDots', ptr, xy, sz, clrs,[],1);
    %Screen('DrawDots', ptr, starfieldOutput(k).xymatrix{1}, starfieldOutput(k).dotsize{1}, starfieldOutput(k).color{1}, starfieldOutput(k).center, 1);
    img = Screen('GetImage', ptr);
    img_name = ['gen.image.' num2str(k) '.png'];
    imwrite(img, img_name);
    StimSettings(k).path1 = {'Image Path', img_name, '*.*'};
    Screen('Close', ptr);
end



halfwidth = (ScreenData.rect(3)-ScreenData.rect(1))/2;
halfheight = (ScreenData.rect(4)-ScreenData.rect(2))/2;
ImgParameters = zeros(10, numRuns);
ImgParameters(end-3:end, :) = Parameters(end-3:end, :); % time etc.
ImgParameters(1, :) = ones(1, numRuns) * size(img,1);  
ImgParameters(2, :) = zeros(1, numRuns);   % height and width - redundant to reset them
% % ImgParameters(3, :) = ones(1, numRuns) * halfwidth;
% % ImgParameters(4, :) = ones(1, numRuns) * halfheight;
% ImgParameters(1, :) = Parameters(5, :);
% ImgParameters(2, :) = Parameters(6, :);
% ImgParameters(3, :) = Parameters(7, :);
% ImgParameters(4, :) = Parameters(8, :);
ImgParameters(5, :) = Parameters(3, :); % velocity
ImgParameters(6, :) = Parameters(4, :); % orientation
output = imgTargetPrep(ImgParameters, ScreenData, StimSettings, NumSubframes);


