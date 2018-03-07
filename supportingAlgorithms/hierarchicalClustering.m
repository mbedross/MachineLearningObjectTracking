function [Clusters] = hierarchicalClustering(points, threshold)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function uses an Agglomerative hierarchical cluster tree algorithm
% to analyze the identified points in the tracking process. It is very
% likely that a single particle of interest is identified more than once
% and if left uncorrected, multiple tracks will be generated for the same
% particle. This algorithm identifies clustered points based on a maximum
% allowable Euclidean distance that is specified by the variable
% 'threshold'
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Y = pdist(points);
Z = linkage(Y);
% Filter out all clusters that are too far apart (> threshold)
for i = size(Z,1): -1 : 1
    if Z(i,3) > threshold
        Z(i,:) = [];
    end
end

if (size(Z,1) ~= 1 || size(points,1) >2) && ~isempty(Z)
    % create cluter cell array
    for i = 1 : size(points,1)
        clusters{i} = i;
    end
    
    for i = 1 : size(Z,1)
        clusters{length(points)+i} = [clusters{Z(i,1)} clusters{Z(i,2)}];
    end
    
    aggregate = clusters{length(clusters)};
    Clusters{1} = aggregate;
    index = 2;
    % Refine clustering data
    for i = length(clusters)-1 : -1 : 1
        temp = clusters{i};
        C = unique([aggregate temp]);
        if length(C) == length([aggregate temp])
            aggregate = [aggregate temp];
            Clusters{index} = clusters{i};
            index = index+1;
        end
    end
    
    % Check for missing values (this means that a single point is its own
    % cluster)
    aggregate = sort(aggregate);
    origPoints = 1:length(points);
    loneClusters = setdiff(origPoints, aggregate);
    
    for i = 1 : length(loneClusters)
        Clusters{index} = loneClusters(i);
        index = index + 1;
    end
else
    Clusters{1} = 1:size(points,1);
end

if isempty(Z)
    % create cluter cell array
    for i = 1 : size(points,1)
        Clusters{i} = i;
    end
end
    