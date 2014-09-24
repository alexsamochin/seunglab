function [voxelErr,merges,splits,best] = optimizeThreshold(truecmp,conn,thresh,nhood)

best.voxelErr = inf;
best.merges = inf;
best.splits = inf;

for k = 1:length(thresh),
	disp([num2str(k) '/' num2str(length(thresh))])
	cmp = connectedComponents(conn>thresh(k),nhood);
	[voxelErr(k),merges(k),splits(k)] = EvalMetrics(@MetricsAllMatches,20:120,71:120,7:94,truecmp,cmp);
	voxelErr(k)
	merges(k)
	splits(k)
	if voxelErr(k)<best.voxelErr,
		best.threshold = thresh(k);
		best.voxelErr = voxelErr(k);
		best.merges = merges(k);
		best.splits = splits(k);
		best.cmp = cmp;
	end
end
