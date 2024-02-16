function layer = getLayer(Name)
% All different layers are defined here.
%

%--------------------------------------------------------------------------
% FlyFly v2
%
% Jonas Henriksson, 2010                                   info@flyfly.se
%--------------------------------------------------------------------------

%default settings for all objects
settings.global = 1;
settings.path1  = {'OFF', 0};
settings.box1   = {'OFF', 0};
settings.box2   = {'OFF', 0};
settings.box3   = {'OFF', 0};
settings.box4   = {'OFF', 0};
settings.box5   = {'OFF', 0};
settings.edit1  = {'OFF', 0};
settings.edit2  = {'OFF', 0};
settings.edit3  = {'OFF', 0};
settings.edit4  = {'OFF', 0};
settings.edit5  = {'OFF', 0};

% experiment_names = {'Rect Target', 'Sine Grating', 'Rolling Image', ...
%             'Color Fill', '.Mat Sequence', 'Aperture', 'Flicker Rect', ...
%             'White Noise', 'Sine Grating RF', 'Mouse Target', 'Grid', ...
%             'TextString', 'Rolling Image MII', 'Dual Apertures', ...
%             'Starfield 1: Cylinder', 'Starfield 2: 3D Space', '3D Target', ...
%             'Image Target' 'Paloma Target Replication', '3D Target (Pursuit)', ...
%             'Starfield 3: Jumps'};
   
experiment_names = {...
    'Rect Target', 'Image Target', '3D Target', ...                 % 1, 2, 3
    'Sine Grating', 'Color Fill', 'Rolling Image', ...              % 4, 5, 6
    'Rolling Image MII', 'Starfield 2: 3D Space', 'Starfield 3: Jumps', ... % 7, 8, 9
    '---- OTHER STIMULI ----', ...                                  % 10 (dummy)
    'Sine Grating RF', 'Aperture', 'Dual Apertures', ...            % 11, 12, 13
    'Flicker Rect', 'Mouse Target', 'Grid', ...                     % 14, 15, 16
    '.Mat Sequence', 'Paloma Target Replication', ...               % 17, 18
    'Loom', 'Image Target Flicker', 'Target3D XYZ', 'RectTarget Relative', ...
    'Starfield Flicker'};                                                        % 19
        
% common_data = the default timing data
common_data = [60; 0; 0; 0];
% If individual stimuli require something other than the default, modify
% timing_data instead of common_data
timing_data = common_data;

switch Name
    
    case 'List' %return list of available draw functions
        layer = experiment_names;
        
    otherwise
        switch Name
            case 1 %Rect Target
                
                fcnPrep = @rectTargetPrep;
                fcnDraw = @rectTargetDraw;
                
                data = [ 5; 5; 100; 100; 60; 0; 0];
                
                rowNames = {'Height', 'Width', 'Xpos', 'Ypos',...
                    'Velocity', 'Direction', 'Brightness'};
                               
            case 2 %Image Target
                
                fcnPrep = @imgTargetPrep;
                fcnDraw = @imgTargetDraw;
                
                 settings.path1  = {'Image Path', 'Images/circle_black.png', '*.*'};
                
                 data = [ 0; 0; 20; 20; 60; 0; 1];
                
                rowNames = {'Height', 'Width', 'Xpos', 'Ypos',...
                    'Velocity', 'Direction', 'Contrast'};   
                
            case 3 %3d Target
                
                fcnPrep = @target3dPrep; 
                fcnDraw = @target3dDraw; 
                
               data = [1; 0; 0; 50; 0; 0; 20; 10; 0];
                
                rowNames = {'Target Size', 'Target Start Azimuth', 'Target Start Elevation', 'Target Start Distance', ...
                    'Target End Azimuth', 'Target End Elevation', 'Target End Distance', ...
                    'Velocity', 'Target Noise'};
                
                settings.global = 0;
                settings.pursuit = false;
               
            case 4 %Sine grating
                
                fcnPrep = @sineGratingPrep;
                fcnDraw = @sineGratingDraw;
                
                data = [ 20; 2; 0; 200; 200; 100; 100; 1];
                
                rowNames = {'Wavelength', 'Temporal Freq', 'Direction', ...
                    'PatchHeight', 'patchWidth', 'Patch Xpos', 'Patch Ypos',...
                    'Contrast'};
                
            case 5 %Color Fill
                
                fcnPrep = @colorFillPrep;
                fcnDraw = @colorFillDraw;
                
                data = [127];
                
                rowNames = {'Brightness'};            
            
            case 6 %Rolling Image
                
                fcnPrep = @rollingImagePrep;
                fcnDraw = @rollingImageDraw;
                
                data = [ 10; 0; 320; 240; 480; 640; 0; 1];
                
                rowNames = {'Speed', 'Direction', 'Xpos', 'Ypos',...
                    'Height', 'Width', 'Offset', 'Contrast'};
                
                settings.path1  = {'Image Path', 'Images/defaultImage.png', '*.png'};
                settings.box1   = {'Keep Offset', 0};
                settings.box2   = {'DLP  mode', 0};
                settings.box3   = {'Generate image', 0};
                settings.box4   = {'Horizontal bars', 0};
                
                settings.edit3  = {'(width)','640'};
                settings.edit4  = {'(height)','480'};
                
           case 7 %Rolling Image MII
                
                fcnPrep = @rollingImageM2Prep;
                fcnDraw = @rollingImageM2Draw;
                
                data = [0; 100; 100; 200; 200; 1];
                
                rowNames = {'Direction', 'Xpos', 'Ypos',...
                    'Height', 'Width', 'Contrast'};
                
                settings.path1  = {'Image Path', 'Images/defaultImage.png', '*.png'};
                settings.box1   = {'Image offset = ', 1};
                settings.box2   = {'X pos = Xpos + ', 0};
                settings.box3   = {'Y pos = Ypos + ', 0};
                settings.box4   = {'Generate image', 0};
                settings.box5   = {'Horizontal bars', 0};
                
                %T: Total experiment time
                %t: Time in current trial
                %n: Number of frames in total
                %k: Current trial
                settings.edit1  = {'(internal roll)', '100*abs(2*(n/1 - floor(n/1+0.5)))'}; %period 1s
                settings.edit2  = {'(patch movement)', '100*sin(n)'};
                settings.edit3  = {'(patch movement)', '100*cos(n)'};
                settings.edit4  = {'(width)','640'};
                settings.edit5  = {'(height)','480'};
      
            case 8 %Starfield 2
                
                fcnPrep = @starfieldPrep; %@starfieldCylPrep; 
                fcnDraw = @starfieldDraw; %@starfieldCylDraw;
                
               data = [2; 1; 0; 0; 0; 0; 0; 0; 0; 0];
                
                rowNames = {'Dot size', 'Dot density', ...
                    'Sideslip',  'Lift', 'Thrust', 'Pitch', 'Yaw', 'Roll', ...
                    'Background Noise', 'Retain into next Trial'};
                
             case 9 %Starfield 3
                
                fcnPrep = @starfield3Prep2; 
                fcnDraw = @starfield3Draw; 
                
                data = [2; 1; 0; 0; 0; 0; 0; 0; 1];
                
                rowNames = {'Dot size', 'Dot density', ...
                    'Sideslip',  'Lift', 'Thrust', 'Pitch', 'Yaw', 'Roll', 'Duration'}; 
            
            case 10 % DUMMY - set everything to null
                fcnPrep = [];
                fcnDraw = [];
                data = [];
                rowNames = {};

            case 11 %sine grating Rf
                
                fcnPrep = @sineGratingRfPrep;
                fcnDraw = @sineGratingRfDraw;
                
                data = [ 20; 2; 0; 16; 200; 200; 100; 100; 1];
                
                rowNames = {'Wavelength', 'Temporal Freq', 'Starting Direction', 'Steps' ...
                    'PatchHeight', 'patchWidth', 'Patch Xpos', 'Patch Ypos', 'Contrast'};
                
                settings.box1   = {'Counter Clockwise', 0};
                
            case 12 %Aperture
                
                fcnPrep = @aperturePrep;
                fcnDraw = @apertureDraw;
                
                data = [50; 0; 100; 100; 320; 280];
                
                rowNames = {'Transp Surround', 'Transp Hole', 'Width', 'Height', 'Xpos', 'Ypos'};
                
                settings.box1   = {'Use Rect', 0};
                
            
           case 13 %Dual Apertures
                
                %Created by Olof J�nsson
                
                fcnPrep = @DualAperturesPrep;
                fcnDraw = @DualAperturesDraw;
                
                data = [255; 127; 0; 255; 100; 100; 320; 280; 50; 50; 100; 100];
                
                rowNames = {'Opacity Surround', 'Brightness Surround', 'Opacity Hole', ...
                    'Brightness Hole', 'Width', 'Height', 'Xpos', 'Ypos' ...
                    'Width2', 'Height2', 'Xpos2', 'Ypos2'};
                
                settings.box1   = {'Use Rect for 1', 0};
                settings.box2   = {'Use Rect for 2', 0};
            
            case 14 %Flicker rect
                
                fcnPrep = @flickerRectPrep;
                fcnDraw = @flickerRectDraw;
                
                data = [ 100; 80; 320; 240; 2; 0; 255];
                
                rowNames = {'Height', 'Width', 'Xpos', 'Ypos',...
                    'FramesPerFlicker', 'Brightness 1', 'Brightness 2'};
                
                settings.box1  = {'Offset X function', 0};
                settings.box2  = {'Offset Y function', 0};
                settings.edit1 = {'X function: ', '100*sin(2*pi/3 *(n-1)*ifi)'};
                settings.edit2 = {'Y function: ', '100*cos(2*pi/3 *(n-1)*ifi)'};
    
            case 15 %mouse target
                
                fcnPrep = @mouseTargetPrep;
                fcnDraw = @mouseTargetDraw;
                
                data = [ 5; 100; 0];
                
                rowNames = {'Width', 'Height', 'Brightness'};
                
            case 16 %grid
                
                fcnPrep = @gridPrep;
                fcnDraw = @gridDraw;
                
                data = [];
                
                rowNames = {};
                
            case 17 %Mat sequence
                
                fcnPrep = @matSequencePrep;
                fcnDraw = @matSequenceDraw;
                
                data = [160; 320; 240];
                
                rowNames = {'Fps', 'Xpos', 'Ypos'};
                
                settings.global = 0;
                settings.path1  = {'.Mat path: ', [cd '/Mat sequences/out.mat'], '*.mat'};
                settings.box1   = {'Use fullscreen', 0};
                
            case 18 %Paloma Target Replication
                
                fcnPrep = @prTargetPrep;
                fcnDraw = @prTargetDraw;
                                
                data = [720; 720; 1280; 1080; 0; 0; 0; 0; 900; 17];
                rowNames = {'Window Width', 'Window Height', 'Window X', 'Window Y', ...
                    'X Start', 'Y Start', 'X End', 'Y End', ...
                    'Speed in pixels per s', ...
                    'Motion Time'};
                timing_data = [41; 20; 20; 20];                

            case 19 %Loom
                fcnPrep = @loomPrep;
                fcnDraw = @loomDraw;
                
                settings.path1  = {'Image Path', 'Images/circle_black.png', '*.*'};
                         
                data = [10; 10; 200; 200; 100; 0; 1; -1; 0];
                rowNames = {'L_HalfDiameter_m', 'V_Velocity_m_per_s', ...
                    'XPos', 'YPos', 'StopSize_pixels', 'LoomTime', ...
                    'Contrast1', 'Contrast2', 'FlickerFramesPerCycle'};   
                
            case 20 %Image Target Flicker
                
                fcnPrep = @imgTargetFlickerPrep;
                fcnDraw = @imgTargetFlickerDraw;
                
                 settings.path1  = {'Image Path', 'Images/circle_black.png', '*.*'};
                
                 data = [ 0; 0; 20; 20; 60; 0; 1; -1; 0];
                
                rowNames = {'Height', 'Width', 'Xpos', 'Ypos',...
                    'Velocity', 'Direction', 'Contrast1', 'Contrast2', 'FlickerFramesPerCycle'};  
                
                
            case 21 %Target 3d XYZ
                
                fcnPrep = @target3dXYZPrep;
                fcnDraw = @target3dXYZDraw;
                
                data = [ 0.8; 0; 0; 0];
                
                rowNames = {'Size', 'X', 'Y', 'Z'};
                
            case 22 %Relative Rect Target
                
                fcnPrep = @Relative_rectTargetPrep;
                fcnDraw = @Relative_rectTargetDraw;
                
                data = [ 5; 5; 100; 100; 60; 0; 0; 0; 0];
                
                rowNames = {'Height', 'Width', 'Xpos', 'Ypos',...
                    'Velocity', 'Direction', 'Brightness','XposOffset','YposOffset'};
               
            case 23 %Starfield Flicker
                
                fcnPrep = @starfieldFlickerPrep; %@starfieldCylPrep; 
                fcnDraw = @starfieldFlickerDraw; %@starfieldCylDraw;
                
               data = [2; 1; 0; 0; 0; 0; 0; 0; 0; 0; 1; -1; 0];
                
                rowNames = {'Dot size', 'Dot density', ...
                    'Sideslip',  'Lift', 'Thrust', 'Pitch', 'Yaw', 'Roll', ...
                    'Background Noise', 'RetainIntoNextTrial', ...
                    'Contrast1', 'Contrast2', 'FlickerFramesPerCycle'};
%             case 20:
%                 fcnPrep = @target3dGeneralPrep;
%                 fcnDraw = @target3dGeneralDraw;
%                                 
%                 data = [2; 0; 0; 0; 0; 0; 0];
%                 rowNames = {'Target Size', ...
%                     'X Start', 'Y Start', 'Z Start', 'X End', 'Y End', 'Z End'};
                

%             case 15 %Starfield 1: Cylinder
%                 
%                 fcnPrep = @starfieldCylPrep; 
%                 fcnDraw = @starfieldCylDraw;
%                 
%                 data = [1; 3000; 0; 0; 0; 0; 0; 20];
%                 
%                 rowNames = {'Dot size', 'Number of dots', 'Sideslip', ...
%                     'Lift', 'Thrust', 'Pitch', 'Yaw', 'Roll'};

%             case 20 %3d Target for Pursuit experiments
%                 
%                 fcnPrep = @target3dPrep; 
%                 fcnDraw = @target3dDraw; 
%                 
%                 data = [1; 0; 0; 50; 0; 0; 20; 10; 0];
%                 
%                 rowNames = {'Target Size', 'Target Start Azimuth', 'Target Start Elevation', 'Target Start Distance', ...
%                     'Target End Azimuth', 'Target End Elevation', 'Target End Distance', ...
%                     'Velocity', 'Target Noise'};
%                 
%                 settings.global = 0;
%                 settings.pursuit = true;

%             case 12 %TextString
%                 
%                 fcnPrep = @textStringPrep;
%                 fcnDraw = @textStringDraw;
%                 
%                 data = [50; 220; 240];
%                 
%                 rowNames = {'Size', 'Xpos', 'Ypos'};
%                 
%                 settings.edit1  = {'Text String', 'FlyFly'};

%             case 8 %white noise
%                 
%                 fcnPrep = @whiteNoisePrep;
%                 fcnDraw = @whiteNoiseDraw;
%                 
%                 data = [ 80; 100; 320; 240; 1; 1];
%                 
%                 rowNames = {'Height', 'Width', 'Xpos', 'Ypos',...
%                     'Contrast', 'Pixels'};
%                 
%                 settings.box1  = {'Offset X function', 0};
%                 settings.box2  = {'Offset Y function', 0};
%                 settings.edit1 = {'X function: ', '100*sin(2*pi/3 *(n-1)*ifi)'};
%                 settings.edit2 = {'Y function: ', '100*cos(2*pi/3 *(n-1)*ifi)'};

        end
        
        %set layer
        
        layer = struct(...
            'name',       experiment_names{Name}, ...
            'fcnPrep',    fcnPrep, ...
            'fcnDraw',    fcnDraw, ...
            'parameters', {[rowNames, {'Time', 'PauseTime', 'PreStimTime', 'PostStimTime'}]}, ...
            'data',       [data; timing_data], ...
            'settings',   settings, ...
            'impulse',    false);
end
