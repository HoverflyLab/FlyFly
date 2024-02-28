function run()
    clear all
    format long g
    [videofile,videopath] = uigetfile('*.mkv','Select Video');
    videoPathAndFileName = fullfile(videopath,videofile);
    fprintf('Loading video file %s...\n', videoPathAndFileName);
    ffmpeg = '/usr/bin/ffmpeg -i';
    fflast = ' -vframes 1';
    [imagefile, imagepath] = uiputfile('*.png','Save Image...');
    ffoutput = fullfile(imagepath,imagefile);
    ffcombine = [ffmpeg, ' ', 39, videoPathAndFileName, 39, fflast, ' ', ffoutput];
    unix(ffcombine);
    nPoints = 2;
    [NumofPoints,mat] = centrepoints(nPoints,ffoutput);
    [savefile, savepath] = uiputfile('*.csv','Save csv...','/home/hoverfly/Desktop');
    CSVPathAndFileName = fullfile(savepath, savefile);
    dlmwrite(CSVPathAndFileName,mat,'delimiter', ',' , 'precision' , 9);
end
function [NumofPoints,mat] = centrepoints(nPoints,ffoutput)
    complete = 0;
    while complete == 0
        NumofPoints = nPoints;
        points = '•';
        %img1 = ffoutput;
        [X,map] = imread('test.png');
        imshow(X,map);
        [x1,y1] = ginput(2);
        h1 = text(x1(:,1),y1(:,1), points, 'Color', 'red', 'FontSize', 24, 'HorizontalAlignment', 'center','VerticalAlignment', 'middle');
        mat = {x1,y1};
        line([x1(1,1) x1(2,1)],[y1(1,1) y1(2,1)]);
        %flip y values so 0 is the bottom and 240 the top
        mat = {x1,240-y1};
        result = validate;
        res = strcat(result);
        No = 'No';
        Yes = 'Yes';
        if strcmp(res,No)
            clear x1
            clear y1
            clear h1
            clear mat
        end
        if strcmp(res,Yes)
           complete = 1;
           close();
        end
    end
end
