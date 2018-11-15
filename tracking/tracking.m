function tracking(particleCoordinates, MaxLinkingDistance, maxGap)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Author: Manuel Bedrossian, Caltech
% Date Created: 2018.11.13
%
% This function takes in as an input the spatial coordinates of particles
% in (x,y,z,t) where xyz are in microns and t is in seconds. With this variable,
% the algorithm creates tracks by using the simple 'Hungarian nearest nieghbor'
% approach. It is also capable of dealing with jumps and gaps specified by the
% variable 'maxGap'. The variable 'MaxLinkingDistance' specifies how far each
% point can be that becomes linked.
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
global zRange
global tRange
global clusterThreshold

[tracks, adjacency_tracks] = simpletracker(particleCoordinates, ...
	'MaxLinkingDistance', MaxLinkingDistance, ...
	'MaxGapClosing', maxGap);
%[tracks, adjacency_tracks] = simpletracker(pointsNEW);
    
% Calculate average swimming speeds
%[velTracks, Speed, A] = calcVelocities(pointsNEW, adjacency_tracks, times);
    
% Save final Track Results
trackResultsDir = fullfile(masterDir,'Tracking Results');
mkdir(trackResultsDir);
trackResultsFile = fullfile(trackResultsDir,'tracks');
trackResultsFileMAT = strcat(trackResultsFile,'.mat');
trackResultsFileXLS = strcat(trackResultsFile, '.xlsx');
save(trackResultsFileMAT, '-regexp', '^(?!(X)$).')
saveTracksXLSX(pointsNEW, adjacency_tracks, times, trackResultsFileXLS)
    
% Delete temporary track file
delete(trackData)
    
% Plot results
createPlot(pointsNEW, adjacency_tracks, times)