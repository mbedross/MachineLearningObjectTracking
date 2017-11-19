% clearvars imStack x0 y0 z0 u v w x1 y1 z1 x0n y0n z0n un vn wn
% tStart = 1;
% vidSize = 139;
% minTrackLength = 10;
% tEnd = 195;
% t_div = 4;
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
%         
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
%         end
%         
%     end
% end
% 
% for i = 1:size(relTracks,2)
%    
%     for t = tStart+1:tStart+vidSize-1
%         for td = 1:t_div
%             idx = (t-1)*t_div+td;
%             
%             if isnan(relTracks{i}(t)) || isnan(relTracks{i}(t-1))
%                 x0n(idx,i) = NaN;
%                 y0n(idx,i) = NaN;
%                 z0n(idx,i) = NaN;
%                 un(idx,i) = NaN;
%                 vn(idx,i) = NaN;
%                 wn(idx,i) = NaN;
%             else
%                 un(idx,i)= u(t,i)./t_div;
%                 vn(idx,i)= v(t,i)./t_div;
%                 wn(idx,i)= w(t,i)./t_div;
%                 x0n(idx,i)=allPoints{t-1}(relTracks{i}(t-1),1)+un(idx,i)*(td-1);
%                 y0n(idx,i)=allPoints{t-1}(relTracks{i}(t-1),2)+vn(idx,i)*(td-1);
%                 z0n(idx,i)=allPoints{t-1}(relTracks{i}(t-1),3)+wn(idx,i)*(td-1);
%                 
%             end
%         end
%     end
% end
% trailSize = 15*t_div;
% 
% 
% for t = 1:size(x0n,1)
%     
%     quiver3([0 400],[0 400],[0 300],[0 0],[0 0],[0 0],0)
%     xlim([0 360]);
%     ylim([0 360]);
%     zlim([0 253]);
%     xlabel('x (micrometers)');
%     ylabel('y (micrometers)');
%     zlabel('z (micrometers)');
%     title('Vibrio Swimming');
%     box on
%     daspect([1 1 1])
%     hold on
%     i = t.*360./size(x0n,1) -37.5;
%     j = 30.*cos(i.*pi./180);
%     view([i j]);
%         
%         for i=1:size(relTracks,2)
%             if (t-tStart)>trailSize
%                 r = trailSize;
%             else
%                 r = t;
%             end
%             
%             %q = quiver3(y0(tStart+1:t,i),x0(tStart+1:t,i),z0(tStart+1:t,i),v(tStart+1:t,i),u(tStart+1:t,i),w(tStart+1:t,i),0);
%             q = quiver3(x0n(t-r+1:t,i),y0n(t-r+1:t,i),z0n(t-r+1:t,i),un(t-r+1:t,i),vn(t-r+1:t,i),wn(t-r+1:t,i),0);
%             scatter3(x0n(t,i)+un(t,i),y0n(t,i)+vn(t,i),z0n(t,i)+wn(t,i),20,[0 0 0],'filled')
%              set(q,'LineStyle','-');
%              set(q,'ShowArrowHead','off');
%              set(q,'AlignVertexCenters','on');
%         end
%         
%     f = getframe(gcf);
%     hold off
%     imStack(:,:,:,t-tStart+1) = (frame2im(f));
%     Creating_video_percent_complete = (t-tStart)*100/(vidSize.*t_div)
% end
% implay(permute(imStack,[1 2 3 4]))
% %-----------------------------------------------------------
% %Video_out_code below---------------------------------------
% %-----------------------------------------------------------
vid = VideoWriter('vibrio_1st_attempt_smooth_panning.avi');
vid.FrameRate =20;
open(vid);
writeVideo(vid,permute(imStack,[1 2 3 4]));
close(vid);
% % % %-----------------------------------------------------------