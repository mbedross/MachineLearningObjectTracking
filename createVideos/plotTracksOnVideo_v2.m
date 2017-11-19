% % %function plotTracksOnVideo(tracks, points, numFrames,imgScaleFactor,contrastFactor)
clearvars imStack x0 y0 z0 u v w x1 y1 z1 relTracks
tStart = 1;
vidSize = 139;
minTrackLength = 10;
tEnd = 195;
z = 120;
numFrames =0;
imgScaleFactor =1;


allPoints = points;
allTracks = tracks;

j = 1;

for i = 1:size(allTracks,1)
    
    if (size(allTracks{i},1) - sum(isnan(allTracks{i})))>minTrackLength
        if all(isnan(allTracks{i}(tStart:tStart+vidSize-1)))
        else
            relTracks{j} = allTracks{i};
            j = j+1;
        end
    end
end
% 
k=1;
for t = tStart:tEnd
%for t = 1:91
    if any(t==replicated)
        % Do nothing
    else
        %[imgA,imgB] = getMedianImg(z,t,tEnd,numFrames, imgScaleFactor);
        [imgA,imgB] = returnMedianImgAndImg(z,t,tEnd,numFrames, imgScaleFactor);
        %I(:,:,t) = uint8((int16(imgA) - int16(imgB)).*contrastFactor+127);
        I(:,:,k) = imgA;
        k=k+1;
        acquiring_images_percent_completed = (t-tStart)*100/vidSize
    end
end
% 
for i = 1:size(relTracks,2)
    
    for t = tStart+1:tStart+vidSize-1
        if isnan(relTracks{i}(t)) || isnan(relTracks{i}(t-1))
            x0(t,i) = NaN;
            y0(t,i) = NaN;
            z0(t,i) = NaN;
            u(t,i) = NaN;
            v(t,i) = NaN;
            w(t,i) = NaN;
        else
            x0(t,i) = allPoints{t-1}(relTracks{i}(t-1),1);
            y0(t,i) = allPoints{t-1}(relTracks{i}(t-1),2);
            z0(t,i) = allPoints{t-1}(relTracks{i}(t-1),3);
            x1(t,i) = allPoints{t}(relTracks{i}(t),1);
            y1(t,i) = allPoints{t}(relTracks{i}(t),2);
            z1(t,i) = allPoints{t}(relTracks{i}(t),3);
            u(t,i) = x1(t,i)-x0(t,i);
            v(t,i) = y1(t,i)-y0(t,i);
            w(t,i) = z1(t,i)-z0(t,i);
            
            
        end
    end
end
trailSize = 15;

for t = tStart+1:tStart+vidSize-1
    imshow(I(:,:,t))
    hold on
   
        
        for i=1:size(relTracks,2)
            if (t-tStart)>trailSize
                r = trailSize;
            else
                r = t;
            end
            
            %q = quiver(x0(1:t,i),y0(1:t,i),u(1:t,i),v(1:t,i),0);
            q = quiver3(x0(t-r+1:t,i),y0(t-r+1:t,i),z0(t-r+1:t,i),u(t-r+1:t,i),v(t-r+1:t,i),w(t-r+1:t,i),0);
            %set(q,'Color',(de2bi(rem(i,27),3,3))./2);
            %set(q,'Color',(de2bi(rem(i,8),3,2)));
            set(q,'LineStyle','--');
            set(q,'ShowArrowHead','off');
        end
        
   

    f = getframe(gca);
    hold off
    imStack(:,:,:,t-tStart) = (frame2im(f));
    Creating_video_percent_complete = (t-tStart)*100/vidSize
end

% % %-----------------------------------------------------------
% % %Video_out_code below---------------------------------------
% % %-----------------------------------------------------------
% vid = VideoWriter('validation_dataset.avi');
% vid.FrameRate = 6;
% open(vid);
% writeVideo(vid,permute(imStack,[1 2 4 3]));
% close(vid);
%-----------------------------------------------------------
 implay(permute(imStack,[1 2 3 4]))
% % %end