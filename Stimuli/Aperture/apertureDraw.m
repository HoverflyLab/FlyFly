function P = apertureDraw(wPtr, n, k, ifi, P)
%Parameters: aperture
%Draw an aperture, covering wPtr. The aperture may be square or oval and
%may be semi transparent.
%

%--------------------------------------------------------------------------
% FlyFly v2
%
% Jonas Henriksson, 2010                            info@flyfly.se
%--------------------------------------------------------------------------

Screen('DrawTexture', wPtr, P.aperture(k), [], [], [], 0);