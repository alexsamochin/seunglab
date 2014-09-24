function [cc,numcc] = ConnectedComponentsSparse(G)
% [cc,numcc] = ConnectedComponentsSparse(G) computes the connected components
% of a sparse symmetric adjacency graph.

numNodes = size(G,1);

% add diagonal connections
G = spdiags(ones(numNodes,1),0,G);

% find cc
[p,p,r,r] = dmperm(G);
sizes = diff(r);				% Sizes of components, in vertices.
numcc = length(sizes);		% Number of components.

% Now compute an array "blocks" that maps vertices of equiv to components;
% First, it will map vertices of equiv(p,p) to components...
cc = zeros(1,numNodes);
cc(r(1:numcc)) = ones(1,numcc);
cc = cumsum(cc);
% Second, permute it so it maps vertices of equiv to components.
cc(p) = cc;
