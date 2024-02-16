% Fly does not move. Target follows trajectory defined against fly's
% position. 

function output = target3dPrep(Parameters, ScreenData, StimSettings, NumSubframes)
%
% Takes input from the user inteface and makes pre computations.
%

%--------------------------------------------------------------------------
% FlyFly v3.1
%
% Jonas Henriksson, 2010                                   info@flyfly.se
%--------------------------------------------------------------------------

if nargin<4
    NumSubframes = 1;
end

global GL;

starfieldUserSettings; %loads user settings from file. loaded files in CAPS

[~, numRuns] = size(Parameters);

P.targetSize  = Parameters(1,:);
P.start_az    = Parameters(2,:)/NumSubframes;   
P.start_el    = Parameters(3,:)/NumSubframes;   
P.start_dist  = Parameters(4,:)/NumSubframes;   
P.end_az    = Parameters(5,:)/NumSubframes;   
P.end_el    = Parameters(6,:)/NumSubframes;   
P.end_dist  = Parameters(7,:)/NumSubframes;  
P.velocity  = Parameters(8,:)/NumSubframes; 
P.target_noise  = Parameters(9,:)/NumSubframes;
P.t           = Parameters(10,:)*NumSubframes;

% z-clipping planes
zFar = 200;
zNear = 3;

% Field of view (y)
fovy = 2*atand(0.5*ScreenData.monitorHeight/ScreenData.flyDistance);
% Aspect ratio
ar = ScreenData.rect(3) / ScreenData.rect(4);

P.monHeight    = ScreenData.monitorHeight;

P.monWidth = P.monHeight * ar;
P.viewDistance = zFar;

ifi = ScreenData.ifi;

pxPerCm = ScreenData.rect(4) ./ P.monHeight;

%[center(1), center(2)] = RectCenter(ScreenData.rect);
center = ScreenData.flyPos(1:2);

hPx = ScreenData.flyPos(4)-center(2); % px offset from center
h   = hPx/pxPerCm;

cameraLookAt = [(ScreenData.flyPos(3:4)-ScreenData.flyPos(1:2))./pxPerCm ScreenData.flyDistance];
cameraLookAt = [0, 0, -1];
tiltAngleX = atand(((ScreenData.flyPos(3)-ScreenData.flyPos(1))./pxPerCm)/ScreenData.flyDistance);
tiltAngleY = atand(((ScreenData.flyPos(4)-ScreenData.flyPos(2))./pxPerCm)/ScreenData.flyDistance);

center(2) = center(2) + h*pxPerCm;

gamma1 = (atan(h/ScreenData.flyDistance))/180*pi;
gamma2 = (pi/2 - gamma1);


Screen('BeginOpenGL', ScreenData.wPtr);

glViewport(0, 0, ScreenData.rect(3), ScreenData.rect(4));

glDisable(GL.LIGHTING);

glEnable(GL.BLEND);
glBlendFunc(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA);

glMatrixMode(GL.PROJECTION);
glLoadIdentity;

gluPerspective(fovy, ar, zNear, zFar);

% glRotatef(-tiltAngleX,1,0,0);
% glRotatef(tiltAngleY,0,1,0);

glMatrixMode(GL.MODELVIEW);
glLoadIdentity;

%gluLookAt(0,0,0, cameraLookAt(1),cameraLookAt(2),cameraLookAt(3), 0,1,0);
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

MP = projectionMatrix*modelviewMatrix;

output(numRuns) = struct('xymatrix',[],'color',[],'dotsize',[],'center',[], 'num_frames', []);

for k=1:numRuns     % for each trial
    
    N = P.t(k);

    all_show = true;
    s_el = deg2rad(P.start_el(k));
    s_az = deg2rad(P.start_az(k));
    e_el = deg2rad(P.end_el(k));
    e_az = deg2rad(P.end_az(k));
    
    %s1 =  -P.start_dist(k)*cos(s_el);
    %e1 =  -P.end_dist(k)*cos(e_el);
    %target_start = [-s1*sin(s_az); P.start_dist(k)*sin(s_el); s1*cos(s_az)];
    %target_end = [-e1*sin(e_az); P.end_dist(k)*sin(e_el); e1*cos(e_az)];
    
    target_start = [P.start_dist(k)*sin(s_az); P.start_dist(k)*sin(s_el); -P.start_dist(k)];
    target_end = [P.end_dist(k)*sin(e_az); P.end_dist(k)*sin(e_el); -P.end_dist(k)];
    target_pos = target_start;
    target_distance = sqrt(target_pos(1)^2 + target_pos(2)^2 +target_pos(3)^2);
            
    output(k).target_xy = cell(1, N);
    output(k).target_dotsize = cell(1, N);
    output(k).target_color = cell(1, N);
    output(k).num_frames = floor(target_distance / (P.velocity(k)*ifi));
    
    for n=1:N   % for each frame  
        % Calculate increment of movement
        target_inc = (target_end - target_pos)/(N+1-n);
        
        noise = 2*P.target_noise(k)*rand(3,1) - P.target_noise(k);
        target_inc = target_inc + noise.*target_inc;
        
        target_pos = target_pos + target_inc;   % perform movement
        
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
            
            % Projection
            if show_target
                [scr_target(1), scr_target(2)] =  project3d(target_pos, modelviewMatrix, projectionMatrix, viewport);  
                % can display start and end by commenting in the following,
                % as well as the code that does the display (later in the
                % program)
                %[scr_start(1), scr_start(2)] =  project3d(target_start, modelviewMatrix, projectionMatrix, viewport); 
                %[scr_end(1), scr_end(2)] =  project3d(target_end, modelviewMatrix, projectionMatrix, viewport); 
            else
                disp('FAILED TEST 2'); target_pos
            end;
        else
            disp('FAILED TEST 1'); target_pos
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

            %colour_block = 255*(target_distance-zNear)/zFar*ones(1, 3);
            colour_block = 255*target_distance/zFar*ones(1, 3);
            output(k).target_color{n} = colour_block;
 
            % convert sizes from cm to pixels for PTB DrawDots()
            output(k).target_dotsize{n} = max( pxPerCm*P.targetSize(k)*ScreenData.flyDistance/target_distance,1);
%             dist_block = min(P.targetSize(k)./(target_distance+0.1),255); 
%             output(k).target_dotsize{n} =  dist_block;
        else
            disp('FAILED TEST 3'); target_pos
        end;
        
        all_show = all_show && show_target;
    end
    
    if ~all_show
        disp('SOME TESTS FAILED');
    end;
    
    output(k).center = [];
end

Screen('EndOpenGL', ScreenData.wPtr);


