function idx = takeAway3(idx,patchSz,nTimes)
% reduces the size of the labeling to compensate for reduction in size from a 'valid' conv
% indices: size of the variable to be reduced
% patchSz: size of conv kernel
% nTimes: # of times a kernel is applied


n2 = floor(patchSz/2);
for j = 1:length(idx),
	for k=1:nTimes,
		idx{j} = idx{j}(n2(j)+1:end-n2(j));
	end
end
