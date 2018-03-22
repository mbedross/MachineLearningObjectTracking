function [I] = import3D(zSorted, time, zRange)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function imports z-slice reconstructions at a single time point as a
% three-dimensional matrix I. Where size(I) = x by y by z. 'x' and 'y' are
% the width and height of the image, respectively, and 'z' is the z step.
% This routine is used as often as possible to conserve RAM, whereas
% 'import4D.m' imports a time series of reconstructions as a
% four-dimensional matrix (x by y by z by t)
%
% Variable list:
% dataDir = (input) string of the filepath where data is located
% zSorted = (input) array of sorted z-slice locations
% time =    (input) the time at which a z-stack is to be imported
% zRange =  (input) array defining the range in z values desired to be
%                   imported (e.g. zRange = [zMin zMax])
%
% type =      a global variable that defines whether to import an Amplitude 
%             or Phase reconstruction
% n =         a global variable that defines the x and y pixel counts of 
%             the z-slices (e.g. n = [2048 2048])
% zNF =       the total number of z-slices to be imported
% reconPath = an intermediate variable to define the filepath to a specific
%             z-slice to be imported
%
% I = (output) the final variable containing the three-dimensional z-stack
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global type n masterDir

% Define the range in z-steps to use in training
zSorted(zSorted > zRange(2)) = [];
zSorted(zSorted < zRange(1)) = [];
zNF = length(zSorted);

% Begin loading images into dTrain
I = uint8(zeros(n(1), n(2), zNF));
for i = 1: zNF
    reconPath = fullfile(masterDir, 'MeanStack', char(type), sprintf('%0.2f', zSorted(i)));
    I(:, :, i) = imread(fullfile(reconPath, sprintf('%05d.tiff', time)));
end