function [ri,stats] = ...
					randIndex(compTrue,compEst,normalize,restrictedRadius,radius)

if ~exist('normalize','var') || isempty(normalize),
	normalize = false;
end

% condition input (also, shift to make positive)
compTrue = double(compTrue)+1; maxCompTrue = max(compTrue(:));
compEst = double(compEst)+1; maxCompEst = max(compEst(:));

% compute the overlap or confusion matrix
% this computes the fraction of each true component
% overlapped by an estimated component
% the sparse() is used to compute a histogram over object pairs
overlap = sparse(compTrue(:),compEst(:),1,maxCompTrue,maxCompEst);

% compute the effective sizes of each set of objects
% computing it from the overlap matrix normalizes the sizes
% of each set of objects to the intersection of assigned space
compTrueSizes = full(sum(overlap(2:end,:),2));
compEstSizes = full(sum(overlap(2:end,2:end),1));

% prune out the zero component (now 1, after shift) in the labeling (un-assigned "out" space)
% we will account for this un-assigned "out" space (bg pixels) by not counting them as positive example pairs
zeroEst = overlap(2:end,1);
overlap = overlap(2:end,2:end);
[idTrue,idEst,overlapSz] = find(overlap);

% convert overlapSz to overlap fraction
% fraction depends on whether or not we are normalizing all object sizes to have the same size
nCompTrue = sum(compTrueSizes>0);
nPixTotal = sum(compTrueSizes);
if normalize,
	% fractional volume of each pixel (if we are normalizing, this is different for each true object)
	pixSz = (1./compTrueSizes) / nCompTrue;
	fracTrue = repmat(1/nCompTrue,size(compTrueSizes));
	% zero out objects with zero pixels
	pixSz(compTrueSizes==0) = 0;
	fracTrue(compTrueSizes==0) = 0;
else,
	pixSz = repmat(1/nPixTotal,size(compTrueSizes));
	fracTrue = compTrueSizes/nPixTotal;
end
overlapFrac = overlapSz .* pixSz(idTrue);
overlap = sparse(idTrue,idEst,overlapFrac);

% fraction of groundtruth positive and negative volume squared
% pos + neg would equal 0.5 if pixel sizes were infinitely small
% but in practice, it will be less than 0.5 by half the sum of the volume of individual pixels squared
pos = (sum(fracTrue.^2) - sum(pixSz.^2 .* compTrueSizes)) / 2;
neg = (sum(fracTrue).^2 - sum(fracTrue.^2)) / 2;
total = pos + neg;

% fraction of true and false positive volume squared
truePos = sum(overlapFrac .* (overlapFrac - pixSz(idTrue)) / 2);
falsePos = full(sum(sum(overlap,1).^2) - sum(sum(overlap.^2,1)))/2;

% fraction of true and false negative volume squared
falseNeg = sum((compTrueSizes-zeroEst) .* zeroEst .* pixSz.^2) ...
			+ (sum((zeroEst.*pixSz).^2) - sum(pixSz.^2 .* zeroEst))/2 ...
			+ full(sum(sum(overlap,2).^2) - sum(sum(overlap.^2,2)))/2;
trueNeg = (pos+neg) - (truePos+falsePos+falseNeg);

% estimated pos and neg volumes squared
posEst = truePos + falsePos;
negEst = (pos + neg) - posEst;


% derived statistics
stats.clusteringError = (falsePos + falseNeg)/total;
ri = 1-stats.clusteringError;

stats.total = total;
stats.truePosRate = truePos / pos;
stats.falsePosRate = falsePos / neg;
stats.prec = truePos / posEst;
stats.rec = stats.truePosRate;
stats.mergeRate = falsePos / pos;
stats.splitRate = falseNeg / negEst;

stats.truePos = truePos;
stats.falsePos = falsePos;
stats.trueNeg = trueNeg;
stats.falseNeg = falseNeg;

stats.pos = pos;
stats.neg = neg;
stats.posEst = posEst;
stats.negEst = negEst;

return
