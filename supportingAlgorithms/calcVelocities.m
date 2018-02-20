function [velTracks, Speed, A] = calcVelocities(points, adjacencyTracks, times)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function, takes as inputs cell arrays of points and adjecency tracks
% from the simpleTracker.m algorithm in order to generate a 3D plot of
% trajectories that are color coded with respect to time.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global masterDir minTrackSize
allPoints = vertcat(points{:});

nTracks = size(adjacencyTracks,1);

% Import timestamp file to calculate velocities
[stamp, timeOfDay, Date, time] = textread(fullfile(masterDir, ...
    'timestamps.txt'),'%f %s %s %f');
clear timeOfDay Date stamp
time = time./1000;                              % Convert time from ms to s

if times(1) == 0
    times(1) = [];
end

ImgTimes = time(times);
ii = 1;
for i = 1 : nTracks
    index = adjacencyTracks{i,1};
    if length(index) >= minTrackSize
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
        diffx = diff(coords(:,1));
        diffy = diff(coords(:,2));
        diffz = diff(coords(:,3));
        difft = diff(coords(:,4));
        vX = diffx./difft;
        vY = diffy./difft;
        vZ = diffz./difft;
        speed = sqrt(vX.^2+vY.^2+vZ.^2);
        velTracks{ii} = [vX vY vZ speed];
        Speed{ii} = speed;
        ii = ii+1;
    end
end

A = zeros(0,1);
for i = 1: length(Speed)
    A = [A Speed{i}'];
end

histogram(A)
