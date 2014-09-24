function pvec = MakePermuteVecDenseGraph(sz,nhood,nhoodTransposeIdx)
% pvec = MakePermuteVecDenseGraph(sz,nhood,nhoodTransposeIdx)
% makes a permutation vector that 'transposes' a dense graph
% of size 'sz' and neighborhood 'nhood'. Requires the transpose of
% the nhood to be available 'nhoodTransposeIdx'
%
% eg:
%     pvec = MakePermuteVecDenseGraph(sz,nhood,nhoodTransposeIdx)
%     Gtranspose = G(pvec);

% initialize the 'identity' permutation
gsz = [sz size(nhood,1)];
pvec = uint32(1:prod(gsz));

[i,j,k] = ndgrid(1:sz(1),1:sz(2),1:sz(3));

for nbor = 1:size(nhood,1),
	% this funky bit of code find the indices of the pairs of nodes connected by this edge, for all nodes!
	idxi = max(1-nhood(nbor,1),1):min(sz(1)-nhood(nbor,1),sz(1));
	idxj = max(1-nhood(nbor,2),1):min(sz(2)-nhood(nbor,2),sz(2));
	idxk = max(1-nhood(nbor,3),1):min(sz(3)-nhood(nbor,3),sz(3));

	ii = i(idxi,idxj,idxk);
	jj = j(idxi,idxj,idxk);
	kk = k(idxi,idxj,idxk);
	edgesold = sub2ind(gsz,ii(:),jj(:),kk(:),nbor*ones(numel(ii),1));

	ii = ii+nhood(nbor,1);
	jj = jj+nhood(nbor,2);
	kk = kk+nhood(nbor,3);
	edgesnew = sub2ind(gsz,ii(:),jj(:),kk(:),nhoodTransposeIdx(nbor)*ones(numel(ii),1));

	pvec(edgesold) = edgesnew;
end
