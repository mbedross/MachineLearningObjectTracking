function n = getImageSize(time)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function gets the image size of the reconstructions used (x,y
% values)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global type masterDir

reconPath = fullfile(masterDir, 'MeanStack', char(type(1)), sprintf('%0.2f', zSorted(1)));
I = imread(fullfile(reconPath, sprintf('%05d.tiff', time)));
[N, M] = size(I);

if N ~= M
    error('Reconstructed images are not square (N doesnt equal M). preProcessing might produce an error')
end

n = [N, M];