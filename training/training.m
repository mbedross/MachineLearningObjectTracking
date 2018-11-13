function [b, Xtrain] = training(trainZrange, trainTrange)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Author: Manuel Bedrossian, Caltech
% Date Created: 2018.10.10
%
% This function contains the training routine for ML based particle
% tracking
%
% The workflow of this routine is as follows:
% 1. The user is presented with a windows dialog box and asked to specify
%    a file location where they would like to save the training data.
% 2. The code checks the data directory to see if any particle coordinates
%    exist there. 
% 3. If particle coordinates exist for the data set that is
%    to be trained, they are loaded to RAM.
% 4. If particle coordinates do not exist, the code then beings the
%    training process by presenting data to the user and asking for particle
%    locations. Refer to getParticleCoordsXY() and getParticleCoordsZ() for
%    more information.
% 5. With particle coordinates for this data set. The code then generates
%    input matrices that will be used to generate predicative models.
% 6. The code then uses these input matrices to calculate models that it
%    can then use to detect similiar particles in unanalyzed data
% 7. The model data is then returned back to the calling function as a
%    list of coefficients and the input matrix used to generate those co-
%    efficients. 
% 
% For a detailed list and description of variables please see the read me
% file 'README.md'
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global masterDir
global ds
global zSorted
gloabl zNF
global zDepth
global n

% Create a datastore of images
[ds] = createImgDataStore();

% Define the range of Z slices to train on as global indices of zSorted 
trainZrange_index = [find(zSorted == trainZrange(1)) find(zSorted == trainZrange(2))]

[trainFileName, trainPath] = uiputfile('*.mat','Choose Where to Save Training Data file');
filename = fullfile(trainPath, trainFileName);

coordName = fullfile(masterDir, 'BugCoords.mat');
if exist(coordName, 'file') == 2
    load(coordName);
else
    trainLock = 1;
    numParticle = 0;
    while trainLock
        tempCoords = getParticleCoordsXY(trainZrange_index, trainTrange);
        tempCoords = getParticleCoordsZ(tempCoords)
        numParticle = numParticle + 1;
        particleCoords{numParticle, :} = [tempCoords];
        track = questdlg('Would you like to track another particle?', 'Yes','No','Yes');
        if strcmp(track, 'No')
            trainLock = 0;
        end
    end
    save(coordName, 'bugCoords')
end

% For each particle at each time point, generate the 3D image to then be formatted as
% a predictor matrix
tempCoords = particleCoords{1,:};
numTimePoints = size(tempCoords,1);
sizeX = sizePredictorMatrix(n(1),n(2),zDepth)
Img = zeros(n(1), n(2), zDepth);
X = zeros(length(particleCoords)*numTimePoints,sizeX);
Y = zeros(length(particleCoords)*numTimePoints, 2);
X_zRanges = zeros(numTimePoints, zDepth);
X_indices = zeros(numTimePoints, zDepth);
for i = 1 : length(particleCoords)
    tempCoords = particleCoords{i,:};
    numTimePoints = size(tempCoords,1)
    Y(((i-1)*numTimePoints)+1 : ((i-1)*numTimePoints)+numTimePoints,:) = tempCoords(:,1:2);
    for j = 1 : numTimePoints
        zSlice = tempCoords(j,3);
        tPoint = tempCoords(j,4);
        for k = 0 : zDepth -1
            X_zRanges(j,k+1) = zSlice - (zDepth-1)/2 + i;
            Img(:,:,k+1) = readimage(ds, tempDSindex;
            X_indices(j,k+1) = getDSindex(X_zRanges(j,k+1), tPoint);
        end
    X(((i-1)*numTimePoints)+j,:) = generatePredictorMatrix(inputPredictor, sizeX);
    end
end

tic
SVMModel = fitcsvm(X,Y);
toc

% With the SVM model generated, save the model parameters
if exist(filename, 'file') == 2
    save(filename, 'SVMModel', '-append')
else
    save(filename, 'SVMModel')
end