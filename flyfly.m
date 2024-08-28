function flyfly()
%      __ _        __ _       
%     / _| |      / _| |      
%    | |_| |_   _| |_| |_   _ 
%    |  _| | | | |  _| | | | |
%    | | | | |_| | | | | |_| |
%    |_| |_|\__, |_| |_|\__, |
%            __/ |       __/ |
%           |___/       |___/ 
%|------------------------------------------------------|
%|   FlyFly 4.2 - Visual Stimulus user interface        |
%|                                                      |
%|    -Requires MatLab 2023 with Psychophysics toolbox  |
%|    -Documentation and user's manual available        |
%|                                                      |
%|                                                      |
%| info@flyfly.se             (c) Jonas Henriksson 2010 |
%|------------------------------------------------------|
%
%               Why did the fly fly?
%            Because the spider spied 'er!
%
%

disp(' ');
disp(' -FlyFly 4.2.1- ');

addpath(cd, [cd '/' genpath('Subfunctions')], [cd '/' genpath('Stimuli')]);
% Phasing this out in a future update
%clearRoot;
main;