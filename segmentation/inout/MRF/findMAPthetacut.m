function [cut, varargout] = findMAPthetacut(Jparam,theta,nhood,im,varargin)

  addpath('../adjacency_list');
  
nhoodsize=2*length(nhood);

% find cut
[m n l]=size(im);
disp('preparing dense weight mat');
tic
cl=ones(m,n,l,nhoodsize/2);
cl2=ones(m,n,l,nhoodsize/2);
for i=1:length(Jparam)
  cl2(:,:,:,i) = cl(:,:,:,i)*Jparam(i);
end
toc
clear cl;
disp('dense2sparse');
tic
J=Dense2SparseGraph(cl2,nhood);
toc
clear cl2;

[i,j,weight]=find(J);
clear J;
lidx=find(i<j);
% sz = size(cl2(:,:,:,1));
% 
% [i,j,k] = ndgrid(1:sz(1),1:sz(2),1:sz(3));
% adm=[];
% for nbor = 1:size(nhood,1),
%   nbor
%   % this funky bit of code find the indices of the pairs of nodes connected by this edge, for all nodes!
% 	idxi = max(1-nhood(nbor,1),1):min(sz(1)-nhood(nbor,1),sz(1));
% 	idxj = max(1-nhood(nbor,2),1):min(sz(2)-nhood(nbor,2),sz(2));
% 	idxk = max(1-nhood(nbor,3),1):min(sz(3)-nhood(nbor,3),sz(3));
% 	ii = i(idxi,idxj,idxk);
% 	jj = j(idxi,idxj,idxk);
% 	kk = k(idxi,idxj,idxk);
% 	nodes1 = sub2ind(sz,ii(:),jj(:),kk(:));
% 	ii = i(idxi+nhood(nbor,1),idxj+nhood(nbor,2),idxk+nhood(nbor,3));
% 	jj = j(idxi+nhood(nbor,1),idxj+nhood(nbor,2),idxk+nhood(nbor,3));
% 	kk = k(idxi+nhood(nbor,1),idxj+nhood(nbor,2),idxk+nhood(nbor,3));
% 	nodes2 = sub2ind(sz,ii(:),jj(:),kk(:));
% 	
% 	% extract the edges for these nodes
% 	edges = 64*cl2(idxi,idxj,idxk,nbor);
% 
% 	% insert them into the sparse graph
% %	Gsparse = Gsparse + sparse(nodes1,nodes2,edges(:),n,n);
%     idx = find(nodes1<nodes2);
% 
%     adm = [ adm; nodes1(idx) nodes2(idx) edges(idx) edges(idx)];
% end
% 
% keyboard

is=i(lidx);
js=j(lidx);
clear i;
clear j
weights=128*weight(lidx);
clear weight;

adm = [is js weights weights];
clear lidx;
clear is;
clear js;
clear weights;


ssm = 128*double([im(:)-theta -(im(:)-theta)]);
%ssm = -16*ssm.^2/2;

%keyboard 
disp('computing cut');
tic
cut=cut_graph_al(ssm,adm);
toc
cut=cut*2-1;
cut=reshape(cut,[m n l]);

if (nargin>4)
  trace=varargin{1};
  varargout{1} = 1-(sum(sum(sum(abs(cut-trace))))/2)/numel(trace);
end








