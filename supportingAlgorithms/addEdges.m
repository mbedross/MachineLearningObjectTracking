function [ Dout ] = addEdges( D,cropSize )

dim1 = size(D,1);
dim2 = size(D,2);
dim3 = size(D,3);
dim4 = size(D,4);

o_size1 = dim1+2.*cropSize-1;
o_size2 = dim2+2.*cropSize-1;
i = cropSize;
j = cropSize;

%Now we must check if D is binary or not by using sum(sum(D>1))==0 if D is
%binary then the sum will = 0, else it is not binary. 
if sum(sum(D(:)>1))==0
    Dout = zeros(o_size1,o_size2,dim3,dim4);
else
    Dout = uint8(127.*ones(o_size1,o_size2,dim3,dim4));
end
Dout(i:o_size1-i,j:o_size2-j,:,:) = D(:,:,:,:);