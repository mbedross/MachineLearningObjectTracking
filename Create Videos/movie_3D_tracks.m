% clearvars imStack x0 y0 z0 u v w x1 y1 z1
% tStart = 1;
% vidSize = 195;
% minTrackLength = 50;
% tEnd = 195;
% 
% 
% allPoints = points2;
% j = 1;
% 
% for i = 1:size(tracks,1)
%     if (size(tracks{i},1) - sum(isnan(tracks{i})))>minTrackLength
%         if all(isnan(tracks{i}(tStart:tStart+vidSize-1)))
%         else
%             relTracks{j} = tracks{i};
%             j = j+1;
%         end
%     end
% end
% 
% for i = 1:size(relTracks,2)
%     
%     for t = tStart+1:tStart+vidSize-1
%         if isnan(relTracks{i}(t)) || isnan(relTracks{i}(t-1))
%             x0(t,i) = NaN;
%             y0(t,i) = NaN;
%             z0(t,i) = NaN;
%             u(t,i) = NaN;
%             v(t,i) = NaN;
%             w(t,i) = NaN;
%         else
%             x0(t,i) = allPoints{t-1}(relTracks{i}(t-1),1);
%             y0(t,i) = allPoints{t-1}(relTracks{i}(t-1),2);
%             z0(t,i) = allPoints{t-1}(relTracks{i}(t-1),3);
%             x1(t,i) = allPoints{t}(relTracks{i}(t),1);
%             y1(t,i) = allPoints{t}(relTracks{i}(t),2);
%             z1(t,i) = allPoints{t}(relTracks{i}(t),3);
%             u(t,i) = x1(t,i)-x0(t,i);
%             v(t,i) = y1(t,i)-y0(t,i);
%             w(t,i) = z1(t,i)-z0(t,i);
%             
%             
%         end
%     end
% end
% trailSize = 15;
% 
% for t = tStart:tStart+vidSize-1
%     
%     quiver3([0 400],[0 400],[0 200],[0 0],[0 0],[0 0],0)
%     box on
%     %daspect([1 1 1])
%     hold on
% 
%         
%         for i=1:size(relTracks,2)
%             if (t-tStart)>trailSize
%                 r = trailSize;
%             else
%                 r = t;
%             end
%             
%             %q = quiver3(y0(tStart+1:t,i),x0(tStart+1:t,i),z0(tStart+1:t,i),v(tStart+1:t,i),u(tStart+1:t,i),w(tStart+1:t,i),0);
%             q = quiver3(x0(t-r+1:t,i),y0(t-r+1:t,i),z0(t-r+1:t,i),u(t-r+1:t,i),v(t-r+1:t,i),w(t-r+1:t,i),0);
%             scatter3(x0(t,i)+u(t,i),y0(t,i)+v(t,i),z0(t,i)+w(t,i),20,[0 0 0],'filled')
%              %set(q,'Color',(de2bi(rem(i,27),3,3))./2);
%              %set(q,'Color',(de2bi(rem(i,7),3,2)));
%              %set(q,'Color',[1 0 0]);
%              set(q,'LineStyle','-');
%              set(q,'ShowArrowHead','off');
%              set(q,'AlignVertexCenters','on');
%         end
%         
%     f = getframe(gca);
%     hold off
%     imStack(:,:,:,t-tStart+1) = (frame2im(f));
%     Creating_video_percent_complete = (t-tStart)*100/vidSize
% end
% implay(permute(imStack,[1 2 3 4]))
% %-----------------------------------------------------------
% %Video_out_code below---------------------------------------
% %-----------------------------------------------------------
vid = VideoWriter('vibrio_7fps_new_track_video.avi');
vid.FrameRate = 7;
open(vid);
writeVideo(vid,permute(imStack,[1 2 3 4]));
close(vid);
% % % %-----------------------------------------------------------