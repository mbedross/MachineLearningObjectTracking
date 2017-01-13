% %Training code - phase 2 -  bug Identification verification
% % img

clearvars -except z_tracking_start z_tracking_end  imgScaleFactor b new_b z contrastFactor Dtrain yTrain Xtrain bugCoords cropSize
%-------------------------------------------------------------------------
% First we must define our training data set.
%-------------------------------------------------------------------------
%------------------------------------------------------------------------
%The parameters pCutOff and minCluster relate to identification. 
%they determine the minimum value of y to be classified as bacteria, and  
%the minimum number of connected pixels allowed in the matrix, respectively.
%-------------------------------------------------------------------------
pCutoff = 0.005;
minCluster = 10;
%-----------------------------------------------------------------------
%End of variable declaration
%-----------------------------------------------------------------------

%-------------------------------------------------
dim1 = size(Dtrain,1);
dim2 = size(Dtrain,2);
dim3 = size(Dtrain,3);
dim4 = size(Dtrain,4);
%-------------------------------------------------
%function glmval() is from Statistical and Machine Learning Toolbox. It
%implements Linear Logistic Regression, and calculates probability vector
%'y' for a given feature matrix 'X' and weight vector 'b'.
%----------------------------------------------------
%-------------------------------------------------
yTrainFit = glmval(b,Xtrain,'logit');
%-------------------------------------------------
DtrainC = classify(yTrainFit, pCutoff, minCluster, dim1,dim2,dim3,dim4);
%-------------------------------------------------

for i = 1:size(Dtrain,3)
    I2 = montage([Dtrain(:,:,i,1) 255.*(DtrainC(:,:,i,1))]);
    compVid(:,:,i) = get(I2,'CData');
end

implay(permute(compVid,[1 2 4 3]))
%-------------------------------------------------