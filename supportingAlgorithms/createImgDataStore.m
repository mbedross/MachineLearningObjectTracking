function [ds, zNF_range, zSorted_range] = createImgDataStore(zRange)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Author: Manuel Bedrossian, Caltech
% Date Created: 2018.10.10
%
% This function imports z-slice reconstructions at a multiple time points 
% as an image datastore for only the range of z-slices defined in zRange.
%
% All images are indexed sequentially by batches of z-slice (in ascending 
% order) and in time. (e.g. If there are a total of 10 z-slices in datastore
% and twenty time points in each z-slice, accessing the 4th time point in 
% the 3rd z-slice would require to access the 24th entry in the datastore 
%
% For a detailed list and description of variables please see the read me
% file 'README.md'
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global type
global masterDir
global zSorted

% Define the range in z-steps to use in training
zSorted_range = zSorted;
zSorted_range(zSorted > zRange(2)) = [];
zSorted_range(zSorted < zRange(1)) = [];
zNF_range = length(zSorted_range);

for z = 1 : zNF_range
    location{z} = fullfile(masterDir, 'MeanStack', char(type), sprintf('%0.2f', zSorted_range(z)));
end

ds = datastore(location, 'IncludeSubfolders', true,'FileExtensions', '.tiff','Type', 'image');

