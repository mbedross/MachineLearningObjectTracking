function [X] = createFeatureMatrix(inputSlice, CSVname)

global masterDir

% dir2save = fullfile(masterDir, 'Xcsv');
% if exists(dir2save, 'file') == 7
% else
%     mkdir(dir2save);
% end

X = getInputMatrixV5zs(inputSlice);
% filename = fullfile(dir2save, CSVname);
% if exist(filename, 'file') == 2
%     message = sprintf('File %s already exists. Overwrite? [Y/N]: ', CSVname);
%     answer = input(message,'s');
%     if answer == 'Y' || answer == 'y'
%         mex_WriteMatrix(filename,X,'%0.5f',',','w+');
%     end
% else
%     mex_WriteMatrix(filename,X,'%0.5f',',','w+');
end