function n = getImageSize(time)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function gets the image size of the reconstructions used (x,y
% values)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global masterDir

reconPath = fullfile(masterDir, 'Holograms');
I = imread(fullfile(reconPath, sprintf('%05d_holo.tif', time)));
[N, M] = size(I);

if N ~= M
    error('Reconstructed images are not square (N doesnt equal M). preProcessing might produce an error')
end

n = [N, M];