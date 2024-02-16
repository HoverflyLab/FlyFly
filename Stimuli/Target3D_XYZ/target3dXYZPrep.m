function output = target3dXYZPrep(Parameters, ScreenData, StimSettings, NumSubframes)
%--------------------------------------------------------------------------
% FlyFly v3.1
%
% Jonas Henriksson, 2010                                   info@flyfly.se
%--------------------------------------------------------------------------

if nargin<4
    NumSubframes = 1;
end

global GL;

[~, numRuns] = size(Parameters);
Parameters;
P.targetSize  = Parameters(1,:);
% P.target_noise  = Parameters(5,:)/NumSubframes;
P.t  = Parameters(5,:)*NumSubframes;
P.X  = Parameters(2,:);
P.Y  = Parameters(3,:);
P.Z  = Parameters(4,:);
target = [P.X; P.Y; P.Z];


% z-clipping planes
zFar = 100;
zNear = 0.1;

% The following doesn't display anything, but just queries for the min and
% max sized dots
[minSmoothPointSize, maxSmoothPointSize, ~, ~] = Screen('DrawDots', ScreenData.wPtr);

% Field of view (y)
fovy = 2*atand(0.5*ScreenData.monitorHeight/ScreenData.flyDistance);
% Aspect ratio
ar = ScreenData.rect(3) / ScreenData.rect(4);

P.monHeight    = ScreenData.monitorHeight;
P.monWidth = P.monHeight * ar;
P.viewDistance = zFar;

pxPerCm = ScreenData.rect(4) ./ P.monHeight;
cmPerpx = P.monHeight./ScreenData.rect(4);

Screen('BeginOpenGL', ScreenData.wPtr);

glViewport(0, 0, ScreenData.rect(3), ScreenData.rect(4));

glDisable(GL.LIGHTING);

glEnable(GL.BLEND);
glBlendFunc(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA);

glMatrixMode(GL.PROJECTION);
glLoadIdentity;

gluPerspective(fovy, ar, zNear, zFar);

glMatrixMode(GL.MODELVIEW);
glLoadIdentity;

gluLookAt(0,0,0,  0,0,-1,  0,1,0);

% These are used in gluProject (3d -> 2d coordinates)
% Get the projection matrix
projection = glGetDoublev(GL.PROJECTION_MATRIX);
projectionMatrix = reshape(projection,4,4);
% Get the modelview matrix
modelview = glGetDoublev(GL.MODELVIEW_MATRIX);
modelviewMatrix = reshape(modelview,4,4);
% Get the viewport
viewport = glGetIntegerv(GL.VIEWPORT);
viewport = double(viewport);
Screen('EndOpenGL', ScreenData.wPtr);

output(numRuns) = struct('xymatrix',[],'color',[],'dotsize',[],'center',[], 'num_frames', []);
StimSettings(1);
for k=1:numRuns  % for each trial
    
    N = P.t(k);
%poss = zeros(3,N);
%     target_start = StimSettings(k).target_start;
%     target_end = StimSettings(k).target_end;
%     target_pos = target_start;

    target_start = target(:,k);
    
%     if k==numRuns
%         target_end = target(:,k);
%     else
%         target_end = target(:,k+1);
%     end
    target_pos = target_start;
%     target_block = [P.X(k); P.Y(k); P.Z(k)]';
%     output(k).target_xy = target_block;

    output(k).target_xy = cell(1, N);
    output(k).target_dotsize = cell(1, N);
    output(k).target_color = cell(1, N);
     
    for n=1:N   % for each frame  
%         n = k;
%         n=1:N
        % Calculate increment of movement
%         target_inc = (target_end - target_pos)/(N+1-n);
        
%         noise = 2*P.target_noise(k)*rand(3,1) - P.target_noise(k);
%         target_inc = target_inc + noise.*target_inc;
        
%         target_pos = target_pos + target_inc;   % perform movement
        %poss(:,n) = target_pos;
        % Target clipping
        target_distance = sqrt(target_pos(1)^2 + target_pos(2)^2 +target_pos(3)^2);
        show_target = target_distance < zFar;
        scr_target = []; 
        if show_target
         
            % Target culling
            ht = abs(target_pos(3)*tand(fovy/2));
            wt = ht*ar;
            show_target = (target_pos(3) < -zNear) && (target_pos(3) > -zFar) && ...
                (abs(target_pos(2)) < ht) && (abs(target_pos(1)) < wt);

            
%             % z-clipping planes
%             zFar = 200;
%             zNear = 1;
%             % Field of view (y)
%             fovy = 2*atand(0.5*ScreenData.monitorHeight/ScreenData.flyDistance);
%             % Aspect ratio
%             ar = ScreenData.rect(3) / ScreenData.rect(4);

            
            
            % Projection
            if show_target
            
                
                [scr_target(1), scr_target(2)] =  project3d(target_pos, modelviewMatrix, projectionMatrix, viewport);  
                % can display start and end by commenting in the following,
                % as well as the code that does the display (later in the
                % program)
                %[scr_start(1), scr_start(2)] =  project3d(target_start, modelviewMatrix, projectionMatrix, viewport); 
                %[scr_end(1), scr_end(2)] =  project3d(target_end, modelviewMatrix, projectionMatrix, viewport); 
            end;
        end;
        
        if show_target
            %{  
            % FOR DEBUGGING: shows the start and end
            target_block = [scr_target; scr_start; scr_end]';
            output(k).target_xy{n} = target_block;
            colour_block = [255*[1 (target_distance-zNear)/zFar (target_distance-zNear)/zFar]; 0 255 0; 0 0 255];
            output(k).target_color{n} = colour_block;
            dist_block = [min(P.targetSize(k)./(target_distance+0.1),255); 10; 15];
            output(k).target_dotsize{n} =  dist_block;
            %}
       
            output(k).target_xy{n} = scr_target;
            colour_block = 255*target_distance/zFar*ones(1, 3);
            output(k).target_color{n} = colour_block;
            
            %calculate physical distance
            dis = sqrt((scr_target(1)-ScreenData.flyPos(1))^2 + (scr_target(2)-ScreenData.flyPos(2))^2); %in pixcel
            disCm = dis*cmPerpx; %convert to cm
            phys_dis(k)= sqrt(disCm^2 + ScreenData.flyDistance^2);
            % convert sizes from cm to pixels for PTB DrawDots()
%            output(k).target_dotsize{n} = max( pxPerCm*P.targetSize(k)*ScreenData.flyDistance/target_distance,1);
%             output(k).target_dotsize{n} = ...
%                 min(max( pxPerCm*P.targetSize(k)*ScreenData.flyDistance/target_distance, minSmoothPointSize), maxSmoothPointSize);
%             
            output(k).target_dotsize{n} = ...
                min(max((pxPerCm*P.targetSize(k)*phys_dis(k))/target_distance, minSmoothPointSize), maxSmoothPointSize)            
            maxSmoothPointSize;
            check = pxPerCm*P.targetSize(k)*phys_dis(k)/target_distance
            output(k).target_dotsize{n};
            
        end;
    end
    % poss
    output(k).center = [];
end


