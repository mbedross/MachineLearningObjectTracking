function [avgTrack, medTrack, stdTrack] = averageTrackSize(adjacencyTracks)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function, takes as inputs cell arrays of points and adjecency tracks
% from the simpleTracker.m algorithm in order to generate a 3D plot of
% trajectories that are color coded with respect to time.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nTracks = size(adjacencyTracks,1);
trackLength = zeros(1,nTracks);

for i = 1 : nTracks
    index = adjacencyTracks{i,1};
    trackLength(i) = length(index); 
end

avgTrack = mean(trackLength);
medTrack = median(trackLength);
stdTrack = std(trackLength);
histogram(trackLength)