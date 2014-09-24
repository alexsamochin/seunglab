function [cmp,numObj,cmpSz] = connectedComponents(F,nhood,threshold,simFn,varargin)
% Constructs a graph using the feature space 'F', neighborhood 'nhood', similarity fn 'sim'
% Segments by finding connected components of graph thresholded
% Usage:
% [components,componentSizes,numberOfComponents] = connectedComponents(G,nhood)
%
% Srini

if ~exist('nhood') || isempty(nhood),
	nhood = [-1 0 0; 0 -1 0; 0 0 -1];
end

[imx,jmx,kmx,ndim] = size(F);
cmp = zeros([imx jmx kmx],'int32');
cmp(:) = 1:numel(cmp);	% initialize with each pixel as a different component
edgeList = zeros([imx*jmx*kmx*size(nhood,1) 2]); lastEdge = 0;

for k = 1:size(nhood,1),
	k
	idxi = max(1-nhood(k,1),1):min(imx-nhood(k,1),imx);
	idxj = max(1-nhood(k,2),1):min(jmx-nhood(k,2),jmx);
	idxk = max(1-nhood(k,3),1):min(kmx-nhood(k,3),kmx);
	r = repmat(shiftdim(nhood(k,:),-2),[length(idxi) length(idxj) length(idxk) 1]);
	% compute similarity
	sim = simFn( ...
		F(idxi,idxj,idxk,:), ...
		F(idxi+nhood(k,1),idxj+nhood(k,2),idxk+nhood(k,3),:), ...
		r, ...
		varargin{:});
	% figure out which edges to keep
	nodes1 = cmp(idxi,idxj,idxk); nodes2 = cmp(idxi+nhood(k,1),idxj+nhood(k,2),idxk+nhood(k,3));
	edgeKeep = (sim(:)>threshold); nEdgeKeep = sum(edgeKeep);
	% add new edges
	edgeList(lastEdge+[1:nEdgeKeep],1) = nodes1(edgeKeep);
	edgeList(lastEdge+[1:nEdgeKeep],2) = nodes2(edgeKeep);
	lastEdge = lastEdge+nEdgeKeep;
end
edgeList = edgeList(1:lastEdge,:);

G = sparse(edgeList(:,1),edgeList(:,2),true,numel(cmp),numel(cmp));
G = G|G';
[cmp cmpSz] = components(G);

% remove dust and sort components
[cmpSz,reverse_renum] = sort(cmpSz,'descend');
dust = cmpSz==1;
cmpSz(dust) = [];
numObj = length(cmpSz);

renum = zeros(1,length(reverse_renum));
reverse_renum(dust) = [];
renum(reverse_renum) = 1:numObj;
cmp = renum(cmp);
cmp = reshape(cmp,[imx jmx kmx]);
