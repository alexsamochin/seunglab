function Plot2dConn3(conn)
%% Plot the connectivity graph for a 2d slice
[x,y] = meshgrid(1:size(conn,2),1:size(conn,1));

hold on
plot([x(conn(:,:,:,2)) x(conn(:,:,:,2))-1]',[y(conn(:,:,:,2)) y(conn(:,:,:,2))]','g-')
plot([x(~conn(:,:,:,2)) x(~conn(:,:,:,2))-1]',[y(~conn(:,:,:,2)) y(~conn(:,:,:,2))]','r-')

plot([x(conn(:,:,:,1)) x(conn(:,:,:,1))]',[y(conn(:,:,:,1)) y(conn(:,:,:,1))-1]','g-')
plot([x(~conn(:,:,:,1)) x(~conn(:,:,:,1))]',[y(~conn(:,:,:,1)) y(~conn(:,:,:,1))-1]','r-')
