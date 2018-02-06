function saveTracksXLSX(points, adjacencyTracks, times, fileName)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function, takes as inputs cell arrays of points and adjecency tracks
% from the simpleTracker.m algorithm in order to generate a 3D plot of
% trajectories that are color coded with respect to time.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global masterDir
allPoints = vertcat(points{:});

% Account for flipped z (this is because of the way numerical
% reconstructions occur and will be fixed later
maxes = max(allPoints);
allPoints(:,3) = maxes(3) -allPoints(:,3); 

nTracks = size(adjacencyTracks,1);

% Import timestamp file to calculate velocities
[stamp, timeOfDay, Date, time] = textread(fullfile(masterDir, ...
    'timestamps.txt'),'%f %s %s %f');
clear timeOfDay Date stamp
time = time./1000;                              % Convert time from ms to s

ImgTimes = time(times);

for i = 1 : nTracks
    index = adjacencyTracks{i,1};
    if length(index)>=6
        coords = allPoints(index,:);
        % Find the times associated to each coordinate
        for j = 1 : length(coords)
            for k = 1 : size(points,2)
                [tf,Index] = ismember(points{1,k}, coords(j,1:3),'rows');
                if any(Index)
                    coords(j,4) = ImgTimes(k);
                    %coords(j,4) = k;
                    break
                end
            end
        end
        xlswrite(fileName,coords,i)
    end
end