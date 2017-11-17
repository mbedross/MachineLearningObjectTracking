function [dupes] = findDuplicates(masterDir)

% tRange = [tStart, tStop]

%holoDir = dir(fullfile(masterDir,'Holograms'));
%NF = length(holoDir(not([holoDir.isdir])));  % number of holograms
NF = tRange(2) - tRange(1);

%dupes = zeros(1, NF);

for k = 1 : NF
    I1 = imread(fullfile(masterDir, 'Holograms', sprintf('%05d_holo.tif', k-1)));
    I2 = imread(fullfile(masterDir, 'Holograms', sprintf('%05d_holo.tif', k)));
    diff = I1-I2;
    if range(diff)==0
        dupes = [dupes; k];
    end
end