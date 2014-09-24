function cmp = pottsRelax(J,nhood,cmp,maxIter,freeMask)
%%  potts relaxation

% parameters
beta = 5e-2;		% strength of 0-0 interactions

% init
sz = size(cmp);
freeIdx = find(freeMask);
freezeIdx = find(~freeMask);

% iterate
for iter = 1:maxIter,
	if ~rem(iter,500),[iter length(freeIdx)],end

	% pick a voxels to update
	if isempty(freeIdx), return, end
	vox = randsample(freeIdx,1);
	[i j k] = ind2sub(sz,vox);

	nn = repmat([i j k],2*size(nhood,1),1)+[nhood;-nhood];
	% check boundaries
	nngood = find(~((nn(:,1)<1 | nn(:,1)>sz(1)) ...
				| (nn(:,2)<1 | nn(:,2)>sz(2)) ...
				| (nn(:,3)<1 | nn(:,3)>sz(3))));
	nn = nn(nngood,:); nn = sub2ind(sz,nn(:,1),nn(:,2),nn(:,3));
	JJ = squeeze(J(i,j,k,nngood(nngood<=size(nhood,1))));
	for nnIdx = (nngood(nngood>size(nhood,1))-size(nhood,1))',
		JJ(end+1) = J(i-nhood(nnIdx,1),j-nhood(nnIdx,2),k-nhood(nnIdx,3),nnIdx);
	end
	JJ = JJ(:);

	cmpnn = setdiff(unique(cmp(nn)),0);
	if length(cmpnn) > 0,
		% compute energies
		E = zeros(1,length(cmpnn));
		for cmpIdx = 1:length(cmpnn),
			E(cmpIdx) = -sum(JJ.*(cmp(nn)==cmpnn(cmpIdx)));
		end
		[EMin,minIdx] = min(E);
		if EMin > 0, % best configuration is to be disconnected
			cmpMin = 0;	% set to out pixel
		else,
			cmpMin = cmpnn(minIdx);
		end
	else,
		cmpMin = cmp(i,j,k);
	end

	% update
	if cmp(i,j,k) == cmpMin,
		freeIdx = setdiff(freeIdx,vox);
	else,
		freeIdx = [freeIdx;setdiff(nn,freezeIdx)];
	end
	cmp(i,j,k) = cmpMin;


end
