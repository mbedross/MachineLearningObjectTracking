%Test code - Execution -  finding the tracks and plotting them.
% this code will plot the tracks for us, once we are satisfied with our selection of parameters
%-------------------------------------------------------------
clearvars -except b points points2 replicated
tic
%-------------------------------------------------------------
%Find Replicated Images - run this command on original dataset.
%%replica_t=find_replica_imgs(1,91);
%-------------------------------------------------------------
%Variable Declarations - things to consider:
%Now we are dealing with 3D data, therefore the variables must take that
%into account.
%----------------------------------------------------------------
%Enter Dataset size below
%----------------------------------------------------------------
z_dataset_start = 70;
z_dataset_end = 170;
t_dataset_start = 1;
t_dataset_end = 195;
%---------------------------------------------------------------
%Enter a subsection of the dataset to track below
%--------------------------------------------------------------
z_tracking_start = 70;
z_tracking_end = 170;
t_tracking_start = 1;
t_tracking_end = 195;
%--------------------------------------------------------------
%Enter image parameters below
%--------------------------------------------------------------
imgScaleFactor = 1;
numFrames = 0;
contrastFactor = 1;
pCutoff = 0.005;
minCluster = 10;
cropSize = 15;
%-------------------------------------------------------------
%Enter tracking parameters below
%------------------------------------------------------------
max_linking_distance = 30;
max_gap_closing = 1;

z_separation = 2.5;
%-------------------------------------------------------------
zSize = abs(z_tracking_end - z_tracking_start + 1);

if z_tracking_start>z_dataset_start
    z_bottom = 0;
else
    z_bottom = 1;
end

if z_tracking_end<z_dataset_end
    z_top = 0;
else
    z_top = 1;
end
tSize = abs(t_tracking_end - t_tracking_start + 1);

t = t_tracking_start;


for tau = t_tracking_start:t_tracking_end;
    
    if any(tau==replicated)
        % Do nothing
    else
        %The loop below creats a 3D matrix at frame t
        
        for z = z_tracking_start-~(z_bottom):z_tracking_end+~(z_top);
            
            k=(z-z_tracking_start+1);
            zVals(k) = z;
            [imgA,imgB] = returnMedianImgAndImg(z,tau,t_dataset_end,numFrames, imgScaleFactor);
            D(:,:,k) = uint8((int16(imgA) - int16(imgB)).*contrastFactor+127);
        end
        %-------------------------------------------------
        dim1 = size(D,1);
        dim2 = size(D,2);
        dim3 = size(D,3);
        dim4 = size(D,4);
        
        croppedD = cropEdges(D,cropSize);
        D = addEdges(croppedD,cropSize);
        
        X = zeros(0,9);
        
        for z = 1:dim3
            
            if z==1
                input_slice(:,:,1) = D(:,:,z);
                input_slice(:,:,2) = D(:,:,z);
            else
                if z ==2
                    input_slice(:,:,1) = D(:,:,z-1);
                    input_slice(:,:,2) = D(:,:,z-1);
                else
                    input_slice(:,:,1) = D(:,:,z-2);
                    input_slice(:,:,2) = D(:,:,z-1);
                end
                
            end
            
            input_slice(:,:,3) = D(:,:,z);
            
            if z==dim3
                input_slice(:,:,4) = D(:,:,z);
                input_slice(:,:,5) = D(:,:,z);
            else
                if z == dim3-1
                    input_slice(:,:,4) = D(:,:,z+1);
                    input_slice(:,:,5) = D(:,:,z+1);
                else
                    input_slice(:,:,4) = D(:,:,z+1);
                    input_slice(:,:,5) = D(:,:,z+2);
                end
            end
            X = [X; getInputMatrixV5zs(input_slice)];
        end
        
        %function glmval() is from statistical and machine learning
        %toolbox. It calculates the probability of a pixel being bacteria
        %by the pixel feature matrix 'X' and the weight vector 'b', 
        %which was found from training.  
        %----------------------------------------
        y = glmval(b,X,'logit');
        %------------------------------------------
        
        D_C = classify(y, pCutoff, minCluster, dim1,dim2,dim3,dim4);
        
        points{t} = findCentroids(D_C);
        points2{t} = points{t}*[360/dim1 0 0;0 360/dim2 0;0 0 z_separation];
        
        percent_complete=(t+1-t_tracking_start)*100/(tSize-size(replicated,2))
        
        t=t+1;
    end
end
%----------------------------------------------------------
[ tracks adjacency_tracks] = simpletracker(points2, ...
    'MaxLinkingDistance', max_linking_distance, ...
    'MaxGapClosing', max_gap_closing);
%The function plotTracks, takes as input adjacency tracks and points to
%to plot the results in a 3D line graph.

plotTracksAndVelocity(adjacency_tracks,points2);
daspect([1 1 1])
createTracks
toc
