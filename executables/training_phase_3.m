% %Training code - phase 3 -  Adding more bugCoords and updating the b
% value.
% After new bugCoords have been added, repeat training Phase 2,
% followed by training phase 3, until satisfaction.

clearvars -except z_tracking_start z_tracking_end  imgScaleFactor b new_b z contrastFactor Dtrain DtrainC yTrain Xtrain bugCoords bugCoords_4d cropSize
%-------------------------------------------------------------------------
%
%-------------------------------------------------------------------------
%------------------------------------------------------------------------
%The parameters zVal and tVal represent the z-slice and timestep values
%respectively of the image we would like to obtain more training pixels
%from.
%-------------------------------------------------------------------------
zVal = 84;
tVal = 1;
%End of Variable declaration
%------------------------------------------------------------------------
[ newCoords ] = getBugMoreBugCoords( DtrainC,zVal,1,tVal  );

prompt = 'Would you like to add these points to bugCoords? Y/N: ';
str = input(prompt,'s');

if str == 'Y'
    bugCoords = [bugCoords; newCoords];
end
prompt = 'Would you like to update your b value Y/N: ';
str = input(prompt,'s');
if str == 'Y'
    
    dim1 = size(Dtrain,1);
    dim2 = size(Dtrain,2);
    dim3 = size(Dtrain,3);
    dim4 = size(Dtrain,4);
    
    yCoords = zeros(dim1,dim2,dim3,dim4);
    
    for i = 1:size(bugCoords,1)
        xval = bugCoords(i,1);
        yval = bugCoords(i,2);
        zval = bugCoords(i,3);
        idx=1;
        
        yCoords(yval,xval,zval,idx) = 1;
    end
    
    yTrain = yCoords(:);
    status = 'Calculating new parameter values...'
    tic
    %function glmfit() is from Statistical and Machine Learning Toolbox. It
    %implements Linear Logistic Regression, and calculates weight vector
    %'b' for a given feature matrix 'X' with its corresponding binary answer
    %key 'y'
    %----------------------------------------------------
    [new_b,dev] = glmfit(Xtrain,yTrain,'binomial','link','logit');
    %------------------------------------------------------
    toc
    
    percentage_change = (b-new_b).*100./new_b
    
    prompt = 'Are you sure you would like to update your b value Y/N: ';
    str = input(prompt,'s');
    if str == 'Y'
        b=new_b;
    end
end
