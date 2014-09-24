function [xmap] = findMAPthetaBP(Jparam,theta,nhood,im,varargin)
% map=findMAPthetaBP(Jparam,theta,nhood,im)
% runs 20 sweeps of BP on the MRF specified by Jparam and an
% applied field of (im-theta)
% E(x) = \sum_ij J_ij x_i x_j + \sum_i (im_i-theta) x_i
% nhood one half of the relative offsets to the neighbors of a given voxel
% the other half is just the negative. 
% Jparam is arranged in the same ordering as nhood, J is symmetric


  

nhoodfull=[nhood; -nhood];
nhoodsize=length(nhoodfull);

Jparamfull = single([Jparam; Jparam]);


[l m n]=size(im);

nim=numel(im);


disp('initializing messages');
% initialize with uniform distribution
mst=zeros(nim,nhoodsize,2,'double');
disp('getting evidence ready');
ms=single([exp(.5*(im(:)-theta)) exp(.5*(-im(:)+theta))]);
ms=ms./repmat(sum(ms,2),1,2);
msb=permute(repmat(ms,[1 1 nhoodsize]),[1 3 2]);

disp('computing permutation');
nhoodtidx = [nhoodsize/2+[1:nhoodsize/2] 1:nhoodsize/2 ];
if (nargin>4)
  p=varargin{1};
else
  p=MakePermuteVecDenseGraph([l m n], nhoodfull, nhoodtidx);
end
borderis=find((1:length(p))==p);

disp('computing Jfull');
 Jfull=repmat(Jparamfull',[nim,1]);
 Jfull = cat(3,Jfull,-Jfull);

T=20;
for t=1:T

  % compute summary of incoming messages
  mst = repmat(sum(mst,2),[1 nhoodsize 1]) - mst;
  
  % add field term
  mst=mst+msb;
  

  % add interactions
  tmst(:,:,:,1)=mst+Jfull;
  tmst(:,:,:,2)=mst-Jfull;
  tmst=exp(tmst);
  mst=squeeze(max(tmst,[],3));
  mst=log(mst./repmat(sum(mst,3),[1 1 2]));
  
  
  
  mst=reshape(mst,[nim*nhoodsize, 2]);
  mst = mst(p,:);
  mst(borderis,:)=0;
  mst=reshape(mst,[nim nhoodsize 2]);

  

  b=squeeze(sum(mst,2))+ms;
  xmap = b(:,1)>b(:,2);
  xmap=reshape(xmap,[l m n]);
  imagesc(xmap(:,:,10));

% keyboard
  

end



  b=squeeze(sum(mst,2))+ms;
  xmap = b(:,1)>b(:,2);
  xmap=reshape(xmap,[l m n]);
%  imagesc(xmap(:,:,30));


