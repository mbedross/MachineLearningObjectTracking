function [varargout] = MAIN(varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
% 2. Training walks the user through a series of GUI's that manually
% identify particles of interest. These selected particles are then used to
% generate model data that is then used in the tracking section to analyze
% new data for simialr particles of interest. Training data is saved in a
% user defined directory. The training algorithm will prompt the user for
% this information at the end of the routine.
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% User defined criteria

% Do you want to preProcess the data? 1 = yes, 0 = no
preProcess = 0;

% Do you want to run the training phases? 1 = yes, 0 = no
train = 0;

% Do you want to track? 1 = yes, 0 = no
track = 1;

% If you are training, define what time point you would like to train


% Very often, there is not enough RAM to load the entire xyzt stack to be
% tracked. This means that it must be broken down into a subset of z and t
% sets
zRange = [-10, 10];
tRange = [1, 5];
time = tRange(1);

% Define global variables
global n
n = [2048 2048];

% Which type of data do you want to track? Amplitude or Phase?
global type
type = "ampXphase";

%% Misc. parameters

global masterDir
masterDir = varargin{1};
if length(varargin) == 2
    global trainDir
    trainDir = varargin{2};
end

if length(varargin) ~=2 && train == 0 && track == 1
    error('Without running the training protocol, a file path to training data must be provided. Either variable track must be 1 or more inputs are needed');
end

% Define tracking parameters
max_linking_distance = 30;
max_gap_closing = 1;

z_separation = 2.5;

% Define image parameters
pCutoff = 0.005;
minCluster = 10;
cropSize = 15;

%% Main section
% Add the preprocess and training subdolders to MATLAB search path, and run
% the respective functions if applicable
if preProcess == 1
    addpath('.\preProcessing');
    [times, zSorted] = preProcessingMain(masterDir);
end
if train == 1
    addpath('.\training');
    if preProcess == 0
        load(fullfile(masterDir, 'MeanStack','metaData.mat'));
    end
    [dTrain]    = import3D(masterDir, zSorted, time, zRange);
    [b, Xtrain] = trainingStage1(dTrain);
    [dTrainC]   = trainingStage2(dTrain, b, Xtrain);
    [b]         = trainingStage3(dTrainC);
end
if track == 1
    if train == 0 && length(varargin) == 2
        % If the dataset is already trained, load the model variables
        load(trainDir);
        load(fullfile(masterDir, 'MeanStack','metaData.mat'))
        [D]    = import4D(masterDir, zSorted, times, zRange, tRange);
    else
        D = dTrain;
    end
    % Add necessary directories to MATLAB PATH
    addpath('.\supportingAlgorithms');
    addpath('.\createVideos');
    addpath('.\writeMatrix');
    % Condition data set for tracking
    croppedD = cropEdges(D,cropSize);
    D = addEdges(croppedD,cropSize);
    numZ = length(zSorted);
    zStepsPerBatch = 20;
    zBatches = floor(numZ/zStepsPerBatch);
    % Find how many time sequences exist
    times(times > tRange(2)) = [];
    times(times < tRange(1)) = [];
    tNF = length(times);
    pointz = zeros(0,3);
    X = zeros(n(1)*n(2)*zStepsPerBatch,9);
    for t = 1 : tNF
        for zB = 1 : zBatches
            if zB == zBatches
                zStepsPerBatch = zStepsPerBatch - 3;
            end
            for zStep = 1 : zStepsPerBatch
                if zB == 1 && (zStep == 1 || zStep == 2)
                    inputSlice = D(:, :, (zB-1)*zStepsPerBatch+1 : (zB-1)*zStepsPerBatch+5, t);
                else
                    inputSlice = D(:, :, (zB-1)*zStepsPerBatch+zStep-2 : (zB-1)*zStepsPerBatch+zStep+2, t);
                end
                xInterval = [(zStep-1)*n(1)*n(2)+1 zStep*n(1)*n(2)];
                X(xInterval(1):xInterval(2),:) = getInputMatrixV5zs(inputSlice);
            end
            y = glmval(b,X,'logit');
            D_C = classify(y, pCutoff, minCluster, size(D,1),size(D,2),zStepsPerBatch);
            tempPoints = findCentroids(D_C);
            tempPoints(:,3) = (zB-1).*zStepsPerBatch+tempPoints(:,3);
            pointz = [pointz; tempPoints];
        end
        points{t} = pointz;
        points2{t} = points{t}*[360/size(D,1) 0 0;0 360/size(D,2) 0;0 0 z_separation];
        [tracks, adjacency_tracks] = simpletracker(points2, ...
            'MaxLinkingDistance', max_linking_distance, ...
            'MaxGapClosing', max_gap_closing);
        % Plot the current trajectories
        plotTracksAndVelocity(adjacency_tracks,points2);
        daspect([1 1 1])
    end
    varargout{1} = points;
    varargout{2} = points2;
    varargout{3} = tracks;
    varargout{4} = adjacency_tracks;
end