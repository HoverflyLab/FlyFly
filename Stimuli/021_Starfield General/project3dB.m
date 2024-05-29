% project3d and project3dB are identical in their output.
% We can consider replacing project3d with project3dB, because it 
% is (arguably) easier to understand for a programmer, even if it may be
% marginally less efficient at the time of setting up a stimulus 
% (although we haven't tested performance).

function [winX, winY] = project3dB(objectPos,model,project,viewport)

% turn into 4D world coordinates
objectPos = [objectPos; ones(1, size(objectPos, 2))];

% modelview, projection - transform to clip coordinates
cc = project * model * objectPos;

% perspective divide - transform to normalized device coordinates
ndcx = cc(1, :)./cc(4, :);
ndcy = cc(2, :)./cc(4, :);

% map to viewport - transform to screen coordinates
winX = viewport(1) + (0.5 + 0.5*ndcx)*viewport(3);
winY = viewport(2) + (0.5 - 0.5*ndcy)*viewport(4);  % NOTE minus for y
