function saveHighdefBash(videopath,videofile)
    guv = 'sudo guvcview'; 
    i = ' --image=';
    profile = ' --profile=./defaultPS3.gpfl --photo_timer=6';
    firstline = '#!/bin/bash \n';
    secondline = '# webcam High Def Image \n';
    thirdline = [guv,i,39,videopath,videofile,39,profile];
    concat = [firstline,secondline,thirdline];
    fid = fopen('HighDefCapture.sh','w');
    fprintf(fid,concat);