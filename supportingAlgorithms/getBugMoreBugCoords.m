function [ newCoords ] = getBugMoreBugCoords( DtrainC,z,t,tVal  )
%This function takes as imput a segmented image 'Dtrain', at z slice 'z', 
%and time step 't. It then returns the all the coordinates of one cluster
%within the image and returns the matrix 'newCoords' of size Nx3 where N 
%is the total number of new points. 
%-------------------------------------------------------------------------


%------------------------------------------------------------------
%DtrainC = addEdges(DtrainC,0.03);
dim1 = size(DtrainC,2);
dim2 = size(DtrainC,1);
imshow(DtrainC(:,:,z,t))
[x, y] = getpts;
cc=bwconncomp(DtrainC(:,:,z,t));
pil = cc.PixelIdxList;
point = dim2.*(uint32(x)-1)+uint32(y);
%index = 0;
% for i = 1:size(pil,2)
%     if size(find(pil{i}==point),1)>0
%         index = i;
%     end
% end
[c, index] = min(abs(uint32(pil{3})-point));
cluster = pil{index};
newCoords = zeros(0,4);
for j = 1:size(cluster,1)
    num = int32(cluster(j));
    y = uint16(rem(num,dim2));
    x = uint16(idivide(num,dim2,'floor'))+1;
    newCoords = [newCoords;x y z tVal];
end
xplot = newCoords(:,1);
yplot = newCoords(:,2);
imshow(DtrainC(:,:,z,t))
hold on
scatter(xplot,yplot,1,'.')
end
% %-------------------------------------------------