#include "Spinnaker.h"
#include "SpinGenApi/SpinnakerGenApi.h"
#include <iostream>
#include <sstream>
 
using namespace Spinnaker;
using namespace Spinnaker::GenApi;
using namespace Spinnaker::GenICam;
using namespace std;

// Entry point; 
int main(int /*argc*/, char** /*argv*/)
{
    // Since this application saves images in the current folder
    // we must ensure that we have permission to write to this folder.
    // If we do not have permission, fail right away.
    FILE* tempFile = fopen("test.txt", "w+");
    if (tempFile == nullptr)
    {
        cout << "Failed to create file in current folder.  Please check "
                "permissions."
             << endl;
        cout << "Press Enter to exit..." << endl;
        getchar();
        return -1;
    }
    fclose(tempFile);
    remove("test.txt");
 
    int result = 0;
 
    // Print application build information
    cout << "Application build date: " << __DATE__ << " " << __TIME__ << endl << endl;
 
    // Retrieve singleton reference to system object
    SystemPtr system = System::GetInstance();
 
    // Print out current library version
    const LibraryVersion spinnakerLibraryVersion = system->GetLibraryVersion();
    cout << "Spinnaker library version: " << spinnakerLibraryVersion.major << "." << spinnakerLibraryVersion.minor
         << "." << spinnakerLibraryVersion.type << "." << spinnakerLibraryVersion.build << endl
         << endl;
 
    // Retrieve list of cameras from the system
    CameraList camList = system->GetCameras();
 
    unsigned int numCameras = camList.GetSize();
 
    cout << "Number of cameras detected: " << numCameras << endl << endl;
 
    // Finish if there are no cameras
    if (numCameras == 0)
    {
        // Clear camera list before releasing system
        camList.Clear();
 
        // Release system
        system->ReleaseInstance();
 
        cout << "Not enough cameras!" << endl;
        cout << "Done! Press Enter to exit..." << endl;
        getchar();
 
        return -1;
    }
 
    // Run example on each camera
    for (unsigned int i = 0; i < numCameras; i++)
    {
        cout << endl << "Running example for camera " << i << "..." << endl;
 
        result = result | RunSingleCamera(camList.GetByIndex(i));
 
        cout << "Camera " << i << " example complete..." << endl << endl;
    }
 
    // Clear camera list before releasing system
    camList.Clear();
 
    // Release system
    system->ReleaseInstance();
 
    cout << endl << "Done! Press Enter to exit..." << endl;
    getchar();
 
    return result;
}

// Acquire images and save them
// This function acquires and saves 10 images from a device.
int AcquireImages(CameraPtr pCam, INodeMap& nodeMap, INodeMap& nodeMapTLDevice)
{
int result = 0;
cout << endl << endl << "*** IMAGE ACQUISITION ***" << endl << endl;
try
{
//
// Set acquisition mode to continuous
//
// *** NOTES ***
// Because the example acquires and saves 10 images, setting acquisition
// mode to continuous lets the example finish. If set to single frame
// or multiframe (at a lower number of images), the example would just
// hang. This would happen because the example has been written to
// acquire 10 images while the camera would have been programmed to
// retrieve less than that.
//
// Setting the value of an enumeration node is slightly more complicated
// than other node types. Two nodes must be retrieved: first, the
// enumeration node is retrieved from the nodemap; and second, the entry
// node is retrieved from the enumeration node. The integer value of the
// entry node is then set as the new value of the enumeration node.
//
// Notice that both the enumeration and the entry nodes are checked for
// availability and readability/writability. Enumeration nodes are
// generally readable and writable whereas their entry nodes are only
// ever readable.
//
// Retrieve enumeration node from nodemap
CEnumerationPtr ptrAcquisitionMode = nodeMap.GetNode("AcquisitionMode");
if (!IsReadable(ptrAcquisitionMode) || !IsWritable(ptrAcquisitionMode))
{
cout << "Unable to set acquisition mode to continuous (enum retrieval). Aborting..." << endl << endl;
return -1;
}
// Retrieve entry node from enumeration node
CEnumEntryPtr ptrAcquisitionModeContinuous = ptrAcquisitionMode->GetEntryByName("Continuous");
if (!IsReadable(ptrAcquisitionModeContinuous))
{
cout << "Unable to get or set acquisition mode to continuous (entry retrieval). Aborting..." << endl
<< endl;
return -1;
}
// Retrieve integer value from entry node
const int64_t acquisitionModeContinuous = ptrAcquisitionModeContinuous->GetValue();
// Set integer value from entry node as new value of enumeration node
ptrAcquisitionMode->SetIntValue(acquisitionModeContinuous);
cout << "Acquisition mode set to continuous..." << endl;
//
// Begin acquiring images
//
// *** NOTES ***
// What happens when the camera begins acquiring images depends on the
// acquisition mode. Single frame captures only a single image, multi
// frame captures a set number of images, and continuous captures a
// continuous stream of images. Because the example calls for the
// retrieval of 10 images, continuous mode has been set.
//
// *** LATER ***
// Image acquisition must be ended when no more images are needed.
//
pCam->BeginAcquisition();
cout << "Acquiring images..." << endl;
//
// Retrieve device serial number for filename
//
// *** NOTES ***
// The device serial number is retrieved in order to keep cameras from
// overwriting one another. Grabbing image IDs could also accomplish
// this.
//
gcstring deviceSerialNumber("");
CStringPtr ptrStringSerial = nodeMapTLDevice.GetNode("DeviceSerialNumber");
if (IsReadable(ptrStringSerial))
{
deviceSerialNumber = ptrStringSerial->GetValue();
cout << "Device serial number retrieved as " << deviceSerialNumber << "..." << endl;
}
cout << endl;
// Retrieve, convert, and save images
const unsigned int k_numImages = 10;
//
// Create ImageProcessor instance for post processing images
//
ImageProcessor processor;
//
// Set default image processor color processing method
//
// *** NOTES ***
// By default, if no specific color processing algorithm is set, the image
// processor will default to NEAREST_NEIGHBOR method.
//
processor.SetColorProcessing(SPINNAKER_COLOR_PROCESSING_ALGORITHM_HQ_LINEAR);
for (unsigned int imageCnt = 0; imageCnt < k_numImages; imageCnt++)
{
try
{
//
// Retrieve next received image
//
// *** NOTES ***
// Capturing an image houses images on the camera buffer. Trying
// to capture an image that does not exist will hang the camera.
//
// *** LATER ***
// Once an image from the buffer is saved and/or no longer
// needed, the image must be released in order to keep the
// buffer from filling up.
//
ImagePtr pResultImage = pCam->GetNextImage(1000);
//
// Ensure image completion
//
// *** NOTES ***
// Images can easily be checked for completion. This should be
// done whenever a complete image is expected or required.
// Further, check image status for a little more insight into
// why an image is incomplete.
//
if (pResultImage->IsIncomplete())
{
// Retrieve and print the image status description
cout << "Image incomplete: " << Image::GetImageStatusDescription(pResultImage->GetImageStatus())
<< "..." << endl
<< endl;
}
else
{
//
// Print image information; height and width recorded in pixels
//
// *** NOTES ***
// Images have quite a bit of available metadata including
// things such as CRC, image status, and offset values, to
// name a few.
//
const size_t width = pResultImage->GetWidth();
const size_t height = pResultImage->GetHeight();
cout << "Grabbed image " << imageCnt << ", width = " << width << ", height = " << height << endl;
//
// Convert image to mono 8
//
// *** NOTES ***
// Images can be converted between pixel formats by using
// the appropriate enumeration value. Unlike the original
// image, the converted one does not need to be released as
// it does not affect the camera buffer.
//
// When converting images, color processing algorithm is an
// optional parameter.
//
ImagePtr convertedImage = processor.Convert(pResultImage, PixelFormat_Mono8);
// Create a unique filename
ostringstream filename;
filename << "Acquisition-";
if (!deviceSerialNumber.empty())
{
filename << deviceSerialNumber.c_str() << "-";
}
filename << imageCnt << ".jpg";
//
// Save image
//
// *** NOTES ***
// The standard practice of the examples is to use device
// serial numbers to keep images of one device from
// overwriting those of another.
//
convertedImage->Save(filename.str().c_str());
cout << "Image saved at " << filename.str() << endl;
}
//
// Release image
//
// *** NOTES ***
// Images retrieved directly from the camera (i.e. non-converted
// images) need to be released in order to keep from filling the
// buffer.
//
pResultImage->Release();
cout << endl;
}
catch (Spinnaker::Exception& e)
{
cout << "Error: " << e.what() << endl;
result = -1;
}
}
//
// End acquisition
//
// *** NOTES ***
// Ending acquisition appropriately helps ensure that devices clean up
// properly and do not need to be power-cycled to maintain integrity.
//
pCam->EndAcquisition();
}
catch (Spinnaker::Exception& e)
{
cout << "Error: " << e.what() << endl;
return -1;
}
return result;
}

