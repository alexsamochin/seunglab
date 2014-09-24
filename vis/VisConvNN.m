function VisConvNN(im,x1,W1,x2,W2,xn,Wn)
%% Makes a pretty plot of the network architecture
%%

imSz = size(im); x1Sz = size(x1); x2Sz = size(x2); xnSz = size(xn);
xspace = ceil(1.1*imSz(1));
zspace = ceil(2*imSz(1));
pSz = 5*[1 1];

hiline = {'color','b','linewidth',1};
loline = {'color',0.6*[1 1 1],'linewidth',0.1};

% original image at the bottom
imagesc3(im,[0 0 0],ceil(0.4*imSz(1)*[-1 1]))

% feature map 1
nHid1 = size(x1,3); xrng1 = (0:nHid1)-(nHid1-1)/2;
for k = 1:nHid1,
	xoff = xspace*xrng1(k); zoff1 = zspace;
	imagesc3(x1(:,:,k),[xoff 0 zoff1],ceil(0.4*x1Sz(1)*[-1 1]))
	connectsquare(ceil(imSz(1)/2)+pSz(1)*[-1 1],ceil(imSz(2)/2)+pSz(2)*[-1 1],0, ...
				xoff+ceil(x1Sz(1)/2)+[0 1],ceil(x1Sz(2)/2)+[0 1],zoff1,loline{:});
end
connectsquare(ceil(imSz(1)/2)+pSz(1)*[-1 1],ceil(imSz(2)/2)+pSz(2)*[-1 1],0, ...
			ceil(x1Sz(1)/2)+[0 1],ceil(x1Sz(2)/2)+[0 1],zoff1,hiline{:});

% feature map 2
nHid2 = size(x2,3); xrng2 = (0:nHid2)-(nHid2-1)/2;
for k = 1:nHid2,
	xoff2 = xspace*xrng2(k); zoff2 = 2*zspace;
	imagesc3(x2(:,:,k),[xoff2 0 zoff2],ceil(0.4*x2Sz(1)*[-1 1]))
	for j = 1:nHid1,
		xoff1 = xspace*xrng1(j);
		connectsquare(xoff1+ceil(x1Sz(1)/2)+pSz(1)*[-1 1],ceil(x1Sz(2)/2)+pSz(2)*[-1 1],zoff1, ...
					xoff2+ceil(x2Sz(1)/2)+[0 1],ceil(x2Sz(2)/2)+[0 1],zoff2,loline{:});
	end
end
for j = 1:nHid1,
	xoff1 = xspace*xrng1(j);
	connectsquare(xoff1+ceil(x1Sz(1)/2)+pSz(1)*[-1 1],ceil(x1Sz(2)/2)+pSz(2)*[-1 1],zoff1, ...
				ceil(x2Sz(1)/2)+[0 1],ceil(x2Sz(2)/2)+[0 1],zoff2,hiline{:});
end

% network output
zoffn = 3*zspace;
imagesc3(xn,[0 0 zoffn],ceil(0.4*xnSz(1)*[-1 1]))
for j = 1:nHid2,
	xoff2 = xspace*xrng2(j);
	connectsquare(xoff2+ceil(x2Sz(1)/2)+pSz(1)*[-1 1],ceil(x2Sz(2)/2)+pSz(2)*[-1 1],zoff2, ...
				ceil(xnSz(1)/2)+[0 1],ceil(xnSz(2)/2)+[0 1],zoffn,hiline{:});
end

% set the view
axis image ij off
view(3)
colormap gray
