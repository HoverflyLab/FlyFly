function setTable(data, rowNames)
%replace current flyfly parameter table with input parameters

%--------------------------------------------------------------------------
% FlyFly v2
%
% Jonas Henriksson, 2010                                   info@flyfly.se
%--------------------------------------------------------------------------

getRoot; %loads navData and chstimuli

k = navData.activeStim;
n = navData.marker(k);

chstimuli(k).layers(n).data = data;

if nargin == 2
    chstimuli(k).layers(n).parameters = rowNames;
end

setRoot;
disp('New parameters set! Press "Number of Trials -> OK" to update')