function cmp = fillOutHyster(cmp,J,nhood,thresLo)
% fills out components up to the low threshold
% cmp = fillOutHyster(cmp,J,nhood,thresLo)
% cmp: high threshold segmentation (presumed shrunken)
% J: weighted graph
% nhood: neighborhood structure for J (use mknhood)
% thresLo: low threshold to fill out

J = J>thresLo;

outVox = cmp==0;

str = strel('diamond',1);

% find zero/out voxels next to in voxels
while sum(outVox(:)),
	nborVox = find(bwperim(outVox))';
	outVox(nborVox) = false;
[length(nborVox) sum(outVox(:))]
	for iVox = nborVox;
		[i,j,k] = ind2sub(size(cmp),iVox);
		cmpNbor = [];
		for nbor = 1:size(nhood,1),
			try,
			if J(i,j,k,nbor) & ~outVox(i+nhood(nbor,1),j+nhood(nbor,2),k+nhood(nbor,3));
				cmpNbor(end+1) = cmp(i+nhood(nbor,1),j+nhood(nbor,2),k+nhood(nbor,3));
			end
			end
		end
		for nbor = 1:size(nhood,1),
			try,
			if J(i-nhood(nbor,1),j-nhood(nbor,2),k-nhood(nbor,3),nbor) & ~outVox(i-nhood(nbor,1),j-nhood(nbor,2),k-nhood(nbor,3)),
				cmpNbor(end+1) = cmp(i-nhood(nbor,1),j-nhood(nbor,2),k-nhood(nbor,3));
			end
			end
		end
		cmpNbor(cmpNbor==0) = [];
		if ~isempty(cmpNbor),
			cmp(iVox) = cmpNbor(1);		% arbitrarily pick the 1st cmp
		end
	end
end
