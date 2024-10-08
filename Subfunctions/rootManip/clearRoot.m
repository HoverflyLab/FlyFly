%clears variables stored in root (debug function)

%--------------------------------------------------------------------------
% FlyFly v2
%
% Jonas Henriksson, 2010                                   info@flyfly.se
%--------------------------------------------------------------------------

% These need to give more accurate commands 
try
    rmappdata(0, 'chstimuli');   %Remove appdata from root
catch
    disp('Error loading structure chStimuli from root. Is flyfly running?')
end
try
    rmappdata(0, 'navData');     %Remove appdata from root
catch
    disp('Error loading structure navData from root. Is flyfly running?')
end
try
    rmappdata(0, 'screenData');  %Remove appdata from root
catch
    disp('Error loading structure screenData from root. Is flyfly running?')
end