function [props] = boundaryDetection(I)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

I_std = stdfilt(I); % This calculates the local standard deviation of the image with 4x4 pixel neighborhoods
I_stdMean = mean(I_std(:));
I_stdSTD = std(I_std(:));
I_std(I_std<(I_stdMean+3*I_stdSTD)) = 0; % Make all non outliers equal to 0
I_blurred = imgaussfilt(I_std, 8);
I_blurredMean = mean(I_blurred);
I_blurredSTD = std(I_blurred);
I_blurred(I_blurred<(I_blurredMean+2*I_blurredSTD)) = 0; % Make all non outliers equal to 0
I_binary = logical(I_blurred);
props = regionprops(I_binary, I_blurred, 'WeightedCentroid', 'MajorAxisLength','MinorAxisLength');

% TO DO: Incorporate this algorithm in detection.m such that it looks at
% centroids of the regions it finds, and creates maps within the region. It
% then uses these maps within each region to cylce through and analyze in
% the detection.m code