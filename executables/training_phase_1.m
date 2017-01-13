% %Training code - phase 1 - bug identification
% % this code will train our classifyer by presenting examples for the user.
%-------------------------------------------------------------------------
% First we must define our training data set.
%-------------------------------------------------------------------------
%-------------------------------------------------------------
clearvars -except b points points2 bugCoords Dtrain replicated

%-------------------------------------------------------------
%Variable Declarations - things to consider:
%Now we are dealing with 3D data, therefore the variables must take that
%into account.
%----------------------------------------------------------------
%Enter Dataset size below
%----------------------------------------------------------------
z_dataset_start = 70;
z_dataset_end = 170;
t_dataset_start = 1;
t_dataset_end = 195;
%---------------------------------------------------------------
%Enter a subsection of the dataset to track below
%--------------------------------------------------------------
z_tracking_start = 70;
z_tracking_end = 170;
t= 1;

%--------------------------------------------------------------
%Enter image parameters below
%cropSize units is Pixels
%--------------------------------------------------------------
cropSize = 15;

%-------------------------------------------------------------
%------------------------------------------------------------------------
%tEnd is the highest time frame available in all zslices of the dataSet
%-----------------------------------------------------------------------
%Variable contrastFactor enhances the contrast of the image after median
%subtraction to make the features more distinguishable from the background.
%Default value is contrastFactor = 3
%------------------------------------------------------------------------
%imgScaleFactor, contrastFactor, tEnd and numFrames must be constant throughout training and
%testing
%------------------------------------------------------------------------
%------------------------------------------------------------------------
%Variable sections is an intger which splits the image into sections^2
%pieces to make identification more accurate. Default value is sections =
%2, which would result in splitting the image into 4 quadrants
%------------------------------------------------------------------------
sections = 1;
imgScaleFactor = 1;
numFrames = 0;
contrastFactor = 1;
%----------------------------------------------------------------------
if z_tracking_start>z_dataset_start
    z_bottom = 0;
else
    z_bottom = 1;
end

if z_tracking_end<z_dataset_end
    z_top = 0;
else
    z_top = 1;
end
%-------------------------------------------------------------------------
%End of variable declaration
%-----------------------------------------------------------------------


for z = z_tracking_start-~(z_bottom):z_tracking_end+~(z_top);

    k=(z-z_tracking_start+1);
    zVals(k) = z;
    [imgA,imgB] = returnMedianImgAndImg(z,t,t_dataset_end,numFrames, imgScaleFactor);
    Dtrain(:,:,k) = uint8((int16(imgA) - int16(imgB)).*contrastFactor+127);

    creating_training_dataSet_percent_completed = k*100/((z_tracking_end-z_tracking_start))
end

%-----------------------------------------------------------------------
implay(permute(Dtrain,[1 2 4 3]))
%-------------------------------------------------


bugCoords = getBugCoords3(Dtrain,t, sections );

dim1 = size(Dtrain,1);
dim2 = size(Dtrain,2);
dim3 = size(Dtrain,3);
dim4 = size(Dtrain,4);

croppedDt = cropEdges(Dtrain,cropSize);
Dtrain = addEdges(croppedDt,cropSize);

Xtrain = zeros(0,9);

for z = 1:dim3
    
    if z==1
        input_slice(:,:,1) = Dtrain(:,:,z);
        input_slice(:,:,2) = Dtrain(:,:,z);
    else
        if z ==2
            input_slice(:,:,1) = Dtrain(:,:,z-1);
            input_slice(:,:,2) = Dtrain(:,:,z-1);
        else
            input_slice(:,:,1) = Dtrain(:,:,z-2);
            input_slice(:,:,2) = Dtrain(:,:,z-1);
        end
        
    end
    
    input_slice(:,:,3) = Dtrain(:,:,z);
    
    if z==dim3
        input_slice(:,:,4) = Dtrain(:,:,z);
        input_slice(:,:,5) = Dtrain(:,:,z);
    else
        if z == dim3-1
            input_slice(:,:,4) = Dtrain(:,:,z+1);
            input_slice(:,:,5) = Dtrain(:,:,z+1);
        else
            input_slice(:,:,4) = Dtrain(:,:,z+1);
            input_slice(:,:,5) = Dtrain(:,:,z+2);
        end
    end
    
    Xtrain = [Xtrain; getInputMatrixV5zs(input_slice)];
    getting_Xtrain_percent_complete = z *100/dim3
end


yCoords = zeros(dim1,dim2,dim3);

for i = 1:size(bugCoords,1)
    xval = bugCoords(i,1);
    yval = bugCoords(i,2);
    zval = bugCoords(i,3);
    
    yCoords(yval,xval,zval) = 1;
end

%The code below generates the input X matrix of the features in the
%training data set Dtrain. X = [pixelvalue 1stDerivative 2ndDerivative]. X
%is of size N x 3 where N = the total number of pixels in the training set
%Dtrain = dim1*dim2*dim3 = N

%We will now create the yTrain vetor from yCoords Matrix
yTrain = yCoords(:);

%The code below finds the vector b: the weights of the parameters of
%logistic regression using Xtrain and Ytrain.
%The vector yTrainFit is generated using Xtrain and the parameter values
%found in vector b. The difference between yTrain and yTrainFit is the
%training error.

%function glmfit() is from Statistical and Machine Learning Toolbox. It
%implements Linear Logistic Regression, and calculates weight vector
%'b' for a given feature matrix 'X' with its corresponding binary answer
%key 'y'
%----------------------------------------------------
tic
[b,dev] = glmfit(Xtrain,yTrain,'binomial','link','logit');
toc
%----------------------------------------------------
