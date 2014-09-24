function conn = MakeNCutW(im,sig,nhood)
% creates the pixel-wise affinity matrix for Ncut

if ~exist('sig','var'),
	sig = 0.3;	%  std of gaussian
end
sz = size(im); n = numel(im);
[i,j,k] = ndgrid(1:sz(1),1:sz(2),1:sz(3));

conn = zeros([sz size(nhood,1)],'single');

% compute pixel intensity differences
for nbor = 1:size(nhood,1),
	idxi = max(1-nhood(nbor,1),1):min(sz(1)-nhood(nbor,1),sz(1));
	idxj = max(1-nhood(nbor,2),1):min(sz(2)-nhood(nbor,2),sz(2));
	idxk = max(1-nhood(nbor,3),1):min(sz(3)-nhood(nbor,3),sz(3));
	imdiff = im(idxi,idxj,idxk) ...
			- im(idxi+nhood(nbor,1),idxj+nhood(nbor,2),idxk+nhood(nbor,3));
	conn(idxi,idxj,idxk,nbor) = exp(-(imdiff/sig).^2);
end
