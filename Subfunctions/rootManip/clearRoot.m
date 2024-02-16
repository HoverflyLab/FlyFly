%clears variables stored in root (debug function)

%--------------------------------------------------------------------------
% FlyFly v2
%
% Jonas Henriksson, 2010                                   info@flyfly.se
%--------------------------------------------------------------------------

try
    rmappdata(0, 'chstimuli');   %Remove appdata from root
end
try
    rmappdata(0, 'navData');     %Remove appdata from root
end
try
    rmappdata(0, 'screenData');  %Remove appdata from root
end