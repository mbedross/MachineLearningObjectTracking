function [X] = generatePredictorMatrix(inputPredictor, sizeX)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Author: Manuel Bedrossian, Caltech
% Date Created: 2018.11.09
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
% The second input, sizeX is the output of sizePredictorMatrix.m
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

% Preallocate memory for predictor matrix
[d] = size(inputPredictor);
lengthdz   = sizeX(1);
lengthGmag = sizeX(2);
lengthGdir = sizeX(3);
lengthSNR  = sizeX(4);
lengthFFT  = sizeX(5);
Gmag_serialized = gpuArray(zeros(1, lengthGmag));
Gdir_serialized = gpuArray(zeros(1, lengthGdir));
SNR_serialized  = gpuArray(zeros(1, lengthSNR));
FFT_serialized  = gpuArray(zeros(1, lengthFFT));
Gmag_index = 0;
Gdir_index = 0;
SNR_index  = 0;
FFT_index  = 0;

% Calculate image differences in the z direction
dz = diff(inputPredictor, 1, 3);
dz_serialized = reshape(dz, [1, lengthdz]);

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
    fft = [magnitude realFFT imagFFT];
	
	% Update serialized variables
	Gmag_serialized(Gmag_index + 1 : Gmag_index + numel(Gmag)) = reshape(Gmag, [1, numel(Gmag)]);
	Gdir_serialized(Gdir_index + 1 : Gdir_index + numel(Gdir)) = reshape(Gdir, [1, numel(Gdir)]);
	SNR_serialized(SNR_index + 1 : SNR_index + numel(SNR)) = reshape(SNR, [1, numel(SNR)]);
	FFT_serialized(FFT_index + 1 : FFT_index + numel(fft)) = reshape(fft, [1, numel(fft)]);

	% Update serialized index variables
	Gmag_index = Gmag_index + numel(Gmag);
	Gdir_index = Gdir_index + numel(Gdir);
	SNR_index = SNR_index + numel(SNR);
	FFT_index = FFT_index + numel(fft);
end

% Compile the predictor matrix X
X = [dz_serialized Gmag_serialized Gdir_serialized SNR_serialized FFT_serialized];