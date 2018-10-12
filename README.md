# Machine Learning Object Tracking (MLOT)

This repo contains all the functions needed for the MLOT algorithm. this algorithm is useful for identification of low SNR particles in 3D. This README file contains a general overview of the algorithm, as well as installation instructions.

## General Overview

### Fundamentals

MLOT uses a linear logistic regression in order to create a general linear model of data based on a small sample dataset. The user is presented with this small training dataset and asked to identify all in focus particles of interest. With pixel locations of known particles, this linear model is generated and stored.

The linear model is applied to unkown data in order to calculate the probability of particlse presence in the dataset. Using a threshold probablility value, unknown data is analyzed. Once all data has been analyzed and particle locations through time are known, these (x,y,z,t) points are then stitched together using a Hungarian simple tracking algorithm with gap detection.

You can read more about the fundamental mathematics behind this algorithm, as well as preliminary results and error quantification, on out AIMES Biophysics paper (link coming soon).

### Practical Implementation

MLOT has three major steps:

1. Image pre-processing
2. Training
3. Tracking

#### Image pre-processing

Preprocessing is a very imporatant step as it de-noises the images and increases the SNR so that the algorithm can better identify particles. This routines (currently) consists of two denoising steps.

1. Mean Subtraction
2. Band-Pass Filtering

Mean subtraction calculates the mean image of a time sequence of images and subtracts that mean image from all images in that sequence. This eliminates any stationary artifacts from the image and increases contrast for objects that are moving (i.e the things that are going to be tracked).

Band-pass filtering eliminates low and high spatial frequency noise from images. For the DHM instrument used in the AIMES Biophysics Paper (link coming soon), the diffraction limited resolution of the instrument is about 800 nm. This represents a physical upper limit of spatial frequencies that can be observed, thus anything beyond this frequency is pure noise. A lower cut off frequency is used to attenuate any large scale artificats in the image (e.g lens curvature). To edit the low and high frequency cutoff values for this filter, edit the following variables in MAIN.m (located in the 'Ask user for inputs' section)

```matlab
innerRadius = 30;
outerRadius = 230;
centerX = n(1)/2;
centerY = n(2)/2;
```

#### Training

This step presents the user with a total of ten z-slices and asks the user to select ONLY in-focus particles. This step is crucial because this determines the selection sensativity of the tracking algorithm. By selecting only in focus particles helps the program intrinsically reduce false positives.

For more information on the GUI aspect of the training routine, see the 'Running the Code' Section of this README document.

Once all in focus particles are selected through the 10 z-slices, a linear logistic regression is used to generate a linear model of the data and answer key provided by the user (where the particles are located). This linear model is used to track other datasets.

#### Tracking

Tracking is done in two stages:
1. Particle Detection
2. Particle Linking

##### Particle Detection

Using the linear model generated from the Training stage, data is compared to this linear model and a probability matrix is generated. Based on a threshold probability value, a pixel is considered a particle if the probability is higher than the chosen threshold.

##### Particle Linking

With particle locations known through time, a Hungarian linking method is used to take raw coordinates in (x,y,z,t) and stitch them together into particle trajectories.

## Installation

This program is intended to be standalone. The only external dependencies are that the MATLAB Statistics and Machine Learning Toolbox must be installed. Once this toolbox is installed, clone the repository into the machine's MATLAB working directory.

## Running the Code

The majority of the user inputs for this code are provided graphically. The only exceptions are the following:

- Z-Slice range to analyze (the desired Z-range to analyze)
- Z-Separation (physical distance between Z-slices in microns)
- Time range (the desired time range of data to analyze in frame numbers TO BE CHANGED TO UNITS OF SECONDS SOON)
- Training time (the time point to use in training)

These values are the first variables defined in MAIN.m in the section 'Ask user for inputs' (shown below for reference)

```matlab
...
% These next few lines will be replaced by a GUI soon!
zRange = [-13, 7];  % This is the zRange you would like to track
z_separation = 2.5; % This is the physical separation between z-slices (in microns)
tRange = [1, 199];  % This is the time range you would like to track
time = tRange(1);   % This is the time point that you would like to train
...
```

Initially, to run the code, run 'MAIN'.

```matlab
>> MAIN();
```

A dialog box will appear asking what you would like to do. From here, you can choose to:

* Pre-Process a dataset
* Train the tracking algorithm
* Track a dataset

These three functions can be operated on 'Amplitude', 'Phase', or 'Amplitude * Phase' reconstructions.

***NOTE: As of now, the 'Amplitude * Phase' feature is not available***

If pre-processing is chosen, a second dialog box will open asking if you would like to use GPU parallelization. 'Yes' should only be selected if the GPU on the machine this code is to run on can handle at least 8 GB of memory usage. If you are unsure, feel free to contact the code author (Manuel Bedrossian mbedross@caltech.edu).

Next, a window will prompt the user to navigate to the data that is wished to be analyzed.

If pre-processing is chosen, the code will begin to run and no further user interaction is needed.

If training is chosen, a dialog box will open asking the user to select where to save the training data once generated. Next, an image will appear and the user will be prompted to begin selecting all in focus particles. The plot that is presented allows the user to hover the curser over a particle and click on it. The pixel location of the click is recorded. To undo the previous click press BACKSPACE. Once all in focus particles are selected pressing ENTER or RETURN will present the next z slice. After all 10 z slices are presented, the image window will close and the machine learning module will begin generating a model of the data. It will automatically store it where ever told by the user.

If tracking is selected IN ADDITION to training being chosen, the program will begin tracking as soon as the training algorithm has concluded. If tracking is chosen WITHOUT training, a dialog box will appear asking the user to point to the training data that is to be used to track the dataset. Once this has happened, the tracking algorithm will begin running and no further user interaction is needed.

## Variable List

Variable lists are organized by the routine they originate from and in alphabetical order.

### MAIN.m

`zRange =` This is the range in the z-direction you would like to track (by folder name)

`z_separation =` This is the physical separation between z-slices (in microns)

`tRange =` This is the range in time you would like to track (in # of frames)

`trainZrange =` The range in the z-direction that you would like to train (in # of frames)

`trainTrange =` The range in time that you would like to train (in # of frames)

`particleSize =` GLOBAL The approximate size of the particle (in pixels)

`batchSize =` GLOBAL The number of reconstructions that are batched together for mean subtraction

`minTrackSize =` GLOBAL The minumum length of a track in order to be recognized as a particle 

`threshold =` 100; % This is the maximum distance used in hierarchical clustering (in pixels)

`preProcess =` Binary variable that is used to decide whether the user wishes to run the Pre-Processing function (0=no, 1=yes)

`train =` Binary variable that is used to decide whether the user wishes to run the training function (0=no, 1=yes)

`track =` Binary variable that is used to decide whether the user wishes to run the tracking function (0=no, 1=yes)

`type =` GLOBAL A character string that contains the type of images that the user wishes to process (e.g. Amplitude, Phase, DIC, etc.)

`Quit =` Binary variable that is used to exit the entire program (0=continue, 1=exit)

`GPU =` A user input whether they want to utilize the GPU during Pre-processing or not ('Yes' or 'No')

`masterDir` = Filepath to the data that is to be analyzed

`max_linking_distance =` The maximum distance (XY) that two points will be linked in time to form a trajectory (in pixels)

`max_gap_closing =` The maximum distance (t) that two points will be linked to close a gap in its trajectory (in # of frames). Position between these gaps will be linearly interpolated

`pCutoff =` The p-value that is used to judge whether a pixel is most-likely a particle or not

`zSorted =` List of all z-slices that are present in the data set

`n =` GLOBAL Size of the images that are to be analyzed (N,M)

`centerx =` The x-direction center that is used for the Fourier Mask in band-pass filtering (in pixels)

`centery =` The y-direction center that is used for the Fourier Mask in band-pass filtering (in pixels)

`innerRadius =` The inner radius size that is used for the Fourier Mask in band-pass filtering (in pixels). This defines the low cut-off frequency

`outerRadius =` The outer radius size that is used for the Fourier Mask in band-pass filtering (in pixels). This defines the upper cut-off frequency

`b =` The coefficients of the linear model generated after training the machine learning algorithm

`Xtrain =` The input matrix used to generate the linear model in `b`

`trainFileName =` If the user chooses to track a data set without tracking first, it is assumed that the user wishes to use a previously trained model. This variable is the filename of that training data

`trainFilePath =` If the user chooses to track a data set without tracking first, it is assumed that the user wishes to use a previously trained model. This variable is the filepath of that training data

`trainDir =` Is `trainFilePath` with `trainFileName` appended to it to define the full file path to the training data

`trackData =` A temperorary file path where tracking progress will be saved iteratively. This preserves progress in the case of a crash. Restarting the tracking algorithm will look for this file first. If it exists, the code will load this and pick up where it left off.

`astestTime =` An index variable specifying the latest time point that data has been tracked

`t =` An index variable specifying the current time point that is being analyzed

