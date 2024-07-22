// To show image drawing window using c#
/* 
This code was obtained from http://softwareservices.flir.com/Spinnaker/latest/_programmer_guide.html 
This includes buffer and camera settings controls to adjust image

This script will open up the spinview camera preview for researchers to adjust their camera prior to recording
*/

#include "Spinnaker.h"
#include "SpinGenApi/SpinnakerGenApi.h"
#include <iostream>
#include <sstream>
 
using namespace Spinnaker;
using namespace Spinnaker::GenApi;
using namespace Spinnaker::GenICam;
using namespace std;

// Initialise GUI library and show on screen
GUIFactory AcquisitionGUI = new GUIFactory ();
AcquisitionGUI.ConnectGUILibrary(cam);
// Get GUI for acquisition preview
ImageDrawingWindow AcquisitionDrawing = AcquisitionGUI.GetImageDrawingWindow();
// Connect camera and begin acquisition preview
AcquisitionDrawing.Connect(cam);
AcquisitionDrawing.Start();
AcquisitionDrawing.ShowModal();
