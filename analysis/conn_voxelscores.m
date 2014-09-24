function [stats]=conn_voxelscores(labels, conn_output, mask, bb, thresholds)

nhood=mknhood(6);
stats=[];


if(~isempty(mask))
	mask=(mask>0);

	if(ndims(mask)==3)
		mask=repmat(mask, [1 1 1 3]);
	end

	conn_output=single(conn_output).*single(mask);
	
	if(ndims(labels)==3)
		labels=uint32(labels).*uint32(mask(:,:,:,1));
	else
		labels=single(labels).*single(mask);
	end
end

if(~isempty(bb))
	labels=labels(bb(1,1):bb(1,2), bb(2,1):bb(2,2), bb(3,1):bb(3,2),:);
	conn_output=conn_output(bb(1,1):bb(1,2), bb(2,1):bb(2,2), bb(3,1):bb(3,2), :);
end

if(ndims(labels)==4)
	display('generating labeled components');
	labels=connectedComponents(labels, nhood);
end


for thresh=thresholds
	thresh
	comp=connectedComponents(conn_output>thresh,nhood);
	[voxel_score, splits, mergers]=MetricsAllMatches(labels, comp, false);
	stats=[stats; thresh, voxel_score, splits, mergers]
end