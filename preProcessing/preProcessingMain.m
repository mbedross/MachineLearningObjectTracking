function [times, zSorted] = preProcessingMain(innerRadius, outerRadius, centerX, centerY)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function takes in a reconstruction stack and pre-processes it,
% getting it ready for ML tracking.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


global n type masterDir
meanDir = fullfile(masterDir, 'MeanStack');
mkdir(meanDir);

mask = makeMask(n, innerRadius, outerRadius, centerX, centerY);

% First, look through the master directory for duplicate holograms
[dupes] = findDuplicates(masterDir);

% Now median subtract images (without duplicates)
%type = ["Amplitude", "Phase"];
for i = 1 : length(type)
    zSorted = zSteps(fullfile(masterDir, 'Stack', char(type(i))));
    NF = length(zSorted);
    for j = 1 : NF
        reconPath = fullfile(masterDir, 'Stack', char(type(i)), sprintf('%0.2f', zSorted(j)));
        timePath = dir(reconPath);
        Ntimes = length(timePath(not([timePath.isdir])));
        times = 0:Ntimes-1;
        % remove duplicate from times
        times(ismember(times, dupes)) = [];
        % Ntimes is the number of times in the reconstruction slice
        I = zeros(n(1), n(2), length(times));
        for t = 1 : length(times)-1
            I(:, :, t) = imread(fullfile(reconPath, sprintf('%05d.tiff', times(t+1))));
        end
        I_mean = meanSubtraction(I);
        dataDir = fullfile(meanDir, char(type(i)), sprintf('%0.2f', zSorted(j)));
        mkdir(dataDir);
        % Now save the mean subtracted images
        for k = 1 : size(I_mean, 3)
            I_temp = freqFilter(I_mean(:,:,k).*255, mask, centerX, centerY, n);
            I_mean(:,:,k) = I_temp;
            imwrite(I_mean(:,:,k), fullfile(dataDir, sprintf('%05d.tiff', times(k))))
        end
    end
end
% Save metaData before ending function
save(fullfile(meanDir, 'metaData.mat'), 'times', 'zSorted')