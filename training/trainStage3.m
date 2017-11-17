function trainStage3()

% The parameters zVal and tVal represent the z-slice and timestep values
% respectively of the image we would like to obtain more training pixels
% from.
zVal = 84;
tVal = 1;

[newCoords] = getBugMoreBugCoords(dTrainC, zVal, 1, tVal);

