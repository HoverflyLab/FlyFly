function [critInput] = imgTargetFlickerPrep(Parameters, ScreenData, StimSettings, NumSubframes)
%
% Prepares input parameters for rectTargetDraw

%--------------------------------------------------------------------------
% FlyFly v3.1
%
% Richard Leibbrandt 2017    
%--------------------------------------------------------------------------

if nargin<4
    NumSubframes = 1;
end


P.height      = Parameters(1,:);
P.width       = Parameters(2,:);
P.xpos        = Parameters(3,:);
P.ypos        = Parameters(4,:);
P.velocity    = Parameters(5,:)/NumSubframes;
P.angle       = Parameters(6,:);
P.bright1       = Parameters(7,:);
P.bright2       = Parameters(8,:);
P.frames_per_cycle  = Parameters(9,:);
P.t = Parameters(10, :)*NumSubframes;
numRuns = size(Parameters,2);

texturePtr = cell(1, numRuns);

for k = 1:numRuns
    N = P.t(k);

    imagePath        = StimSettings(k).path1{2};
    [I, ~, alpha] = imread(imagePath);
    I = double(I);
%     I = P.contrast(k)*(I-127) + 127;
    if ~isempty(alpha)
        I(:,:,4) = alpha;
    end

    [Iorig, ~, alpha] = imread(imagePath);
    Iorig = double(Iorig);
    
    F = P.frames_per_cycle(k);
    using_flicker = (F ~= 0);
    if using_flicker
        deg_vector = (180.0/F)*[0:N-1];
        wave = (cosd(deg_vector)+1)/2;
        b = P.bright2(k) + wave*(P.bright1(k)-P.bright2(k));
    end
    
    aratio = size(I,1)/size(I,2);
    P.srcRect = [0; 0; size(I,1); size(I,2)]
    if P.width(k) == 0
        if P.height(k) == 0
            P.height(k) = size(I, 1);
            P.width(k) = size(I, 2);
        else
            P.width(k) = P.height(k) / aratio;
        end
    else
        if P.height(k) == 0
            P.height(k) = P.width(k) * aratio;
        else
            P.height(k) = min(P.height(k), P.width(k) * aratio);
            P.width(k) = P.height(k) / aratio;
        end
    end;
    texturePtr{k} = cell(1, N);
    for n = 1:N
        if using_flicker
            b_factor = b(n);
        else
            b_factor = P.bright1(k);
        end
        
        I = b_factor*(Iorig-127) + 127;
        if ~isempty(alpha)
            I(:,:,4) = alpha;
        end

        texturePtr{k}{n} = Screen('MakeTexture', ScreenData.wPtr, I);
    end
end

% the x and y components of the movement vector
delta_x = cos(P.angle*pi/180);
delta_y = -sin(P.angle*pi/180);

critInput.RGB      = [0; 0; 0];

critInput.pos      = [P.xpos - P.width/2; P.ypos - P.height/2; ...
    P.xpos + P.width/2; P.ypos + P.height/2];

critInput.deltaPos = ScreenData.ifi*...
    [P.velocity.*delta_x; P.velocity.*delta_y; ...
    P.velocity.*delta_x; P.velocity.*delta_y];

critInput.srcRect = P.srcRect;
critInput.texturePtr      = texturePtr;

