function [bugCoords] = getBugCoords(Dtrain, t)
%bugCoords returns a matrix of size N x 4 where each row of the matrix
%represents the (x, y, z, t) coordinates of pixels that the user labelled as
%bugs.

%initialize variable tempBugCoords
tempBugCoords = [0 0 0 0];
%The following nested loops captures the input from the user and stores it
%in x and y matrix arrays.
x1 = 0;
y1 = x1;
xSize = size(Dtrain,1);
ySize = size(Dtrain,2);

for i = 1:size(Dtrain,3)
    Dcrop = imcrop(Dtrain(:,:,i),[x1 y1 xSize ySize]);
    h1 = figure(1);
    imagesc(Dcrop)
    axis equal
    axis([0 size(Dcrop,1) 0 size(Dcrop,2)])
    colormap gray
    title('Select all in focus particles. Press ENTER to show next z-plane')
    [xi, yi] = (getpts);
    x = x1 + xi;
    y = y1 +yi;
    for u = 1:size(x,1)
        tempBugCoords = [tempBugCoords; x(u) y(u) i t];
    end
end

bugCoords = uint16(tempBugCoords(2:size(tempBugCoords,1),:));

close(h1)

