function [I_mean] = meanSubtractionGPU(I)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Author: Manuel Bedrossian
% Last Modified: 2017.07.30
%
% This function calculates the median subtracted image of a time series I.
% Data structure of I is NxMxT where a single image is a matrix of NxM
% pixels and T is the number of images in the series to be median
% subtracted.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


x = class(I);
% Calculate median image
Mean = mean(I,3);
t = size(I,3);
        
switch x
    case 'gpuArray'
        for t = 1 : t
            I(:,:,t) = I(:,:,t) - Mean;
            % Normalize images to prevent flaring
            I_int = I(:,:,t);
            I_int= (I_int-min(I_int(:)))./(max(I_int(:))-min(I_int(:)));
            I_int = I_int+(0.5-mean(I_int(:)));
            I_int(I_int<0) = 0;
            I_int(I_int>1) = 1;
            I(:,:,t) = I_int;
        end    
    case 'uint8'
        for t = 1 : t
            I(:,:,t) = I(:,:,t) - Mean;
            % Normalize images to prevent flaring
            I_int = I(:,:,t);
            I_int= (I_int-min(I_int(:)))./(max(I_int(:))-min(I_int(:)));
            I(:,:,t) = I_int+(127-mean(I_int(:)));
            I_int(I_int<0) = 0;
            I_int(I_int>255) = 255;
            I(:,:,t) = I_int;
        end
end

I_mean = I;