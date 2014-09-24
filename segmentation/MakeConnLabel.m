function conn = MakeConnLabel(cmp,nhood2,nhood1)
% Makes connectivity rep for arbitrary nhoods

if ~exist('nhood2','var') || isempty(nhood2),
	nhood2 = -eye(ndims(cmp));
	nhood1 = zeros(size(nhood2));
end

if ~exist('nhood1','var') || isempty(nhood1),
	nhood1 = zeros(size(nhood2));
end

sz = size2(cmp,1:size(nhood1,2));
conn = false([sz size(nhood1,1)]);

for k = 1:size(nhood1,1),
	for j = 1:size(nhood1,2),
		sub{j} = 1:sz(j);
		sub1{j} = (1:sz(j))+nhood1(k,j); sub2{j} = (1:sz(j))+nhood2(k,j);
		subKeep = (sub1{j}>=1 & sub1{j}<=sz(j)) ...
				& (sub2{j}>=1 & sub2{j}<=sz(j));
		sub{j} = sub{j}(subKeep);
		sub1{j} = sub1{j}(subKeep); sub2{j} = sub2{j}(subKeep);
	end

	conn(sub{:},k) = (cmp(sub1{:})==cmp(sub2{:})) ...
					& (cmp(sub1{:})~=0) & (cmp(sub2{:})~=0);
end
