function [index] = getDSindex(zDesired, tDesired)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Author: Manuel Bedrossian, Caltech
% Date Created: 2018.11.09
%
% This function takes in as input information on the image datastore (zNF 
% and tNF) which are the number of z-slices and time points in the datastore,
% respectively. As input, the funtion also expects a desired z-slice and 
% desired time point.
%
% zDesired is the index of the particular z slice that you want (e.g. the
% desired z slice is the 34th in the stack zSorted(34), then zDesired would
% be 34)
%
% tDesired is the index of the particular time point you want
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global tNF
global zNF

zDesired = zDesired-1;
totalIndex = zNF*tNF;
index = zDesired*tNF + tDesired;

if index > totalIndex
	error('The desired time point and/or z-slice is out of bounds with the image datastore')
end