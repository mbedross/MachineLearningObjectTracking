function [times, zSorted] = preProcessingMain(innerRadius, outerRadius, centerX, centerY, GPU)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function takes in a reconstruction stack and pre-processes it,
% getting it ready for ML tracking.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic
% Turn duplicate directory warning off
%w = warning('query','last');
%id = w.identifier;
%warning('off',id)

global n type masterDir batchSize
N = n;
bSize = batchSize;
meanDir = fullfile(masterDir, 'MeanStack');
mkdir(meanDir);

switch GPU
    case 'Yes'
        mask = makeMaskGPU(N, innerRadius, outerRadius, centerX, centerY);
    case 'No'
        mask = makeMask(N, innerRadius, outerRadius, centerX, centerY);
end

% First, look through the master directory for duplicate holograms
[dupes] = findDuplicates(masterDir);

% Now median subtract images (without duplicates)
%type = ["Amplitude", "Phase"];
for i = 1 : length(type)
    zSorted = zSteps(fullfile(masterDir, 'Stack', char(type(i))));
    NF = length(zSorted);
    for j = 1 : NF
        reconPath = fullfile(masterDir, 'Stack', char(type(i)), sprintf('%0.2f', zSorted(j)));
        % timePath = dir(reconPath);
        % Ntimes = length(timePath(not([timePath.isdir])));
        % Ntimes is the number of times in the reconstruction slice
        times = 0:length(dupes)-1;
        % remove duplicate from times
        times(logical(dupes)) = [];
        % Calculate the number of batches to be processed
        batches = floor(length(times)/(bSize));
        switch GPU
            case 'Yes'
                if batches==0
                    I = gpuArray(zeros(N(1), N(2), length(times)));
                else
                    I = gpuArray(zeros(N(1), N(2), bSize));
                end
            case 'No'
                if batches==0
                    I = zeros(N(1), N(2), length(times));
                else
                    I = zeros(N(1), N(2), bSize);
                end  
        end
        for k = 0 : batches - 1
            parfor ii = 1 : bSize
                I(:, :, ii) = imread(fullfile(reconPath, sprintf('%05d.tiff', times(k*bSize+ii))));
            end
            I_mean = meanSubtraction(I);
            dataDir = fullfile(meanDir, char(type(i)), sprintf('%0.2f', zSorted(j)));
            mkdir(dataDir);
            % Now save the mean subtracted images
            switch GPU
                case 'Yes'
                    parfor kk = 1 : size(I_mean, 3)
                        I_temp = freqFilterGPU(I_mean(:,:,kk).*255, mask, centerX, centerY, N);
                        I_temp = gather(I_temp);
                        imwrite(I_temp, fullfile(dataDir, sprintf('%05d.tiff', times(k*bSize+kk))))
                    end
                case 'No'
                    parfor kk = 1 : size(I_mean, 3)
                        I_temp = freqFilter(I_mean(:,:,kk).*255, mask, centerX, centerY, N);
                        I_mean(:,:,kk) = I_temp;
                        imwrite(I_mean(:,:,kk), fullfile(dataDir, sprintf('%05d.tiff', times(k*bSize+kk))))
                    end
            end
        end
        
        % Process remaining files
        switch GPU
            case 'Yes'
                I = gpuArray(zeros(N(1), N(2), length(times)-batches*bSize));
            case 'No'
                I = zeros(N(1), N(2), length(times)-batches*bSize);
        end
        parfor jj = 1 : (length(times)-batches*bSize)
            I(:, :, jj) = imread(fullfile(reconPath, sprintf('%05d.tiff', times(batches*bSize+jj))));
        end
        I_mean = meanSubtraction(I);
        dataDir = fullfile(meanDir, char(type(i)), sprintf('%0.2f', zSorted(j)));
        mkdir(dataDir);
        % Now save the mean subtracted images
        switch GPU
            case 'Yes'
                parfor kk = 1 : size(I,3)
                    I_temp = freqFilterGPU(I_mean(:,:,kk).*255, mask, centerX, centerY, N);
                    I_temp = gather(I_temp);
                    imwrite(I_temp, fullfile(dataDir, sprintf('%05d.tiff', times(batches*bSize+kk))))
                end
            case 'No'
                parfor kk = 1 : size(I,3)
                    I_temp = freqFilter(I_mean(:,:,kk).*255, mask, centerX, centerY, N);
                    I_mean(:,:,kk) = I_temp;
                    imwrite(I_mean(:,:,kk), fullfile(dataDir, sprintf('%05d.tiff', times(batches*bSize+kk))))
                end
        end
    end
end
% Save metaData before ending function
save(fullfile(meanDir, 'metaData.mat'), 'times', 'zSorted')
toc