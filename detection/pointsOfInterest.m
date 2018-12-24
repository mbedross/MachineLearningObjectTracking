function [coordinates] = pointsOfInterest(props, imageSize)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Author: Manuel Bedrossian, Caltech
% Date Created: 2018.12.24
%
% This function takes in as an input the region properties of a thresholded
% image in order to calculate 
% This expects the props variable to contain 'WeightedCentroid', 
% 'MajorAxisLength', and 'MinorAxisLength'.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global particleSize

points = round(cat(1, props.WeightedCentroid));
sizeMajor = round(cat(1, props.MajorAxisLength));
sizeMinor = round(cat(1, props.MinorAxisLength));

% Cyle through all points and look at region eSize
% If the region size is as large as a particle then divide up the region into 5 points
% 5 points are the center and top bottom left right
bigPoints = points(sizeMajor>=particleSize,:);
newPoints = zeros(size(bigPoints,1)*4, 2);
for i = 0 : size(bigPoints,1)-1
    newPoints(i*4+1 : i*4+4,:) = [bigPoints(i+1,1) + particleSize bigPoints(i+1,2);...
        bigPoints(i+1,1) - particleSize bigPoints(i+1,2);...
        bigPoints(i+1,1) bigPoints(i+1,2) + particleSize;...
        bigPoints(i+1,1) bigPoints(i+1,2) - particleSize];
end

coordinates = [points; newPoints];
% filter points that are out of the range of the image
coordinates = coordinates(coordinates(:,1)>=0+(imageSize(1)-1)/2+1,:);
coordinates = coordinates(coordinates(:,2)>=0+(imageSize(1)-1)/2+1,:);
coordinates = coordinates(coordinates(:,1)<=2048-(imageSize(1)-1)/2-1,:);
coordinates = coordinates(coordinates(:,2)<=2048-(imageSize(1)-1)/2-1,:);