function [dupes] = findDuplicates(masterDir)

holoDir = dir(fullfile(masterDir,'Holograms'));
NF = length(holoDir(not([holoDir.isdir])));  % number of holograms

dupes = zeros(NF,1);
parfor k = 1 : NF-1
    I1 = gpuArray(imread(fullfile(masterDir, 'Holograms', sprintf('%05d_holo.tif', k-1))));
    I2 = gpuArray(imread(fullfile(masterDir, 'Holograms', sprintf('%05d_holo.tif', k))));
    diff = I1-I2;
    if range(gather(diff))==0
        dupes(k) = 1;
    end
end