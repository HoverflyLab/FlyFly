function [Xstart, Ystart, Xend, Yend] = generateXY(num_trials, speed, duration, width, height, midx, midy, rect_size)
    % distance to move per trial
    dist = floor(speed*duration);
    
    a=linspace(0,2*pi,num_trials+1);
    a = a(1:end-1);
    orderA = randperm(num_trials);
    a = a(orderA);
    
    a = 2*pi*rand(1, num_trials);
    
    Xdiff = dist*cos(a);
    Ydiff = dist*sin(a);

    Xmid = dist/2 + rect_size/2 + (width - dist - rect_size - 1)*rand(1,num_trials);
    Ymid = dist/2 + rect_size/2 + (height - dist - rect_size - 1)*rand(1,num_trials);
    
    X1 = Xmid - Xdiff/2;
    Y1 = Ymid - Ydiff/2;
    X2 = Xmid + Xdiff/2;
    Y2 = Ymid + Ydiff/2;
    
    Xadj = midx - width/2;
    Yadj = midy - height/2;
    
    X1 = X1 + Xadj;
    Y1 = Y1 + Yadj;
    X2 = X2 + Xadj;
    Y2 = Y2 + Yadj;
    
    Xstart = round(X1);     Xend = round(X2);
    Ystart = round(Y1);     Yend = round(Y2);
end