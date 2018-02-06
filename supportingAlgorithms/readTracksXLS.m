function [tracks] = readTracksXLS(fileName)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function reads an excel spread sheet created from 'saveTracksXLS'
% and returns a cell array where each cell contains (x,y,z,t) information
% about a particular particle.
%
% Each cell contains an (n by 4) matrix where each column represents x, y,
% z, and t data (in that order)
%
% x, y, z values are in microns
% t values are in seconds
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

S = importdata(fileName);
numParticles = numel(fieldnames(S));

clear S
for i = 1 : numParticles
    temp_tracks{i} = xlsread(fileName, i);
end

tracks = temp_tracks;