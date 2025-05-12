function [critInput] = sineBackgroundPrep(Parameters, ScreenData, ~, NumSubframes)
%
%  Prepares input parameters for sineGratingDraw

%--------------------------------------------------------------------------
% FlyFly v2
%
% Jonas Henriksson, 2010                                   info@flyfly.se
%--------------------------------------------------------------------------

% If we are missing length of trial, default to one frame.
if nargin<4
    NumSubframes = 1;
end

% How many trials are we needing?
[~, numRuns] = size(Parameters);
% Output is the shade to print on the screen for each frame
critInput.rgb = cell(1, numRuns);

% Extract parameters from user selection
params.freq        = Parameters(1,:);
params.contrast    = Parameters(2,:);
params.trialLength = Parameters(3,:);

% Loop over all trials of experiment
for run = 1:numRuns
    % Init array of shade values for each frame
    sineBackground = ones(params.trialLength(numRuns), 3);
    % Loop over all frames of current trial
    for frame = 1:params.trialLength(numRuns)
        % This equation generates a shade from a sine wave, centered around the gray band.
        % The equation factors in contrast from gray, temporal frequency, and the 
        % frame rate of the current monitor
        shade = (255 * params.contrast(run) * (sin(2 * pi * params.freq(run) * frame / ScreenData.ifi) / 2)) + 127.5;
        sineBackground(frame, :) = [shade shade shade]; % Throwing so much shade, woah shit!! :O
    end
    critInput.rgb{run} = sineBackground;
end
