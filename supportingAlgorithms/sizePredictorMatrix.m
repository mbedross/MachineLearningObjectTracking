function [sizeX] = sizePredictorMatrix(N,M,z)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Author: Manuel Bedrossian, Caltech
% Date Created: 2018.11.12
%
% This function takes in as an input, the dimensions of the input 
% predictor matrix and it callculates the length of the predictor matrix X.
% This has been written as a separate function because it is to be used to 
% pre-allocate memory for speed and efficiency
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[d] = [N, M, z];

% Preallocate memory for predictor matrix
lengthdz = N*M*(z-1);
lengthGmag = d(1)*d(2)*d(3);
lengthGdir = lengthGmag;
lengthSNR = lengthGmag;
lengthFFT = 3*lengthGmag; % x3 because of magnitude, real, and imaginary parts
sizeX = [lengthdz, lengthGmag, lengthGdir, lengthSNR, lengthFFT];