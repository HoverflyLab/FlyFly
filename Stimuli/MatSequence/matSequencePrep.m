function [critInput] = matSequencePrep(Parameters, ScreenData, StimSettings, NumSubframes)
%
% Prepares input parameters for matSequenceDraw

%--------------------------------------------------------------------------
% FlyFly v2
%
% Jonas Henriksson, 2010                            info@flyfly.se
%--------------------------------------------------------------------------

if nargin<4
    NumSubframes = 1;
end

[tmp, numRuns] = size(Parameters);

P.fps  = Parameters(1,:);
P.Xpos = Parameters(2,:);
P.Ypos = Parameters(3,:);

usedTextures = {};
newTex       = 1;
index        = 1;
p            = 1;

for k = 1:numRuns
    
    fileName = StimSettings(k).path1{2};
    
    for n = 1:length(usedTextures)
        if strcmp(fileName, usedTextures{n})
            newTex = 0;
            index  = n;
            break;
        end
    end
    
    if newTex
        usedTextures{end+1} = [fileName];
        
        load(fileName);
        
        try
            [R, C, Z] = size(out); %out is the matrix loaded from "fileName"
        catch
            disp(['File error. Does ' fileName 'contain a 3D matrix with the name "out"? ']);
        end
        
        for z = 1:Z
            I = out(:,:,z);
            textures(p, z) = Screen('MakeTexture', ScreenData.wPtr, 255*I);
        end
        
        [index tmp] = size(textures);
        newTex = 1;
        p = p+1;
    end
    
    textureIndex(k) = index;
    numFrames(k) = Z;
    
    stretch = StimSettings(k).box1{2}; %true/false
    if stretch
        dstRect(:,k) = [0; 0; ScreenData.rect(3); ScreenData.rect(4)];
    else
        dstRect(:,k) = [P.Xpos(k)-C/2 P.Ypos(k)-R/2 P.Xpos(k)+C/2 P.Ypos(k)+R/2];
    end
    
   
end

critInput.textures  = textures;
critInput.numFrames = numFrames;
%critInput.nSwitch   = P.fps / ScreenData.hz;
critInput.nSwitch   = P.fps * ScreenData.ifi;

critInput.dstRect   = dstRect;
critInput.textureIndex = textureIndex;
