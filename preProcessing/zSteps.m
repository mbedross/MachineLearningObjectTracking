function [zSorted] = zSteps(filePath)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function reads a directory that contains z-step reconstructions and
% organizes them in numerically increasing order
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fileDir = dir(filePath);
NF = length(fileDir([fileDir.isdir]));  % number of subfolders in filePath
z = zeros(1, NF);
for i = 1 : NF
    z(i) = str2double(fileDir(i).name);
end
zSorted = sort(z);
% Remove all './' and '../ that show up as NaN in zSorted
zSorted(isnan(zSorted)) = [];

