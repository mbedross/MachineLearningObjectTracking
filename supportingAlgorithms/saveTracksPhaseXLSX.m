function saveTracksPhaseXLSX(points, adjacencyTracks, times, fileName)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function, takes as inputs cell arrays of points and adjecency tracks
% from the simpleTracker.m algorithm in order to generate a 3D plot of
% trajectories that are color coded with respect to time.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global masterDir
allPoints = vertcat(points{:});
maxes = max(allPoints);
nTracks = size(adjacencyTracks,1);

% Import timestamp file to calculate velocities
[stamp, timeOfDay, Date, time] = textread(fullfile(masterDir, ...
    'timestamps.txt'),'%f %s %s %f');
clear timeOfDay Date stamp
time = time./1000;                              % Convert time from ms to s

ImgTimes = time(times);
ii = 1;
for i = 1 : nTracks
    index = adjacencyTracks{i,1};
    if length(index)>=10
        coords = allPoints(index,:);
        if (coords(:,1) > 10 & coords(:,1) < 350) & (coords(1,2) > 10 & coords(1,2) < 350)
            if coords(:,1) > 50 | coords(1,2) > 50
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
                % Account for flipped z (this is because of the way numerical
                % reconstructions occur and will be fixed later
                coords(:,3) = maxes(3) - coords(:,3);
                
                warning('off', 'MATLAB:xlswrite:AddSheet');
                xlswrite(fileName,coords,ii)
                ii = ii +1;
            end
        end
    end
end