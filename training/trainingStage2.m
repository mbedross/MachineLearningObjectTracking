function [dTrainC] = trainingStage2(dTrain, b, Xtrain)

pCutoff = 0.005;
minCluster = 10;

yTrainFit = glmval(b,Xtrain,'logit');
dTrainC = classify(yTrainFit, pCutoff, minCluster, size(dTrain,1),size(dTrain,2),size(dTrain,3),size(dTrain,4));

for i = 1:size(dTrain,3)
    I2 = montage([dTrain(:,:,i,1) 255.*(dTrainC(:,:,i,1))]);
    compVid(:,:,i) = get(I2,'CData');
end

implay(permute(compVid,[1 2 4 3]))

prompt = 'Where should the training data be saved? (e.g. C:\Users\manu\Desktop\TrainingData\Colwellia.mat) : ';
filename = input(prompt,'s');
if exist(filename, 'file') == 2
    save(filename, 'b', '-append')
else
    save(filename, 'b')
end