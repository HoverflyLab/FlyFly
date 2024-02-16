%function starfieldRender(wPtr, input, k, n)
function Parameters = target3dGeneralDraw(wPtr, n, k, ifi, Parameters)

if ~isempty(Parameters(k).target_xy{n})
    Screen('DrawDots', wPtr, Parameters(k).target_xy{n}, Parameters(k).target_dotsize{n}, Parameters(k).target_color{n}, Parameters(k).center, 1);
end;