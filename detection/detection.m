function [points_clustered] = detection(model, imageSize, voxelPitch)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Author: Manuel Bedrossian, Caltech
% Date Created: 2018.11.13
%
% This function takes as an input the parameters for the Support Vector
% Machine (SVM) generated for the data that is to be analyzed
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global masterDir
global n
global zSorted
global zDepth
global ds
global zRange
global tRange
global clusterThreshold
global times

%GPU = questdlg('Would you like to use GPU parallelization for Pre-Processing? NOTE: This is only to be called when the user wants to use GPU parallelization. This depends on the capabilities of the GPU on the machine this is to run on. Check GPU specs before using and/or contact Manuel Bedrossian (mbedross@caltech.edu)', ...
%    'GPU Parallelization', ...
%    'Yes','No','No');

% Create a datastore of images
[ds] = createImgDataStore();

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
xMargin = (imageSize(1)-1)/2;
yMargin = (imageSize(2)-1)/2;
zMargin = (imageSize(3)-1)/2;
zSorted_range(1:zMargin+1) = [];
zSorted_range(end-zMargin+1:end) = [];
xRange = n(1)-2*xMargin;
yRange = n(2)-2*yMargin;
interval = xMargin;
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
[Ax, Ay] = meshgrid(xMargin+(0:nX-1)*interval+1, yMargin+(0:nY-1)*interval+1);
points_raw = cell(nT, 1);
points_spatial = cell(nT, 1);
I = gpuArray(zeros(n(1),n(2),zDepth));
Img = gpuArray(zeros(imageSize(1),imageSize(2),imageSize(3)));
X = gpuArray(zeros(nY, sum(sizeX)));
for it = latestTime : nT
    tPoint = timePoints_range(it);
    for iz = 1 : nZ
        zPlane = find(zSorted == zSorted_range(iz));
        for k = 0 : zDepth -1
            tempZ = zPlane - (zDepth-1)/2 + k;
            index = getDSindex(tempZ,tPoint);
            I(:,:,k+1) = readimage(ds, index);
        end
        centerImageIndex = getDSindex(zPlane, tPoint);
        centerImage = readimage(ds, centerImageIndex);
        [props] = boundaryDetection(I);
        [coordinates] = pointsOfInterest(props)
        nPoints = size(coordinates,1);
        X = gpuArray(zeros(nPoints, sum(sizeX)));
        for ixy = 1 : length(coordinates)
            center = coordinates(ixy, :);
            xRange_subImage = [center(1)-(imageSize(1)-1)/2, center(1)-(imageSize(1)-1)/2+imageSize(1)-1];
            yRange_subImage = [center(2)-(imageSize(2)-1)/2, center(2)-(imageSize(2)-1)/2+imageSize(2)-1];
            for k = 0 : zDepth -1
                Img(:,:,k+1) = I(yRange_subImage(1):yRange_subImage(2), xRange_subImage(1):xRange_subImage(2),k+1);
            end
            X(ixy,:) = generatePredictorMatrix(Img, sizeX);
        end
        [label] = predict(model, X);






        for ix = 1 : nX
            tic
            for iy = 1 : nY
                center = [Ax(iy,ix), Ay(iy,ix)];
                xRange_subImage = [center(1)-(imageSize(1)-1)/2, center(1)-(imageSize(1)-1)/2+imageSize(1)-1];
                yRange_subImage = [center(2)-(imageSize(2)-1)/2, center(2)-(imageSize(2)-1)/2+imageSize(2)-1];
                for k = 0 : zDepth -1
                    Img(:,:,k+1) = I(yRange_subImage(1):yRange_subImage(2), xRange_subImage(1):xRange_subImage(2),k+1);
                end
                X(iy,:) = generatePredictorMatrix(Img, sizeX);
            end
            %[label, PostProbs] = predict(model, X);
            [label] = predict(model, X);
%             A(iy, ix, iz) = label;
%             if label == 1
%                 %probability(iy,ix,iz) = PostProbs(2);
%                 points_raw{it} = [points_raw{it}; Ax(iy,ix), Ay(iy,ix), zSorted_range(iz)];
%             else
%                 %probability(iy,ix,iz) = PostProbs(1);
%             end
            toc
        end
    end
    points_spatial{it} = points_raw{it}*[voxelPitch(1), 0, 0; 0, voxelPitch(2); 0, 0, voxelPitch(3)];
    [Clusters] = hierarchicalClustering(points_spatial{it}, clusterThreshold);
    clusterPoints = findClusterCentroids(Clusters, points_raw{it});
    temporaryPoints = zeros(size(clusterPoints,1), 4);
    temporaryPoints(:,1:3) = clusterPoints;
    temporaryPoints(:,4) = tPoint;
    points_clustered = [points_clustered; temporaryPoints];
    clear temporaryPoints
    save(trackData, '-regexp', '^(?!(X)$).') % Save temporary workspace
end