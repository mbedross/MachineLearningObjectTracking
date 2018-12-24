function [props] = boundaryDetection(I)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Author: Manuel Bedrossian, Caltech
% Date Created: 2018.11.13
%
% This function takes in as an image the reconstruction at a single z-plane
% of holographic data reconstructed in either amplitude, phase, or any other
% type of reconstruction.
%
% With the input image it calculates the STD map of the image with 5 pixel neighborhoods
% and uses this to look for particles as a very low level filter for the ML code.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pixelNeighborhood = 5;    %Pixel pixelNeighborhood to calculate stdfilt with
outlierMultiple = 3;   % The number of std's to consider as an outlier
pixelNeighborhood_blurring = 5;
outlierMultiple_blurring = 2;

I_std = stdfilt(I, true(pixelNeighborhood)); % This calculates the local standard deviation of the image with 4x4 pixel neighborhoods
I_stdMean = mean(I_std(:));
I_stdSTD = std(I_std(:));
I_std(I_std<(I_stdMean+outlierMultiple*I_stdSTD)) = 0; % Make all non outliers equal to 0
I_blurred = imgaussfilt(I_std, pixelNeighborhood_blurring);
I_blurredMean = mean(I_blurred);
I_blurredSTD = std(I_blurred);
I_blurred(I_blurred<(I_blurredMean+outlierMultiple_blurring*I_blurredSTD)) = 0; % Make all non outliers equal to 0
I_binary = logical(I_blurred);
props = regionprops(I_binary, I_blurred, 'WeightedCentroid', 'MajorAxisLength','MinorAxisLength');