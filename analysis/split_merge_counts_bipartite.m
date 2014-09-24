function [splits,mergers,missing,stats] = split_merge_count(compTrue,compEst,voxelThreshold,fractionThreshold,stop)

% condition input (also, shift to make positive)
compTrue = double(compTrue)+1;
compEst = double(compEst)+1;

% compute component sizes and figure out the nonzeros
compTrueSizes = sparse(1,compTrue(:),1);
compEstSizes = sparse(1,compEst(:),1);
labelsTrue = find(compTrueSizes>0)-1;
labelsEst = find(compEstSizes>0)-1;

% compute the overlap or confusion matrix
% this computes the fraction of each true component
% overlapped by an estimated component
overlap = sparse(compTrue(:),length(compTrueSizes)+compEst(:),1,length(compTrueSizes)+length(compEstSizes),length(compTrueSizes)+length(compEstSizes));%./compTrueSizes(compTrue(:)));

% squeeze out non-existant components
overlap = overlap([labelsTrue+1,length(compTrueSizes)+labelsEst+1],[labelsTrue+1,length(compTrueSizes)+labelsEst+1]);
compTrueSizes = full(compTrueSizes(labelsTrue+1));
compEstSizes = full(compEstSizes(labelsEst+1));

% get rid of out space (zero component)
overlap(1,:) = [];
overlap(:,length(compTrueSizes)+1) = [];
compTrueSizes(labelsTrue==0) = [];
compEstSizes(labelsEst==0) = [];
labelsTrue(labelsTrue==0) = [];
labelsEst(labelsEst==0) = [];
numCompTrue = length(labelsTrue);
numCompEst = length(labelsEst);


%% prune overlap matrix to remove small overlaps
% overlaps of size less than voxelThreshold 
% contributing to less than fractionThreshold
% fraction of the true component are zero'd
overlapClean = overlap;
for icmp = 1:numCompTrue,
	[sortedOverlaps,idx] = sort(full(overlap(icmp,:)));
	idxZero = (sortedOverlaps<voxelThreshold) ...
				& ((cumsum(sortedOverlaps)/compTrueSizes(icmp))<fractionThreshold);
	numPrune = sum(sortedOverlaps(idxZero)>0);
	overlapClean(icmp,idx(idxZero)) = 0;
	if numPrune > 0,
		disp(['cmp ' num2str(labelsTrue(icmp)) ': pruning ' num2str(numPrune) ' overlaps'])
	end
end
overlap = overlapClean;
% symmetrize
overlap = max(overlap,overlap');

%% compute splits and mergers
% basic idea:
% each object should only overlap with one other object
% splits and mergers only increase the number of overlaps
% so, count up the number of overlaps in each direction
% if a true component overlaps with more than one estimated
% component, this indicates a split
numSplitsPerObject = sum(overlap(1:numCompTrue,numCompTrue+(1:numCompEst))>0,2)-1;
numMissingObjects = sum(numSplitsPerObject<0);
numSplitsPerObject = max(0,numSplitsPerObject);

% compute mergers
% find objects reachable by one hop to the estimated objects and back
% ie: what objects are merged by an estimated object?
overlap2 = overlap*overlap;
nOverlaps = sum(overlap2(1:numCompTrue,1:numCompTrue)>0,1);
numMergersPerObject = max(0,nOverlaps-1);
numMissingObjects = sum(nOverlaps==0);


% compute statistics (ignoring out spaces; comp==0)
meanSplitsPerObject = mean(numSplitsPerObject(2:end));
meanMergersPerObject = mean(numMergersPerObject(2:end));
medianSplitsPerObject = median(numSplitsPerObject(2:end));
medianMergersPerObject = median(numMergersPerObject(2:end));
maxSplitsPerObject = max(numSplitsPerObject(2:end));
maxMergersPerObject = max(numMergersPerObject(2:end));
meanMissingPerObject = numMissingObjects/numCompTrue;

% compute histogram (ignoring out spaces; comp==0)
bins = max(maxMergersPerObject,maxSplitsPerObject);
histSplitsPerObject = hist(numSplitsPerObject(2:end),0:bins);
histMergersPerObject = hist(numMergersPerObject(2:end),0:bins);


%% copy into output
stats.compTrueSizes = compTrueSizes;
stats.compEstSizes = compEstSizes;
stats.numSplitsPerObject = numSplitsPerObject;
stats.numMergersPerObject = numMergersPerObject;
stats.bins = bins;
stats.histSplitsPerObject = histSplitsPerObject;
stats.histMergersPerObject = histMergersPerObject;
stats.numMissingObjects = numMissingObjects;

splits = meanSplitsPerObject;
mergers = meanMergersPerObject;
missing = meanMissingPerObject;

% stop inside the function for analysis, if requested
if exist('stop','var') && stop,
	keyboard
end
