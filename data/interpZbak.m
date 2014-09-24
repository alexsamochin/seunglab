function cmpHi = interpZ(cmpLo,fac)

[xx,yy,zz] = meshgrid(1:size(cmpLo,2),1:size(cmpLo,1),1:(1/fac):size(cmpLo,3));
cmpHi = zeros(size(xx));
cmpIdx = unique(cmpLo);
nPix = zeros(length(cmpIdx),2);

for idx = 35:length(cmpIdx),
	cmp = cmpLo == cmpIdx(idx);
	idxZ = find(sum(sum(cmp))>0);
[cmpIdx(idx) length(idxZ)]
	d = zeros(size(cmpLo,1),size(cmpLo,2),length(idxZ));
	for k = 1:length(idxZ),
		d(:,:,k) = bwdist(cmp(:,:,idxZ(k)))-bwdist(~cmp(:,:,idxZ(k)));
	end
	[xx,yy,zz] = meshgrid(1:size(cmpLo,2),1:size(cmpLo,1),1:(1/fac):length(idxZ));
	dd = interp3(d,xx,yy,zz);
	[i,j,k] = find(dd<=0);
	cmpHi(i,j,k+(idxZ(1)-1)*fac) = cmpIdx(idx);
	nPix(idx,:) = [sum(cmp(:)) sum(dd(:)<=0)];
nPix(idx,:)
if nPix(idx,2) == 0, keyboard, end
end
