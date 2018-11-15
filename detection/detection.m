function [points_clustered] = detection(model, train, varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Author: Manuel Bedrossian, Caltech
% Date Created: 2018.11.13
%
% This function takes as an input the parameters for the Support Vector 
% Machine (SVM) generated for the data that is to be analyzed
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global batchSize
global minTrackSize
global particleSize
global type
global masterDir
global n 
global zSorted
gloabl zNF
global tNF
global zDepth
global ds
global zRange
global tRange
global clusterThreshold
global times

if nargin == 1
	imageSize = varargin{1}
end

% Create a datastore of images
[ds] = createImgDataStore();

% If the dataset is already trained, load the model variables
if train == 0
	[trainFileName, trainPath] = uigetfile('*.mat','Choose Training Data file');
	trainDir = fullfile(trainPath, trainFileName);
	load(trainDir);
	load(fullfile(masterDir, 'MeanStack','metaData.mat'))
end

% If tracking data already exists, load it
% This is a temporary file that saves after each iteration in order to
% prevent data loss as a result of an error or power failure
trackData = fullfile(masterDir,'tempTrackData.mat');
if exist(trackData, 'file') == 2
	load(trackData)
	latestTime = it;
	clear t
else
	latestTime = 1;
end

zSorted_range = zSorted;
zSorted_range(zSorted > zRange(2)) = [];
zSorted_range(zSorted < zRange(1)) = [];   
timePoints_range = times;
timePoints_range(timePoints_range > tRange(2)) = [];
timePoints_range(timePoints_range < tRange(1)) = [];
sizeX = sizePredictorMatrix(imageSize(1),imageSize(2),imageSize(3));
xMargin = imageSize(1)/2;
yMargin = imageSize(2)/2;
zMargin = (imageSize(3)-1)/2;
zSorted_range(1:zMargin) = [];
zSorted_range(end-zMargin:end) = [];
xRange = n(1)-2*xMargin;
yRange = n(2)-2*yMargin;
interval = floor(particleSize/2);
nX = floor(xRange/interval);
nY = floor(yRange/interval);
nZ = length(zSorted_range);
nT = length(timePoints_range);

% Pre-allocate memory for a 3D logical matrix where the results of the ML detection will be stored
% a 0 signifies no particle, 1 signifies a particle
A = false(nX, nY, nZ);
probability = zeros(nX,nY,nZ);
% Ax and Ay are transfer functions to translate the location of a label in A to xy pixel locations
% e.g. the label of A(x,y,z) corresponds to the pixel location of [Ax(x,y), Ay(x,y), zSorted_range(z)]
[Ax, Ay] = meshgrid(xMargin+(0:nX-1)*interval, yMargin+(0:nY-1)*interval);
points_raw = cell(nT, 1);
for it = latestTime : nT
	tPoint = timePoints_range(it);
	for iz = 1 : nZ
		zPlane = zSlice - (zDepth-1)/2 + iz;
		index = getDSindex(zPlane,tPoint)
		I = readimage(ds, index);
		for ix = 1 : nX
			for iy 1 : nY
				center = [Ax(ix,iy), Ay(ix,iy)];
				for k = 0 : zDepth -1
					xRange_subImage = [center(1)-floor(imageSize(1)/2), center(1)-floor(imageSize(1)/2)+sizeImageXY];
					yRange_subImage = [center(2)-floor(imageSize(2)/2), center(2)-floor(imageSize(2)/2)+sizeImageXY];
					Img = I(xRange_subImage(1):xRange_subImage(2), yRange_subImage(1):yRange_subImage(2));
				end
				X = generatePredictorMatrix(Img, sizeX);
				[label, PostProbs] = predict(model, X);
				A(ix, iy, iz) = label;

				if label == 1
					probability(ix,iy,iz) = PostProbs;
					points_raw{it} = [points_raw{it}; Ax(ix,iy), Ay(ix,iy), zSorted_range(iz)];
				else
					probability(ix,iy,iz) = 1 - PostProbs;
				end
			end
		end
	end
	[Clusters] = hierarchicalClustering(points{it}, clusterThreshold);
	clusterPoints = findClusterCentroids(Clusters, points{it});
	temporaryPoints = zeros(size(clusterPoints,1), 4);
	temporaryPoints(:,1:3) = clusterPoints;
	temporaryPoints(:,4) = tPoint;
	points_clustered = [points_clustered; temporaryPoints];
	clear temporaryPoints
	save(trackData, '-regexp', '^(?!(X)$).') % Save temporary workspace
end