function conn = MakeConnLabel(cmp,nhood,sim,varargin)
% Makes connectivity rep for arbitrary nhoods using an arbitrary similarity metric

[imx,jmx,kmx,ndim] = size(cmp);
conn = zeros([imx jmx kmx size(nhood,1)],'single');

for k = 1:size(nhood,1),
	idxi = max(1-nhood(k,1),1):min(imx-nhood(k,1),imx);
	idxj = max(1-nhood(k,2),1):min(jmx-nhood(k,2),jmx);
	idxk = max(1-nhood(k,3),1):min(kmx-nhood(k,3),kmx);
	r = repmat(shiftdim(nhood(k,:),-2),[length(idxi) length(idxj) length(idxk) 1]);
	conn(idxi,idxj,idxk,k) = sim( ...
		cmp(idxi,idxj,idxk,:), ...
		cmp(idxi+nhood(k,1),idxj+nhood(k,2),idxk+nhood(k,3),:), ...
		r, ...
		varargin{:});
end
