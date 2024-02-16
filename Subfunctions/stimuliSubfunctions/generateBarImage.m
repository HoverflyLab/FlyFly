function generateBarImage(x,y,filename,dir)
if nargin<4
    dir = 'horizontal';
end
switch dir
    case 'vertical'
        out = round(rand(y,1))*ones(1,x);
    otherwise
        out = ones(y,1)*round(rand(1,x));
end
imwrite(out,filename,'png');