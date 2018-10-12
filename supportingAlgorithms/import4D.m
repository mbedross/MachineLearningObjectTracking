function [ds, zNF] = import4D(zSorted, zRange)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Author: Manuel Bedrossian, Caltech
% Date Created: 2018.10.10
%
% This function imports z-slice reconstructions at a multiple time points 
% as an image datastore. 
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
% For a detailed list and description of variables please see the read me
% file 'README.md'
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global type masterDir

% Define the range in z-steps to use in training
zSorted(zSorted > zRange(2)) = [];
zSorted(zSorted < zRange(1)) = [];
zNF = length(zSorted);

for z = 1 : zNF
    location{z} = fullfile(masterDir, 'MeanStack', char(type), sprintf('%0.2f', zSorted(z)));
end

ds = datastore(location, 'IncludeSubfolders', true,'FileExtensions', '.tiff','Type', 'image');

