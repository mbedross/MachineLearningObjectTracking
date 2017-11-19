function [ Dout ] = cropEdges( D,cropSize )
%This function takes as input a data set D and cropSize where
%0<cropSize<1.It crops the edges of the images in data set D, 
%by cropSize amount, and returns the cropped version of the image as Dout.

dim1 = size(D,1);
dim2 = size(D,2);
dim3 = size(D,3);
dim4 = size(D,4);

i = cropSize;
j = cropSize;

Dout(:,:,:,:) = D(i:dim1-i,j:dim2-j,:,:);

end