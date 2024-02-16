function [data rowNames] = getTable()
% load active parameter table of flyfly
% use in conjunction with setTable for easy manipulation of parameter data

%--------------------------------------------------------------------------
% FlyFly v2
%
% Jonas Henriksson, 2010                                   info@flyfly.se
%--------------------------------------------------------------------------

data = [];
getRoot; %loads navData and chstimuli

if ~isempty(navData)
    k = navData.activeStim;
    n = navData.marker(k);
else
    disp('Error loading structure navData from root. Is flyfly running?')
end

if ~isempty(chstimuli)
    data     = chstimuli(k).layers(n).data;
    rowNames = chstimuli(k).layers(n).parameters;
else
    disp('Error loading structure chstimuli from root. Is flyfly running?')
end