function out = generateBarStimImage(x,y,dir)
if nargin<3
    dir = 'vertical';
end
switch dir
    case 'vertical'
        out = ones(y,1)*round(rand(1,x));
    otherwise
        out = round(rand(y,1))*ones(1,x);
end