num_trials=1000;
speed=900;
duration = 0.1;
width=720;
midx=1280;
height=720;
midy=1080;
rect_size = 15;
[X1, Y1, X2, Y2] = generateXY(num_trials, speed, duration, width, height, midx, midy, rect_size);

dX=X1-X2;
dY=Y1-Y2;
a=atan2d(dX,dY);    

figure; histogram(a);   % uniform
figure; histogram(dX);   % non-uniform distribution biased against 0
figure; histogram(dY);   % non-uniform distribution biased against 0
figure;scatter(a,dX);

figure; scatter(dY,dX); % circle

figure;plot(dX);    % no pattern
figure;plot(dY);    % no pattern

ts = {};
for t = 1:length(X1)
    ts{t} = [X1(t) X2(t); Y1(t) Y2(t)];
end

figure; hold on;
for t = 1:length(X1)
    X=ts{t}(1,:); 
    Y=ts{t}(2,:);  
    plot(X,Y,'Marker','s','MarkerIndices',[2]);
end
% should be random trajectories, all within the rectangle
