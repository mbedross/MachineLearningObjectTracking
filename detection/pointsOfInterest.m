function [coordinates] = pointsOfInterest(props)

% This expects the props variable to contain 'WeightedCentroid', 'MajorAxisLength', and 'MinorAxisLength'

global particleSize

points = props.WeightedCentroid;
sizeMajor = props.MajorAxisLength;
sizeMinor = props.MinorAxisLength;

% Cyle through all points and look at region eSize
% If the region size is as large as a particle then divide up the region into 5 points
% 5 points are the center and top bottom left right
newPoints = zeros(0,2);
for i = 1 : length(points)
    if sizeMajor >= particleSize
        newPoints = [newPonts; points(i,1) + particleSize points(i,2);...
            points(i,1) - particleSize points(i,2);...
            points(i,1) points(i,2) + particleSize;...
            points(i,1) points(i,2) - particleSize];
    end
end

coordinates = [points; newPoints];