function [labels,idx1,idx2,idx3] = takeAway(labels,patchSz,nTimes)
% reduces the size of the labeling to compensate for reduction in size from a 'valid' conv
% labels: the variable to be reduced
% patchSz: size of conv kernel
% nTimes: # of times a kernel is applied

sz = size(labels);
idx1=1:sz(1); idx2=1:sz(2); idx3=1:sz(3);

n2 = floor(patchSz/2);
for k=1:nTimes,
	idx1=idx1(n2(1)+1:end-n2(1));
	idx2=idx2(n2(2)+1:end-n2(2));
	idx3=idx3(n2(3)+1:end-n2(3));
end
labels = labels(idx1,idx2,idx3,:);
