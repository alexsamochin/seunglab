function [cmp,numObj,cmpSz] = connectedComponents(G,nhood,verbose)
% Finds connected components according to the connectivity structure G
% Usage:
% [components,componentSizes,numberOfComponents] = connectedComponents(G,nhood)
%
% Srini

if ~exist('nhood') || isempty(nhood),
	nhood = [-1 0 0; 0 -1 0; 0 0 -1];
end

szG = size(G);

% compute components
G = Dense2SparseGraphAssymLogical(G,nhood); G = G|G';
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
cmp = reshape(cmp,szG(1:3));
