function tracking(particleCoordinates)

[tracks, adjacency_tracks] = simpletracker(particleCoordinates, ...
	'MaxLinkingDistance', max_linking_distance, ...
	'MaxGapClosing', max_gap_closing);
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