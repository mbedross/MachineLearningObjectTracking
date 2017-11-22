function [bugCoords] = getBugCoords3( Dtrain, t, sections )
%bugCoords returns a matrix of size N x 4 where each row of the matrix
%represents the (x, y, z, t) coordinates of pixels that the user labelled as
%bugs.
dim1 = size(Dtrain,1);
dim2 = size(Dtrain,2);
dim3 = size(Dtrain,3);

%initialize variable tempBugCoords
tempBugCoords = [0 0 0 0];
%The following nested loops captures the input from the user and stores it
%in x and y matrix arrays.

for j = 1:sections
    for k = 1:sections
        for i = 1:dim3
            x1 = (k-1).*(dim1./sections)+1;
            y1 = (j-1).*(dim2./sections)+1;
            xSize = dim1./sections;
            ySize = dim2./sections;
            
            Dcrop = imcrop(Dtrain(:,:,i),[x1 y1 xSize ySize]);
            
            imshow(Dcrop);

            [xi, yi] = (getpts);
            x = x1 + xi;
            y = y1 +yi;
            
            for u = 1:size(x,1)
                tempBugCoords = [tempBugCoords; x(u) y(u) i t];
            end
            
        end
    end
end
bugCoords = uint16(tempBugCoords(2:size(tempBugCoords,1),:));
end

