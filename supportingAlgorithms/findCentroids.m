function [ points ] = findCentroids( D )

dim4 = size(D,4);


    
    cc = bwconncomp(D(:,:,:));
    s = regionprops(cc);
    totalObjects = size(s,1);
    initMatrix = [ 0 0 0];
    for j = 1:totalObjects
        initMatrix = [initMatrix; s(j).Centroid];
       
    end
    points = initMatrix(2:size(initMatrix,1),:);
    



end