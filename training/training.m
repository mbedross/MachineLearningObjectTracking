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
        tempCoords = getParticleCoordsZ(tempCoords, trainZrange, trainTrange)
        numParticle = numParticle + 1;
        particleCoords{numParticle, :} = [tempCoords];
        track = questdlg('Would you like to track another particle?', 'Yes','No','Yes');
        if strcmp(track, 'No')
            trainLock = 0;
        end
    end
    save(coordName, 'bugCoords')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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