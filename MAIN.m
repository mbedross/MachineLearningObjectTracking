 function MAIN

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Author: Manuel Bedrossian, Caltech
% Date Created: 2018.10.10
%
% This is the main function for the machine learning assisted tracking of
% off-axis holographic reconstructions.
%
% This function has three main sections (details on each section below):
% 1. Pre-Processing
% 2. Training
% 3. Tracking
%
% All data must be pre-processed in order to conduct training or tracking,
% however, pre processing does not need to be done multiple times. All
% processed data is saved for future use (see variable list for where
% this data is stored)
%
% 1. Pre-Processing consists of mean subtracting and band-pass filtering.
% Mean subtraction eliminates stationary objects in the reconstructions and
% band-pass filtering is used to eliminate low and high frequency noise.
% The processed data is stored in the directory 'MeanStack' located in the
% master directory
%
% 2. Training walks the user through a series of GUIs that manually
% identify particles of interest. These selected particles are then used to
% generate model data that is then used in the tracking section to analyze
% new data for simialr particles of interest. Training data is saved in a
% user defined directory. The training algorithm will prompt the user for
% this information at the end of the routine.
%
% NOTE: The variable trainZrange defaults to the center 10 z-slices of the
% reconstruction. These are the z-slices that are presented to the user for
% the code to train with. If you would like to specify a different
% trainZrange, find the variable in the code (using the FIND feature) and
% relace the z range bounds by your desired value.
%
% 3. Tracking conducts the tracking algorithm based on information for the
% training section.
%
% Variable list:
% varargin = (input) a variable length input. The first variable
%            (mandatory) defines the 'master' directory where the raw data 
%            and reconstructions are located. The second variable 
%            (optional) is to be used if training has already been 
%            conducted and defines the path length to the training data.
%
% preProcess = logical operator to conduct preProcessing or not
% train = logical operator to conduct training or not
% track = logical operator to conduct tracking or not
% masterDir = the first entry in varargin
% trainDir = the second entry in varargin
% zRange =  array defining the range in z values desired to be
%                   imported (e.g. zRange = [zMin zMax])
% tRange =  array defining the range in times desired to be
%           imported (e.g. tRange = [tMin tMax])
%
% For a detailed list and description of variables please see the read me
% file 'README.md'
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Ask user for inputs
global batchSize
global minTrackSize
global particleSize
global type
global masterDir
global n 
global zSorted
global zDepth
global zRange
global tRange
global clusterThreshold
global times
global tNF

% These next few lines will be replaced by a GUI soon!
zRange = [-30, -14];  % This is the zRange you would like to track
zSeparation = 2.5; % This is the physical separation between z-slices (in microns)
tRange = [1, 335];  % This is the time range you would like to track
%trainZrange = [zSorted(floor(length(zSorted)/2)), zSorted(floor(length(zSorted)/2))+1];
trainZrange = [1, 14];
trainTrange = [1, 3];
particleSize = 30; % Approximate size of the particle in pixels (MUST BE INTEGER)
pixelPitchX = 350/2048; % Size of each pixel in the image x direction (in microns)
pixelPitchY = pixelPitchX; % Size of each pixel in the image y direction (in microns)
pixelPitch = mean([pixelPitchX pixelPitchY]);
batchSize = 30; % This is the number of reconstructions that are batched together for mean subtraction
minTrackSize = 20; % The minumum length of a track in order to be recorded
zDepth = 2*ceil((4*particleSize*pixelPitch)/zSeparation)+1; % number of z-slices to use while tracking
clusterThreshold = 3*particleSize;


addpath('.\GUI')

[preProcess, train, track, type, Quit] = initGUI();

if preProcess == 1
    GPU = questdlg('Would you like to use GPU parallelization for Pre-Processing? NOTE: This is only to be called when the user wants to use GPU parallelization. This depends on the capabilities of the GPU on the machine this is to run on. Check GPU specs before using and/or contact Manuel Bedrossian (mbedross@caltech.edu)', ...
	'GPU Parallelization', ...
	'Yes','No','No');
end

if Quit == 1
    return
end

%% Misc. parameters
masterDir = uigetdir('Choose Data Parent Directory');

% Define tracking parameters in microns
maxLinkDistance = 10;
maxGap = 3;

% Add necessary directories to MATLAB PATH
addpath('.\supportingAlgorithms');
addpath('.\preProcessing');

% Define global variables

zSorted = zSteps(fullfile(masterDir, 'MeanStack', char(type(1))));
n = getImageSize(trainTrange(1));

if strcmp(char(type(1)), 'DIC')
    n = [n(1), (n(2)-1)];
end

centerx = n(1)/2;
centery = n(2)/2;
innerRadius = 25;
outerRadius = 310; %310 for common mode

%% Main section
% Add the preprocess and training subdolders to MATLAB search path, and run
% the respective functions if applicable
if preProcess == 1
    addpath('.\preProcessing');
    if strcmp(GPU, 'Yes')
        [times, zSorted] = preProcessingGPU(innerRadius, outerRadius, centerx, centery, GPU);
    else
        [times, zSorted] = preProcessing(innerRadius, outerRadius, centerx, centery, GPU);
    end
end
if train == 1
    addpath('.\training');
    if preProcess == 0
        load(fullfile(masterDir, 'MeanStack','metaData.mat'));
    end
    tNF = length(times);
    [model, imageSize] = training(trainZrange, trainTrange);
end
if track == 1
    if train == 1
        [coordinates] = detection(model, train, imageSize);
    else
        [coordinates] = detection(model, train);
    end
    % Convert the units of the output of detection.m into spatial and temporal units
    % Import timestamp file to convert to seconds
    timeFile = fullfile(masterDir, 'timestamps.txt');
    [stamp, timeOfDay, Date, eTime] = textread(timeFile, '%f %s %s %f');
    clear timeOfDay Date stamp
    eTime = eTime./1000;
    for i = 1 : length(coordinates)
        coordinates(i,4) = etimes(coordinates(i,4));
    end
    coordinates(:,1:3) = coordinates(:,1:3)*[pixelPitchX, 0, 0; 0, pixelPitchY; 0, 0, zSeparation];
    tracking(coordinates, maxLinkDistance, maxGap)
end