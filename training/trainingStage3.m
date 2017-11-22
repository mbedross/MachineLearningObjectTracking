function [b] = trainingStage3(dTrainC)

% The parameters zVal and tVal represent the z-slice and timestep values
% respectively of the image we would like to obtain more training pixels
% from.
zVal = 84;
tVal = 1;

[newCoords] = getBugMoreBugCoords(dTrainC, zVal, 1, tVal);

prompt = 'Would you like to add these points to bugCoords? Y/N: ';
str = input(prompt,'s');

if str == 'Y'
    bugCoords = [bugCoords; newCoords];
end
prompt = 'Would you like to update your b value Y/N: ';
str = input(prompt,'s');
if str == 'Y'
    yCoords = zeros(size(dTrain));
    for i = 1:size(bugCoords,1)
        xval = bugCoords(i,1);
        yval = bugCoords(i,2);
        zval = bugCoords(i,3);
        idx=1;
        yCoords(yval,xval,zval,idx) = 1;
    end
    yTrain = yCoords(:);
    disp('Calculating new parameter values...')
    tic
    %function glmfit() is from Statistical and Machine Learning Toolbox. It
    %implements Linear Logistic Regression, and calculates weight vector
    %'b' for a given feature matrix 'X' with its corresponding binary answer
    %key 'y'
    %----------------------------------------------------
    [new_b,dev] = glmfit(Xtrain,yTrain,'binomial','link','logit');
    %------------------------------------------------------
    toc   
    prompt = 'Are you sure you would like to update your b value Y/N: ';
    str = input(prompt,'s');
    if str == 'Y'
        b=new_b;
    end
end
filename = 'Where should the training data be saved? (e.g. C:\Users\manu\Desktop\TrainingData\Colwellia.mat';
save(filename, b, '-append')