function skippedFrames = animationLoop(Stimulus, ScreenData, UserSettings, TrialSubset)
%function skippedFrames = animationLoop(Stimulus, ScreenData, UserSettings, TrialSubset)
% 
% This functions runs the loop that draws the stimuli to the screen in
% realtime. All the timing is handled from here.
% 
% Each layer is made up of two parts - A preparatory function that makes
% any neccesary pre-computations and a draw function which draws the layer
% to the screen.
% 
% Each frame the current frame number n and layer number z is used to
% calculate which draw functions should be called. The draw functions draw
% their objects to the screen and returns control to the animation loop. 
% When all drawing is finished the back buffer is flipped and the loop
% proceeds to the next frame. 
% 

%--------------------------------------------------------------------------
% FlyFly v2
%
% Jonas Henriksson, 2010                                   info@flyfly.se
%--------------------------------------------------------------------------

% GENERAL SETUP
%--------------------------------------------------------------------------

SKIP_PROP_THRESHOLD = 3;

numLayers = length(Stimulus.layers);
numRuns   = length(TrialSubset);

critInput = cell(numLayers,1);
fcnDraw = cell(numLayers,1);

%Screen data
%--------------------------------------------------------------------------
% FIRST CHANGE THE BACKGROUND COLOR in ScreenData!!
% ScreenData.beforeBgColor = ScreenData.bgColor;
% ScreenData.bgColor = ScreenData.targetBgColor;
% ScreenData = rmfield(ScreenData, 'targetBgColor');

S.triggerPos    = ScreenData.triggerPos;
S.monitorHz     = ScreenData.hz;
S.wPtr          = ScreenData.wPtr;
S.ifi           = ScreenData.ifi;
S.flyPos        = ScreenData.flyPos;
S.rect          = ScreenData.rect;
S.recording     = ScreenData.recording;
S.monitorHeight = ScreenData.monitorHeight;
S.triggerRGBon  = ScreenData.triggerRGBon;
S.triggerRGBoff = ScreenData.triggerRGBoff;

S.bgColor       = ScreenData.bgColor; 

NumSubframes = 1;

fprintf('Calculating (might take some time if you have a starfield with many dots)... ');
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

        % This is a secondary hacky solution that makes the idea of two stimuli work...
        % Afaik, you're not supposed to misuse settings in this way,
        % but there seem to be few other neat-ish solutions.
        % pursuit distinguishes between "Target 3D" and "Target 3D (Pursuit)".
        pursuit = Stimulus.layers(z).settings(1).pursuit;
        
        data = Stimulus.layers(z).data(1:end, TrialSubset);
        
        % prepareForTarget3D returns fields named "num_frames", "target_start",
        % "target_end". These are calculated based on input data, and are needed
        % later when the "real" prep function (target3dPrep) is executed.
        ret = prepareForTarget3D(pursuit, data, S.ifi, NumSubframes);
        
        % Now hack the number of frames back into data!
        data(end-3,:) = ret.num_frames;
        Stimulus.layers(z).data(1:end, TrialSubset) = data;

        % and now put the target start and end positions into settings, so the 
        % prep function can use them! 
        for k = 1:length(Stimulus.layers(z).settings(TrialSubset))
            idx = TrialSubset(k);
            Stimulus.layers(z).settings(idx).target_start = ret.target_start(:, k);
            Stimulus.layers(z).settings(idx).target_end = ret.target_end(:, k);
        end
    end 
    
    data     = Stimulus.layers(z).data(1:end, TrialSubset);
    impulse  = Stimulus.layers(z).impulse;

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
    
    critInput{z} = fcnPrep(data, ScreenData, settings, NumSubframes);

%     % General mechanism for storing general-purpose data related to
%     % the experiment that has been generated during preparation.
%     % Such data can be included in the "extraData" field returned by
%     % fcnPrep.
%     if isfield(critInput{z}, 'extraData')
%         Stimulus.layers(z).extraData = critInput{z}.extraData;
%     end

    % save image data if using rolling image with auto generated image
    if strncmp(name, 'rollingImage', length('rollingImage'))
        for k=1:length(settings)
            if ((strcmp(name(13),'P') && settings(k).box3{2}==1) || ...
                (strcmp(name(13),'M') && settings(k).box4{2}==1))
                Stimulus.layers(z).images = critInput{z}.images;
                critInput{z} = rmfield(critInput{z},'images');
                break;
            end
        end
    end
    
    fcnDraw{z} = Stimulus.layers(z).fcnDraw;
end
fprintf('Done!\n');

% RGB difference between each trigger frame
if S.recording
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
totalStimFrames = 0;
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
        if any(frames(1:end-1))  % this would be false if all layers are in pre or post stim time
            totalStimFrames = totalStimFrames + 1;
        end;
        if n>max(T.preStim(:,k)+T.time(:,k)+T.postStim(:,k))
            frames(end) = S.triggerRGBoff;
        else
            frames(end) = S.triggerRGBon - triggerFlickOffset*mod(N,2);
        end
        frameMatrix{k}(:,n) = frames;
    end
end

totalFrames = N;

%Animation loop internal parameters
%--------------------------------------------------------------------------
% Create struct and allocate memory for datalog
K = max(T.maxTrialFrames(k));
dataLog = struct('frames',cell(1),'time',cell(1),'frameDelay',cell(1),'missed',cell(1));
dataLog = repmat(dataLog,numRuns,K);

% Draw to all the RGBA channels (normal mode)
Screen('BlendFunction', S.wPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, [1 1 1 1]);

newPrio = MaxPriority(S.wPtr); %Find max prio of screen
Priority(newPrio);             %Set max prio

timeStart          = datestr(now, 0); %time as datestr
timeStartPrecision = clock; %exact time (ms precision) as time vector

disp(' ');
disp('---------------------------------------------------------- ');
disp([' Experiment ' Stimulus.name ' starting at ' timeStart]);
disp('---------------------------------------------------------- ');

%SAVE PARAMETERS
%--------------------------------------------------------------------------
if UserSettings.saveParameters
    ddstimulus = struct(Stimulus);
    ddstimulus = rmfield(ddstimulus, 'hGui');   % opens figure and causes Matlab to hang
    % DEBUGDATA CREATED HERE!
    debugData.stimulus = ddstimulus;
    debugData.screenData   = ScreenData;
    debugData.userSettings = UserSettings;
    debugData.trialSubset  = TrialSubset;
    
    Stimulus   = formatStimulus(Stimulus); %Parameters used in an easier to read format    
    pathName   = UserSettings.saveDataPathName;
    timeStart  = regexprep(timeStart, ':', '_'); %(replaces ':' with '_' in string)
    
    fileName   = strcat(pathName, '/', Stimulus.name, '-', timeStart);
    message    = 'NOTE: THIS RUN WAS ABORTED';
    
    % only save the parameters of the executed trial subset
    for l=1:length(Stimulus.layers)
        Stimulus.layers(l).Param = Stimulus.layers(l).Param(TrialSubset);
        Stimulus.layers(l).settings = Stimulus.layers(l).settings(TrialSubset);
    end
    
    
    save(fileName, 'timeStart', 'timeStartPrecision', 'debugData', 'Stimulus', 'message');
    disp(['Parameters saved to ' fileName]);
    disp(' ');
end
%--------------------------------------------------------------------------

%Run through draw functions once to load them into memory
for z = 1:numLayers
    [~] = fcnDraw{z}(S.wPtr, 1, 1, 0, critInput{z});
end


Screen('FillRect', S.wPtr, S.bgColor); %fill with required background colour
Screen('FillRect', S.wPtr, S.triggerRGBoff, S.triggerPos); %trigger off

% CRITICAL SECTION
%--------------------------------------------------------------------------

vbl = Screen('Flip', S.wPtr);

critSecStart = tic;

drawTime = [];

missedFrames = 0;

for k=1:length(frameMatrix)
    fprintf(' - TRIAL %d starting at %.6f s -\n\n',k,toc(critSecStart));
    N = size(frameMatrix{k},2);
    n = 1;
    nd = 0;
    while (n<=N)
        tic     % measure draw time
        for z=1:(size(frameMatrix{k},1)-1)
            if (frameMatrix{k}(z,n)~=0)
                %%% Normal mode %%%
                if Stimulus.layers(z).impulse
                    arg_n = 1;
                else
                    arg_n = frameMatrix{k}(z,n);
                end
                critInput{z} = fcnDraw{z}(S.wPtr, arg_n, k, ScreenData.ifi, critInput{z});
            end
        end
        Screen('FillRect', S.wPtr, frameMatrix{k}(end,n), S.triggerPos);
        Screen('DrawingFinished',S.wPtr);  % supposedly speeds up performance
        
        drawTime = [drawTime; toc];
        
        [vbl, ~, ~, missed, ~] = Screen('Flip', S.wPtr, vbl+(0.7)*S.ifi);
        
        nd = nd+1;
        dataLog(k,nd).time = toc(critSecStart);      % the time when the Flip finished executing (when the frame was displayed)
        dataLog(k,nd).frames = frameMatrix{k}(:,n);  % which frame from each layers was displayed, and trigger value
        dataLog(k,nd).missed = missed;               % the 'missed' returned value
        if (missed>0)
            if (n==1) && (k==1) % First frame cannot be missed
                missedFrames = 0;
            else
                missedFrames = ceil(missed/(S.ifi*1.05));   % how many frames was the Flip delayed (estimate)
            end
        else
            missedFrames = 0;
        end
        dataLog(k,nd).frameDelay = missedFrames;
        
        n = n+1+missedFrames;
    end
end

totalStimTime = toc(critSecStart);
timeFinish    = datestr(now, 0);

%Turn trigger off (end experiment)
Screen('FillRect', S.wPtr, S.bgColor);
Screen('FillRect', S.wPtr, S.triggerRGBoff, S.triggerPos); %trigger off
Screen('DrawingFinished',S.wPtr);
Screen('Flip', S.wPtr, vbl+(0.7)*S.ifi);

Priority(0); %set normal priority
%----------------------------------------------------------------------
% /CRITICAL SECTION

% Special stuff for the starfield stimulus which is drawn on a opengl 3d
% cylinder object
for z = 1:numLayers
    if strcmp(func2str(Stimulus.layers(z).fcnPrep),'starfieldCylPrep')
        Screen('BeginOpenGL', critInput{z}(1).extendedWinPtr);
        glBindTexture(critInput{z}(1).gltextarget, 0);
        glDisable(critInput{z}(1).gltextarget);
        glDeleteLists(critInput{z}(1).listindex, 1);
        Screen('EndOpenGL', critInput{z}(1).extendedWinPtr);
        break;
    end
end

numTrials = size(dataLog,1);
frames = zeros(numTrials,1);
skippedFrames = zeros(numTrials,1);
skippedStimFrames = zeros(numTrials,1);
% Determine how many frames that were actually missed during stimuli
for i=1:numTrials
    skippedFrames(i) = sum([dataLog(i,:).frameDelay]);
    for j=1:size(dataLog,2)
        if ~isempty(dataLog(i,j).frames)
            frames(i) = frames(i) + 1;
            skippedStimFrames(i) = skippedStimFrames(i) + ...
                (sum(dataLog(i,j).frames)>0)*dataLog(i,j).frameDelay;
        end
    end
    %fprintf('%d %d\n',sum(length(arrayfun(@isempty,frameMatrix{i}(end,:)))), ...
    %    frames(i)+skippedFrames(i));
end

fprintf('SUMMARY:\n');
fprintf('Total time: %.6f s\n', totalStimTime);
fprintf('Skipped frames: %d out of %d (%.3f%%) -- TOTAL frame time\n', sum(skippedFrames), totalFrames, 100*sum(skippedFrames)/totalFrames);

%fprintf('Skipped during stimuli: %d\n', sum(skippedStimFrames));
ssf = sum(skippedStimFrames);
ssfp = 100*sum(skippedStimFrames)/totalStimFrames;
fprintf('Skipped frames during stimuli: %d out of %d (%.3f%%) -- STIMULUS frame time\n', ssf, totalStimFrames, ssfp);
if ssfp > SKIP_PROP_THRESHOLD
    skipped_msg = sprintf('Number of frames skipped exceeds %d%%:\n %d out of %d frames (%.3f%%)\n', SKIP_PROP_THRESHOLD, ssf, totalStimFrames, ssfp);
    msgbox(skipped_msg, 'Warning', 'warn');
end;

% Check if the skipped frame count is correct
for i=1:numTrials
    if sum(length(arrayfun(@isempty,frameMatrix{i}(end,:))))~=(frames(i)+skippedFrames(i))
        fprintf('Something went wrong with the skipped frame count for trial %d! Don''t use this experiment!\n',i);
    end
end
fprintf('Average draw load: %.2f%%, min: %.2f%%, max: %.2f%%, std: %.2f%%\n\n', ...
    100*mean(drawTime)/S.ifi, 100*min(drawTime)/S.ifi, 100*max(drawTime)/S.ifi, 100*std(drawTime)/S.ifi);

% Ouput total skipped frames
skippedFrames = sum(skippedFrames);

%SAVE PARAMETERS
if UserSettings.saveParameters
    
    debugData.dataLog    = dataLog;
    
    pathName   = UserSettings.saveDataPathName;    
    timeFinish = regexprep(timeFinish, ':', '_'); %replaces ':' with '_' in string
    fileName   = strcat(pathName, '/', Stimulus.name, '-', timeStart);
    message    = 'NOTE: STIMULUS PLAYED TO THE END';
    
    try
        %{
      ddstimulus = struct(debugData.stimulus); 
      ddstimulus = rmfield(ddstimulus, 'hGui');   % opens figure and causes Matlab to hang
      debugData.stimulus = ddstimulus; 
        %}
      save(fileName, 'timeStart', 'timeStartPrecision', 'timeFinish', 'debugData', 'Stimulus', 'message' );
    catch e
        disp('Error saving file... Retrying... (1)');
        pause(2);
        try
            save(fileName, 'timeStart', 'timeStartPrecision', 'timeFinish', 'debugData', 'Stimulus', 'message' );
        catch e
            disp('Error saving file... Retrying... (2)');
            pause(2);
            save(fileName, 'timeStart', 'timeStartPrecision', 'timeFinish', 'debugData', 'Stimulus', 'message' );
        end
    end
    
    disp(['Skipped frames and total time saved to ' fileName]);
    disp('---------------------------------------------------------- ');
else
    disp(['Parameter saving disabled']);
end