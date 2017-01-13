function [ Dn ] = normalizeGrayscale_127( D )
%normalizeGrayscaleValue Normalize the 2D images to all have a median value of 127

dim3=size(D,3);
dim4 = size(D,4);

for i = 1:dim4
    for j = 1:dim3
        slice = D(:,:,j,i);
        diff = 127 - double(median(slice(:)));
        Dn(:,:,j,i)= uint8(slice + diff);
                
    end 
end


end

