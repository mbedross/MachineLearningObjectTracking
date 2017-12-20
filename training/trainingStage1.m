function [b, Xtrain] = trainingStage1(dTrain)

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
addpath('./supportingAlgorithms');
cropSize = 15;

%bugCoords = getBugCoords3(dTrain, 1, 1);
%save('BugCoords.mat', 'bugCoords')
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
    if z ~= 1 && z ~= 2
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
    if z ~= size(dTrain,3) && z~= size(dTrain,3) - 1
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