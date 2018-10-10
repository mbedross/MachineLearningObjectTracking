function [times, zSorted] = preProcessing(innerRadius, outerRadius, centerX, centerY, GPU)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function takes in a reconstruction stack and pre-processes it,
% getting it ready for ML tracking.
%
% This function is almost identical to preProcessingGPU.m except that this
% is meant to run without any GPU utilization.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic

global n type masterDir batchSize
N = n;
bSize = batchSize;
meanDir = fullfile(masterDir, 'MeanStack');
mkdir(meanDir);

% Generate Fourier Mask for band-pass filtering
mask = makeMask(N, innerRadius, outerRadius, centerX, centerY);

% First, look through the master directory for duplicate holograms
[dupes] = findDuplicates(masterDir);
times = 0:length(dupes)-1;
% remove duplicate from times
times(logical(dupes)) = [];

% Now median subtract images (without duplicates)
%type = ["Amplitude", "Phase"];
for i = 1 : length(type)
    zSorted = zSteps(fullfile(masterDir, 'Stack', char(type(i))));
    NF = length(zSorted);
    for j = 1 : NF
        reconPath = fullfile(masterDir, 'Stack', char(type(i)), sprintf('%0.2f', zSorted(j)));
        dataDir = fullfile(meanDir, char(type(i)), sprintf('%0.2f', zSorted(j)));
        mkdir(dataDir);
        % Calculate the number of batches to be processed
        batches = floor(length(times)/(bSize));
        if batches==0
            I = zeros(N(1), N(2), length(times));
        else
            I = zeros(N(1), N(2), bSize);
        end
        for k = 0 : batches - 1
            parfor ii = 1 : bSize
                I(:, :, ii) = imread(fullfile(reconPath, sprintf('%05d.tiff', times(k*bSize+ii))));
            end
            I_mean = meanSubtraction(I);
            
            % Now save the mean subtracted images
            parfor kk = 1 : size(I_mean, 3)
                I_temp = freqFilter(I_mean(:,:,kk).*255, mask, centerX, centerY, N);
                I_mean(:,:,kk) = I_temp;
                imwrite(I_mean(:,:,kk), fullfile(dataDir, sprintf('%05d.tiff', times(k*bSize+kk))))
            end
        end
        
        % Process remaining files
        I = zeros(N(1), N(2), length(times)-batches*bSize);
        parfor jj = 1 : (length(times)-batches*bSize)
            I(:, :, jj) = imread(fullfile(reconPath, sprintf('%05d.tiff', times(batches*bSize+jj))));
        end
        I_mean = meanSubtraction(I);
        % Now save the mean subtracted images
        parfor kk = 1 : size(I,3)
            I_temp = freqFilter(I_mean(:,:,kk).*255, mask, centerX, centerY, N);
            I_mean(:,:,kk) = I_temp;
            imwrite(I_mean(:,:,kk), fullfile(dataDir, sprintf('%05d.tiff', times(batches*bSize+kk))))
        end
    end
end

% Save metaData before ending function
save(fullfile(meanDir, 'metaData.mat'), 'times', 'zSorted')
toc