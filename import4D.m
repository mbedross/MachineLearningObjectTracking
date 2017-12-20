function [I] = import4D(dataDir, zSorted, times, zRange, tRange)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function imports z-slice reconstructions at a multiple time points 
% as a four-dimensional matrix I. Where size(I) = x by y by z by t. 'x' 
% and 'y' are the width and height of the image, respectively, 'z' is the z
% step, and 't' is time.
%
% Variable list:
% dataDir = (input) string of the filepath where data is located
% zSorted = (input) array of sorted z-slice locations (all locations)
% times =   (input) the times at which z-stack exist (all locations)
% zRange =  (input) array defining the range in z values desired to be
%                   imported (e.g. zRange = [zMin zMax])
% tRange =  (input) array defining the range in times desired to be
%           imported (e.g. tRange = [tMin tMax])
%
% type =      a global variable that defines whether to import an Amplitude 
%             or Phase reconstruction
% n =         a global variable that defines the x and y pixel counts of 
%             the z-slices (e.g. n = [2048 2048])
% zNF =       the total number of z-slices to be imported
% tNF =       the total number of time points to be imported
% reconPath = an intermediate variable to define the filepath to a specific
%             z-slice to be imported
%
% I = (output) the final variable containing the three-dimensional z-stack
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global type n

% Define the range in z-steps to use in training
zSorted(zSorted > zRange(2)) = [];
zSorted(zSorted < zRange(1)) = [];
zNF = length(zSorted);

% Find how many time sequences exist
times(times > tRange(2)) = [];
times(times < tRange(1)) = [];
tNF = length(times);

% Begin loading images into dTrain
I = uint8(zeros(n(1), n(2), zNF, tNF));
for i = 1: zNF
    reconPath = fullfile(dataDir, 'MeanStack', char(type), sprintf('%0.2f', zSorted(i)));
    for t = 1 : length(times)
        I(:, :, i, t) = imread(fullfile(reconPath, sprintf('%05d.tiff', times(t))));
    end
end