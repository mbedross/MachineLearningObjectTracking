function preProcessing(masterDir)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function takes in a reconstruction stack and pre-processes it,
% getting it ready for ML tracking.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

n = 2048;
meanDir = fullfile(masterDir, 'MeanStack');
mkdir meanDir

% First, look through the master directory for duplicate holograms
[dupes] = findDuplicates(masterDir);

% Now median subtract images (without duplicates)
type = ['Amplitude', 'Phase'];
for i = 1 : length(type)
    filePath = dir(fullfile(masterDir, 'Stack', type(i)));
    NF = length(filePath([filePath.isdir]));  % number of z-steps
    for j = 1 : NF
        reconPath = fullfile(masterDir, 'Stack', type(i), filePath(j+2).name);
        % j + 2 is used for ../ and ./
        timePath = dir(reconPath);
        Ntimes = length(timePath(not([timePath.isdir])));
        times = linspace(1, Ntimes);
        % remove duplicate from times
        times(ismember(times, dupes)) = [];
        % Ntimes is the number of times in the reconstruction slice
        I = zeros(n, n, length(times));
        for t = 1 : length(times)
            I(:, :, t) = imread(fullfile(reconPath, sprintf('%05d.tiff', times(t))));
        end
        I_mean = meanSubtraction(I);
        dataDir = fullfile(meanDir, type(i), filePath(j+2).name);
        mkdir dataDir
        % Now save the mean subtracted images
        for k = 1 : size(I_mean, 3)
            imwrite(I_mean(:,:,k), fullfile(dataDir, '%05d.tiff'))
        end
    end
end