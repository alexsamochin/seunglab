function [idx1,idx2,idx3] = takeAway2(imSz,patchSz,nTimes)
% reduces the size of the labeling to compensate for reduction in size from a 'valid' conv
% imSz: size of the variable to be reduced
% patchSz: size of conv kernel
% nTimes: # of times a kernel is applied

idx1=1:imSz(1); idx2=1:imSz(2); idx3=1:imSz(3);

n2 = floor(patchSz/2);
for k=1:nTimes,
	idx1=idx1(n2(1)+1:end-n2(1));
	idx2=idx2(n2(2)+1:end-n2(2));
	idx3=idx3(n2(3)+1:end-n2(3));
end
