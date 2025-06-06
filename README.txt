
|------------------------------------|
|      __ _        __ _              |
|     / _| |      / _| |             |
|    | |_| |_   _| |_| |_   _        |
|    |  _| | | | |  _| | | | |       |
|    | | | | |_| | | | | |_| |       |
|    |_| |_|\__, |_| |_|\__, |       |
|            __/ |       __/ |       |
|           |___/       |___/        | 
|------------------------------------|


FlyFly is a free, high level interface used to create visual stimuli developed for use in motion vision research. You will need 64-bit MatLab (http://www.mathworks.com) with Psychophysics toolbox (http://psychtoolbox.org) to run it.

To use this program, open this folder up in matlab and type 'flyfly' into the command window!


For more information please visit http://www.flyfly.se


(C) Jonas Henriksson 2010    jonas.henriksson@flyfly.se

               Why did the fly fly?
           Because the spider spied 'er!

------------------------------------------------------------------------------------------
Version History 
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
4.X Updates
------------------------------------------------------------------------------------------

4.3
* Added experimental feature to run two PTB screens side by side (split screen)
* Added feature to initialise a background to match the background colour of the main stimuli, so bg colour is made when stimulus window fails or is closed
* Minor QOL features and misc. bug fixes

4.2.3
* Significant bugfixes with loading and patching old stimuli settings
* Added the functionality to load stimuli from parameter files (the .mat files saved after an experiment is run)
* Improvements made to the tools used for saving stimuli as an image sequence or as a video, much more stable and less prone to crashing Matlab

4.2.2
* Deprecated old functions that used matlab's image processing toolbox as it was found to be too slow and unoptimised for the purposes of this application
* Minor bug fixes

4.2.1
* Can now stop stimuli mid-way through experiments in case of errors via a new button in the main table GUI
* Fixed issue where image and movie generation for stimuli was not working properly

4.2 
* Sweeping backend changes to increase readability and optimisation
* Removed all references to GUIDE, app is fully contained in Matlab App Designer
* Completely redone how stimuli are handled in loading, instead of being a hardcoded list, stimuli are read and loaded dynamically based on the 'stimuli' folder
* It is now much easier to add / remove stimuli from the load order

------------------------------------------------------------------------------------------
4.1.1 Hotfix
* Added a temporary fix for stimuli settings not being initialised correctly in 'getLayer.m'

4.1

* Added camera functionality to FlyFly; users can now select an option in the settings where if they have a camera connected, a video will start recording whilst the stimuli is being shown.
* Camera settings for webcams can be imported via csv files, documentation on how to create these settings have been included alongside an example settings file
* Additional functionality to integrate video work with guvcview if needed
* A 'preview camera' button has been added to the settings and stimuli windows for users to check their camera is set up correctly
* Added rotated screen functionality; users with rotated screen setups can now click an option in the settings that will rotate the stimulus by 90 degrees for them.
* Removed Dlp monitor support
* Consolidated fly gaze and fly position together
* Various stability improvements, QOL features, and bug fixes from the matlab compatability patch

------------------------------------------------------------------------------------------
4.0

* New numbered version as due to sweeping compatability changes that allows Flyfly to run on modern software
* Made Flyfly compatible with MATLAB 2018a up to release 2023b
* Updated documentation for install guide to keep in line with modern versions of PsychToolbox as the old installation method has been deprecated
* Migrated the Flyfly GUI from GUIDE to App Designer, to ensure support for the GUI is maintainable in future MATLAB releases
* NOTE: As the GUI is now running on App Designer, the user must use MATLAB 2018a or later for Flyfly to work

------------------------------------------------------------------------------------------
3.x Updates
------------------------------------------------------------------------------------------
3.1

* general 3D star field stimulus is now included as Starfield 2. The older cylindrical starfield is also included as Starfield 1.
* new stimulus (Target3D) allows 3D target to move through space. Can be used with Starfield 2 for target movement in background clutter.
* new stimulus (ImageTarget) allows 2D movement of a user-specified image along a trajectory

------------------------------------------------------------------------------------------
2.x Updates
------------------------------------------------------------------------------------------
2.60
*Merged with flyfly version with Roel's shuffle button. This button uses the value from 
the box 'use Value' and takes this number of trials as a 'set' that it will keep together 
when shuffling. (tested for 1, 2, 3 and 4 as 'set' length. The total number of trials needs 
to be a multiple of 'use value'
*Merged with Jonas modified version of Starfield. See changelog.txt in Stimuli\Starfield
*Removed exit experimental exit dialog
*Removed delay at screen init, not needed with new daq

------------------------------------------------------------------------------------------
2.55
* Several trials in Starfield generated a bug because the number of stars 
  must be a scalar. Now only the first trials determines the number of stars.
* Dialog added to confirm exit to prevent loss of changes to the stimuli. 
  Only for exit option in menu yet. REMOVED IN VERSION 2.60 due to unreliability
* Added a delay between initializing screen and stimuli onset. REMOVED IN VERSION 2.60
* Removed the flickering of the Trigger. This can easily be added again if needed, 
  it is only commented away.

------------------------------------------------------------------------------------------
2.50
* Dual Apertures added, same as Apertures but with two holes. 
  Possibility to change transperancy of background and apertures
* New way to set fly position in Settings window without clicking on the screen, 
  useful when using single screen mode

------------------------------------------------------------------------------------------
2.40
* New Stimulus: Rolling Image M2 - Improved version of rolling image
* New Stimulus: Grid - Draws a static grid
* New Stimulus: Mouse target - Displays a rotatable bar at mouse position
* New Stimulus: Text string - Draws a text string to screen
* Added possibility to set patch coordinates as a function for White Noise and Flickering Rect.
* Screen is automatically initialized and closed down when clicking the run button.
* Added button "mseq" for multiplying rows with random m-sequence.
* Added DLP-mode for Rolling Image.
* Added support for transparent images in Rolling Image.

------------------------------------------------------------------------------------------
2.25
* New Stimulus: White Noise - Draws a patch of white noise
* New Stimulus: Aperture - Draws an aperture
* New Stimulus: Starfield Impulse - Discrete moving version of starfield 
* New Stimulus: Sine Grating RF - Sine grating for mapping receptive fields
* New stimulus: Flickering rect -  Rect that flickers between two colours

* Saves parameters before running experiments (and after)
* Helper functions "getTable" and "setTable" to aquire content of active table in gui

------------------------------------------------------------------------------------------
2.2
* New Stimuli: Starfield
* New Stimuli: Mat sequence
Starfield
* Generates a virtual cloud of N dots with maximum size
* Draws each dot on screen according to position
* May set constant translations and rotations
* May set distance to and width of monitor
* Drawing is calibrated with set fly position
.Mat sequence
* Reads a 3D matrix "out" from file
* Draws each layer of the matrix as a frame
* Set drawing position on screen or stretch to fullscreen
* Set fps to play with

------------------------------------------------------------------------------------------
2.1
* Record Image option
* Import Stimuli

------------------------------------------------------------------------------------------
2.0
* Important changes
* Stimulus functions split into prep/draw
* Timing controlled in new function "animation loop"
* Possible to draw in multiple layers
* Not compatible with old saved files

Main/Settings
* Test Init button (close screen after 2s)
* Set gamma value of screen
* Copy stimulus in project
* Rename stimulus in project
* Only loads screen settings if no screen is currently initialized

TableGui
* New layer manager
* -Add/remove/copy layer, change order
* Change layer from drop list
* May rename layer
* Template function not implemented

* Mouse target 
* Not implemented

* Sine
* Set contrast of grating
* Center option removed

* Target
* Removed background options (obsolete)

Rolling image
* Texture check: Same image in different trials just use one texture

------------------------------------------------------------------------------------------
1.x Updates
------------------------------------------------------------------------------------------
1.7.2

Main/Settings
* Add stimuli to a project
* Save project
* Open Project
* Start new project
* Save stimulus with parameters as template
* Move between stimuli, next/previous and from list
* Rename stimuli
* Set size and position of trigger
* Set folder where to save parameter data
* Save data parameters automatically
* Choose not to save data
* Set monitor to use
* Use full screen or partial screen
* Set size of partial screen
* Save two positions on monitor
* Display these positions

TableGui
* Initialize screen
* Kill screen
* Draw grid to screen
* Clear screen
* Run stimulus
* Run subset of trials
* Set number of trials
* Choose table value with mouse
* Interpolate linearly/logarithmical between row values
* Shuffle row values
* Option to affect all rows with shuffle/linear/log
* Use chosen value for all trials
* Use chosen values for each 2nd/3rd/Nth trial
* Move between different targets/patches, next/previous
* See size of monitor
* See Hz of monitor
* See number of skipped frames last set
* See number of skipped frames last in total 
* Reset counter of missed frames

Target
* Draw rectangular target with brightness
* May display several targets at same time
* Each target move from individual x,y position with chosen speed, direction and duration
* Set target background
* Set pre/post stim, pause
* Set background brightness
* Use image as background
* Move background left or right with speed
* Use same settings for all trials

Sine
* Draw rectangular patch with grating
* May draw multiple patches at same time
* Set frequency, duration, wavelength, direction, size and position of each patch
* Set pre/post stim, pause
* Set background brightness
* Draw all patches centered

Mouse Target
* Create bar that is controlled by mouse movements
* Set size of bar with keyboard
* Rotate set number of degrees with mouse click
* May run in trials or abort on mouse click
* Does not use trigger

Rolling image
* Display chosen image on background
* May rotate image any number of degrees
* Set contrast of image
* Move image with chosen speed
* Set starting offset
* Choose size of patch to use
* Choose position of patch to use
* Option to remember offset 
* Set pre/post stim, pause

