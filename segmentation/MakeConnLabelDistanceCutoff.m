function conn = MakeConnLabel(cmp,nhood1,nhood2,d_cutoff)
% Makes connectivity rep for arbitrary nhoods
% only creates edges between pixels if the edge is close to the labeled pixels
% this keeps from creating long-range edges with unrealistic geometries

% nhood1 is used to determine the topology (connectedness of the object)
% nhood2 is the readout -- the size of the graph output
% d_cutoff is the graph distance threshold for edges between nodes

% get sizes
[imx,jmx,kmx] = size(cmp);
sz = [imx,jmx,kmx];
n = prod(sz);

% initialize memory
[i,j,k] = ndgrid(1:imx,1:jmx,1:kmx);
conn = false([imx jmx kmx size(nhood2,1)]);
G = sparse(n,n);

%% first compute the graph using nhood1
for nbor = 1:size(nhood1,1),
	idxi = max(1-nhood1(nbor,1),1):min(imx-nhood1(nbor,1),imx);
	idxj = max(1-nhood1(nbor,2),1):min(jmx-nhood1(nbor,2),jmx);
	idxk = max(1-nhood1(nbor,3),1):min(kmx-nhood1(nbor,3),kmx);
	ii = i(idxi,idxj,idxk);
	jj = j(idxi,idxj,idxk);
	kk = k(idxi,idxj,idxk);
	nodes1 = sub2ind(sz,ii(:),jj(:),kk(:));
	ii = ii+nhood1(nbor,1);
	jj = jj+nhood1(nbor,2);
	kk = kk+nhood1(nbor,3);
	nodes2 = sub2ind(sz,ii(:),jj(:),kk(:));
	
	% extract the edges for these nodes
	edges = (cmp(nodes1) == cmp(nodes2)) & (cmp(nodes1) > 0);

	% insert them into the sparse graph
	G = G | sparse(nodes1,nodes2,edges(:),n,n);
end
% symmetrize
G = G|G';

%% compute edges that are d_cutoff apart
G = G^ceil(d_cutoff);

%% copy graph into dense graph
for nbor = 1:size(nhood2,1),
	idxi = max(1-nhood2(nbor,1),1):min(imx-nhood2(nbor,1),imx);
	idxj = max(1-nhood2(nbor,2),1):min(jmx-nhood2(nbor,2),jmx);
	idxk = max(1-nhood2(nbor,3),1):min(kmx-nhood2(nbor,3),kmx);
	ii = i(idxi,idxj,idxk);
	jj = j(idxi,idxj,idxk);
	kk = k(idxi,idxj,idxk);
	nodes1 = sub2ind(sz,ii(:),jj(:),kk(:));
	ii = ii+nhood2(nbor,1);
	jj = jj+nhood2(nbor,2);
	kk = kk+nhood2(nbor,3);
	nodes2 = sub2ind(sz,ii(:),jj(:),kk(:));
	
	% extract the edges for these nodes
	edges = full(G(sub2ind([n n],nodes1,nodes2)));
	conn(idxi,idxj,idxk,nbor) = reshape(edges,size(ii));
end
