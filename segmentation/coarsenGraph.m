function Gsmall = coarsenGraph(Gbig,cc)
% Gsmall = coarsenGraph(Gbig,cc)
% Creates a coarser graph Gsmall, from a fine graph Gbig such that
% nodes with in the same connected component of cc are collapsed to
% a single node in Gsmall

[i,j,edge] = find(Gbig);
i = cc(i); j = cc(j);
idxkeep = (i>0)&(j>0);	% throw away 0 pixels
i=double(i(idxkeep)); j=double(j(idxkeep)); edge=edge(idxkeep);

Gsmall = sparse(i,j,edge);
