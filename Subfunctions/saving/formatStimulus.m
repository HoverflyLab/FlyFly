function newStimulus = formatStimulus(Stimulus)
%Formats the input stimulus to an easier to read format used when saving
%parameters

%--------------------------------------------------------------------------
% FlyFly v2
%
% Jonas Henriksson, 2010                                   info@flyfly.se
%--------------------------------------------------------------------------

Stimulus = rmfield(Stimulus, 'hGui');
Stimulus = rmfield(Stimulus, 'fileNameGui');
Stimulus = rmfield(Stimulus, 'settingsGui');
Stimulus = rmfield(Stimulus, 'stimSettings');

newStimulus = Stimulus;
newStimulus = rmfield(newStimulus, 'layers');

for z = 1:length(Stimulus.layers)
    
    layer = Stimulus.layers(z);
    
    [R C] = size(layer.data);
    
    for c=1:C
        for r=1:R
            parName = [layer.parameters{r}];
            parName = regexprep(parName, ' ', '_'); %replace space with underscore
            eval(['layer.Param(c).' parName '=layer.data(r,c);']);
        end
    end
    
    layer = rmfield(layer, 'data');
    layer = rmfield(layer, 'parameters');
    
    newStimulus.layers(z) = layer;
end

