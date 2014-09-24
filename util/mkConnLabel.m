function conn = mkConnLabel(comp)
% generates connectivity labeling from component labeling
% Usage:
% conn = mkConnLabel(components)
% Note:
% The equivalence classes are
% [1 3 7 9] [2 4 6 8] [10 12] [11 13] [5]
% 5 joins [11 13] if x,y are the same as z

conn = zeros([size(comp) 14]);
[imx jmx kmx] = size(comp);
idx = 0;
for ii = -1:0,
	for jj = -1:(0-ii),
		for kk = -1:(0-min(ii,jj)),
			idx = idx+1;
			idxi = max(1-ii,1):min(imx-ii,imx);
			idxj = max(1-jj,1):min(jmx-jj,jmx);
			idxk = max(1-kk,1):min(kmx-kk,kmx);
			conn(idxi,idxj,idxk,idx) = comp(idxi,idxj,idxk) == comp(idxi+ii,idxj+jj,idxk+kk);
		end
	end
end
conn(:,:,:,end) = 0;
