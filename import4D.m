function [I] = import4D(dataDir, zSorted)

% Define the range in z-steps to use in training (this is because using the
% entire z-stack will be too RAM heavy)
zNF = length(zSorted);

% Find how many time sequences exist
filePath = dir(fullfile(dataDir, char(type), sprintf('%0.2f', zSorted(1))));
tNF = length(filePath(not([filePath.isdir]))) - 2;  % number of time sequeces

% Begin loading images into dTrain
I = zeros(n, n, zNF, tNF);
% to avoid constantly changing working directories, dTrain will be
% populated by z first (e.g. all times for z = zLow will be imported than z
% = zLow+zStep, on and on)
for i = 1: zNF
    reconPath = fullfile(dataDir, char(type), sprintf('%0.2f', zSorted(i)));
    for t = 1 : length(times)
        I(:, :, i, t) = imread(fullfile(reconPath, sprintf('%05d.tiff', times(t))));
    end
end