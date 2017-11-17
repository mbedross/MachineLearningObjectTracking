function preProcessing(masterDir)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function takes in a reconstruction stack and pre-processes it,
% getting it ready for ML tracking.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

n = 2048;
meanDir = fullfile(masterDir, 'MeanStack');
mkdir(meanDir);

innerRadius = 15;
outerRadius = 300;
centerX = n/2;
centerY = n/2;
mask = makeMask(n, innerRadius, outerRadius, centerX, centerY);

% First, look through the master directory for duplicate holograms
[dupes] = findDuplicates(masterDir);

% Now median subtract images (without duplicates)
type = ["Amplitude", "Phase"];
for i = 1 : length(type)
    zSorted = zSteps(fullfile(masterDir, 'Stack', char(type(i))));
    NF = length(zSorted);
    %filePath = dir(fullfile(masterDir, 'Stack', char(type(i))));
    %NF = length(filePath([filePath.isdir])) - 2;  % number of z-steps
    for j = 1 : NF
        reconPath = fullfile(masterDir, 'Stack', char(type(i)), sprintf('%0.2f', zSorted(j)));
        timePath = dir(reconPath);
        Ntimes = length(timePath(not([timePath.isdir])));
        times = 0:Ntimes-1;
        % remove duplicate from times
        times(ismember(times, dupes)) = [];
        % Ntimes is the number of times in the reconstruction slice
        I = zeros(n, n, length(times));
        for t = 1 : length(times)
            I(:, :, t) = imread(fullfile(reconPath, sprintf('%05d.tiff', times(t))));
            %I_temp = freqFilter(I(:,:,t), mask, centerX, centerY, n);
            %I(:,:,t) = I_temp;
        end
        I_mean = meanSubtraction(I);
        dataDir = fullfile(meanDir, char(type(i)), sprintf('%0.2f', zSorted(j)));
        mkdir(dataDir);
        % Now save the mean subtracted images
        for k = 1 : size(I_mean, 3)
            imwrite(I_mean(:,:,k), fullfile(dataDir, sprintf('%05d.tiff', times(k))))
        end
    end
end