%function starfieldRender(wPtr, input, k, n)
function Parameters = starfield3Draw(wPtr, n, k, ifi, Parameters)

if ~isempty(Parameters(k).xymatrix{n})
    Screen('DrawDots', wPtr, Parameters(k).xymatrix{n}, Parameters(k).dotsize{n}, Parameters(k).color{n}, Parameters(k).center, 1);
end;


end