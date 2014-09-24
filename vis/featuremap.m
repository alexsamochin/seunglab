% 3d plot of convolutional network
% retina, linear, nonlinear layers
n=10; % retina size
height=[10 15 25];  % heights to plot linear and nonlinear layers
im=[[0 0 1 1 1 0 0 0 0 0]',zeros(n,n-1)];  % vertical bar at edge
%im3=circshift(im,[0 4]);  % shift to interior
im3=circshift(im,[4 6]);  % shift to interior
im1=circshift(im',[3 1]); % horizontal bar
im2=circshift(im,[3 7])';  
w1=[-0.5 1 -0.5]'*ones(1,3); 

subplot(1,4,1)
u1=filter2(w1,im1,'same'); x1=max(u1-1.5,0); u2=sum(x1(:));
imagesc3(im1)
hold on;
imagesc3(u1,[0 0 height(1)]); imagesc3(x1,[0 0 height(2)]); 
imagesc3(u2,[4 4 height(3)]);
connectsquare([4 5],[3 4],height(1),[3 6],[2 5],0);
connectsquare([4 5],[4 5],height(3),[0 n],[0 n],height(2));
hold off
axis ij image off; shading flat; view(-15,20); caxis([-1.5 3])
set(findobj('type', 'line'), 'color', 'black');

subplot(1,4,2)
u1=filter2(w1,im2,'same'); x1=max(u1-1.5,0); u2=sum(x1(:));
imagesc3(im2);
hold on;
imagesc3(u1,[0 0 height(1)]); imagesc3(x1,[0 0 height(2)]);
imagesc3(u2,[4 4 height(3)]);
connectsquare([6 7],[7 8],height(1),[5 8],[6 9],0);
connectsquare([4 5],[4 5],height(3),[0 n],[0 n],height(2));
hold off
axis ij image off; shading flat; view(-15,20); caxis([-1.5 3])
set(findobj('type', 'line'), 'color', 'black');

subplot(1,4,3)
u1=filter2(w1,im3,'same'); x1=max(u1-1.5,0); u2=sum(x1(:));
imagesc3(im3);
hold on;
imagesc3(u1,[0 0 height(1)]); imagesc3(x1,[0 0 height(2)]);
imagesc3(u2,[4 4 height(3)]);
connectsquare([4 5],[3 4],height(1),[3 6],[2 5],0);
connectsquare([6 7],[7 8],height(1),[5 8],[6 9],0);
connectsquare([4 5],[4 5],height(3),[0 n],[0 n],height(2));
hold off
axis ij image off; shading flat; view(-15,20); caxis([-1.5 3])
set(findobj('type', 'line'), 'color', 'black');

subplot(1,4,4)
imagesc3(w1);
view(-15,20); caxis([-1.5 3]);  axis image off ij; shading flat

