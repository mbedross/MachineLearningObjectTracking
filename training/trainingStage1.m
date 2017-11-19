function [b, Xtrain] = trainingStage1(masterDir, zSorted, times, type, dTrain)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function represents Stage 1 of the training routine for ML based
% particle tracking
%
% This function assumes that the zSteps sub routine is already been run and
% its results are passed to it
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% First import mean subtracted and filtered reconstructions into a four
% dimensional matrix dTrain = XxYxZxt

n = 2048;
cropSize = 15;
dataDir = fullfile(masterDir, 'MeanStack');
% type ='Amplitude';
% type = 'Phase';

% Define the range in z-steps to use in training (this is because using the
% entire z-stack will be too RAM heavy)
zLow = -16;
zHigh = 16;
zStep = 0.1;
zNF = (zHigh - zLow)/zStep + 1;

% Find how many time sequences exist
filePath = dir(fullfile(dataDir, char(type), sprintf('%0.2f', zLow)));
tNF = length(filePath(not([filePath.isdir]))) - 2;  % number of time sequeces

implay(permute(dTrain,[1 2 4 3]))

bugCoords = getBugCoords3(dTrain, 1, 1);

croppedDt = cropEdges(dTrain, cropSize);
dTrain = addEdges(croppedDt, cropSize);

Xtrain = zeros(0,9);
for z = 1 : size(dTrain,3)
    if z == 1
        input_slice(:,:,1) = dTrain(:,:,z);
        input_slice(:,:,2) = dTrain(:,:,z);
    end
    if z ==2
        input_slice(:,:,1) = dTrain(:,:,z-1);
        input_slice(:,:,2) = dTrain(:,:,z-1);
    end
    if z ~= 1 || z ~= 2
        input_slice(:,:,1) = dTrain(:,:,z-2);
        input_slice(:,:,2) = dTrain(:,:,z-1);
    end
    input_slice(:,:,3) = dTrain(:,:,z);
    if z == size(dTrain,3)
        input_slice(:,:,4) = dTrain(:,:,z);
        input_slice(:,:,5) = dTrain(:,:,z);
    end
    if z == size(dTrain,3) - 1
        input_slice(:,:,4) = dTrain(:,:,z+1);
        input_slice(:,:,5) = dTrain(:,:,z+1);
    end
    if z ~= size(dTrain,3) || z~= size(dTrain,3) - 1
        input_slice(:,:,4) = dTrain(:,:,z+1);
        input_slice(:,:,5) = dTrain(:,:,z+2);
    end
    Xtrain = [Xtrain; getInputMatrixV5zs(input_slice)];
end

yCoords = zeros(size(dTrain,1),size(dTrain,2),size(dTrain,3));

for i = 1:size(bugCoords,1)
    xval = bugCoords(i,1);
    yval = bugCoords(i,2);
    zval = bugCoords(i,3);
    yCoords(yval,xval,zval) = 1;
end

yTrain = yCoords(:);

% Use the coordinate information found earlier to begin generating linear
% models to be used as a training data set
tic
[b,dev] = glmfit(Xtrain,yTrain,'binomial','link','logit');
toc