% Starfield 2 is nominally a cuboid, but is effectively infinite in size, because we
% allow space to "roll around" from one edge to the other 
% (copying dots from inaccessible areas into accessible areas).
% Fly does not move. Background moves in ONE of the 6 available motions.
% Combined background movements may work but have not been tested yet.
% Combined translations should be fine.

% TODO = we may consider implementing an arbitrary line of sight.
% But the problems are: 
% 1. the frustum culling below won't work anymore (frustum has to move to 
% be in line with the line of sight; the culling code below assumes we are looking down the
% (negative) z-axis)
% 2. and in that case, the monitor won't be orthogonal to the line of sight
% anymore, and hence not parallel to the near or far planes. So then we
% need Generalized Perspective Projection. 
% 3. And we need to rotate things around the arbitrary axis of the line of
% sight (as well as adjusting translations)!

function output = starfield3Prep2(Parameters, ScreenData, StimSettings, NumSubframes)

%--------------------------------------------------------------------------
% FlyFly v3.1
%
% Jonas Henriksson, 2010                                   info@flyfly.se
% Richard Leibbrandt, 2018
%--------------------------------------------------------------------------

if nargin<4
    NumSubframes = 1;
end

global GL;

DEBUG_SPACE = false;

DENSITY_CONVERSION = 1e-4;

[~, numRuns] = size(Parameters);

P.dotSize     = Parameters(1,:)/NumSubframes;
P.density     = DENSITY_CONVERSION*Parameters(2,:)/NumSubframes;
P.rl          = Parameters(3,:)/NumSubframes;   % sideslip
P.ud          = Parameters(4,:)/NumSubframes;   % lift
P.fb          = Parameters(5,:)/NumSubframes;   % thrust
P.pitch       = Parameters(6,:)/NumSubframes;
P.yaw         = Parameters(7,:)/NumSubframes;
P.roll        = Parameters(8,:)/NumSubframes;
P.duration           = Parameters(9,:)*NumSubframes;
P.t           = Parameters(10,:)*NumSubframes;
%P.duration      = ones(1, size(Parameters, 2));
% CORRECTION OF DIRECTIONS
P.rl = -P.rl;
P.fb = -P.fb;
P.roll = -P.roll;
% ud, pitch and yaw are "correct"

% PROJECTION MATRIX PARAMETERS
% z-clipping planes
zFar = 200;
zNear = 6;
%zNear = ScreenData.flyDistance;
% Field of view (y)
fovy = 2*atand(0.5*ScreenData.monitorHeight/ScreenData.flyDistance);
% Aspect ratio
ar = ScreenData.rect(3) / ScreenData.rect(4);

P.monHeight    = ScreenData.monitorHeight;
P.monWidth = P.monHeight * ar;
P.viewDistance = zFar;
ifi = ScreenData.ifi;
pxPerCm = ScreenData.rect(4) ./ P.monHeight;

% INITIAL SPACE - just needs to be reasonably large, as it will essentially
% be infinite - see below
box_x = 2*P.viewDistance;
box_y = box_x;
box_z = box_x;

P.viewDistX = box_x/2;
P.viewDistY = box_y/2;
P.viewDistZ = box_z/2;

maxSize = (ScreenData.flyDistance/zNear)*pxPerCm*P.dotSize;
if any(maxSize > 255)
    safe_size = (255*zNear)/(ScreenData.flyDistance*pxPerCm);
    too_big_msg = sprintf('Some dots may be too large to display with your setup, with the specified dot size. Use a dot size no larger than %1.2f to avoid this.\n', safe_size);
    msgbox(too_big_msg, 'Warning', 'warn');
end

% OPENGL STUFF - required to obtain  ModelView and Projection matrices, and viewport 
% Note we don't use OpenGL functions for transformations, projections or
% rendering (only the matrices).
Screen('BeginOpenGL', ScreenData.wPtr);

glViewport(0, 0, ScreenData.rect(3), ScreenData.rect(4));

glDisable(GL.LIGHTING);

%glEnable(GL.BLEND);
%glBlendFunc(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA);

glMatrixMode(GL.PROJECTION);
glLoadIdentity;

if isfield(StimSettings(1), 'ortho')
    disp('USING ORTHO PROJECTION!');
    imgWidth = 10000;imgHeight=10000;
    glOrtho(-imgWidth/2, imgWidth/2, -imgHeight/2, imgHeight/2, zNear, zFar);
else
    gluPerspective(fovy, ar, zNear, zFar);
end

%glOrtho(-P.monWidth/2, P.monWidth/2, -P.monHeight/2, P.monHeight/2, zNear, zFar);
%
% glRotatef(-tiltAngleX,1,0,0);
% glRotatef(tiltAngleY,0,1,0);

glMatrixMode(GL.MODELVIEW);
glLoadIdentity;
origin = [0, 0, 0];
%cameraLookAt = [(ScreenData.flyPos(3:4)-ScreenData.flyPos(1:2))./pxPerCm -ScreenData.flyDistance];
cameraLookAt = [0, 0, -1]; 
upDir = [0, 1, 0];
gluLookAt(origin(1),origin(2),origin(3), cameraLookAt(1),cameraLookAt(2),cameraLookAt(3), upDir(1),upDir(2),upDir(3));

% These are used in project3d (3d -> 2d coordinates)
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

% PREPARE THE OUTPUT
output(numRuns) = struct('xymatrix',[],'color',[],'dotsize',[],'center',[]);

%origin_pos = [0 0 0];
crash_alert = false;

numshown = zeros(1,numRuns);

if ~DEBUG_SPACE
        [x, y, z, sizes, clrs] = starSeed2(P.density(1), P.dotSize(1), box_x, box_y, box_z, zFar);
else
        % DEBUGGING - CREATE A SPACE WITH A FIXED GRID OF DOTS, INSTEAD OF
        % RANDOM STARFIELD
        xmin=-15.5;xmax=15.5;xspace=1;
        ymin=-12;ymax=-1;yspace=1;
        zmin=-20;zmax=-20;zspace=5;
        sz=1;
       [x, y, z, sizes] = starSeedDebug(xmin, xmax, xspace, ymin, ymax, yspace, zmin, zmax, zspace, sz);
end
    
for k=1:numRuns     % for each trial
    % N = NUMBER OF FRAMES
    N = P.t(k);
    D = P.duration(k);
    
    output(k).color = cell(1,N);
    output(k).dotsize = cell(1,N);
    output(k).xymatrix = cell(1,N);

    sx = cell(1,N);
    sy = cell(1,N);
      
    inc_yaw = [zeros(1, N-D) deg2rad(P.yaw(k)*ifi)*ones(1,D)];
    inc_roll = [zeros(1, N-D) deg2rad(P.roll(k)*ifi)*ones(1,D)];
    inc_pitch = [zeros(1, N-D) deg2rad(P.pitch(k)*ifi)*ones(1,D)];
    inc_fb = [zeros(1, N-D) P.fb(k)*ifi*ones(1,D)];
    inc_ud = [zeros(1, N-D) P.ud(k)*ifi*ones(1,D)];
    inc_rl = [zeros(1, N-D) P.rl(k)*ifi*ones(1,D)];
    
    for n=1:N   % for each frame
        
        %ROTATE
        %yaw - affects x and z
        if inc_yaw(n) ~= 0
            [x, z] = rotateXY(x, z, inc_yaw(n));
        end
        
        %pitch - affects y and z
        if inc_pitch(n) ~= 0
            [y, z] = rotateXY(y, z, inc_pitch(n));
        end
        
        %roll - affects x and y
        if inc_roll(n) ~= 0
            [x, y] = rotateXY(x, y, inc_roll(n));
        end
        
        %TRANSLATE
        if inc_rl(n) ~= 0
            x = x + inc_rl(n);
        end;
        
        if inc_ud(n) ~= 0
            y = y + inc_ud(n);
        end;
        
        if inc_fb(n) ~= 0
            z = z + inc_fb(n);
        end;
        
        % TRICK TO MAKE THE SPACE INFINITE!
        % Effectively, scrolling the space around when we "go over"
        x(abs(x)> P.viewDistX) = -(x(abs(x)> P.viewDistX));
        y(abs(y)> P.viewDistY) = -(y(abs(y)> P.viewDistY));
        z(abs(z)> P.viewDistZ) = -(z(abs(z)> P.viewDistZ));
                     
        % CULLING
        % Frustum culling, [fx; fy; fz] are all the points that are inside the frustum
        % http://www.lighthouse3d.com/tutorials/view-frustum-culling/radar-approach-testing-points-ii/
        % Note: this is essentially culling in eye coordinates
        % This code will need to be modified if we use a general frustum
        % ASSUME: we are looking down the negative z axis
        h = abs(z*tand(fovy/2));
        w = h*ar;
        
        indices = and(z<-zNear,z>-zFar);
        indices = and(indices,and(y>-h,y<h));
        indices = and(indices,and(x>-w,x<w));
 
        % Switch to fx, fy, fz at this point instead of x, y, z
        % This is because we don't want to cull the actual dots, or
        % eventually we'll have none left!
        fx = x(indices);
        fy = y(indices);
        fz = z(indices);
        fs = sizes(indices);
        fc = clrs(indices);

        culled(n) = numel(x)-numel(fx);
        
        % CALCULATE ALL DISTANCES FROM THE ORIGIN
        distances = sqrt(fx.^2+fy.^2+fz.^2);                
        
        % CLIPPING
        % Don't draw particles that are too far away
        a = numel(fx);
        indices = distances<zFar;
        fx = fx(indices);
        fy = fy(indices);
        fz = fz(indices);
        fs = fs(indices);
        fc = fc(indices);
        distances = distances(indices);       
        b = numel(fx);
        clipped(n) = a-b;
        
        % SORT FROM FAR TO NEAR
        % So that the nearer dots are displayed in front of the further
        % ones (drawn last)
        [~, sort_idx] = sort(distances, 'descend');
        fx = fx(sort_idx);
        fy = fy(sort_idx);
        fz = fz(sort_idx);
        fs = fs(sort_idx);
        fc = fc(sort_idx);
        distances = distances(sort_idx);
        
        numshown(n) = numel(fx);
        
        % THE FOLLOWING IS FOR DEBUGGING PURPOSES
        if isempty(fx) && ~crash_alert
            fprintf('EMPTY SPACE ENCOUNTERED in TRIAL %d, FRAME %d', k, n);
            crash_alert = true;
        end;
        
        % PROJECTION
        [sx{n}, sy{n}] = project3d([fx; fy; fz], modelviewMatrix, projectionMatrix, viewport);  
        output(k).xymatrix{n} =[sx{n}; sy{n}];
        
        % COLOR AND SIZE OF DOTS
        % distanceRatios connects virtual-world sizes (in cm) with
        % real-world centimetres: the ratio is 1 when the object is located
        % exactly in the plane of the screen.
        distanceRatios = ScreenData.flyDistance./-fz;
        % convert sizes from cm to pixels for PTB DrawDots()
        output(k).dotsize{n} = max( pxPerCm*fs.*distanceRatios,1);
        % Colour = greyscale
        output(k).color{n} = repmat(255*fc, 3, 1);
    end
    
    output(k).center = [];

end

function [x1,y] = rotateXY(x, y, angle)
% rotates coordinate (x, y) angle degrees around origin
x1 = x*cos(angle) - y*sin(angle);
y  = y*cos(angle) + x*sin(angle);
