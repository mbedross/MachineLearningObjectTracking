function [pointsOUT] = formatPoints(pointsIN)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function takes as an input the resulting cell array from the
% particle identification algorithm and reformats them to be accepted by 
% the tracking algorithm (simpleTracker).
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

M = size(pointsIN, 2);

for i = M : -1 : 2
    pointsIN{1,i}(1:length(pointsIN{1,i-1}),:)=[];
end

pointsOUT = pointsIN;