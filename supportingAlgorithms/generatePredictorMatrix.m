function [X] = generatePredictorMatrix(inputPredictor)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Author: Manuel Bedrossian, Caltech
% Date Created: 2018.10.10
%
% This function takes in as an input, a series of images that it is to
% condition and format in order to be accepted by downstream ML functions
%
% This function expects inputPredictor to be an n by m by p matrix where
% n and m are the size of the separate images and p is the number of images.
% 
% p is expected to be an odd number where there is a center 'z' slice and 
% (p-1)/2 z slices on either side of it.
%
% The image characteristics that are considered when generating the
% predictor matrix X are as follows:
% 1. Image gradients
% 1a. Image gradient
% 1b. Image gradient direction
% 1c. Image gradient of xz slice
% 1d. Image gradient direction of xz slice
% 2. SNR map
% 3. Fourier Transform
% 3a. FFT magnitude
% 3b. Real part of the FFT
% 3c. Imaginary part of the FFT
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[d] = size(inputPredictor);

% Calculate image differences in the z direction
dz = diff(inputPredictor, 1, 3);
dz_serialized = reshape(dz, [1, numel(dz)]);

% Preallocate memory for predictor matrix
lengthdz = numel(dz);
lengthGmag = d(1)*d(2)*d(3);
lengthGdir = lengthGmag;
lengthSNR = lengthGmag;
lengthFFT = 3*lengthGmag; % x3 because of magnitude, real, and imaginary parts
lengthX = lengthdz + lengthGmag + lengthGdir + lengthSNR + lengthFFT;

Gmag_serialized = zeros(1, lengthGmag);
Gdir_serialized = zeros(1, lengthGdir);
SNR_serialized = zeros(1, lengthSNR);
FFT_serialized = zeros(1, lengthFFT);
Gmag_index = 0;
Gidr_index = 0;
SNR_index = 0;
FFT_index = 0;
X = zeros(1, lengthX);

% Loop through the inputPredictor matrix and calculate characteristics to use in X
for i = 1 : d(3)
	Img = inputPredictor(:,:,i);

	% Calculate image gradient
	[Gmag, Gdir] = imgradient(Img);
	Gmag = Gmag./8; % Normalization factor for Sobel Gradient Operator

	% Calculate SNR
	SNR = Img./std2(Img);

	% Calculate the Fourier Transform
	FFT = fft2(Img);
	magnitude = abs(FFT);
	realFFT = real(FFT);
	imagFFT = imag(FFT);
	
	% Update serialized variables
	Gmag_serialized(Gmag_index + 1, Gmag_index + numel(Gmag)) = reshape(Gmag, [1, numel(Gmag)]);
	Gdir_serialized(Gdir_index + 1, Gdir_index + numel(Gdir)) = reshape(Gdir, [1, numel(Gdirr)]);
	SNR_serialized(SNR_index + 1, SNR_index + numel(SNR)) = reshape(SNR, [1, numel(SNR)]);
	FFT_serialized(FFT_index + 1, FFT_index + numel(FFT)) = reshape(FFT, [1, numel(FFT)]);

	% Update serialized index variables
	Gmag_index = Gmag_index + numel(Gmag);
	Gdir_index = Gdir_index + numel(Gdir);
	SNR_index = SNR_index + numel(SNR);
	FFT_index = FFT_index + numel(FFT);
end

% Compile the predictor matrix X
X = [Gmag_serialized Gdir_serialized SNR_serialized FFT_serialized];