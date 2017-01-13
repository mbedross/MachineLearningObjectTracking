%This script will perform median subtraction on a bunch of images, and then
%save the updated, noise removed images in a new folder.
%This script will also ignore identical consecutive images. 
clearvars
%-----------------------------
z_dataset_start = 70;
z_dataset_end = 170;
t_dataset_start = 1;
t_dataset_end = 195;
%-----------------------------
imgScaleFactor = 0.25;
numFrames = 9;
contrastFactor = 3;
%-----------------------------

%array replicated is the time-frames that contain duplicated images.
replicated = find_replica_imgs(t_dataset_start,t_dataset_end,z_dataset_start);

%The loop below will save all the images in the dataset to the current
%directory with background noise, and duplicated images, removed. 
for z = z_dataset_start:1:z_dataset_end
    for t = t_dataset_start:t_dataset_end
        if any(t==replicated)
            %Do Nothing Because image is a copy of the previous one
        else
            [imgA,imgB,imName] = returnMedianImgAndImg(z,t,t_dataset_end,numFrames, imgScaleFactor);
            X(:,:) = uint8((int16(imgA) - int16(imgB)).*contrastFactor+127);
            folderName = strtok(imName);
            mkdir(folderName);
            imwrite(X,strcat(folderName,'/',imName))
            
        end
    end
    percent_complete = (z - z_dataset_start)*100/(z_dataset_end - z_dataset_start)
end