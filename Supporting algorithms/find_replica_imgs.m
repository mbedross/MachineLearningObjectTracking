%This function will find duplicate images and return their locations.
function [replica_t] = find_replica_imgs( t_dataset_start,t_dataset_end,z )

%----------------------------
imgScaleFactor = 0.5;
contrastFactor = 1;
numFrames = 0;
%------------------------------


replica_t = zeros(0,t_dataset_end);


t = t_dataset_start;
[imgA,imgB,imName] = returnMedianImgAndImg(z,t,t_dataset_end,numFrames, imgScaleFactor);
prev_img = uint8((int16(imgA) - int16(imgB)).*contrastFactor+127);

for t = t_dataset_start+1:t_dataset_end
    
    [imgA,imgB,imName] = returnMedianImgAndImg(z,t,t_dataset_end,numFrames, imgScaleFactor);
    curr_img = uint8((int16(imgA) - int16(imgB)).*contrastFactor+127);
    diff = int16(prev_img(:)) - int16(curr_img(:));
    
    if any(diff(:)) ==0
        replica_t = [replica_t t];
    end
    prev_img = curr_img;
end
