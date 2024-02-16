function flyfly()
%      __ _        __ _       
%     / _| |      / _| |      
%    | |_| |_   _| |_| |_   _ 
%    |  _| | | | |  _| | | | |
%    | | | | |_| | | | | |_| |
%    |_| |_|\__, |_| |_|\__, |
%            __/ |       __/ |
%           |___/       |___/ 
%|-------------------------------------------------------
%|   FlyFly 3.0 - Visual Stimulus user interface        |
%|                                                      |
%|    -Requires MatLab 2010 with Psychophysics toolbox  |
%|    -Documentation and user�s manual available        |
%|                                                      |
%|                                                      |
%| info@flyfly.se             (c) Jonas Henriksson 2010 |
%-------------------------------------------------------|
%
%               Why did the fly fly?
%            Because the spider spied 'er!
%
%

disp(' ');
disp(' -FlyFly 3.2- ');

addpath(cd, [cd '/' genpath('Subfunctions')], [cd '/' genpath('Stimuli')]);
clearRoot;
main;