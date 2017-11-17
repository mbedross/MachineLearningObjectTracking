function [I] = freqFilter(Img, mask, centerx, centery, N)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Author: Manuel Bedrossian
% Date Created: 2017.08.18
% Date Last Modified: 2017.08.17
%
% This function takes an image input and conducts frequency filtering using
% a annulus mask with inner radius (innerRadius) and outer radius
% (outerRadius)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


Y = fftshift(fft2(Img));
Fh = Y.*mask;
fftshifted = imtranslate(Fh,[(N/2)-centerx, (N/2)-centery],'FillValues',0+0*1i);
Inew = ifft2(ifftshift(fftshifted));
I = abs(Inew);
