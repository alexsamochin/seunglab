function A = mkSymmConn(conn);
% symmetrize conn for speed (call it A)
[imx jmx kmx jnk] = size(conn);
A = zeros([imx jmx kmx 3 3 3],'single');
idx = 0;
for ii = -1:0, for jj = -1:(0-ii), for kk = -1:(0-min(ii,jj)),
	idx = idx+1;
	idxi = max(1-ii,1):min(imx-ii,imx);
	idxj = max(1-jj,1):min(jmx-jj,jmx);
	idxk = max(1-kk,1):min(kmx-kk,kmx);
	if idx<14,
		A(idxi,idxj,idxk,2+ii,2+jj,2+kk) = conn(idxi,idxj,idxk,idx);
		A(idxi+ii,idxj+jj,idxk+kk,2-ii,2-jj,2-kk) = conn(idxi,idxj,idxk,idx);
	end
end, end, end
A = A(:,:,:,:);
