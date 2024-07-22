// These are the libraries we need to run this
#include "Spinnaker.h"
#include "SpinGenApi/SpinnakerGenApi.h"
#include <iostream>
#include <sstream>

// Redefine names for easier use
using namespace Spinnaker;
using namespace Spinnaker::GenApi;
using namespace Spinnaker::GenICam;
using namespace std;

// Use the following enum to select the stream mode.
// This will auto select correct on for current OS.
enum StreamMode
{
STREAM_MODE_TELEDYNE_GIGE_VISION, // Teledyne Gige Vision is the default stream mode for spinview which is supported on Windows
STREAM_MODE_PGRLWF, // Light Weight Filter driver is our legacy driver which is supported on Windows
STREAM_MODE_SOCKET, // Socket is supported for MacOS and Linux, and uses native OS network sockets instead of a
// filter driver
};
#if defined(WIN32) || defined(WIN64)
const StreamMode chosenStreamMode = STREAM_MODE_TELEDYNE_GIGE_VISION;
#else
const StreamMode chosenStreamMode = STREAM_MODE_SOCKET;
#endif


// Get instance of Spinnaker system
SystemPtr system = System::GetInstance();

// Then use this system object to get a list of all connected cameras 
CameraList camList = system->GetCameras();

/* Lastly, get the camera from the list. The easiest way to do this is
   with the GetByIndex method: */
CameraPtr pCam = camList.GetByIndex(i);

// Get camera settings as object
INodeMap& nodeMap = pCam->GetNodeMap();

// Start acquiring images with selected camera
pCam->BeginAcquisition();
