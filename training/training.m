function [SVMmodel, sizeSubImage] = training(trainZrange, trainTrange)

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
global zDepth
global particleSize

% Desired size of sub-image
sizeImageXY = 4*particleSize+1;

% Create a datastore of images
[ds] = createImgDataStore();

% Define the range of Z slices to train on as global indices of zSorted
trainZrange_index = [find(zSorted == trainZrange(1)) find(zSorted == trainZrange(2))];

[trainFileName, trainPath] = uiputfile('*.mat','Choose Where to Save Training Data file');
filename = fullfile(trainPath, trainFileName);

coordName = fullfile(masterDir, 'BugCoords.mat');
if exist(coordName, 'file') == 2
    load(coordName);
else
    % Ask user to select coordinates with particles in the FOV
    trainLock = 1;
    numParticle = 0;
    while trainLock
        tempCoords = getParticleCoordsXY(trainZrange_index, trainTrange, 1);
        tempCoords = getParticleCoordsZ(tempCoords);
        numParticle = numParticle + 1;
        particleCoords{numParticle, :} = tempCoords;
        track = questdlg('Would you like to track another particle?', 'Track Another Particle?', 'Yes','No','Yes');
        if strcmp(track, 'No')
            trainLock = 0;
        end
    end
    % Ask user to select coordinates with NO particles in the FOV
    trainTrange_empty = [trainTrange(1), numParticle*(trainTrange(2)-trainTrange(1)+1)];
    tempCoords = getParticleCoordsXY(trainZrange_index, trainTrange_empty, 0);
    emptyCoords = tempCoords;
    save(coordName, 'particleCoords', 'emptyCoords')
end

% For each particle at each time point, generate the 3D image to then be formatted as
% a predictor matrix
sizeSubImage = [sizeImageXY, sizeImageXY, zDepth];
tempCoords = particleCoords{1,:};
numTimePoints = size(tempCoords,1);
sizeX = sizePredictorMatrix(sizeSubImage(1),sizeSubImage(2),sizeSubImage(3));
Img = zeros(sizeSubImage(1),sizeSubImage(2),sizeSubImage(3));
X = zeros(length(particleCoords)*numTimePoints+size(emptyCoords,1),sum(sizeX));
Y = zeros(length(particleCoords)*numTimePoints+size(emptyCoords,1), 1);
X_zRanges = zeros(length(particleCoords)*numTimePoints+size(emptyCoords,1), zDepth);
X_indices = zeros(length(particleCoords)*numTimePoints+size(emptyCoords,1), zDepth);
for i = 1 : length(particleCoords)
    tempCoords = particleCoords{i,:};
    numTimePoints = size(tempCoords,1);
    for j = 1 : numTimePoints
        zSlice = tempCoords(j,3);
        tPoint = tempCoords(j,4);
        xRange = [tempCoords(j,1)-floor(sizeImageXY/2), tempCoords(j,1)-floor(sizeImageXY/2)+sizeImageXY-1];
        yRange = [tempCoords(j,2)-floor(sizeImageXY/2), tempCoords(j,2)-floor(sizeImageXY/2)+sizeImageXY-1];
        for k = 0 : zDepth -1
            X_zRanges(j,k+1) = zSlice - (zDepth-1)/2 + k;
            X_indices(j,k+1) = getDSindex(X_zRanges(j,k+1), tPoint);
            I = readimage(ds, X_indices(j,k+1));
            Img(:,:,k+1) = I(yRange(1):yRange(2), xRange(1):xRange(2));
        end
        X(((i-1)*numTimePoints)+j,:) = generatePredictorMatrix(Img, sizeX);
        Y(((i-1)*numTimePoints)+j) = 1;
    end
end

lastIndexX = ((i-1)*numTimePoints)+j;

% For each coordinate of empty space, generate the 3D image to then be formatted as
% a predictor matrix
for ii = 1 : size(emptyCoords,1)
    zSlice = emptyCoords(ii, 3);
    tPoint = emptyCoords(ii, 4);
    xRange = [emptyCoords(ii,1)-floor(sizeImageXY/2), emptyCoords(ii,1)-floor(sizeImageXY/2)+sizeImageXY-1];
    yRange = [emptyCoords(ii,2)-floor(sizeImageXY/2), emptyCoords(ii,2)-floor(sizeImageXY/2)+sizeImageXY-1];
    for k = 0 : zDepth -1
        X_zRanges(lastIndexX+ii,k+1) = zSlice - (zDepth-1)/2 + i;
        X_indices(lastIndexX+ii,k+1) = getDSindex(X_zRanges(lastIndexX+ii,k+1), tPoint);
        I = readimage(ds, X_indices(lastIndexX+ii,k+1));
        Img(:,:,k+1) = I(yRange(1):yRange(2), xRange(1):xRange(2));
    end
    X(lastIndexX+ii,:) = generatePredictorMatrix(Img, sizeX);
end

tic
% Train a Support Vector Machine model based on the predictor matrix X and class labels Y
[SVMmodel] = fitcsvm(X,Y);
% Compute the optimal transfer function between fit scores and posterior probabilities of
% the SVM model using the predictor matrix X and class labels Y
[SVMmodel] = fitSVMPosterior(SVMmodel, X, Y);
toc

% Calculating the optimal score to posterior probability transfer function allows the SVM
% model to output confidence intervals on its predictions as a probability (a value between 0 and 1)

% With the SVM model generated, save the model parameters
if exist(filename, 'file') == 2
    save(filename, 'SVMmodel', 'sizeSubImage', '-append')
else
    save(filename, 'SVMmodel', 'sizeSubImage')
end