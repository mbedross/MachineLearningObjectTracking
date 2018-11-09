function [particleCoords] = getParticleCoordsXY(trainZrange, trainTrange, ds)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Author: Manuel Bedrossian, Caltech
% Date Created: 2018.10.10
%
% This function is intended to display a sequence of images to a user who
% is to select particles of interest in order the Machine Learning Algorithm
% to be trained.
%
% The user will first be shown a single reconstruction a the first time point
% specified in the trainTrange variable, at the center z-plane specified by
% the trainZrange variable. With this image, the user will select eith an in-
% focus or out of foucs particle. (Note: Choose a single partlice)
%
% Next the user will be presented the next chronological image (same z-plane
% but the next image in the time sequence). The user will be asked to then
% select the same particle at this time point.
%
% The user will be asked to repeat this step for a total of 10 time points.
%
% Finally, the user will then be displayed the XZ and YZ cross sections of
% the particles they selected (in order of when they were selected). The
% user will be asked to then locate the particle in the z-direction.
%
% The user will then be asked if they wish to select a new particle. A total
% three particles is required to generate a statisitically significant
% amount of training data.
%
% For a detailed list and description of variables please see the read me
% file 'README.md'
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global masterDir
global ds
global zNF

% First import mean subtracted and filtered reconstructions into an iamge
%datastore (ds)
addpath('./supportingAlgorithms');
load(fullfile(masterDir, 'MeanStack','metaData.mat'))
%[ds, zNF] = import4D(zSorted, trainZrange);

zCenter = zSorted(floor(length(zSorted)/2));
zCenterIdx = find(zSorted==zCenter);
tNF = length(times);

dsIndex = zCenterIdx*tnF + trainTrange(1) - 1;
particleCoords = zeros(10, 4);

for i = 1 : length(trainTrange)
    h1 = figure(1)
    img = readimage(ds, dsIndex + i);
    imagesc(img)
    axis equal
    colormap gray
    if i = 1
        title(sprintf('Please select a single particle you wish to track. %f z-plane is shown. Press ENTER when youve selected the single particle', zCenter))
    else
        title(sprintf('Please select the same particle you wish to track. %f z-plane is shown. Press ENTER when youve selected the single particle', zCenter))
    end
    [X,Y] = getpts;
    x = mean(X); y = mean(Y);
    particleCoords(i,:) = [x, y, zCenter, dsIndex+i];
end
close(h1)