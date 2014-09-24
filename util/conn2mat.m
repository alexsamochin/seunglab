function Gmat = conn2mat(Gconn,nhood)
% Converts connectivity graph to a sparse adjacency matrix

sz = size(Gconn(:,:,:,1));
n = prod(sz);
Gmat = sparse([],[],[],n,n,numel(Gconn));

for i = 1:size(Gconn,1),
	for j = 1:size(Gconn,2),
		for k = 1:size(Gconn,3),
			for nbor = 1:size(nhood,1),
				try,
					idx1 = sub2ind(sz,i,j,k); idx2 = sub2ind(sz,i+nhood(nbor,1),j+nhood(nbor,2),k+nhood(nbor,3));
					Gmat(idx1,idx2) = Gconn(i,j,k,nbor);
				end
			end
		end
	end
end

% symmetrize
Gmat = Gmat+Gmat';
