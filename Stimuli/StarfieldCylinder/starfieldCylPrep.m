function output = starfieldCylPrep(Parameters, ScreenData, StimSettings, NumSubframes)
%function [critInput, dynamic] = starfieldPrep(Parameters, ScreenData,
%                                StimSettings)
%
% Takes input from the user inteface and makes pre computations.
%

%--------------------------------------------------------------------------
% FlyFly v3
%
% Jonas Henriksson, 2010                                   info@flyfly.se
%--------------------------------------------------------------------------

if nargin<4
    NumSubframes = 1;
end

global GL;

% If the fly is not located in front of the exact center of the screen,
% create an extended offscreen window to move the focus point in the OpenGL
% viewport
X = ScreenData.rect(3);
Y = ScreenData.rect(4);

centerX = round(X/2);
centerY = round(Y/2);

extendedX = X+2*(abs(ScreenData.flyPos(1)-centerX));
extendedY = Y+2*(abs(ScreenData.flyPos(2)-centerY));

copyRect = zeros(1,4);
if ScreenData.flyPos(1)>=centerX
    copyRect([1 3]) = [0 X];
else
    copyRect([1 3]) = [extendedX-X extendedX];
end
if ScreenData.flyPos(2)>=centerY
    copyRect([2 4]) = [0 Y];
else
    copyRect([2 4]) = [extendedY-Y extendedY];
end

[extendedWinPtr extendedWinRect] = Screen('OpenOffscreenWindow',ScreenData.wPtr,0,[0 0 extendedX extendedY]);

[texturePtr textureRect] = Screen('OpenOffscreenWindow',ScreenData.wPtr,0,[0 0 2048 2048]);
[gltex, gltextarget tu tv] = Screen('GetOpenGLTexture', extendedWinPtr, texturePtr);
Screen('BlendFunction', texturePtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, [1 1 1 1]);

%%% Create cylinder 3d object %%%

fovxd = 360;%2*atand(0.5*monitorWidth/flyDistance);
fovx = (min(360,fovxd+10))*pi/180;   %only used for calculating the cylinder section
sections = 360;
sections_horizontal = 1;
radius = ScreenData.flyDistance;

angle = linspace(-fovx/2,fovx/2,sections+1);
x = radius*cos(angle);
y = radius*sin(angle);

%arc_length = radius*fovx;
arc_length = sum(sqrt(diff(x).^2+diff(y).^2));  % Length of arc

z = linspace(arc_length/2,-arc_length/2,sections_horizontal+1);

x = repmat(x,sections_horizontal+1,1);
y = repmat(y,sections_horizontal+1,1);
z = repmat(z',1,sections+1);

Screen('BeginOpenGL', extendedWinPtr);

% Set size of OpenGL viewport to size of the offscreen window
glViewport(extendedWinRect(1),extendedWinRect(2), ...
    extendedWinRect(3),extendedWinRect(4));
ar=extendedWinRect(4)/extendedWinRect(3);

glColor3f(1,1,1);

glEnable(GL.DEPTH_TEST);

glMatrixMode(GL.PROJECTION);
glLoadIdentity;

% Set correct prespective according to out screen settings
extendedMonitorWidth = extendedX/X*ScreenData.monitorHeight;
extendedMonitorHeight = extendedMonitorWidth*ar;
fovyd = 2*atand(0.5*extendedMonitorHeight/ScreenData.flyDistance);
gluPerspective(fovyd, 1/ar, 0.001, 100);

glMatrixMode(GL.MODELVIEW);
glLoadIdentity;

gluLookAt(0, 0, 0, 1, 0, 0, 0, 0, -1);

glClearColor(0,0,0,0);

glClear;

glEnable(gltextarget);

glBindTexture(gltextarget, gltex);

glTexEnvfv(GL.TEXTURE_ENV, GL.TEXTURE_ENV_MODE, GL.MODULATE);

% Create a OpenGL list for faster rendering of the cylinder
index = glGenLists(1);
glNewList(index, GL.COMPILE);
glBegin(GL.TRIANGLE_STRIP);
for j=1:sections
    for i=1:sections_horizontal+1
        glTexCoord2f(tu*((j-1)/sections),tu*((i-1)/sections_horizontal));
        glVertex3f(x(i,j),y(i,j),z(i,j));
        glTexCoord2f(tu*(j/sections),tu*((i-1)/sections_horizontal));
        glVertex3f(x(i,j+1),y(i,j+1),z(i,j+1));
    end
end
glEnd();
glEndList();

Screen('EndOpenGL', extendedWinPtr);

[~, numRuns] = size(Parameters);

P.dotSize     = Parameters(1,:);
P.nDots       = Parameters(2,:);
P.rl          = Parameters(3,:)/NumSubframes;
P.ud          = Parameters(4,:)/NumSubframes;
P.fb          = Parameters(5,:)/NumSubframes;
P.pitch       = Parameters(6,:)/NumSubframes;
P.yaw         = Parameters(7,:)/NumSubframes;
P.roll        = Parameters(8,:)/NumSubframes;
P.N           = Parameters(9,:)*NumSubframes;

P.dotSize      = min(max(0.01, P.dotSize),1);

nDots = max(P.nDots);

ifi = ScreenData.ifi;

%rotation/frame
P.pitch = -P.pitch/180*pi *ifi;
P.yaw   = -P.yaw/180*pi   *ifi;   
P.roll  = -P.roll/180*pi  *ifi;  

%transaltion/frame
P.rl    = -P.rl*ifi;
P.ud    = -P.ud*ifi;
P.fb    = -P.fb*ifi;

oX = 2048/2;
oY = 2048/2;

x = (rand(1,nDots)-0.5)*600;
y = (rand(1,nDots)-0.5)*600;
z = (rand(1,nDots)-0.5)*600;

pxPerDegree = 2048/360;
elevationFactor = radius*2048/arc_length;

% sy = sin(-P.yaw);
% cy = cos(-P.yaw);
% sp = sin(P.pitch);
% cp = cos(P.pitch);
% sr = sin(P.roll);
% cr = cos(P.roll);
% rotationMatrix = [cy*cp    cy*sp*sr-sy*cr  cy*sp*cr+sy*sr;
%                   sy*cp    sy*sp*sr+cy*cr  sy*sp*cr-cy*sr;
%                   -sp      cp*sr           cp*cr];

output(numRuns) = struct('xymatrix',[],'color',[],'dotsize',[],'center',[], ...
    'texturePtr',[],'copyRect',[],'extendedWinPtr',[],'flyTiltAngle',[], ...
    'flyRotAngle',[],'listindex',[]);

for k=1:numRuns

    N = P.N(k);
    output(k).color = cell(1,N);
    output(k).dotsize = cell(1,N);
    output(k).xymatrix = cell(1,N);
    
    for n=1:N
        x = x + P.fb(k);
        y = y + P.rl(k);
        z = z + P.ud(k);
        
        if P.pitch(k) ~= 0
            [x z] = rotateXY(x, z, P.pitch(k));
        end
        if P.yaw(k) ~= 0
            [x y] = rotateXY(x, y, -P.yaw(k));
        end
        if P.roll(k) ~= 0
            [y z] = rotateXY(y, z, P.roll(k));
        end
%         C = rotationMatrix*[x; y; z];
%         x = C(1,:);
%         y = C(2,:);
%         z = C(3,:);

        xi = abs(x)>300;
        yi = abs(y)>300;
        zi = abs(z)>300;
        x(xi) = -x(xi);
        y(yi) = -y(yi);
        z(zi) = -z(zi);

        i = x>10;
        x_ = x(i);
        y_ = y(i);
        z_ = z(i);
        
        % uncomment to sort dots by distance from viewr to make sure dots
        % that are further away are not drawn on top closer dots.
        dist2 = x_'.^2 + y_'.^2 + z_'.^2;
        [~,i] = sort(dist2);
        i = flipud(i);
        x_ = x_(i);
        y_ = y_(i);
        z_ = z_(i);
        
        dist = sqrt(x_'.^2 + y_'.^2 + z_'.^2);

        azimuth = atand(y_./x_);
        elevation = atand(-z_./x_);

        xx = oX + azimuth*pxPerDegree;
        yy = oY + tand(elevation)*elevationFactor;
        
        output(k).xymatrix{n} = [xx; yy];
        % The dot size and alpha color might need some fine-tuning!
        output(k).dotsize{n} = max(min(63,P.dotSize(k)*1000./dist),1)';
        output(k).color{n} = [zeros(3,length(output(k).dotsize{n})); 255-.7*dist'];
    end
    
    output(k).center = [];
end

cmPerPx = ScreenData.monitorHeight/ScreenData.rect(3);
flyDeltaX = (ScreenData.flyPos(3)-ScreenData.flyPos(1))*cmPerPx;
flyDeltaY = (ScreenData.flyPos(4)-ScreenData.flyPos(2))*cmPerPx;
flyTiltAngle = atand(flyDeltaY/ScreenData.flyDistance);
flyRotAngle = atand(flyDeltaX/ScreenData.flyDistance);

for i=1:k
    output(i).texturePtr = texturePtr;
    output(i).extendedWinPtr = extendedWinPtr;
    output(i).copyRect = copyRect;
    output(i).flyTiltAngle = flyTiltAngle;
    output(i).flyRotAngle = flyRotAngle;
    output(i).listindex = index;
    output(i).gltextarget = gltextarget;
end


function [x1,y] = rotateXY(x, y, angle)
% rotates coordinate (x, y) angle degrees around origin

x1 = x*cos(angle) - y*sin(angle);
y  = y*cos(angle) + x*sin(angle);