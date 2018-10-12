function [particleCoords] = getParticleCoordsZ(xyCoords, trainZrange, trainTrange)

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
% Although this function is meant to perform tracking in z, the input variable
% contains z values of the approximate z location of the particle
%
% For a detailed list and description of variables please see the read me
% file 'README.md'
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global masterDir particleSize

% First import mean subtracted and filtered reconstructions into an iamge
% datastore (ds)
addpath('./supportingAlgorithms');
load(fullfile(masterDir, 'MeanStack','metaData.mat'))
[ds, zNF] = import4D(zSorted, trainZrange);

zCenter = zSorted(floor(length(zSorted)/2));
zCenterIdx = find(zSorted==zCenter);
tNF = length(times);

zSortedRange = zSorted;
zSortedRange(zSorted > trainZrange(2)) = [];
zSortedRange(zSorted < trainZrange(1)) = [];
zRangeNF = length(zSortedRange);
zNF = length(zSorted);

% The time and number of z slices to analyze when constructing XZ slices
time = trainTrange(1);

nom_dsIndex_init = zCenterIdx*tNF + trainTrange(1)-1
dsRange = -zRangeNF:zRangeNF;

numZ = length(dsRange);
yRange = -2*particleSize:2*particleSize

xzSlice = zeros(numZ, 4*particleSize+1)
% Loop through all time points for this particle
for t = 1 : length(trainTrange)
	nom_dsIndex = nom_dsIndex_init+t;
	dsIndex = nom_dsIndex+dsRange.*tNF;
	xCoord = xyCoords(t,1);
	yCoord = xyCoords(t,2);

	%Assemble an XZ slice of the particle at a particular time
	for i = 1 : numZ
		img = readimage(ds, dsIndex(i));
		xzSlice(i,:) = img(xCoord, yCoord+yRange(1):yCoord+yRange(end))
	end
	% The XZ slice display is scaled 1:15 because of the non-uniform voxel size between the x and z z-direction
	h1 = figure(1)
	imshow(xzSlice, [], 'XData', [0 1], 'YData', [0 15]);
	title('Select the point at which the particle is in focus (the waist of the PSF). Press ENTER when done.')
	[X,Z] = getpts;
    x = mean(X); y = mean(Z);
	particleCoords(t,3) = zSortedRange(z);
end