function [winX winY] = project3d(objectPos,model,project,viewport)
% MATLAB optimzed version of glhProjectf
% (http://www.opengl.org/wiki/GluProject_and_gluUnProject_code)
% Much faster than calling gluProject in a loop
% (the glhProjectf (works only from perspective projection. With the
% orthogonal projection it gives different results than standard
% gluProject.)

temp = model(:,1:3)*objectPos + model(:,4)*ones(1,size(objectPos,2));

temp2 = project(1:3,:)*temp;
temp3 = -temp(3,:);

r = (temp3~=0);

temp2 = temp2(:,r)./(ones(3,1)*temp3(r));
winX = (temp2(1,:)*.5+.5)*viewport(3)+viewport(1);
winY = (-temp2(2,:)*.5+.5)*viewport(4)+viewport(2); % NOTE THE SIGN OF Y IS BEING FLIPPED HERE
% This is to take into account that the y axis is upside down on a screen:
% https://www.scratchapixel.com/lessons/3d-basic-rendering/computing-pixel-coordinates-of-3d-point/mathematics-computing-2d-coordinates-of-3d-points

%winZ = (1+temp2(3,:))*.5;

% [ winX, winY, winZ, r ] = gluProject( objX, objY, objZ, model, proj, view )