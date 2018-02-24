function [centroids] = findClusterCentroids(Clusters, points)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function takes the clustered information from using an Agglomerative
% hierarchical cluster tree algorithm and calculates the centroid of the
% clustered points. This algorithm calculates an unweighted average as the
% centroid where later versions will calculate a weighted centroid based on
% the confidence interval of detection.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

centroids = zeros(length(Clusters),3);
for i = 1 : length(centroids)
    index = Clusters{i,1};
    coords = points(index,:);
    centroids(i,:) = mean(coords);
end
