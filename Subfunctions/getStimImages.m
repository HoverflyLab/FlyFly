function imageArray = getStimImages(Stimulus, ScreenData, UserSettings, TrialSubset, fps)
%function imageArray = getStimImages(Stimulus, ScreenData, UserSettings,
%TrialSubset, fps)
%
% Simplified version of animation loop. Draws the objects to the screen
% with a specified fps and returns the drawn frames as an image sequence.
%

%--------------------------------------------------------------------------
% FlyFly v2
%
% Jonas Henriksson, 2010                                   info@flyfly.se
%--------------------------------------------------------------------------

numLayers = length(Stimulus.layers);
numRuns   = length(TrialSubset);

critInput = cell(numLayers,1);
fcnDraw = cell(numLayers,1);

%Screen data
%--------------------------------------------------------------------------
ScreenData.ifi = 1/fps;
ScreenData.hz  = fps;

if ScreenData.dlp
    NumSubframes = 3;
else
    NumSubframes = 1;
end
    
fprintf('Calculating... ');
for z = 1:numLayers
    % GET CRITICAL INPUT AND DRAW FUNCTION FOR EACH LAYER
    fcnPrep  = Stimulus.layers(z).fcnPrep;
    name = func2str(fcnPrep);
    
    % Hacky solution to Target 3D - because we specify velocity instead of
    % number of frames, the number of frames needs to be calculated and 
    % "slipped into" the data field.
    % Also note that we place the "pursuit" field into settings, to
    % distinguish between a "plain" vs a "pursuit" Target 3D stimulus.
    % This code is duplicated in animationLoop and getStimImages.
    % Target3D (in both versions) violates the "spirit" of Flyfly, by not
    % fitting into the framework of user-specified frame lengths.
    if strcmpi(name, 'target3dPrep') 

        % This next line is the hacky thing that makes the two stimuli work...
        % Afaik, you're not supposed to misuse settings in this way,
        % but there seem to be few other neat-ish solutions.
        % pursuit distinguishes between "Target 3D" and "Target 3D (Pursuit)".
        pursuit = Stimulus.layers(z).settings(1).pursuit;
        
        data = Stimulus.layers(z).data(1:end, TrialSubset);
        
        ret = prepareForTarget3D(pursuit, data, ScreenData.ifi, NumSubframes);
        
        % Now hack the number of frames back into data and settings!!
        data(end-3,:) = ret.num_frames;
        Stimulus.layers(z).data(1:end, TrialSubset) = data;

        % and now put the target start and end positions into settings, so the 
        % prep function can use them! (They have already been calculated,
        % so shouldn't calculate them again.)
        for k = 1:length(Stimulus.layers(z).settings(TrialSubset))
            idx = TrialSubset(k);
            Stimulus.layers(z).settings(idx).target_start = ret.target_start(:, k);
            Stimulus.layers(z).settings(idx).target_end = ret.target_end(:, k);
        end
    end 
    
    data     = Stimulus.layers(z).data(1:end, TrialSubset);
    impulse  = Stimulus.layers(z).impulse;

    % GET STIMULUS TIMES FOR EACH LAYER
    T.time(z,:)     = data(end-3,:);
    T.pause(z,:)    = data(end-2,:);
    T.preStim(z,:)  = data(end-1,:);
    T.postStim(z,:) = data(end,:);
    
    settings = Stimulus.layers(z).settings(1:end,TrialSubset);
    if settings(1).global
        for k = 2:length(settings)
            settings(k) = settings(1);
        end
    end
    
    % DLP or normal mode
    if ScreenData.dlp
        critInput{z} = fcnPrep(data, ScreenData, settings, 3);
    else
        critInput{z} = fcnPrep(data, ScreenData, settings, 1);
    end
    
    % save image data if using rolling image with auto generated image
    name = func2str(Stimulus.layers(z).fcnPrep);
    name = name(1:min(12, length(name)));
    if strcmp(name,'rollingImage');
        Stimulus.layers(z).images = critInput{z}.images;
        critInput{z} = rmfield(critInput{z},'images');
    end
    
    fcnDraw{z} = Stimulus.layers(z).fcnDraw;
end
fprintf('Done!\n');

% RGB difference between each trigger frame
if ScreenData.dlp
    triggerFlickOffset = 0;
else
    triggerFlickOffset = 105;
end

T.trialFrames = T.preStim + T.time + T.postStim + T.pause;
T.maxTrialFrames = max(T.trialFrames,[],1);

% Build frame matrix, this holds information on what layer frame to be
% drawn for each "real" frame and/or if the trigger should be visible.
% frameMatrix consists of as many cells as there are trials. Each of these
% cells contains a matrix, with one row for each layer plus one row for the
% trigger.
N = 0;
frameMatrix = cell(1,numRuns);
for k=1:numRuns
    frames = zeros(numLayers+1,1);
    for n=1:T.maxTrialFrames(k)
        N = N+1;
        for z=1:numLayers
            if ((n>T.preStim(z,k)) && (n<=(T.preStim(z,k)+T.time(z,k))))
                frames(z) = frames(z) + 1;
            else
                frames(z) = 0;
            end
        end
        if n>max(T.preStim(:,k)+T.time(:,k)+T.postStim(:,k))
            frames(end) = ScreenData.triggerRGBoff;
        else
            frames(end) = ScreenData.triggerRGBon - triggerFlickOffset*mod(N,2);
        end
        frameMatrix{k}(:,n) = frames;
    end
end

totalFrames = N;

%Animation loop internal parameters
%--------------------------------------------------------------------------
% Create struct and allocate memory for datalog

% Draw to all the RGBA channels (normal mode)
Screen('BlendFunction', ScreenData.wPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, [1 1 1 1]);

newPrio = MaxPriority(ScreenData.wPtr); %Find max prio of screen
Priority(newPrio);             %Set max prio

%SAVE PARAMETERS
%--------------------------------------------------------------------------

%Run through draw functions once to load them into memory
for z = 1:numLayers
    [~] = fcnDraw{z}(ScreenData.wPtr, 1, 1, 0, critInput{z});
end

Screen('FillRect', ScreenData.wPtr, 255); %fill with white
Screen('FillRect', ScreenData.wPtr, ScreenData.triggerRGBoff, ScreenData.triggerPos); %trigger off

% CRITICAL SECTION
%--------------------------------------------------------------------------

vbl = Screen('Flip', ScreenData.wPtr);

p = 1;

for k=1:length(frameMatrix)
    N = size(frameMatrix{k},2);
    n = 1;
    nd = 0;
    while (n<=N)
        tic     % measure draw time
        for z=1:(size(frameMatrix{k},1)-1)
            if (frameMatrix{k}(z,n)~=0)
                if ~ScreenData.dlp
                    %%% Normal mode %%%
                    critInput{z} = fcnDraw{z}(ScreenData.wPtr, frameMatrix{k}(z,n), k, 1/fps, critInput{z});
                else
                    %%% DLP mode
                    % It is assumed that the draw functions (fcnDraw) outputs only grayscale
                    % images, i.e. that for each pixel the R, G and B values are the same.
                    % Each subframe is then drawn to just one of the three RGB channels in
                    % the order BRG.
                    
                    % Draw first subframe to BLUE channel
                    [sourceFactorOld, destinationFactorOld, colorMaskOld] = ...
                        Screen('BlendFunction', ScreenData.wPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, [0 0 1 1]);
                    critInput{z} = fcnDraw{z}(ScreenData.wPtr, frameMatrix{k}(z,n)*3-2, k, 1/fps, critInput{z});
                    % Draw second subframe to RED channel
                    Screen('BlendFunction', ScreenData.wPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, [1 0 0 1]);
                    critInput{z} = fcnDraw{z}(ScreenData.wPtr, frameMatrix{k}(z,n)*3-1, k, 1/fps, critInput{z});
                    % Draw third subframe to GREEN channel
                    Screen('BlendFunction', ScreenData.wPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, [0 1 0 1]);
                    critInput{z} = fcnDraw{z}(ScreenData.wPtr, frameMatrix{k}(z,n)*3, k, 1/fps, critInput{z});
                    % Reset blend function to original values
                    Screen('BlendFunction', ScreenData.wPtr, sourceFactorOld, destinationFactorOld, colorMaskOld);
                end
            end
        end
        Screen('FillRect', ScreenData.wPtr, frameMatrix{k}(end,n), ScreenData.triggerPos);
        Screen('DrawingFinished',ScreenData.wPtr);  % supposedly speeds up performance
        
        imageArray{p} = Screen('GetImage', ScreenData.wPtr,[],'backBuffer');
        
        % Set background color to 'white' (the 'clear' color)
        glClearColor(1,1,1, 0);
        % Clear out the backbuffer
        glClear;
        
        %[vbl, ~, ~, ~, ~] = Screen('Flip', ScreenData.wPtr, vbl+(0.7)/fps);
        
        p = p+1;
        n = n+1;
    end
end

%Turn trigger off (end experiment)
Screen('FillRect', ScreenData.wPtr, 255);
Screen('FillRect', ScreenData.wPtr, ScreenData.triggerRGBoff, ScreenData.triggerPos); %trigger off
Screen('DrawingFinished',ScreenData.wPtr);
Screen('Flip', ScreenData.wPtr);

Priority(0); %set normal priority
%----------------------------------------------------------------------
% /CRITICAL SECTION

% Special stuff for the starfield cylinder stimulus
for z = 1:numLayers
    fcnName = func2str(Stimulus.layers(z).fcnPrep);
    if strcmp(fcnName,'starfieldCylPrep')
        Screen('BeginOpenGL', critInput{z}(1).extendedWinPtr);
        glBindTexture(critInput{z}(1).gltextarget, 0);
        glDisable(critInput{z}(1).gltextarget);
        glDeleteLists(critInput{z}(1).listindex, 1);
        Screen('EndOpenGL', critInput{z}(1).extendedWinPtr);
        break;
    end
end
