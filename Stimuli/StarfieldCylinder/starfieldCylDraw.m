function Parameters = starfieldCylDraw(wPtr, n, k, ifi, Parameters)

Screen('FillRect',Parameters(k).texturePtr,255);

Screen('DrawDots', Parameters(k).texturePtr, Parameters(k).xymatrix{n}, Parameters(k).dotsize{n}, Parameters(k).color{n}, Parameters(k).center, 1);

Screen('BeginOpenGL', Parameters(k).extendedWinPtr);

glClear;
    
glPushMatrix();
glRotatef(-Parameters(k).flyTiltAngle, 0,1,0);
glRotatef(-Parameters(k).flyRotAngle, 1,0,0);
glCallList(Parameters(k).listindex);
glPopMatrix();

Screen('EndOpenGL', Parameters(k).extendedWinPtr);
Screen('DrawTexture',wPtr,Parameters(k).extendedWinPtr,Parameters(k).copyRect);