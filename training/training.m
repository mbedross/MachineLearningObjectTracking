function [b, Xtrain] = training(trainZrange, trainTrange)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function contains the training routine for ML based particle
% tracking
%
% This function assumes that the zSteps sub routine has already been run and
% its results are passed to it
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global masterDir

cropSize = 15;

[trainFileName, trainPath] = uiputfile('*.mat','Choose Where to Save Training Data file');
filename = fullfile(trainPath, trainFileName);

coordName = fullfile(masterDir, 'BugCoords.mat');
if exist(coordName, 'file') == 2
    load(coordName);
else
    trainLock = 1;
    numParticle = 0;
    while trainLock
        tempCoords = getParticleCoordsXY(trainZrange, trainTrange);
        tempCoords = getParticleCoordsZ(particleCoords);
        numParticle = numParticle + 1;
        particleCoords{numParticle, :} = [tempCoords];
        track = questdlg('Would you like to track another particle?', 'Yes','No','Yes');
        if strcmp(track, 'No')
            trainLock = 0;
        end
    end
    save(coordName, 'bugCoords')
end
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

if exist(filename, 'file') == 2
    save(filename, 'b', '-append')
else
    save(filename, 'b')
end