function imagesc3(im,offset,zbox)
% analog of imagesc in 3d
% display 2d image in a constant z plane
% a collection of patches
% like the surf command, but that creates triangles
if nargin>1
    x=offset(1); y=offset(2); z=offset(3);
else
    x=0; y=0; z=0;  % default is image starting at origin
end
%im=double(im); cmin=min(im(:));cmax=max(im(:)); caxis([cmin cmax]);
[m n]=size(im);
[X,Y]=meshgrid(0:m-1,0:n-1); Z=ones(size(Y));
X=X(:)'+x; Y=Y(:)'+y; Z=z*Z(:)';
XX=[X; X; X+1; X+1];
YY=[Y; Y+1; Y+1; Y];
ZZ=[Z; Z; Z; Z];
%cmap=colormap;
%index = fix((im(:)'-cmin)/(cmax-cmin)*length(cmap))+1;
%index(index<=1)=1;
%index(index>=length(cmap))=length(cmap);
%for i=1:m*n,patch(XX(:,i),YY(:,i),ZZ(:,i),im(i)','EdgeColor',cmap(index(i),:),'LineWidth',0.25);end
patch(XX,YY,ZZ,im(:)','EdgeColor','none')

% draw a line box in z
if exist('zbox'),
	connectsquare(x+[0 m],y+[0 n],z+zbox(1),x+[0 m],y+[0 n],z+zbox(2),'color',0.7*[1 1 1])
end
