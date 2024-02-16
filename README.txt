
|------------------------------------|
|      __ _        __ _              |
|     / _| |      / _| |             |
|    | |_| |_   _| |_| |_   _        |
|    |  _| | | | |  _| | | | |       |
|    | | | | |_| | | | | |_| |       |
|    |_| |_|\__, |_| |_|\__, |       |
|            __/ |       __/ |       |
|           |___/       |___/        | 
|-------------------------------------


FlyFly is a free, high level interface used to create visual stimuli developed for use in motion vision research. You will need 64-bit MatLab (http://www.mathworks.com) with Psychophysics toolbox (http://psychtoolbox.org) to run it.


For more information please visit http://www.flyfly.se


(C) Jonas Henriksson 2010    jonas.henriksson@flyfly.se



------------------------------------------------------------------------------------------
Version History 
------------------------------------------------------------------------------------------
3.1

* general 3D star field stimulus is now included as Starfield 2. The older cylindrical starfield is also included as Starfield 1.
* new stimulus (Target3D) allows 3D target to move through space. Can be used with Starfield 2 for target movement in background clutter.
* new stimulus (ImageTarget) allows 2D movement of a user-specified image along a trajectory

2.60
*Merged with flyfly version with Roel's shuffle button. This button uses the value from 
the box 'use Value' and takes this number of trials as a 'set' that it will keep together 
when shuffling. (tested for 1, 2, 3 and 4 as 'set' length. The total number of trials needs 
to be a multiple of 'use value'
*Merged with Jonas modified version of Starfield. See changelog.txt in Stimuli\Starfield
*Removed exit experimental exit dialog
*Removed delay at screen init, not needed with new daq


2.55
* Several trials in Starfield generated a bug because the number of stars 
  must be a scalar. Now only the first trials determines the number of stars.
* Dialog added to confirm exit to prevent loss of changes to the stimuli. 
  Only for exit option in menu yet. REMOVED IN VERSION 2.60 due to unreliability
* Added a delay between initializing screen and stimuli onset. REMOVED IN VERSION 2.60
* Removed the flickering of the Trigger. This can easily be added again if needed, 
  it is only commented away.

2.50
* Dual Apertures added, same as Apertures but with two holes. 
  Possibility to change transperancy of background and apertures
* New way to set fly position in Settings window without clicking on the screen, 
  useful when using single screen mode

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

