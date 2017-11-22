function [ D_C3 ] = classify( y, pCutoff, minCluster, dim1, dim2, dim3, dim4 )
%This function classify() takes as input a vector y: which contains the
%output of the logistic regression fit 0<y<1. Element values of
%y>detectionParam are classified as positive and all others are classified
%as negative. The parameter minCluster represents the minimun number of connected
%components in the binary output matrix D_C

Dfit = reshape(y,dim1,dim2,dim3);
Dfit(Dfit>pCutoff) = 1;
D_C = Dfit>pCutoff;


%The function cropEdges removes the edges of the hologram image that have
%high noise. 
%----------------------------------------------
% linearPercentToCrop = 0.03;
% D_C2 = cropEdges(D_C,linearPercentToCrop);
%----------------------------------------------

% the code below removes connected components from D_C that are below
% minCluster pixels
for j = 1:dim4
    %for z = 1:dim3
    D_C3(:,:,:,j) = bwareaopen(D_C(:,:,:,j),minCluster,18);
        %D_C3(:,:,z,j) = bwareaopen(D_C2(:,:,z,j),minCluster,4);
    %end
end
end