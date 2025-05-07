function [critInput] = prTargetPrep(Parameters, ScreenData, StimSettings, NumSubframes)
    %
    % Prepares input parameters for rectTargetDraw
    %--------------------------------------------------------------------------
    % FlyFly v3.1
    %
    % Richard Leibbrandt, 2017
    %------------------------------------------------------------`--------------
    NUM_TRIALS = size(Parameters, 2);
    Xstart = Parameters(5, :);
    Ystart = Parameters(6, :);
    Xend = Parameters(7, :);
    Yend = Parameters(8, :);
    MOVING_FRAMES = Parameters(10, 1);
    FRAMES_PER_TRIAL = Parameters(11, 1);

    STATIONARY_FRAMES = FRAMES_PER_TRIAL - MOVING_FRAMES;
    NUM_FRAMES = FRAMES_PER_TRIAL * NUM_TRIALS;

    target_halfwidth = 7;
    target_halfheight = 7;

    if ScreenData.usePartial
        WIDTH   = ScreenData.partial(3);
        HEIGHT  = ScreenData.partial(4);
    else
        screenRes = get(0, 'ScreenSize');   %[1 1 screenWidth screenHeight]
        WIDTH   = screenRes(3);
        HEIGHT  = screenRes(4);  
    end

    % width_adj = floor(WIDTH/2 - SUBWIDTH/2);
    % height_adj = max(HEIGHT-SUBHEIGHT-120, floor(HEIGHT/2 - SUBHEIGHT/2));

    % [Xstart, Ystart, Xend, Yend] = ...
    %     generateXY(NUM_TRIALS, SPEED, MOVE_DURATION, SUBWIDTH, SUBHEIGHT);

    % fps = 1/ScreenData.ifi;
    % STATIONARY_FRAMES = round(0.15*fps);
    % MOVING_FRAMES = round(0.1*fps);
    % FRAMES_PER_TRIAL = STATIONARY_FRAMES + MOVING_FRAMES;
    % NUM_FRAMES = FRAMES_PER_TRIAL * NUM_TRIALS;

    D = zeros(NUM_FRAMES, 2);

    for t = 1:NUM_TRIALS
        disp(t);
        iblock = zeros(FRAMES_PER_TRIAL, 2);
        srange = 1:STATIONARY_FRAMES;
        % need the zero in the following line as we will double-write the first
        % one! hack, hack
        mrange = STATIONARY_FRAMES + (0:MOVING_FRAMES);
        iblock(srange, 1) = Xstart(t);
        iblock(srange, 2) = Ystart(t); 
        iblock(mrange, 1) = round(linspace(Xstart(t), Xend(t), MOVING_FRAMES+1));
        iblock(mrange, 2) = round(linspace(Ystart(t), Yend(t), MOVING_FRAMES+1));

        D(((t-1)*FRAMES_PER_TRIAL+1):t*FRAMES_PER_TRIAL, :) = iblock;
        iblock = [iblock(:,1)-target_halfwidth,  iblock(:,2)-target_halfheight, ...
                 iblock(:,1)+target_halfwidth,   iblock(:,2)+target_halfheight];

        % Crop any targets that stray out of the screen (they will just be displayed on
        % the screen edge for the remainder of the trial, so that timing is not
        % affected). In practice, it should be possible to choose a box location
        % so this will never happen.
        iblock(:, 1) = min(max(1, iblock(:, 1)), WIDTH);
        iblock(:, 2) = min(max(1, iblock(:, 2)), HEIGHT);

        critInput(t).pos = iblock;
        critInput(t).rgb = [0; 0; 0];
    end

    D = [zeros(NUM_FRAMES, 4) D zeros(NUM_FRAMES, 7)];
    % outfile = 'debug/3000scan.flinders.txt';
    %dlmwrite(outfile, D, ' ');
%    critInput.extraData.xymatrix = D;

end


