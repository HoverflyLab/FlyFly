function [critInput] = loomPrep(Parameters, ScreenData, StimSettings, NumSubframes)
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

P.L       = Parameters(1,:);
P.V      = Parameters(2,:);
P.xpos        = Parameters(3,:);
P.ypos        = Parameters(4,:);
P.stop_size    = Parameters(5,:);
P.loom_frames    = Parameters(6,:);
P.bright1       = Parameters(7,:);
P.bright2  = Parameters(8,:);
P.frames_per_cycle  = Parameters(9,:);
P.t           = Parameters(10,:)*NumSubframes;
numRuns = size(Parameters,2);

texturePtr = cell(1, numRuns);
pos = cell(1, numRuns);
for k = 1:numRuns
    imagePath        = StimSettings(k).path{2};
    [Iorig, ~, alpha] = imread(imagePath);
    Iorig = double(Iorig);
    
    N = P.t(k);
    
    screen_dist = ScreenData.flyDistance/100;   % in m
    
    pxPerCm = ScreenData.partial(4) ./ ScreenData.monitorHeight;
    pix_per_m = 100 * pxPerCm;
    
    factor = screen_dist * 2 * pix_per_m;
    loom_time = factor * P.L(k)./(P.V(k)*P.stop_size(k));
    loom_frames = P.loom_frames(k);
    t = linspace(-loom_time-loom_frames*ScreenData.ifi, -loom_time,  loom_frames);
    screen_size =  factor * P.L(k)./(-P.V(k)*t);

        
    texturePtr{k} = cell(1, N);
    pos{k} = cell(1, N);
    
    F = P.frames_per_cycle(k);
    using_flicker = (F ~= 0);
    if using_flicker
        deg_vector = (180.0/F)*[0:N-1];
        wave = (cosd(deg_vector)+1)/2;
        b = P.bright2(k) + wave*(P.bright1(k)-P.bright2(k));
    end
 
%     height = P.stop_size(k);
%     width = P.stop_size(k);
%     stop_rect = [P.xpos(k)-width/2, P.ypos(k)-height/2, ...
%         P.xpos(k)+width/2, P.ypos(k)+height/2];
        
    for n = 1:N
        if n <= loom_frames
            height = screen_size(n); %-size(I, 1)*t(n);
            width = screen_size(n); %-size(I, 2)*t(n);
        else
            height = P.stop_size(k);
            width = P.stop_size(k);
        end
        rect = [P.xpos(k)-width/2, P.ypos(k)-height/2, ...
            P.xpos(k)+width/2, P.ypos(k)+height/2];
        pos{k}{n} = rect;
        
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
%     
%     if loom_frames > 0
%         stop_rect = pos{k}{loom_frames}; 
%         stop_image = texturePtr{k}{loom_frames};
%     end 
%     
%     for n = loom_frames+1:N
%         pos{k}{n} = stop_rect;
%         texturePtr{k}{n} = stop_texture;
%     end

end

% critInput.RGB      = [0; 0; 0];

% % the x and y components of the movement vector
% delta_x = cos(P.angle*pi/180);
% delta_y = -sin(P.angle*pi/180);
%
% critInput.deltaPos = ScreenData.ifi*...
%     [P.velocity.*delta_x; P.velocity.*delta_y; ...
%     P.velocity.*delta_x; P.velocity.*delta_y];

% critInput.srcRect = P.srcRect;

critInput.texturePtr      = texturePtr;
critInput.pos     = pos;

