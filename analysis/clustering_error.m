function clustErr = clustering_error(compTrue,compEst,noOutVoxel)

if ~exist('noOutVoxel','var'),
	noOutVoxel = false;
end

clustErr = 0;
nvox = numel(compTrue);
for shift = 2:nvox,
	clustTrue = compTrue(1:(nvox-shift+1)) == compTrue(shift:nvox);
	clustEst = compEst(1:(nvox-shift+1)) == compEst(shift:nvox);
	if noOutVoxel,
		outVoxel = (compTrue(1:(nvox-shift+1))==0)|(compTrue(shift:nvox)==0);
		clustErr = clustErr + sum((clustTrue~=clustEst)&~outVoxel);
	else,
		clustErr = clustErr + sum(clustTrue~=clustEst);
	end
end
clustErr = clustErr/(nvox*(nvox-1)/2);
