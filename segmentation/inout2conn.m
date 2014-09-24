function conn = inout2conn(inout,nhood2,nhood1)
% Makes connectivity rep for arbitrary nhoods

if ~exist('nhood1','var') || isempty(nhood1),
	nhood1 = zeros(size(nhood2));
end

sz = size2(inout,1:size(nhood1,2));
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

	conn(sub{:},k) = min(inout(sub1{:}),inout(sub2{:}));
end

% function conn = inout2conn(inout,nhood)
% % Makes connectivity rep for arbitrary nhoods
% 
% [imx,jmx,kmx] = size(inout);
% conn = zeros([imx jmx kmx size(nhood,1)]);
% 
% for k = 1:size(nhood,1),
% 	idxi = max(1-nhood(k,1),1):min(imx-nhood(k,1),imx);
% 	idxj = max(1-nhood(k,2),1):min(jmx-nhood(k,2),jmx);
% 	idxk = max(1-nhood(k,3),1):min(kmx-nhood(k,3),kmx);
% 	conn(idxi,idxj,idxk,k) = ...
% 		min(inout(idxi,idxj,idxk), ...
% 		 inout(idxi+nhood(k,1),idxj+nhood(k,2),idxk+nhood(k,3)));
% end
