function [x y z] = starSeed(NDots, box_x, box_y, box_z)
%function [x y z] = starSeed(ThisCase, NDots, ViewDist)
%
% Returns randomly generated position vector [x y z].
% ThisCase: Set-up to use. 1=cube, 2=lines, 3=sphere
% NDots: Number of dots in space
% ViewDist: Spread of dots in space
%

%--------------------------------------------------------------------------
% FlyFly v2
%
% Jonas Henriksson, 2010                                   info@flyfly.se
%--------------------------------------------------------------------------

ThisCase = 1;
switch ThisCase
    
    case 1
        % CARTESIAN COORDINATES SET-UP RAND 1
        % Cube with width 2*ViewDist centered around origin
        %x = (2*ViewDist)*(rand(1, NDots) -0.5);
        %y = (2*ViewDist)*(rand(1, NDots) -0.5);
        %z = (2*ViewDist)*(rand(1, NDots) -0.5);
        
        %x1 / x2 = z1 / z2
        %x1 = monWidth, z1 = monDist, z2 = viewDist, x2 will be cube width
        % => x2 = x1*z2 / z1
        
        x = box_x*(rand(1, NDots) -0.5);
        %x = zeros(1, NDots);
        y = box_y*(rand(1, NDots) -0.5);
        z = box_z*(rand(1, NDots) -0.5);
        
    case 2
        % CARTESIAN COORDINATES SET-UP, 4 ROWS
        x = 5*[ones(1, NDots/4) ...
            ones(1, NDots/4) ...
            -ones(1, NDots/4) ...
            -ones(1, NDots/4)];
        
        y = 5*[ones(1, NDots/4) ...
            -ones(1,   NDots/4) ...
            ones(1,    NDots/4) ...
            -ones(1,   NDots/4)];
        
        z = [linspace(-ViewDist, ViewDist,  NDots/4) ...
            linspace(-ViewDist,  ViewDist,  NDots/4) ...
            linspace(-ViewDist,  ViewDist,  NDots/4) ...
            linspace(-ViewDist,  ViewDist,  NDots/4)];
        
    case 3
        %SPHERICAL COORDINATES SET-UP
        theta = 2*pi*rand(1, NDots);
        fi    = 2*pi*rand(1, NDots);
        r     = ViewDist*(rand(1, NDots));
        
        x = r.*sin(theta) .*cos(fi) + cos(theta).*cos(fi) - sin(fi);
        y = r.*sin(theta) .* sin(fi) + cos(theta).*sin(fi) + cos(fi);
        z = r.*cos(theta) - sin(theta);
        
    case 4
        % CARTESIAN COORDINATES SET-UP, 1 ROW ON Z AXIS
        x = zeros(1, NDots);        
        y = 2*ones(1, NDots);        
        z = linspace(-ViewDist, ViewDist,  NDots);

   case 5
        % CARTESIAN COORDINATES SET-UP, 1 ROW ON X AXIS
        x = linspace(-ViewDist, ViewDist,  NDots);
        y = zeros(1, NDots);        
        z = MonDistance*ones(1, NDots);   
    case 6
        % CARTESIAN COORDINATES SET-UP, CUBE IN FRONT
        x = 8*(rand(1, NDots)-0.5);
        y = 8*(rand(1, NDots)-0.5);        
        z = 8*(rand(1, NDots)-0.5);   
        
        z = z + 60;
end



