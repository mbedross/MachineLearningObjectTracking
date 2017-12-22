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

x = class(Img);

Y = fft2(Img);
Y = fftshift(Y);
Fh = Y.*mask;
fftshifted = imtranslate(Fh,[(N(1)/2)-centerx, (N(2)/2)-centery],'FillValues',0+0*1i);
Inew = ifftshift(fftshifted);
Inew = ifft2(Inew);
I = real(Inew);
I = (I-min(I(:)))./(max(I(:))-min(I(:)));

% Normalize image to prevent flaring
switch x
    case 'double'
        I = I+(0.5-mean(I(:)));
        I(I<0) = 0;
        I(I>1) = 1;
    case 'uint8'
        I(:,:,t) = I+(127-mean(I(:)));
        I(I<0) = 0;
        I(I>255) = 255;
end
