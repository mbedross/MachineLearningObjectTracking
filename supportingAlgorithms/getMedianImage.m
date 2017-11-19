function [ medianImage ] = getMedianImage( timeStack )
% This function takes as input a 2D video of format [x y t] and returns the
% medianImage of the video (the background). 

%The function uses 'numFrames' random time steps to find the median value of every
%pixel. 
dim1 = size(timeStack,1);
dim2 = size(timeStack,2);
dim3 = size(timeStack,3);

numFrames = dim3;
medianImage = uint8(zeros(dim1,dim2));
for i = 1:dim1
    for j = 1:dim2
        
        pixelGrayLevel = zeros(1,numFrames);
        for k = 1:numFrames
            %t = int16(k.*tSize./(numFrames +1));
            %pixelGrayLevel = [pixelGrayLevel timeStack(i,j,t)];
            pixelGrayLevel(k) = timeStack(i,j,k);
           %pixelGrayLevel = [pixelGrayLevel timeStack(i,j,k)];
            
        end
        %pixelGrayLevel = pixelGrayLevel(2:size(pixelGrayLevel,2));
        medianImage(i,j) = uint8(median(pixelGrayLevel));
    end
end

end