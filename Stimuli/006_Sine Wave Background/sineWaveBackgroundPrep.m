function [critInput] = sineWaveBackgroundPrep(Parameters, ScreenData, ~, ~)
%
%  Prepares input parameters for sineGratingDraw

%--------------------------------------------------------------------------
% FlyFly v2
%
% Jonas Henriksson, 2010                                   info@flyfly.se
%--------------------------------------------------------------------------

% How many trials are we needing?
[~, numRuns] = size(Parameters);
% Output is the shade to print on the screen for each frame
critInput.rgb = cell(1, numRuns);

% Extract parameters from user selection
params.freq        = Parameters(1,:);
params.contrast    = Parameters(2,:);
params.patchHeight = Parameters(3,:);
params.patchWidth  = Parameters(4,:);
params.patchXpos   = Parameters(5,:);
params.patchYpos   = Parameters(6,:);
params.trialLength = Parameters(7,:);

white = WhiteIndex(ScreenData.screenNumber);
black = BlackIndex(ScreenData.screenNumber);
gray  = (white+black) / 2;

texX = params.patchWidth  / 2;
texY = params.patchHeight / 2;

% Loop over all trials of experiment
for run = 1:numRuns
    % Init array of shade values for each frame
    sineBackground = ones(params.trialLength(numRuns), 3);
    % Loop over all frames of current trial
    for frame = 1:params.trialLength(numRuns)
        % This equation generates a shade from a sine wave, centered around the gray band.
        % The equation factors in contrast from gray, temporal frequency, and the 
        % frame rate of the current monitor
        shade = (white * params.contrast(run) * (sin(2 * pi * params.freq(run) * (frame / ScreenData.hz)) / 2)) + gray;
        sineBackground(frame, :) = [shade shade shade]; % Throwing so much shade, woah shit!! :O
    end
    critInput.rgb{run} = sineBackground;
end

critInput.dstRect = [params.patchXpos - texX; params.patchYpos - texY; ...
                     params.patchXpos + texX; params.patchYpos + texY ];
