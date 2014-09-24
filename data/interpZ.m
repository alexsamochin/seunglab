function [cmpHi,z] = interpZ(cmpLo,fac)

disp('Interpolating...')

z = 1:(1/fac):size(cmpLo,3);
cmpHi = zeros([size(cmpLo(:,:,1)) length(z)],'single');
cmpIdx = unique(cmpLo);
if cmpIdx(1) == 0, cmpIdx = cmpIdx(2:end); end

for idx = 1:length(cmpIdx),
	cmpIdx(idx)
	cmp(:,:,1) = cmpLo(:,:,1) == cmpIdx(idx);
	d(:,:,1) = bwdist(cmp(:,:,1))-bwdist(~cmp(:,:,1));
	for k = 2:size(cmpLo,3),
		cmp(:,:,2) = cmpLo(:,:,k) == cmpIdx(idx);
		d(:,:,2) = bwdist(cmp(:,:,2))-bwdist(~cmp(:,:,2));
		d(isinf(d))=1e31;
		[xx,yy,zz] = meshgrid(1:size(cmpLo,2),1:size(cmpLo,1),z(1:fac));
		dd = interp3(d,xx,yy,zz);
		cmpHi(:,:,(k-1)*fac+[1:fac]) = (dd<=0)*cmpIdx(idx);
	end
end
