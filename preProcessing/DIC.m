function DIC(masterDir)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function cycles through preprocessed phase
% reconstructions and performs differential interference contrast (DIC).
%
% This is done by taking the derivative of the phase image along a single
% direction (x by default).
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

poolobj = parpool;

zSorted = zSteps(fullfile(masterDir, 'MeanStack', 'Amplitude'));
NFz = length(zSorted);

meanDir = fullfile(masterDir, 'MeanStack','DIC');
mkdir(meanDir);

% First, look through the master directory for duplicate holograms
[dupes] = findDuplicates(masterDir);
times = 0:length(dupes)-1;
% remove duplicate from times
times(logical(dupes)) = [];

for z = 1 : NFz
    phasePath = fullfile(masterDir, 'MeanStack', 'Phase', sprintf('%0.2f', zSorted(z)));
    dataDir = fullfile(meanDir, sprintf('%0.2f', zSorted(z)));
    mkdir(dataDir);
    parfor t = 1 : length(times)
        I_phase = gpuArray(imread(fullfile(phasePath, sprintf('%05d.tiff', times(t)))));
        I_phase = im2double(I_phase);
        dic = diff(I_phase,1,2);
        
        % Normalize Images
        dic = (dic-min(dic(:)))./(max(dic(:))-min(dic(:)));
        dic = dic+(0.5-mean(dic(:)));
        dic(dic<0) = 0;
        dic(dic>1) = 1;
        
        I = gather(dic);
        imwrite(I, fullfile(dataDir, sprintf('%05d.tiff', times(t))))
    end
end

delete(poolobj)