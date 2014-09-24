function cmp = wKMeansSeg(conn)
% Weighted K-Means segmentation using the connectivity matrix
% based on Dhillon, Guan & Kulis. now obsolete since they released their 'graclus' code

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
A(A<0.6) = 0;
clear conn
D = sum(A(:,:,:,:),4);	% degree or D


% set up kernel and weights
% w = D;	% normalized cuts
% sigma = 1e1;
% K = zeros([imx jmx kmx 3 3 3],'single');
% for ii = -1:1, for jj = -1:1, for kk = -1:1,
% 	idxi = max(1-ii,1):min(imx-ii,imx);
% 	idxj = max(1-jj,1):min(jmx-jj,jmx);
% 	idxk = max(1-kk,1):min(kmx-kk,kmx);
% 	K(:,:,:,2+ii,2+jj,2+kk) = sigma./D + 
% end, end, end
zeroIdx = sub2ind([3 3 3],2,2,2);
K = reshape(A,[],27);
for idx=1:27,
	K(:,idx) = K(:,idx) - D(:);
end
K(:,zeroIdx) = -1e30;	% diagonal load for conditioning
w = ones([imx jmx kmx],'single');

% initialize conservatively
th = 2*10;
cmp = single(bwlabeln(D>th,26));
cmps = unique(cmp(cmp>0));
nCmp = length(cmps);

% iterate
nIter = 500;
nVox = 5e4;
m2 = zeros(nCmp,1);
vol = zeros(nCmp,1);
dist = zeros(nVox,3,3,3);
nobnd = D>0;
for iter = 1:nIter,

	cmpold = cmp;

	free = find(sum(mkConnLabel(cmp),4)<13 & nobnd);
	% select some voxels to update, find their neighbors
	voxSel = randsample(free,nVox);
	[i,j,k] = ind2sub([imx jmx kmx],voxSel);
	nn = zeros([nVox 3 3 3]);
	for ii=-1:1, for jj=-1:1, for kk=-1:1,
		nn(:,ii+2,jj+2,kk+2) = sub2ind([imx jmx kmx],i+ii,j+jj,k+kk)';
	end, end, end
	nn = nn(:,:);

	% remove zero voxels surrounded by zeros
% 	nozero = cmp(nn)>0; nozero = sum(nozero,2);
% 	nn = nn(nozero>0,:,:,:);
% 	nVox = size(nn,1)

	[cmpTest,jnk,nncmpIdx] = unique(cmp(nn));
	nncmpIdx = reshape(nncmpIdx,size(nn));
	for iCmp = 1:length(cmpTest),
		iCmpVox = cmp(:)==cmpTest(iCmp);
		den(iCmp) = sum(w(iCmpVox));
		m2(iCmp) = sum(sum(K(iCmpVox,:)))/den(iCmp)^2;	% assumes w=1
	end

	dist = m2(nncmpIdx) - 2*w(nn).*K(nn(:,zeroIdx),:)./den(nncmpIdx);
	dist(cmp(nn)==0) = inf;
	[jnk,cmpIdx] = min(dist,[],2);
	cmp(nn(:,zeroIdx)) = cmpTest(nncmpIdx(sub2ind([nVox 27],1:nVox,cmpIdx')));

	sum(cmpold(:)~=cmp(:))
figure(5),imagesc(cmp(:,:,10))

end
