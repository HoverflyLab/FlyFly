function output = target3dGeneralPrep(Parameters, ScreenData, StimSettings, NumSubframes)
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

P.targetSize  = Parameters(1,:);
P.target_noise  = Parameters(9,:)/NumSubframes;
P.t           = Parameters(end-3,:)*NumSubframes;

% z-clipping planes
zFar = 200;
zNear = 6;

% Field of view (y)
fovy = 2*atand(0.5*ScreenData.monitorHeight/ScreenData.flyDistance);
% Aspect ratio
ar = ScreenData.partial(3) / ScreenData.partial(4);

P.monHeight    = ScreenData.monitorHeight;
P.monWidth = P.monHeight * ar;
P.viewDistance = zFar;

pxPerCm = ScreenData.partial(4) ./ P.monHeight;

Screen('BeginOpenGL', ScreenData.wPtr);

glViewport(0, 0, ScreenData.partial(3), ScreenData.partial(4));

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

for k=1:numRuns     % for each trial
    N = P.t(k);

    target_start = StimSettings(k).target_start;
    target_end = StimSettings(k).target_end;
    target_pos = target_start;

    output(k).target_xy = cell(1, N);
    output(k).target_dotsize = cell(1, N);
    output(k).target_color = cell(1, N);
     
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
            end;
        end;
        
        if show_target
            output(k).target_xy{n} = scr_target;
            colour_block = 255*target_distance/zFar*ones(1, 3);
            output(k).target_color{n} = colour_block;
            output(k).target_dotsize{n} = max( pxPerCm*P.targetSize(k)*ScreenData.flyDistance/-target_pos(3),1);
        end;
    end
    output(k).center = [];
end


