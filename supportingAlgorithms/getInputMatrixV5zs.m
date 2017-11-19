function [ X ] = getInputMatrixV5zs( D )
%This function takes as input a 4D image stack of size
%mxnx5xt, where mxnxt is an image video sequence; therefore mxnx3xt
%represent 5 image sequences; one in the plane, one directly above the plane and one
%directly below the plane

%The purpose of this function is to generate 3D features for every pixel.
%This function can only handle features for 1 z plane at a time. 

dim1 = size(D,1);
dim2 = size(D,2);
dim4 = size(D,4);

% greyLevel = zeros(dim1,dim2,dim4);
Gmag = zeros(dim1,dim2,dim4);
stdWindow = zeros(dim1,dim2,dim4);
medianWindow = zeros(dim1,dim2,dim4);


% greyLevel_up = zeros(dim1,dim2,dim4);
Gmag_up = zeros(dim1,dim2,dim4);
%stdWindow_up = zeros(dim1,dim2,dim4);
medianWindow_up = zeros(dim1,dim2,dim4);
medianWindow_up2 = zeros(dim1,dim2,dim4);

% greyLevel_down = zeros(dim1,dim2,dim4);
Gmag_down = zeros(dim1,dim2,dim4);
%stdWindow_down = zeros(dim1,dim2,dim4);
medianWindow_down = zeros(dim1,dim2,dim4);
medianWindow_down2 = zeros(dim1,dim2,dim4);

%difference_down =zeros(dim1,dim2,dim4);
%difference_up =zeros(dim1,dim2,dim4);

%I got rid of this because it messes up datasets that have a large
%variability in its standard deviation between time frames. Instead, i
%reintroduces stdwindow. 
%std2_z_slice = zeros(dim1,dim2,dim4);

has_lowest_std2 = zeros(dim1,dim2,dim4);
is_darkest_lightest = zeros(dim1,dim2,dim4);


for t = 1:dim4
    
    [Gmag_down2(:,:,t), ~]= imgradient(D(:,:,1,t));
    [Gmag_down(:,:,t), ~]= imgradient(D(:,:,2,t));
    
    medianWindow_down2(:,:,t) = medfilt2(D(:,:,1,t));
    medianWindow_down(:,:,t) = medfilt2(D(:,:,2,t));
    
    
    [Gmag(:,:,t), ~]=imgradient(D(:,:,3,t));
    stdWindow(:,:,t)=stdfilt(D(:,:,3,t));
    medianWindow(:,:,t) = medfilt2(D(:,:,3,t));
    
    
    [Gmag_up(:,:,t), ~]=imgradient(D(:,:,4,t));
    [Gmag_up2(:,:,t), ~]=imgradient(D(:,:,5,t));
    
    medianWindow_up(:,:,t) = medfilt2(D(:,:,4,t));
    medianWindow_up2(:,:,t) = medfilt2(D(:,:,5,t));
    
    %std2_z_slice(:,:,t)= std2(D(:,:,3,t));
    
    %-------------------------------------------------
    std2_array = [std2(D(:,:,1,t)) std2(D(:,:,2,t))...
        std2(D(:,:,3,t)) std2(D(:,:,4,t))...
        std2(D(:,:,5,t))];
    
    [M,I] = min(std2_array);
    if I ==3
      has_lowest_std2(:,:,t) = 1;
    end
    %-------------------------------------------------
    
    
    
end


gradientVal = Gmag(:);
stdVal = stdWindow(:);
medianVal = abs(double(medianWindow(:))-127);


gradientVal_up = Gmag_up(:);

medianVal_up =  abs(double(medianWindow_up(:))-127);
medianVal_up2 =  abs(double(medianWindow_up2(:))-127);


gradientVal_down = Gmag_down(:);

medianVal_down =  abs(double(medianWindow_down(:))-127);
medianVal_down2 =  abs(double(medianWindow_down2(:))-127);

%ZStdVal = std2_z_slice(:);

lowest_std_val =  double(has_lowest_std2(:));
%--------------------------------------------
darkest_lightest = double(medianVal>medianVal_up)+...
    double(medianVal>medianVal_down)+...
    double(medianVal>medianVal_up2)+...
    double(medianVal>medianVal_down2);

darkest_lightest_val = darkest_lightest(:);
%--------------------------------------------


X = [ gradientVal  medianVal ... 
     gradientVal_up  medianVal_up ...
    gradientVal_down  medianVal_down ...
     stdVal lowest_std_val darkest_lightest_val];

end

