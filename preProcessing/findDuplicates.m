function [dupes] = findDuplicates(masterDir)

holoDir = dir(fullfile(masterDir,'Holograms'));
NF = length(holoDir(not([holoDir.isdir])));  % number of holograms

dupes = zeros(NF,1);
for k = 1 : NF-1
    I1 = imread(fullfile(masterDir, 'Holograms', sprintf('%05d_holo.tif', k-1)));
    I2 = imread(fullfile(masterDir, 'Holograms', sprintf('%05d_holo.tif', k)));
    diff = I1-I2;
    if range(diff)==0
        dupes(k) = 1;
    end
end