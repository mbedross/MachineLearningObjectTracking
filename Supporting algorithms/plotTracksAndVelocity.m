function [xv, yv, zv] = plotTracksAndVelocity( adj_tracks, points )

allPoints = vertcat(points{:});
totalTracks = size(adj_tracks(:),1);
minTrackLength = 6;

for i = 1:totalTracks
    
    singleTrack = adj_tracks(i);
    
    totalpoints = size(singleTrack{:},1);
    x = 0;
    y = 0;
    z = 0;
    
    hold on
    for j = 1:totalpoints
        if(allPoints(singleTrack{1}(j),1) ==0)
        else
            
            x(j) = allPoints(singleTrack{1}(j),1);
            y(j) = allPoints(singleTrack{1}(j),2);
            z(j) = allPoints(singleTrack{1}(j),3);
        end
    end
    xv = 0;
    yv = 0;
    zv = 0;

    for j = 1:totalpoints-1
        if(allPoints(singleTrack{1}(j),1) ==0)
        else
            xv(j) = x(j+1) - x(j);
            yv(j) = y(j+1) - y(j);
            zv(j) = z(j+1) - z(j);
            
        end
        
    end
%     xv(j+1) = 0;
%     yv(j+1) = 0;
%     zv(j+1) = 0;
    if size(x,2) > minTrackLength
        %plot3(y,x,z,'Color', [1 0 1],'LineStyle','-.','LineWidth', 1)
        %quiver3(y(1:j),x(1:j),z(1:j),yv,xv,zv,0,'Color',[1 0 1],'LineWidth', 3)
        scatter3(y,x,z,'*','MarkerEdgeColor',[1 0 1])
    end

end
grid on 
hold off
end