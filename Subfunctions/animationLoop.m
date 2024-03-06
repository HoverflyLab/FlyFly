function skippedFrames = animationLoop(stimulus, screenData, userSettings, trialSubset)
%function skippedFrames = animationLoop(Stimulus, ScreenData, UserSettings, TrialSubset, video)
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

numLayers = length(stimulus.layers);
numRuns   = length(trialSubset);

critInput = cell(numLayers,1);
fcnDraw = cell(numLayers,1);

navData = getappdata(0, 'navData');

%Screen data
%--------------------------------------------------------------------------
% FIRST CHANGE THE BACKGROUND COLOR in ScreenData!!
% ScreenData.beforeBgColor = ScreenData.bgColor;
% ScreenData.bgColor = ScreenData.targetBgColor;
% ScreenData = rmfield(ScreenData, 'targetBgColor');

S.triggerPos    = screenData.triggerPos;
S.monitorHz     = screenData.hz;
S.wPtr          = screenData.wPtr;
S.ifi           = screenData.ifi;
S.flyPos        = screenData.flyPos;
S.rect          = screenData.rect;
S.recording     = screenData.recording;
S.monitorHeight = screenData.monitorHeight;
S.triggerRGBon  = screenData.triggerRGBon;
S.triggerRGBoff = screenData.triggerRGBoff;
cameraSettings  = screenData.cameraSettings;

S.bgColor       = screenData.bgColor; 

NumSubframes = 1;
video.FramesPerTrigger = Inf;

fprintf('Calculating (might take some time if you have a starfield with many dots)... ');
for z = 1:numLayers

    % GET CRITICAL INPUT AND DRAW FUNCTION FOR EACH LAYER
    fcnPrep  = stimulus.layers(z).fcnPrep;
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
        pursuit = stimulus.layers(z).settings(1).pursuit;
        
        data = stimulus.layers(z).data(1:end, trialSubset);
        
        % prepareForTarget3D returns fields named "num_frames", "target_start",
        % "target_end". These are calculated based on input data, and are needed
        % later when the "real" prep function (target3dPrep) is executed.
        ret = prepareForTarget3D(pursuit, data, S.ifi, NumSubframes);
        
        % Now hack the number of frames back into data!
        data(end-3,:) = ret.num_frames;
        stimulus.layers(z).data(1:end, trialSubset) = data;

        % and now put the target start and end positions into settings, so the 
        % prep function can use them! 
        for k = 1:length(stimulus.layers(z).settings(trialSubset))
            idx = trialSubset(k);
            stimulus.layers(z).settings(idx).target_start = ret.target_start(:, k);
            stimulus.layers(z).settings(idx).target_end = ret.target_end(:, k);
        end
    end 
    
    data     = stimulus.layers(z).data(1:end, trialSubset);
    impulse  = stimulus.layers(z).impulse;

    T.time(z,:)     = data(end-3,:);
    T.pause(z,:)    = data(end-2,:);
    T.preStim(z,:)  = data(end-1,:);
    T.postStim(z,:) = data(end,:);
    
    settings = stimulus.layers(z).settings(1:end,trialSubset);
    if settings(1).global
        for k = 2:length(settings)
            settings(k) = settings(1);
        end
    end
    
    critInput{z} = fcnPrep(data, screenData, settings, NumSubframes);

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
                stimulus.layers(z).images = critInput{z}.images;
                critInput{z} = rmfield(critInput{z},'images');
                break;
            end
        end
    end
    
    fcnDraw{z} = stimulus.layers(z).fcnDraw;
end
fprintf('Done!\n');

% RGB difference between each trigger frame
triggerFlickOffset = 105;

% Set up connection to cammera equipment
if S.recording ~= 0
    % Create video object
    video = videoinput(screenData.videoAdaptor, 1);
    % Set up location and filename
    videoLocation = navData.saveDataPathName;
    videoName = "recording1.avi";
    fullVideoName = fullfile(videoLocation, videoName);
    
    % Create and configure the video writer
    logfile = VideoWriter(fullVideoName, "Motion JPEG AVI");
    
    % Configure the device to log to disk using the video writer
    video.LoggingMode = "disk";
    video.DiskLogger = logfile;
    % Make sure camera records until we tell it to stop
    video.FramesPerTrigger = Inf;

    % Apply all user selected camera settings
    vidSrc = getselectedsourc(video);
    vidSrc.Brightness = 0;
    vidSrc.Contrast = 0;
    vidSrc.FrameRate = 0;
    vidSrc.HorizontalFlip = 0;
    vidSrc.VerticalFlip = 0;
    vidSrc.PowerLineFrequency = 0;
    vidSrc.Saturation = 0;
    vidSrc.Sharpness = 0;
    vidSrc.WhiteBalanceMode = 0;
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
        end
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

timeStart          = string(datetime('now')); %time as datestr
timeStartPrecision = clock; %exact time (ms precision) as time vector

disp(' ');
disp('---------------------------------------------------------- ');
disp(' Experiment ' + stimulus.name + ' starting at ' + timeStart);
disp('---------------------------------------------------------- ');

%SAVE PARAMETERS
%--------------------------------------------------------------------------
if userSettings.saveParameters
    ddstimulus = struct(stimulus);
    ddstimulus = rmfield(ddstimulus, 'hGui');   % opens figure and causes Matlab to hang
    % DEBUGDATA CREATED HERE!
    debugData.stimulus = ddstimulus;
    debugData.screenData   = screenData;
    debugData.userSettings = userSettings;
    debugData.trialSubset  = trialSubset;
    
    stimulus   = formatStimulus(stimulus); %Parameters used in an easier to read format    
    pathName   = userSettings.saveDataPathName;
    timeStart  = regexprep(timeStart, ':', '_'); %(replaces ':' with '_' in string)
    
    fileName   = strcat(pathName, '/', stimulus.name, '-', timeStart);
    message    = 'NOTE: THIS RUN WAS ABORTED';
    
    % only save the parameters of the executed trial subset
    for l=1:length(stimulus.layers)
        stimulus.layers(l).Param = stimulus.layers(l).Param(trialSubset);
        stimulus.layers(l).settings = stimulus.layers(l).settings(trialSubset);
    end
    
    
    save(fileName, 'timeStart', 'timeStartPrecision', 'debugData', 'stimulus', 'message');
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

for k=1:length(frameMatrix)
    fprintf(' - TRIAL %d starting at %.6f s -\n\n',k,toc(critSecStart));
    N = size(frameMatrix{k},2);
    n = 1;
    nd = 0;
    %Start recording video if desired
    if S.recording ~= 0
        startcam(k,T.pause(z,:),1:length(frameMatrix), video);
    end
    while (n<=N)
        tic     % measure draw time
        for z=1:(size(frameMatrix{k},1)-1)
            if (frameMatrix{k}(z,n)~=0)
                %%% Normal mode %%%
                if stimulus.layers(z).impulse
                    arg_n = 1;
                else
                    arg_n = frameMatrix{k}(z,n);
                end
                critInput{z} = fcnDraw{z}(S.wPtr, arg_n, k, screenData.ifi, critInput{z});
            end
        end
        Screen('FillRect', S.wPtr, frameMatrix{k}(end,n), S.triggerPos);
        Screen('DrawingFinished',S.wPtr);  % supposedly speeds up performance
        
        drawTime = [drawTime; toc];
        
        [vbl, ~, ~, missed, ~] = Screen('Flip', S.wPtr, vbl+(0.7)*S.ifi);
        
        nd = nd+1;
        tStamp = toc(critSecStart);
        dataLog(k,nd).time = tStamp;                 % the time when the Flip finished executing (when the frame was displayed)
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
    if S.recording ~= 0
        stopcam(k, T.pause(z,:), 1:length(frameMatrix), video);
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
    if strcmp(func2str(stimulus.layers(z).fcnPrep),'starfieldCylPrep')
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
end

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
if userSettings.saveParameters
    
    debugData.dataLog    = dataLog;
    
    pathName   = userSettings.saveDataPathName;    
    timeFinish = regexprep(timeFinish, ':', '_'); %replaces ':' with '_' in string
    fileName   = strcat(pathName, '/', stimulus.name, '-', timeStart);


    message    = 'NOTE: STIMULUS PLAYED TO THE END';
    
    try
        %{
      ddstimulus = struct(debugData.stimulus); 
      ddstimulus = rmfield(ddstimulus, 'hGui');   % opens figure and causes Matlab to hang
      debugData.stimulus = ddstimulus; 
        %}
      save(fileName, 'timeStart', 'timeStartPrecision', 'timeFinish', 'debugData', 'stimulus', 'message' );
      
      if S.recording~=0
        videoName = strcat(fileName, '.avi');
        movefile(fullVideoName, videoName);
      end
    catch
        disp('Error saving file... Retrying... (1)');
        pause(2);
        try
            save(fileName, 'timeStart', 'timeStartPrecision', 'timeFinish', 'debugData', 'stimulus', 'message' );
        catch
            disp('Error saving file... Retrying... (2)');
            pause(2);
            save(fileName, 'timeStart', 'timeStartPrecision', 'timeFinish', 'debugData', 'stimulus', 'message' );
        end
    end
    
    disp(['Skipped frames and total time saved to ' fileName]);
    disp('---------------------------------------------------------- ');
else
    disp('Parameter saving disabled');
end

%Written By Chris Johnston - chris.johnstonaus@gmail.com 14/04/21
% Function to start recording from webcam (Current Trial Number, 
% trial pause times in frames, list of trials)
function startcam(TRun, Pauset, Tlength, video) 
if TRun <= length(Tlength)
    nPause = Pauset(:,TRun); % Current trials Pause time in frames
    
    if ((nPause == 0) && (TRun == 1)) % Checks if there is a pause and if it's the first trial
            start(video); % Starts Recording
    end
    if(TRun > 1) % Runs if there is more than one trial
        lPause = Pauset(:,TRun-1); % Gets previous trial time in frames
        if((nPause == 0) && (lPause ~= 0)) % Checks if current frame time is 0 and if the last pause time was not 0
            start(video); % Starts a recording
        end
    end
end


function stopcam(TRun, Pauset, Tlength, video)% Function to stop recording video from webcam (Current Trial Number, Current trial pause time in frames, list of trials,Time of Stimulus Start, Stimulus Name)
if TRun <= length(Tlength) 
    if(TRun ~= length(Tlength))
        nPause = Pauset(:,TRun+1);
    else
        nPause = Pauset(:,TRun);
    end  
    %disp(nPause);
    if (nPause ~= 0)
        disp('pause is more than 0, Ending Recording');
        stop(video);
        % Double check video has saved properly before moving on
        while video.FramesAcquired ~= video.DiskLoggerFrameCount
            pause(.1);
        end
    else
        %disp('Gets this far');
        L = length(Tlength);
        if(TRun == L)
            disp('End of Trials, Ending Recording');
            stop(video);
            % Double check video has saved properly before moving on
            while video.FramesAcquired ~= video.DiskLoggerFrameCount
                pause(.1);
            end
        end
    end
end
