function x = rgbCal(x, gamma)
%Monitor brightness calibration
% On a monitor, the displayed brightness is typically defined by 
% L = K*x^gamma, where x is the brightness input to the monitor
%
% This function takes the estimated gamma and transforms x so that a linear
% increase in x corresponds to a linear change in L.

%--------------------------------------------------------------------------
% FlyFly v2
%
% Jonas Henriksson, 2010                                   info@flyfly.se
%--------------------------------------------------------------------------

x = (255^(gamma-1).*x).^(1/gamma);